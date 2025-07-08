function subj = mc_subjinfo(sub, rawdir, usebids)

pwdir = pwd;

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

    % these are the 6pilot datasets, assume that the dataset specific folder starts with Pilot0x
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
    if isequal(subjname, 'sub-013')
      basedir = strrep(basedir, 'opm001', 'opm02');
    elseif isequal(subjname, 'sub-021')
      basedir = strrep(basedir, 'opm001', 'opm021');
    elseif isequal(subjname, 'sub-022')
      basedir = strrep(basedir, 'opm001', 'opm022');
    end
    videodir = fullfile(pwd, 'ses-001');

    % check whether an emptyroom folder exists
    if exist(fullfile(pwd, 'ses-opmemptyroom'), 'dir')
      emptyroomexists = true;
    else
      emptyroomexists = false;
    end
  end
  
  if emptyroomexists
    d = dir(fullfile(pwd, 'ses-opmemptyroom', '*.fif'))
    for k = 1:numel(d)
      dataset_er{k} = fullfile(d(k).folder, d(k).name);
    end
  else
    dataset_er = [];
  end
end
procdir = fullfile(procdir, subjname);

d      = dir(fullfile(videodir, '**'));
selmp4 = contains({d.name}', 'mp4');
selannot = contains({d.name}', 'txt') & startsWith({d.name}', 'sub');
dmp4   = d(selmp4);
dannot = d(selannot);
if isempty(dannot)
  % fall back option
  dannot = dir(fullfile(strrep(rawdir, 'raw', 'jansch'), 'Output', sprintf('%s-videocoding.txt', subjname)));
end

if numel(dmp4)==1
  videofile = fullfile(dmp4(1).folder, dmp4(1).name);
elseif numel(dmp4)==0
  warning('no videofile detected in raw folder');
  videofile = '';
else
  error('more than one videofile detected, don''t know what to do');
end

if numel(dannot)==1
  annotfile = fullfile(dannot.folder, dannot.name);
elseif numel(dannot)==0
  annotfile = '';
else
  error('more than one annotation file found')
end

% NOTE: there are a lot of inconsistencies in the naming of the files and
% in the content of the directories (e.g. with and without emptyroom
% measurements). This could be addressed in the production stage. Don't
% spend time on this now. For the first 6 pilots it seems that the
% heuristic to select the first dataset from the list works fine enough.

d   = dir(fullfile(basedir, '**'));
sel = contains({d.name}', 'fif');
d   = d(sel);

if isscalar(d)
  dataset = fullfile(d(1).folder, d(1).name);
else
  dataset = cell(numel(d),1);
  for k = 1:numel(d)
    dataset{k} = fullfile(d(k).folder, d(k).name);
  end
end

if isequal(subjname, 'sub-006')
  % here the first recording was 'stopped', and the experiment was restarted
  dataset = dataset(2);
end

subj.rawdir   = rawdir;
subj.basedir  = basedir;
subj.ispilot  = ispilot;
subj.procdir  = procdir;
subj.subjname = subjname;
subj.dataset  = dataset;
subj.videofile = videofile;
subj.annotfile = annotfile;

if exist('dataset_er', 'var')
  subj.dataset_er = dataset_er;
end

if ~iscell(subj.dataset)
  subj.dataset = {subj.dataset};
end

for k = 1:numel(subj.dataset)
  cfg          = [];
  cfg.dataset  = subj.dataset{k};
  cfg.trialfun = 'ft_trialfun_show';
  cfg          = ft_definetrial(cfg);

  subj.event{k} = cfg.event(:);
end
if isscalar(subj.dataset)
  subj.event = subj.event{1};
end

% exception, I don't know why, but sub-005 has an offset of 2^16 on all
% trigger values
if isequal(subj.subjname, 'sub-005') && subj.event(1).value>2^16
  for k = 1:numel(subj.event)
    subj.event(k).value = subj.event(k).value-2^16;
  end
end

if ~isempty(subj.annotfile)
  tmpsubj = subj;
  tmpsubj.event = tmpsubj.event{contains(tmpsubj.dataset, 'faces')};
  [subj.videoevent, subj.videoevent_artctdef] = mc_videoevents(tmpsubj);
else
  subj.videoevent = [];
  subj.videoevent_artfctdef = [];
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

  if isequal(subj.subjname, 'sub-003')
    subj.event = subj.event{2}; % this is overruling the fact that this particular subject has 2 data files with task data, but that the first file does not contain events
  end

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
        ev(k).type = 'white';
      case 255
        ev(k).type = 'black';
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
          ev(k).type = 'white';
        case 255
          ev(k).type = 'black';
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

cd(pwdir);
