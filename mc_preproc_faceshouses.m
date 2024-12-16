function mc_preproc_faceshouses(sub)

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
cfg.dataset    = d.name;
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

keyboard