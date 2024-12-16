sensorfile = {
  'C1.stl'
  'C3.stl'
  'L11.stl'
  'L12.stl'
  'L13.stl'
  'L21.stl'
  'L22.stl'
  'L23.stl'
  'L24.stl'
  'L31.stl'
  'L32.stl'
  'L33.stl'
  'L41.stl'
  'L42.stl'
  'L43.stl'
  'L51.stl'
  'L61.stl'
  'R11.stl'
  'R12.stl'
  'R13.stl'
  'R21.stl'
  'R22.stl'
  'R23.stl'
  'R24.stl'
  'R31.stl'
  'R32.stl'
  'R33.stl'
  'R41.stl'
  'R42.stl'
  'R43.stl'
  'R51.stl'
  'R61.stl'
  };

bowlfile = 'bowl.stl';

%%

cd '/Volumes/SamsungT7/data/BabyOPMs/Analysis/Matlab files/helmet-v3/'

for i=1:32
  sensor{i} = ft_read_headshape(sensorfile{i});
end

bowl = ft_read_headshape(bowlfile);

%%

cd ~/matlab/fieldtrip/private/

for i=1:32
  [sensor{i}.pos, sensor{i}.tri] = remove_double_vertices(sensor{i}.pos, sensor{i}.tri);
end

%%

close all

ft_plot_mesh(bowl, 'facecolor', 'g');
ft_plot_axes(bowl);
hold on

for i=1:32
  ft_plot_mesh(sensor{i}, 'facecolor', 'r');
end


%%

centerpoint = [0 0 70];

grad = [];

for i=1:32

  dx = sensor{i}.pos(:,1) - centerpoint(1);
  dy = sensor{i}.pos(:,2) - centerpoint(2);
  dz = sensor{i}.pos(:,3) - centerpoint(3);
  dd = sqrt(dx.^2 + dy.^2 + dz.^2);
  [dd, indx] = sort(dd);

  pos1 = mean(sensor{i}.pos(indx(1:4),:));
  pos2 = mean(sensor{i}.pos(indx(5:8),:));
  ori = pos2 - pos1;
  ori = ori/norm(ori);

  grad.label{i} = strtok(sensorfile{i}, '.');
  grad.coilpos(i,:) = pos1;
  grad.coilori(i,:) = ori;

end

grad.tra = eye(32);
grad.chantype = repmat({'megmag'}, 32, 1);

grad = ft_transform_geometry(rotate([90 0 0]), grad);
grad = ft_transform_geometry(rotate([0 0 180]), grad);
grad = ft_transform_geometry(translate([0 -70 0]), grad);
grad.coordsys = 'neuromag';
grad.unit = 'mm';

ft_plot_sens(grad, 'label', 'yes')
ft_plot_axes(grad)

%%

mapping = {
  's1_bz'   'L61'
  's2_bz'   'L51'
  's3_bz'   'L43'
  's4_bz'   'L42'
  's5_bz'   'L41'
  's6_bz'   'L33'
  's7_bz'   'L32'
  's8_bz'   'L31'
  's9_bz'   'L24'
  's10_bz'  'L23'
  's11_bz'  'L22'
  's12_bz'  'L21'
  's13_bz'  'L13'
  's14_bz'  'L12'
  's15_bz'  'L11'
  's16_bz'  'C1'
  's17_bz'  'R61'
  's18_bz'  'R51'
  's19_bz'  'R43'
  's20_bz'  'R42'
  's21_bz'  'R41'
  's22_bz'  'R33'
  's23_bz'  'R32'
  's24_bz'  'R31'
  's25_bz'  'R24'
  's26_bz'  'R23'
  's27_bz'  'R22'
  's28_bz'  'R21'
  's29_bz'  'R13'
  's30_bz'  'R12'
  's31_bz'  'R11'
  's32_bz'  'C3'
  };

montage = [];
montage.tra = eye(32);
montage.labelold = mapping(:,2);
montage.labelnew = mapping(:,1);

grad.balance.current = 'none';
grad = ft_apply_montage(grad, montage, 'balancename', 'rename');

%%

close all

ft_plot_sens(grad, 'label', 'yes')
ft_plot_axes(grad)


%%

cfg = [];
cfg.grad = grad;
cfg.outline = 'helmet';
cfg.mask = 'convex';
cfg.feedback = 'yes';
layout = ft_prepare_layout(cfg);

%%

cd '/Volumes/SamsungT7/data/BabyOPMs/Analysis/Matlab files/helmet-v3/'

save grad.mat grad
save layout.mat layout