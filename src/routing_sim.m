global Nchip

%% simulation


if Nchip == 1
    xy;
else
    load('backup_new_LUTPost.mat')
    LUT_opt = zeros(512,size(LUTPost,2));
    final_info = cell(4);

    for i = 1:Nchip
        covert_name = ['node_covert_chip' int2str(i) '.mat'];
        load(covert_name)
        final_info{i} = node_covert;
    end

    for i = 2:size(final_info,2)
        for j = 1:length(final_info{i})
            final_info{i}(j) = final_info{i}(j) + (i-1)*156;
        end
    end

    node_covert = [];
    for i = 1:size(final_info,2)
        node_covert = [node_covert final_info{i}];
    end

    % backup_new_LUTPost
    LUT_opt = backup_new_LUTPost(:,node_covert);

    for i = 1:size(LUT_opt,1)
        for j =1:size(LUT_opt,2)
            if LUT_opt(i,j) ~= 0
                LUT_opt(i,j) = find(node_covert == LUT_opt(i,j));
            end
        end
    end
    
    addpath('router_sim_mc')
    File_name = '4_chips_opt.mat';
    top_mc;
end