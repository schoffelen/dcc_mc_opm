function [videoevents, artfctdef] = mc_videoevents(subj)

% MC_VIDEOEVENTS converts a file with manually annotated events into a 
% fieldtrip compatible structure of events, where the timestamps of the events
% are aligned to the measured data. this assumes that the annotation file
% contains annotations of type '1. Stimulus' and value 1. These are aligned
% with the 'white' flashes (= trigger 254) during the data recording.

if ~isstruct(subj)
  subj = mc_subjinfo(subj);
end

t = readtable(subj.annotfile);

selevents = strcmp(table2array(t(:,1)), '1. Stimulus') & table2array(t(:,end))==1;

% currently, the subj.dataset and subj.events may be cell-arrays
if iscell(subj.event) && iscell(subj.dataset)
  % check which of the datasets is the task dataset (the other is the emptyroom)
  sel = find(contains(subj.dataset, 'faceshousesoddball'));
  if numel(sel)==2
    % most likely we will need the second one
    sel = sel(2);
  end
  subj.event = subj.event{sel};
end

selevents2 = strcmp({subj.event.type}', 'white');
if sum(selevents2)==0
  % fall back to triggers of value 254, this may happen if we end up here
  % using an event table that has not (yet) been BIDS-converted
  selevents2 = [subj.event.value]'==254;
end

twhite = t(selevents, :);
ewhite = subj.event(selevents2);

if numel(ewhite)==4 && size(twhite,1)==4
  % ok
elseif isequal(subj.subjname, 'sub-006')
  % the first 2 white flashes are missing, unfortunately
  twhite = twhite(3:end,:);
elseif isequal(subj.subjname, 'sub-003')
  twhite = twhite([1 3 4 5],:);
elseif isequal(subj.subjname, 'sub-002')
  twhite = twhite(2:3,:);
  ewhite = ewhite(3:4);
else
  % something wrong
  error('there''s something wrong with the number of ''white'' events');
end


tstamp1 = table2array(twhite(:, end-3));
tstamp2 = [ewhite.sample]';

if isfield(ewhite,'timestamp')
  tstamp3 = [ewhite.timestamp]';
else
  tstamp3 = ([ewhite.sample]'-1)./5000;
end
X = [tstamp1 ones(numel(ewhite),1)];
b = X\tstamp2;

bt = X\tstamp3;

% modeled annotated timestamps expressed relative to samples in recording
tstamp1hat = X*b;

tstamp = table2array(t(:, end-3));
tstamp2hat = [tstamp ones(numel(tstamp),1)]*b;

tstamp2hatt = [tstamp ones(numel(tstamp),1)]*bt;

type   = t.Var1;
value  = table2array(t(:,end));
sample = tstamp2hat;
duration = table2array(t(:,end-1)).*b(1);
timestamp = tstamp2hatt;
for k = 1:numel(type)
  tmp = lower(type{k});
  if contains(tmp, '. ')
    % assume that it starts with something like '#. '
    tmp = tmp(4:end);
    tmp = strrep(tmp, ' ', '_'); % so that an artifact can be named as a valid fieldname
  end
  videoevents(k,1).type   = tmp;
  videoevents(k).value    = value(k);
  videoevents(k).sample   = sample(k);
  videoevents(k).duration = duration(k);
  videoevents(k).offset   = 0;
  videoevents(k).timestamp = timestamp(k);
end

[ftver, ftpath] = ft_version;
curr_wd = pwd;
cd(fullfile(ftpath, 'private'));

% do some stuff
a = event2artifact(videoevents);
types = unique(a.type);
for k = 1:numel(types)
  sel = strcmp(a.type, types{k});
  artfctdef.(types{k}).artifact = round([a.begsample(sel) a.endsample(sel)]);
end

% go back
cd(curr_wd);
