function data = mc_preproc_faceshouses(subj)

if ~isstruct(subj)
  subj = mc_subjinfo(subj);
end

cfg                     = [];
if isfield(subj, 'event_faces_houses')
  cfg.event               = subj.event_faces_houses;
  cfg.trialdef.eventvalue = (1:24);
  cfg.trialdef.eventtype  = 'di15';
else
  cfg.event               = subj.event;
  cfg.trialdef.eventtype  = {'house' 'face_male' 'face_female'};
end
cfg.trialdef.prestim    = 0.2;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun            = 'ft_trialfun_general';
cfg.dataset             = subj.dataset{2};
cfg                     = ft_definetrial(cfg);
trl                     = cfg.trl;

cfg            = [];
cfg.dataset    = subj.dataset;
cfg.trl        = trl;
cfg.hpfilter   = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 1;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 30;
cfg.channel    = {'all' '-di15'};
cfg.usefftfilt = 'yes';
cfg.demean     = 'yes';
cfg.baselinewindow = [-inf 0];
data           = ft_preprocessing(cfg);

cfg = [];
cfg.demean     = 'yes';
cfg.baselinewindow = [-inf 0];
data           = ft_preprocessing(cfg, data);


% cfg = [];
% cfg.method = 'summary';
% data = ft_rejectvisual(cfg, data);

save(fullfile(subj.procdir, sprintf('%s_preproc_faceshouses_hp1', subj.subjname)), 'data');
