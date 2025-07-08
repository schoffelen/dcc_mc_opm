function data = mc_preproc_oddball(subj)

if ~isstruct(subj)
  subj = mc_subjinfo(subj);
end

cfg                     = [];
cfg.event               = subj.event;
cfg.trialdef.eventtype  = {'standard', 'deviant'};
cfg.trialdef.prestim    = 0.2;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun            = 'ft_trialfun_general';
cfg.dataset             = subj.dataset{1};
cfg                     = ft_definetrial(cfg);
trl                     = cfg.trl;

cfg            = [];
cfg.dataset    = subj.dataset;
cfg.trl        = trl;
cfg.hpfilter   = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 0.1;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 30;
cfg.usefftfilt = 'yes';
cfg.channel    = {'all' '-di15'};
data           = ft_preprocessing(cfg);

cfg = [];
cfg.demean = 'yes';
cfg.baselinewindow = [-inf 0];
data = ft_preprocessing(cfg, data);

% cfg = [];
% cfg.method = 'summary';
% data = ft_rejectvisual(cfg, data);

save(fullfile(subj.procdir, sprintf('%s_preproc_oddball', subj.subjname)), 'data');
