%%
cd /Users/jansch/projects/opm_baby/data/processed/
clear tmp
for k = 1:3
  tmp(k) = load(sprintf('pil-%03d_results',k),'tlck*');
end

%%
cd /Users/jansch/projects/opm_baby/code/helmet-v3/
load layout

cfg = [];
cfg.channel = tmp(1).tlck.label(tmp(1).tlck.avg(:,1)~=0);

for k = 1:numel(tmp)
  
  tmp(k).tlck = ft_selectdata(cfg, tmp(k).tlck);
  tmp(k).tlck_faces = ft_selectdata(cfg, tmp(k).tlck_faces);
  tmp(k).tlck_houses = ft_selectdata(cfg, tmp(k).tlck_houses);
end

for k = 1:numel(tmp)
  if k==1
    avg_faces = tmp(k).tlck_faces;
    avg_houses = tmp(k).tlck_houses;
  else
    avg_faces.avg = tmp(k).tlck_faces.avg + avg_faces.avg;
    avg_houses.avg = tmp(k).tlck_houses.avg + avg_houses.avg;
  end
end
avg_faces.avg = avg_faces.avg./numel(tmp);
avg_houses.avg = avg_houses.avg./numel(tmp);


grp{1} = {'s6_bz'; 's7_bz'; 's9_bz'; 's10_bz'; 's13_bz'; 's14_bz'};
grp{2} = {'s22_bz'; 's23_bz'; 's25_bz'; 's26_bz'; 's29_bz'; 's30_bz'};
grp{3} = {'s1_bz'; 's2_bz'; 's3_bz'; 's4_bz'; 's17_bz'; 's18_bz'; 's19_bz'; 's20_bz'};
grp{4} = {'s5_bz'; 's8_bz'; 's11_bz'; 's12_bz'; 's15_bz'; 's16_bz'};
grp{5} = {'s21_bz'; 's24_bz'; 's127_bz'; 's28_bz'; 's31_bz'; 's32_bz'};

%%
fname = '/Users/jansch/projects/opm_baby/data/processed/singleplots.pdf';


cfg =[];
cfg.channel = grp{1}; 
cfg.title   = 'left_parietal';
cfg.figure  = subplot(221);
ft_singleplotER(cfg, tmp(1).tlck_faces, tmp(1).tlck_houses);
cfg.figure  = subplot(222);
ft_singleplotER(cfg, tmp(2).tlck_faces, tmp(2).tlck_houses);
cfg.figure  = subplot(223);
ft_singleplotER(cfg, tmp(3).tlck_faces, tmp(3).tlck_houses);
cfg.figure  = subplot(224);
ft_singleplotER(cfg, avg_faces, avg_houses);
exportgraphics(gcf, fname)
close 

cfg =[];
cfg.channel = grp{2}; 
cfg.title   = 'right_parietal';
cfg.figure  = subplot(221);
ft_singleplotER(cfg, tmp(1).tlck_faces, tmp(1).tlck_houses);
cfg.figure  = subplot(222);
ft_singleplotER(cfg, tmp(2).tlck_faces, tmp(2).tlck_houses);
cfg.figure  = subplot(223);
ft_singleplotER(cfg, tmp(3).tlck_faces, tmp(3).tlck_houses);
cfg.figure  = subplot(224);
ft_singleplotER(cfg, avg_faces, avg_houses);
exportgraphics(gcf, fname, 'Append', true)
close

cfg =[];
cfg.channel = grp{3}; 
cfg.title   = 'central';
cfg.figure  = subplot(221);
ft_singleplotER(cfg, tmp(1).tlck_faces, tmp(1).tlck_houses);
cfg.figure  = subplot(222);
ft_singleplotER(cfg, tmp(2).tlck_faces, tmp(2).tlck_houses);
cfg.figure  = subplot(223);
ft_singleplotER(cfg, tmp(3).tlck_faces, tmp(3).tlck_houses);
cfg.figure  = subplot(224);
ft_singleplotER(cfg, avg_faces, avg_houses);
exportgraphics(gcf, fname, 'Append', true)
close

cfg =[];
cfg.channel = grp{4}; 
cfg.title   = 'left_occipital';
cfg.figure  = subplot(221);
ft_singleplotER(cfg, tmp(1).tlck_faces, tmp(1).tlck_houses);
cfg.figure  = subplot(222);
ft_singleplotER(cfg, tmp(2).tlck_faces, tmp(2).tlck_houses);
cfg.figure  = subplot(223);
ft_singleplotER(cfg, tmp(3).tlck_faces, tmp(3).tlck_houses);
cfg.figure  = subplot(224);
ft_singleplotER(cfg, avg_faces, avg_houses);
exportgraphics(gcf, fname, 'Append', true)
close

cfg =[];
cfg.channel = grp{5}; 
cfg.title   = 'right_occipital';
cfg.figure  = subplot(221);
ft_singleplotER(cfg, tmp(1).tlck_faces, tmp(1).tlck_houses);
cfg.figure  = subplot(222);
ft_singleplotER(cfg, tmp(2).tlck_faces, tmp(2).tlck_houses);
cfg.figure  = subplot(223);
ft_singleplotER(cfg, tmp(3).tlck_faces, tmp(3).tlck_houses);
cfg.figure  = subplot(224);
ft_singleplotER(cfg, avg_faces, avg_houses);
exportgraphics(gcf, fname, 'Append', true)
close
