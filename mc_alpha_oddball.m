function [tlck, tlck_standard, tlck_deviant] = mc_alpha_oddball(sub)

subj = mc_subjinfo(sub);

cfg                     = [];
cfg.event               = subj.event_oddball;
cfg.trialdef.eventvalue = [4 8 16];
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = -1;
cfg.trialdef.poststim   = 9-1./5000;
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
cfg.padding    = 10;
cfg.channel    = {'all' '-di15'};
data           = ft_preprocessing(cfg);

cfg        = [];
cfg.length = 1;
data       = ft_redefinetrial(cfg, data);

cfg = [];
cfg.method = 'summary';
data = ft_rejectvisual(cfg, data);

cfg = [];
cfg.method = 'mtmfft';
cfg.taper  = 'dpss';
cfg.tapsmofrq = 2;
cfg.output = 'pow';
cfg.pad = 2;
cfg.foilim = [0 30];
cfg.trials = data.trialinfo==4;
freq4 = ft_freqanalysis(cfg, data);
cfg.trials = data.trialinfo==8;
freq8 = ft_freqanalysis(cfg, data);
cfg.trials = data.trialinfo==16;
freq16 = ft_freqanalysis(cfg, data);

save(fullfile(subj.procdir, sprintf('%s_alpha_oddball', subj.subjname)), 'freq4', 'freq8', 'freq16');
