% this script is based on https://www.fieldtriptoolbox.org/example/video_eeg/

% rootdir = '/Volumes/SamsungT7/data/babyOPMs';
rootdir = '\\ru.nl\wrkgrp\STD-Donders-DCC-Hunnius-BabyOPMs\';

filename.pilot1 = fullfile(rootdir, ['Data' filesep 'Raw data' filesep 'Neural' filesep 'Pilot' filesep 'Pilot01_20240829' filesep '20240829_154459_sub-pilot01_file-pilot01_raw.fif']);
filename.pilot2 = fullfile(rootdir, ['Data' filesep 'Raw data' filesep 'Neural' filesep 'Pilot' filesep 'Pilot02_20240904' filesep 'Pilot02' filesep 'sub-pilot02' filesep '20240904_091352_sub-pilot02_file-pilot02_raw.fif']);
filename.pilot3 = fullfile(rootdir, ['Data' filesep 'Raw data' filesep 'Neural' filesep 'Pilot' filesep 'Pilot03_20240911' filesep 'Pilot03' filesep '20240911_100359_sub-pilot03_file-03_raw.fif']);

subjid = 'pilot2';

%%

% read the continuous data in memory, this results in one long segment (trial)
cfg = [];
cfg.dataset = filename.(subjid);
cfg.lpfilter = 'yes';
cfg.lpfreq = 30;
cfg.hpfilter = 'yes';
cfg.hpfiltord = 2;
cfg.hpfreq = 2;
data_continuous = ft_preprocessing(cfg);

% we also want to plot the events (if present)
event = ft_read_event(filename.(subjid));

% replace the numeric codes by more meaningful strings
event = update_event(event);

%%

cfg = [];
cfg.event = event;
cfg.continuous = 'yes';
cfg.blocksize = 30;
cfg.channel = 's*';
ft_databrowser(cfg, data_continuous);

%%

cfg = [];
cfg.dataset = filename.(subjid);
cfg.event = event; % use the events with the updated values
cfg.trialdef.prestim = 0.3;
cfg.trialdef.poststim = 0.7;
cfg.trialdef.eventtype = 'di15';
cfg.trialdef.eventvalue = {'male', 'female', 'house'};
cfg = ft_definetrial(cfg);
data_segmented = ft_redefinetrial(cfg, data_continuous);

cfg = [];
cfg.channel = 's*';
cfg.demean = 'yes';
cfg.baselinewindow = [-inf 0];
data_segmented = ft_preprocessing(cfg, data_segmented);

load helmet-v3/grad.mat
grad.chanunit = repmat({'T'}, size(grad.label));

data_segmented.grad = grad;
data_segmented = rmfield(data_segmented, 'hdr');

%%

cfg = [];
cfg.continuous = 'yes';
cfg.blocksize = 30;
ft_databrowser(cfg, data_segmented);

%%

cfg = [];
cfg.method = 'summary';
cfg.metric = 'std';
data_reject = ft_rejectvisual(cfg, data_segmented);


%%

% cfg = [];
% cfg.threshold = 2e-11;
% cfg.metric = 'std';
% cfg = ft_badsegment(cfg, data_segmented);
% data_reject = ft_rejectartifact(cfg, data_segmented);

%%

% cfg = [];
% cfg.order = 1;
% cfg.updatesens = 'yes';
% data_hfc = ft_denoise_hfc(cfg, data_reject);

%%

cfg = [];
cfg.continuous = 'yes';
cfg.blocksize = 30;
ft_databrowser(cfg, data_reject);


%%

cfg = [];
cfg.trials = ismember(data_reject.trialinfo.eventvalue, {'female', 'male'});
timelock_faces = ft_timelockanalysis(cfg, data_reject);
cfg.trials = ismember(data_reject.trialinfo.eventvalue, {'house'});
timelock_houses = ft_timelockanalysis(cfg, data_reject);

%%

load helmet-v3/layout.mat

cfg = [];
cfg.layout = layout;
cfg.showlabels = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, timelock_faces, timelock_houses)