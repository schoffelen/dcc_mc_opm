% try out sandbox
restoredefaultpath
addpath('/project/3031008.01/code/dcc_mc_opm');
addpath('/project/3031008.01/code/fieldtrip');
ft_defaults

subj = mc_subjinfo('sub-001')

% try out sub-014
cfg = [];
cfg.method = 'summary';
bob = ft_rejectvisual(cfg,data)

cfg = [];
cfg.event = subj.videoevent; 
ft_databrowser(cfg,data)