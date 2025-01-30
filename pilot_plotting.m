%%
clear tmp
for k = 1:7
  subj = mc_subjinfo(sprintf('pil-%03d',k));

  tmp(k) = load(fullfile(subj.procdir,sprintf('%s_erf_faceshouses',subj.subjname)),'tlck*');
end

%%
cd /Users/jansch/projects/opm_baby/helmet-v3/
load layout


for k = 1:numel(tmp)
  cfg = [];
  cfg.channel = tmp(1).tlck.label(tmp(1).tlck.avg(:,1)~=0); % stick to the original good subset of channels for now

  tmp(k).tlck = ft_selectdata(cfg, tmp(k).tlck);
  tmp(k).tlck_faces = ft_selectdata(cfg, tmp(k).tlck_faces);
  tmp(k).tlck_houses = ft_selectdata(cfg, tmp(k).tlck_houses);
end

% quick and dirty averaging, does not yet take into account the non-missing
% channels in the later pilots
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

tt = {'left_parietal';'right_parietal';'central';'left_occipital';'right_occipital'};

%%
fname = '/Users/jansch/projects/opm_baby/singleplots.pdf';

div = [2 4];
for k = 1:numel(grp)
  cfg.channel = grp{k};
  cfg.title   = tt{k};
  for m = 1:numel(tmp)
    cfg.figure = subplot(div(1),div(2),m);
    ft_singleplotER(cfg, tmp(m).tlck_faces, tmp(m).tlck_houses);
  end
  cfg.figure = subplot(div(1),div(2),m+1);
  ft_singleplotER(cfg, avg_faces, avg_houses);
  if k==1
    exportgraphics(gcf, fname)
    close 
  else
    exportgraphics(gcf, fname, 'Append', true)
    close
  end

end
