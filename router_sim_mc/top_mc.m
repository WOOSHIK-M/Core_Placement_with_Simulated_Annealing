% load('LUTPost_4chips.mat');
load(File_name);
% LUTTemp = LUT_zigzag;
LUTTemp = LUT_opt;
init_54cores;
% random_xy;
xy;
mean = mean2(net);
save net_zigzag.mat net


% total_cycle_opt_zigzag = zeros(1,10);
% mean_opt_zigzag = zeros(1,10);
% pack_num_opt_zigzag = zeros(1,10);
% max_time_opt_zigzag = zeros(1,10);
% for top_loop = 1:10
%     clearvars -except top_loop total_cycle_opt_zigzag mean_opt_zigzag pack_num_opt_zigzag max_time_opt_zigzag;
%     close all;
%     clc;
%     load('LUT_zigzag.mat');
%     LUTTemp = LUT_zigzag;
%     init_54cores;
%     random_xy;
%     eval(['save net_opt_zigzag_',num2str(top_loop),' net']);
%     eval(['total_cycle_opt_zigzag(',num2str(top_loop), ') = total_cycle']);
%     eval(['mean_opt_zigzag(',num2str(top_loop), ') = mean2(net)']);
%     eval(['pack_num_opt_zigzag(',num2str(top_loop), ') = PACK_NUM']);
%     eval(['max_time_opt_zigzag(',num2str(top_loop), ') = max_time']);
% end

% total_cycle_ramdom = zeros(1,10);
% mean_ramdom = zeros(1,10);
% pack_num_ramdom = zeros(1,10);
% max_time_ramdom = zeros(1,10);
% for top_loop = 1:10
%     clearvars -except top_loop total_cycle_ramdom mean_ramdom pack_num_ramdom max_time_ramdom;
%     close all;
%     clc;
%     filename=['LUT_random_',num2str(top_loop),'.mat'];
%     load(filename);
%     LUTTemp = LUT_random;
%     init_54cores;
%     random_xy;
%     eval(['save net_random_',num2str(top_loop),' net']);
%     eval(['total_cycle_ramdom(',num2str(top_loop), ') = total_cycle']);
%     eval(['mean_ramdom(',num2str(top_loop), ') = mean2(net)']);
%     eval(['pack_num_ramdom(',num2str(top_loop), ') = PACK_NUM']);
%     eval(['max_time_ramdom(',num2str(top_loop), ') = max_time']);
% end


% total_cycle_opt_turning = zeros(1,10);
% mean_opt_turning = zeros(1,10);
% pack_num_opt_turning = zeros(1,10);
% max_time_opt_turning = zeros(1,10);
% for top_loop = 1:10
%     clearvars -except top_loop total_cycle_opt_turning mean_opt_turning pack_num_opt_turning max_time_opt_turning;
%     close all;
%     clc;
%     filename=['LUT_opt_turning_',num2str(top_loop),'.mat'];
%     load(filename);
%     LUTTemp = LUT_opt;
%     init_54cores;
%     random_xy;
%     eval(['save net_opt_turning_',num2str(top_loop),' net']);
%     eval(['total_cycle_opt_turning(',num2str(top_loop), ') = total_cycle']);
%     eval(['mean_opt_turning(',num2str(top_loop), ') = mean2(net)']);
%     eval(['pack_num_opt_turning(',num2str(top_loop), ') = PACK_NUM']);
%     eval(['max_time_opt_turning(',num2str(top_loop), ') = max_time']);
% end


% total_cycle_opt_cyclic = zeros(1,10);
% mean_opt_cyclic = zeros(1,10);
% pack_num_opt_cyclic = zeros(1,10);
% max_time_opt_cyclic = zeros(1,10);
% for top_loop = 1:5
%     clearvars -except top_loop total_cycle_opt_cyclic mean_opt_cyclic pack_num_opt_cyclic max_time_opt_cyclic;
%     close all;
%     clc;
%     filename=['LUT_opt_cyclic_',num2str(top_loop),'.mat'];
%     load(filename);
%     LUTTemp = LUT_opt;
%     init_54cores;
%     xy;
%     eval(['save net_opt_cyclic_',num2str(top_loop),' net']);
%     eval(['total_cycle_opt_cyclic(',num2str(top_loop), ') = total_cycle']);
%     eval(['mean_opt_cyclic(',num2str(top_loop), ') = mean2(net)']);
%     eval(['pack_num_opt_cyclic(',num2str(top_loop), ') = PACK_NUM']);
%     eval(['max_time_opt_cyclic(',num2str(top_loop), ') = max_time']);
% end
% 
% 
total_cycle_opt_two = zeros(1,20);
mean_opt_two = zeros(1,20);
pack_num_opt_two = zeros(1,20);
max_time_opt_two = zeros(1,20);
for top_loop = 19:20
    clearvars -except top_loop total_cycle_opt_two mean_opt_two pack_num_opt_two max_time_opt_two;
    close all;
    clc;
    filename=['LUT_opt_two_',num2str(top_loop),'.mat'];
    load(filename);
    LUTTemp = LUT_opt;
    init_54cores;
    random_xy;
    eval(['save net_opt_two_',num2str(top_loop),' net']);
    eval(['total_cycle_opt_two(',num2str(top_loop), ') = total_cycle']);
    eval(['mean_opt_two(',num2str(top_loop), ') = mean2(net)']);
    eval(['pack_num_opt_two(',num2str(top_loop), ') = PACK_NUM']);
    eval(['max_time_opt_two(',num2str(top_loop), ') = max_time']);
end
