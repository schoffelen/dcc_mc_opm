function subj = mc_subjinfo(sub, rawdir, usebids)

if ~ischar(sub)
  sub = sprintf('sub-%03d', sub);
end

if nargin<3 || isempty(usebids)
  usebids = true;
end

if nargin<2 || isempty(rawdir) 
  rawdir = '/project/3031008.01/raw';
end
procdir = fullfile(strrep(rawdir, 'raw', getenv('USER')), 'processed');

if startsWith(sub, 'pil')
  ispilot = true;
else
  ispilot = false;
end

if usebids
  % the raw data is located in the bids-folder
  rawdir = strrep(rawdir, 'raw', 'bids');

  if ispilot
    subjname = sprintf('sub-pilot%s', sub(end-1:end));
  else
    subjname = sub;
  end
  basedir = fullfile(rawdir, subjname);
  videodir = fullfile(rawdir, 'sourcedata', subjname, 'video');
else

  if ispilot
    subjname = sprintf('sub-pilot%s', sub(end-1:end));

    % these are the pilot datasets, assume that the dataset specific folder starts with Pilot0x
    cd(rawdir);
    dirstr = sprintf('Pilot%s*', sub(6:7));
    d = dir(dirstr);
    basedir = fullfile(rawdir, d(1).name);
    videodir = basedir;
  else
    subjname = sub;
    cd(rawdir);
    cd(subjname);

    % so far this has worked
    basedir = fullfile(pwd, 'ses-opm001');
    videodir = fullfile(pwd, 'ses-001');
  end
  
end
procdir = fullfile(procdir, subjname);

d      = dir(fullfile(videodir, '**'));
selmp4 = contains({d.name}', 'mp4');
dmp4   = d(selmp4);
fprintf('found %d mp4-files for this subject, keeping the first one:\n', numel(d));
for k = 1%:numel(dmp4)
  fprintf('%s\n', dmp4(k).name);
end
videofile = fullfile(dmp4(1).folder, dmp4(1).name);

% NOTE: there are a lot of inconsistencies in the naming of the files and
% in the content of the directories (e.g. with and without emptyroom
% measurements). This could be addressed in the production stage. Don't
% spend time on this now. For the first 6 pilots it seems that the
% heuristic to select the first dataset from the list works fine enough.

d   = dir(fullfile(basedir, '**'));
sel = contains({d.name}', 'fif');
d   = d(sel);

if (~isequal(subjname, 'sub-003') && ~isequal(subjname, 'sub-006')) || numel(d)==1
  fprintf('found %d fif-files for this subject, keeping the first one:\n', numel(d));
  keepfif = 1;
elseif isequal(subjname, 'sub-003') || isequal(subjname, 'sub-006')
  % exception, the first fif-file in this rawdir should be skipped
  keepfif = 2;
end
for k = keepfif
  fprintf('%s\n', d(k).name);
  dataset   = fullfile(d(k).folder, d(k).name);
end

subj.rawdir   = rawdir;
subj.basedir  = basedir;
subj.ispilot  = ispilot;
subj.procdir  = procdir;
subj.subjname = subjname;
subj.dataset  = dataset;
subj.videofile = videofile;


cfg          = [];
cfg.dataset  = subj.dataset;
cfg.trialfun = 'ft_trialfun_show';
cfg          = ft_definetrial(cfg);

subj.event   = cfg.event(:);

% exception, I don't know why, but sub-005 has an offset of 2^16 on all
% trigger values
if isequal(subj.subjname, 'sub-005') && subj.event(1).value>2^16
  for k = 1:numel(subj.event)
    subj.event(k).value = subj.event(k).value-2^16;
  end
end



%%
% this section interprets the triggers, required for non-bids only

if ~usebids
  % create a matrix that can be used to determine the faces-houses versus
  % oddball sections. Currently, both tasks are recorded in the same
  % datafile, and (although I thought that I made the trigger values
  % sufficiently distinct) there is overlap in trigger values (with different
  % meanings):
  %
  % for the faces houses: values 1-24 reflect the faces/houses individual stimuli
  % for the oddball: the values 1-2 reflect the standard/deviant, and 4/8/16 reflect luminance changes in the movie

  event    = subj.event;
  eventmat = [[event.value]' [event.sample]' diff([event(1).sample;[event.sample]'])];
  %subj.eventmat = eventmat;

  sel = find(ismember(eventmat(:,1), [1 2]));

  % heuristic: the 1/2's during the oddball typically follow one another, so
  % the gaps between the indices are ~1, a 1/2 face/house trigger is never
  % followed by another image trigger
  %
  % also, there's most likely a long temporal gap between triggers when the
  % oddball starts (or the faces/houses) -> for now it is assumed that the
  % faces/houses are first

  if numel(sel)>20
    [m, start_oddball_idx] = max(eventmat(:,3));

    subj.event_oddball      = event(start_oddball_idx:end);
    subj.event_faces_houses = event(1:(start_oddball_idx-1));
  else
    % the first set of pilot subjects only did faces/houses
    subj.event_faces_houses = event;
  end

  % get a richer specification of the events
  ev = subj.event_faces_houses;
  for k = 1:numel(ev)
    if ev(k).value > 2^16
      ev(k).value = ev(k).value-2.^16;
    end
    switch ev(k).value
      case {1 2 3 4 5 6}
        ev(k).type = 'face_female';
      case {7 8 9 10 11 12 13 14 15 16 17 18}
        ev(k).type = 'house';
      case {19 20 21 22 23 24}
        ev(k).type = 'face_male';
      case 25
        ev(k).type = 'square';
      case 50
        ev(k).type = 'music_on';
      case 51
        ev(k).type = 'music_off';
      case {101 102 103 104 105 106}
        ev(k).type = 'attentiongetter_on';
      case {107 108 109 110 111 112}
        ev(k).type = 'attentiongetter_off';
      case 254
        ev(k).type = 'black';
      case 255
        ev(k).type = 'white';
    end
  end
  subj.event_faces_houses_new = ev;

  if isfield(subj, 'event_oddball')
    ev = subj.event_oddball;
    for k = 1:numel(ev)
      if ev(k).value > 2^16
        ev(k).value = ev(k).value-2.^16;
      end
      switch ev(k).value
        case 1
          ev(k).type = 'standard';
        case 2
          ev(k).type = 'deviant';
        case 4
          ev(k).type = 'luminance_low';
        case 8
          ev(k).type = 'luminance_medium';
        case 16
          ev(k).type = 'luminance_high';
        case 25
          ev(k).type = 'square';
        case 50
          ev(k).type = 'music_on';
        case 51
          ev(k).type = 'music_off';
        case {101 102 103 104 105 106}
          ev(k).type = 'attentiongetter_on';
        case {107 108 109 110 111 112}
          ev(k).type = 'attentiongetter_off';
        case 254
          ev(k).type = 'black';
        case 255
          ev(k).type = 'white';
      end
    end
    subj.event_oddball_new = ev;

    ev = cat(1, subj.event_faces_houses_new, ev);
    [srt, idx] = sort([ev.sample]);
    subj.event_new = ev(idx);
  else
    subj.event_new = subj.event_faces_houses_new;
  end

  subj.event_orig = subj.event;
  subj.event      = subj.event_new;
  subj = rmfield(subj, 'event_new');
end
