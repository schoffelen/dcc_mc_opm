function [tlck, tlck_faces, tlck_houses] = mc_erf_faceshouses(sub)

subj = mc_subjinfo(sub);


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
