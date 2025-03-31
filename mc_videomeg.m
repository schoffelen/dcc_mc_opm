function mc_videomeg(subj)

% MC_VIDEOMEG creates a movie of the data (using ft_databrowser) that can
% be used to align it with the recorded video
% this function is based on https://www.fieldtriptoolbox.org/example/video_eeg/

if ~isstruct(subj)
  subj = mc_subjinfo(subj, [], 0);
end


%%
% read the continuous data in memory, this results in one long segment (trial)
cfg = [];
cfg.dataset = subj.dataset
data_continuous = ft_preprocessing(cfg);

% we also want to plot the events (if present)
event = subj.event_new;

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
vidObj = VideoWriter(fullfile(subj.procdir, sprintf('%s_databrowser', subj.subjname)), 'MPEG-4');
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
