% this script is based on https://www.fieldtriptoolbox.org/example/video_eeg/

rootdir = '/Volumes/SamsungT7/data/babyOPMs';

pilot1video = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot01_20240829/2024-08-29 15-43-29.mp4');
pilot1meg   = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot01_20240829/20240829_154459_sub-pilot01_file-pilot01_raw.fif');

pilot2video = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot02_20240904/Pilot02/2024-09-04 09-12-35.mp4');
pilot2meg   = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot02_20240904/Pilot02/sub-pilot02/20240904_091352_sub-pilot02_file-pilot02_raw.fif');

pilot3video = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot03_20240911/Pilot03/2024-09-11 10-03-24.mp4');
pilot3meg   = fullfile(rootdir, 'Data/Raw data/Neural/Pilot/Pilot03_20240911/Pilot03/20240911_100359_sub-pilot03_file-03_raw.fif');

%%

videofile = pilot3video;
megfile = pilot3meg;

%%

% read the continuous data in memory, this results in one long segment (trial)
cfg = [];
cfg.dataset = megfile;
data_continuous = ft_preprocessing(cfg);

% we also want to plot the events (if present)
event = ft_read_event(megfile);

% replace the numeric codes by more meaningful strings
event = update_event(event);


%%
% determine the right settings for the databrowser

cfg = [];
cfg.trackcallinfo = 'no';     % prevent too much feedback info to be printed on screen
cfg.showcallinfo = 'no';      % prevent too much feedback info to be printed on screen
cfg.viewmode = 'vertical';
cfg.event = event;
cfg.ploteventlabels = 'value';
cfg.plotlabels = 'no';
cfg.fontsize = 12;
cfg.continuous = 'yes';
cfg.blocksize = 10;
cfg.preproc.demean = 'yes';
cfg.ylim = [-3 3]*1e-11;
cfg.channel = '*_bz';
ft_databrowser(cfg, data_continuous)

%%

begtime = 0;
endtime = 15 - 1/data_continuous.fsample; % 15 seconds minus one sample
increment = 0.5; % stepwise in seconds

% make a figure with the desired size, see https://en.wikipedia.org/wiki/Display_resolution
close all
figh = figure;

set(figh, 'position', [10 10 1280 720]);
% set(figh, 'WindowState', 'maximized');

% prepare the video file
vidObj = VideoWriter('databrowser', 'MPEG-4');
vidObj.FrameRate = 1/increment;
vidObj.Quality = 100;
open(vidObj);

% prevent too much feedback info to be printed on screen
ft_debug off
ft_info off
ft_notice off

%%

while (endtime < data_continuous.time{1}(end)) && ishandle(figh)

  % cut a short piece of data from the continuous recording
  cfg = [];
  cfg.toilim = [begtime endtime];
  cfg.trackcallinfo = 'no';
  cfg.showcallinfo = 'no';
  data_piece = ft_redefinetrial(cfg, data_continuous);

  cfg = [];
  cfg.figure = figh;            % IMPORTANT: reuse the existing figure
  cfg.blocksize = round(endtime-begtime);
  
  cfg.trackcallinfo = 'no';     % prevent too much feedback info to be printed on screen
  cfg.showcallinfo = 'no';      % prevent too much feedback info to be printed on screen
  cfg.viewmode = 'vertical';
  cfg.event = event;
  cfg.ploteventlabels = 'value';
  cfg.plotlabels = 'no';
  cfg.fontsize = 12;
  cfg.continuous = 'yes';
  cfg.preproc.demean = 'yes';
  cfg.ylim = [-3 3]*1e-11;
  cfg.channel = '*_bz';

  ft_databrowser(cfg, data_piece);

  set(gca, 'XGrid', 'on');
  currFrame = getframe(gcf);
  writeVideo(vidObj,currFrame);

  % go to the next segment of data
  begtime = begtime + increment;
  endtime = endtime + increment;
end

% close the file
close(vidObj);