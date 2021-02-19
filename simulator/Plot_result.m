%% Find the max weight of all net

max_weight = 0;
load('4_chip_after.mat');
max_weight = max(max_weight,max(max(net_chip)));

%% Plot the zigzag traffic figure

figure('position',[300 300 600 450]);
plot_traffic(net_chip,max_weight);
caxis([0 max_weight]);
% title('net\_zigzag');
axis off;
set(gcf, 'color', [1 1 1]);
set(gca,'position',[0 0 0.9 1]);
colorbar('position',[0.9 0.1 0.015 0.8]);


% figure('position',[300 300 600 450]);
% plot_traffic(net_chip_LUTOpt,max_weight);
% caxis([0 max_weight]);
% % title('net\_zigzag');
% axis off;
% set(gcf, 'color', [1 1 1]);
% set(gca,'position',[0 0 0.9 1]);
% colorbar('position',[0.9 0.1 0.015 0.8]);