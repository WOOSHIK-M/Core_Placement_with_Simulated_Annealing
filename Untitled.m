%% test
% global cycle_flag
global Nchip
global X_DIM

%% dkdk
node_covert = [];
for i = 1:length(node)
    node(i).covert = node(i).x + node(i).y * X_DIM + 1;
end

node_covert = [node.covert];
if length(node_covert) ~= length(unique(node_covert))
    error('what')
end

if Nchip == 1
    save node_covert.mat node_covert
    load('node_covert.mat')
%     load('Dataset/MLP_154core_2048-1024-1024-1024-512-384 (2).mat')

    copy_LUT = LUTPost;
    LUTPost = zeros(512,length(node));
    for i = 1:size(LUTPost,2)
        LUTPost(:,node_covert(i)) = copy_LUT(:,i);
    end

    for i = 1:size(LUTPost,1)
        for j =1:size(LUTPost,2)
            if LUTPost(i,j) ~= 0
                LUTPost(i,j) = node_covert(LUTPost(i,j));
            end
        end
    end

    save sample_chips_opt.mat LUTPost
    
else
    eval(['save router_sim_mc/node_covert_chip' num2str(iterate) '.mat LUTPost -ASCII'])
end
