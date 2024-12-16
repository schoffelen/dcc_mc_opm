function subj = mc_subjinfo(sub, rawdir)

if nargin<2
  rawdir = '/Users/jansch/projects/opm_baby/raw';
end
procdir = strrep(rawdir, 'raw', 'processed');

cd(rawdir);
if startsWith(sub, 'pil')
  % these are the pilot datasets, assume that the dataset specific folder
  % starts with Pilot0x
  dirstr = sprintf('Pilot%s*', sub(6:7));
  d = dir(dirstr);
  basedir = fullfile(rawdir, d(1).name);
end

subj.rawdir  = rawdir;
subj.procdir = procdir;
subj.basedir = basedir;

d   = dir(fullfile(subj.basedir, '**'));
sel = contains({d.name}', 'fif');
d   = d(sel);

fprintf('found %d fif-files for this subject:\n', numel(d));
for k = 1:numel(d)
  fprintf('%s\n', d(k).name);
end

tok = tokenize(d(1).name, '_');

subj.subjname = tok{3};
subj.dataset  = fullfile(d(1).folder, d(1).name);

% NOTE: there are a lot of inconsistencies in the naming of the files and
% in the content of the directories (e.g. with and without emptyroom
% measurements). This could be addressed in the production stage. Don't
% spend time on this now. For the first 6 pilots it seems that the
% heuristic to select the first dataset from the list works fine enough.

cfg = [];
cfg.dataset  = subj.dataset;
cfg.trialfun = 'ft_trialfun_show';
cfg = ft_definetrial(cfg);

subj.event = cfg.event;

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
