function [tlck, tlck_standard, tlck_deviant] = mc_erf_oddball(sub)

subj = mc_subjinfo(sub);

cfg                     = [];
cfg.event               = subj.event_oddball;
cfg.trialdef.eventvalue = [1 2];
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

% standard
cfg.keeptrials = 'no';
cfg.trials = ismember(data.trialinfo, 1);
tlck_standard = ft_timelockanalysis(cfg, data);

% deviant
cfg.trials = ismember(data.trialinfo, 2);
tlck_deviant = ft_timelockanalysis(cfg, data);

save(fullfile(subj.procdir, sprintf('%s_erf_oddball', subj.subjname)), 'tlck', 'tlck_standard', 'tlck_deviant');
