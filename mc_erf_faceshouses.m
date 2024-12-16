function [tlck, tlck_faces, tlck_houses] = mc_erf_faceshouses(sub)

subj = mc_subjinfo(sub);

cfg                     = [];
cfg.event               = subj.event_faces_houses;
cfg.trialdef.eventvalue = (1:24);
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = 0.1;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun            = 'ft_trialfun_general';
cfg.dataset             = subj.dataset;
cfg                     = ft_definetrial(cfg);
trl                     = cfg.trl;

cfg            = [];
cfg.dataset    = subj.dataset;
cfg.trl        = trl;
cfg.hpfilter   = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 2;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 5;
cfg.channel    = {'all' '-di15'};
data           = ft_preprocessing(cfg);

cfg = [];
cfg.method = 'summary';
data = ft_rejectvisual(cfg, data);

cfg = [];
cfg.preproc.demean = 'yes';
cfg.preproc.baselinewindow = [-0.1 0];
tlck = ft_timelockanalysis(cfg, data);

% faces
cfg.keeptrials = 'no';
cfg.trials = ismember(data.trialinfo, [1:6 19:24]);
tlck_faces = ft_timelockanalysis(cfg, data);

% houses
cfg.trials = ismember(data.trialinfo, (7:18));
tlck_houses = ft_timelockanalysis(cfg, data);

save(fullfile(subj.procdir, sprintf('%s_erf_faceshouses', subj.subjname)), 'tlck', 'tlck_houses', 'tlck_faces');
