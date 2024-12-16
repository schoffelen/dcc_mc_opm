%% script to inspect the pilot data, note that the folder names are as represented on JM's Macbook when the wrkgrp folder is mounted

%datadir  = '/Volumes/wrkgrp/STD-Donders-DCC-Hunnius-BabyOPMs/Data/Raw data/Neural/Pilot';
datadir  = '/Users/jansch/projects/opm_baby/data';
datasets = {'Pilot01_20240829';'Pilot02_20240904';'Pilot03_20240911'};

%% Pilot01
cd(fullfile(datadir, datasets{1}));
d = dir('*.fif');
event = ft_read_event(d.name);

cfg = [];
cfg.event = event;
cfg.trialdef.eventvalue = (1:24);
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = 0.1;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun = 'ft_trialfun_general';
cfg.dataset  = d.name;
cfg = ft_definetrial(cfg);
trl = cfg.trl;

cfg          = [];
cfg.dataset  = d.name;
cfg.trl      = trl;
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 2;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 5;
cfg.channel    = {'all' '-di15'};
data = ft_preprocessing(cfg);

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

m1 = max(abs(tlck_faces.avg(:)));
m2 = max(abs(tlck_houses.avg(:)));
zlim = [-1 1].*max(m1,m2)./1.25;

% visualise
%load('/Volumes/wrkgrp/STD-Donders-DCC-Hunnius-BabyOPMs/Analysis/Matlab files/helmet-v3/layout');
load('/Users/jansch/projects/opm_baby/code/helmet-v3/layout');
cfg = [];
cfg.layout = layout;
cfg.channel = tlck.label(find(tlck.avg(:,1)));
cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, tlck_faces, tlck_houses);

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
cfg.dataset  = d.name;
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

fd = ft_freqdescriptives([], freq);
fd.powspctrm = log10(fd.powspctrm)+28;
fd.powspctrm(~isfinite(fd.powspctrm)) = 0;

cfg = [];
cfg.layout = layout;
cfg.channel = fd.label(find(fd.powspctrm(:,1)));
%cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, fd);

savedir = '/Users/jansch/projects/opm_baby/data/processed';
save(fullfile(savedir, 'pil-001_results'), 'tlck', 'tlck_faces', 'tlck_houses', 'data', 'data_assr', 'fd');

%% Pilot02
cd(fullfile(datadir, datasets{2}, 'Pilot02', 'sub-pilot02'));
d = dir('*.fif');
event = ft_read_event(d.name);

cfg = [];
cfg.event = event;
cfg.trialdef.eventvalue = (1:24);
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = 0.1;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun = 'ft_trialfun_general';
cfg.dataset  = d.name;
cfg = ft_definetrial(cfg);
trl = cfg.trl;

cfg          = [];
cfg.dataset  = d.name;
cfg.trl      = trl;
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 2;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 5;
cfg.channel    = {'all' '-di15'};
data = ft_preprocessing(cfg);

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

m1 = max(abs(tlck_faces.avg(:)));
m2 = max(abs(tlck_houses.avg(:)));
zlim = [-1 1].*max(m1,m2)./1.25;

% visualise
%load('/Volumes/wrkgrp/STD-Donders-DCC-Hunnius-BabyOPMs/Analysis/Matlab files/helmet-v3/layout');
load('/Users/jansch/projects/opm_baby/code/helmet-v3/layout');
cfg = [];
cfg.layout = layout;
cfg.channel = tlck.label(find(tlck.avg(:,1)));
cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, tlck_faces, tlck_houses);

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
cfg.dataset  = d.name;
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

fd = ft_freqdescriptives([], freq);
fd.powspctrm = log10(fd.powspctrm)+28;
fd.powspctrm(~isfinite(fd.powspctrm)) = 0;

cfg = [];
cfg.layout = layout;
cfg.channel = fd.label(find(fd.powspctrm(:,1)));
%cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, fd);

savedir = '/Users/jansch/projects/opm_baby/data/processed';
save(fullfile(savedir, 'pil-002_results'), 'tlck', 'tlck_faces', 'tlck_houses', 'data', 'data_assr', 'fd');

%% Pilot03
cd(fullfile(datadir, datasets{3}, 'Pilot03'));
d = dir('*.fif');
event = ft_read_event(d.name);

cfg = [];
cfg.event = event;
cfg.trialdef.eventvalue = (1:24);
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = 0.1;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun = 'ft_trialfun_general';
cfg.dataset  = d.name;
cfg = ft_definetrial(cfg);
trl = cfg.trl;
trl(trl(:,1)>1000000,:) = []; % hard coded, second part is oddball 

cfg          = [];
cfg.dataset  = d.name;
cfg.trl      = trl;
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 2;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 5;
cfg.channel    = {'all' '-di15'};
data = ft_preprocessing(cfg);

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

m1 = max(abs(tlck_faces.avg(:)));
m2 = max(abs(tlck_houses.avg(:)));
zlim = [-1 1].*max(m1,m2)./1.25;

% visualise
%load('/Volumes/wrkgrp/STD-Donders-DCC-Hunnius-BabyOPMs/Analysis/Matlab files/helmet-v3/layout');
load('/Users/jansch/projects/opm_baby/code/helmet-v3/layout');
cfg = [];
cfg.layout = layout;
cfg.channel = tlck.label(find(tlck.avg(:,1)));
cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, tlck_faces, tlck_houses);

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

trl_assr(trl_assr(:,2)>1000000,:) = [];

cfg          = [];
cfg.dataset  = d.name;
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

fd = ft_freqdescriptives([], freq);
fd.powspctrm = log10(fd.powspctrm)+28;
fd.powspctrm(~isfinite(fd.powspctrm)) = 0;

cfg = [];
cfg.layout = layout;
cfg.channel = fd.label(find(fd.powspctrm(:,1)));
%cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, fd);

savedir = '/Users/jansch/projects/opm_baby/data/processed';
save(fullfile(savedir, 'pil-003_results'), 'tlck', 'tlck_faces', 'tlck_houses', 'data', 'data_assr', 'fd');

% pilot 3 oddball
cfg = [];
cfg.event = event;
cfg.trialdef.eventvalue = [1 2];
cfg.trialdef.eventtype  = 'di15';
cfg.trialdef.prestim    = 0.1;
cfg.trialdef.poststim   = 0.6 - 1./5000;
cfg.trialfun = 'ft_trialfun_general';
cfg.dataset  = d.name;
cfg = ft_definetrial(cfg);
trl = cfg.trl;
trl(trl(:,1)<1000000,:) = []; % hard coded, only second part is oddball 

cfg          = [];
cfg.dataset  = d.name;
cfg.trl      = trl;
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfreq     = 2;
cfg.lpfilter   = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq     = 30;
cfg.padding    = 5;
cfg.channel    = {'all' '-di15'};
data = ft_preprocessing(cfg);

cfg = [];
cfg.method = 'summary';
data = ft_rejectvisual(cfg, data);

cfg = [];
cfg.preproc.demean = 'yes';
cfg.preproc.baselinewindow = [-0.1 0];
tlck = ft_timelockanalysis(cfg, data);

% faces
cfg.keeptrials = 'no';
cfg.trials = ismember(data.trialinfo, 1);
tlck_std = ft_timelockanalysis(cfg, data);

% houses
cfg.trials = ismember(data.trialinfo, 2);
tlck_dev = ft_timelockanalysis(cfg, data);

m1 = max(abs(tlck_std.avg(:)));
m2 = max(abs(tlck_dev.avg(:)));
zlim = [-1 1].*max(m1,m2);

cfg = [];
cfg.layout = layout;
cfg.channel = tlck.label(find(tlck.avg(:,1)));
cfg.zlim    = zlim;
cfg.hotkeys = 'yes';
ft_topoplotER(cfg, tlck_std, tlck_dev);

savedir = '/Users/jansch/projects/opm_baby/data/processed';
save(fullfile(savedir, 'pil-003_results_odb'), 'tlck', 'tlck_std', 'tlck_dev', 'data');


figure;
load pil-001_results
subplot(3,2,1);plot(tlck_faces.time,tlck_faces.avg);
subplot(3,2,2);plot(tlck_faces.time,tlck_houses.avg);
load pil-002_results
subplot(3,2,3);plot(tlck_faces.time,tlck_faces.avg);
subplot(3,2,4);plot(tlck_faces.time,tlck_houses.avg);
load pil-003_results
subplot(3,2,5);plot(tlck_faces.time,tlck_faces.avg);
subplot(3,2,6);plot(tlck_faces.time,tlck_faces.avg);

for k = 1:6
  subplot(3,2,k);
  y(k,:) = get(gca,'ylim');
end

y1(1) = min(y(1:2,1));
y1(2) = max(y(1:2,2));
subplot(3,2,1);ylim(y1);
subplot(3,2,2);ylim(y1);
y1(1) = min(y(3:4,1));
y1(2) = max(y(3:4,2));
subplot(3,2,3);ylim(y1);
subplot(3,2,4);ylim(y1);
y1(1) = min(y(5:6,1));
y1(2) = max(y(5:6,2));
subplot(3,2,5);ylim(y1);
subplot(3,2,6);ylim(y1);
