function [freq] = mc_assr_faceshouses(sub)

subj  = mc_subjinfo(sub);
event = subj.event_faces_houses;

% settings for ASSR, this benefits from another trl-matrix
sel50 = find([event.value]'==50);
sel51 = find([event.value]'==51);

if sel50(1)>sel51(1)
  sel50 = [find([event.value]'==25,1,'first');sel50];
end
if numel(sel51)<numel(sel50)
  sel51 = [sel51;find([event.value]'==25,1,'last')];
end
trl_assr = [[event(sel50).sample]' [event(sel51).sample]'];
trl_assr(:,3) = 0;

cfg          = [];
cfg.dataset  = subj.dataset;
cfg.trl      = trl_assr;
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 0.5;
cfg.padding    = 10;
cfg.channel    = {'all' '-di15'};
cfg.dftfilter  = 'yes';
data_assr = ft_preprocessing(cfg);

cfg = [];
cfg.length = 1;
cfg.overlap = 0.5;
data_assr = ft_redefinetrial(cfg, data_assr);

cfg = [];
cfg.method = 'summary';
data_assr = ft_rejectvisual(cfg, data_assr);

% spectral transformation
cfg        = [];
cfg.method = 'mtmfft';
cfg.foilim = [0 80];
cfg.taper  = 'hanning';
cfg.pad    = 5;
cfg.output = 'fourier';
freq       = ft_freqanalysis(cfg, data_assr);

freq = ft_freqdescriptives([], freq);
freq.powspctrm = log10(freq.powspctrm);
freq.powspctrm(~isfinite(freq.powspctrm)) = 0;

save(fullfile(subj.procdir, sprintf('%s_assr_faceshouses', subj.subjname)), 'freq');
