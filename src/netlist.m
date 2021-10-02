% global con_with_failed
global packet_info
global X_DIM
global Y_DIM
%% Build network
load(File_name);

LUTPost_backup = LUTPost;

unused_node_vec = []; % Verify unused nodes
for i = 1:size(LUTPost,2)
    if ismember(~1,LUTPost(:,i) == 0) == 0 && ismember(~0,LUTPost == i) == 0
        unused_node_vec = [unused_node_vec i];
    end
end

used_failed = linspace(1,X_DIM*Y_DIM,X_DIM*Y_DIM);
used_failed(ismember(used_failed,unused_node_vec) == 1) = [];
used_failed(ismember(used_failed,failed_node_vec) == 0) = []; % used + failed --> need to move to unused + non-failed

unused_non_failed = linspace(1,X_DIM*Y_DIM,X_DIM*Y_DIM);
unused_non_failed(ismember(unused_non_failed,unused_node_vec) == 0) = [];
unused_non_failed(ismember(unused_non_failed,failed_node_vec) == 1) = [];

disp_sann = ['"' int2str(length(unused_non_failed)) '" core(s) is(are) unused (except for failed nodes). Unused node: ' int2str(unused_non_failed)];
disp(disp_sann)

count = 1;
for i = 1:length(used_failed)
    LUTPost(:,unused_non_failed(count)) = LUTPost(:,used_failed(i));
    LUTPost(:,used_failed(i)) = 0;
    LUTPost(LUTPost == used_failed(i)) = unused_non_failed(count);
    disp_sansan = ['Node ' int2str(used_failed(i)) ' is moved to Node ' int2str(unused_non_failed(count)) ', because this node is failed'];
    disp(disp_sansan)
    count = count + 1;
end

multi_pos = LUTPost(257:512,:);
multi_vec = [];
for i = 1:size(multi_pos,2)
    if ~all(multi_pos(:,i) == 0)
        multi_vec = [multi_vec i];
    end
end

fprintf('\n')
str_m0 = ['This network have "' int2str(length(multi_vec)) '" multi-cast cores.'];
disp(str_m0)

save after_move.mat LUTPost
% unused_non_failed(ismember(unused_non_failed,failed_node_vec) == 1) = [];

% disp_sann = ['"' int2str(length(unused_non_failed)) '" core(s) is(are) unused (except for failed nodes). Unused node: ' int2str(unused_non_failed)];
% disp(disp_sann)

for i = 1:nnode                                     % 生成路由表 LUT，包括正常和多播
    for j = 1:nnode
        LUT(i,j) = sum(LUTPost(:,i) == j);
    end
end

for i = 1:nnode                                     % 生成多播表 LUT_M
    for j = 1:nnode
        LUT_M(i,j) = sum(LUTPost(257:512,i) == j);
    end
end

for i = 1:nnode                                     % 导入连接关系和每个core发送的包数
    find_to = find(LUT(i,:));
    send_node_num(i) = length(find_to);
    for k = 1:send_node_num(i)
        node(i).connected_to_cores(k) = find_to(k);
        node(i).connected_to_cores_num = sum(node(i).connected_to_cores>0);
        node(i).connected_to_packet_num(k) = LUT(i,find_to(k));
    end
end

for i = 1:nnode                                     % 导入反连接关系
    find_from = find(LUT(:,i));
    receive_node_num(i) = length(find_from);
    for k = 1:receive_node_num(i)
        node(i).connected_from_cores(k) = find_from(k);
        node(i).connected_from_cores_num = sum(node(i).connected_from_cores>0);
    end
end

for i = 1:nnode                                     % 导入多播连接关系和每个多播core发送的包数
    find_multi_to = find(LUT_M(i,:));
    multi_to_num(i) = length(find_multi_to);
    for k = 1:multi_to_num(i)
        node(i).multi_to_cores(k) = find_multi_to(k);
        node(i).multi_to_cores_num = sum(node(i).multi_to_cores>0);
        node(i).multi_to_packet_num(k) = LUT_M(i,find_multi_to(k));
    end
end

for i = 1:nnode                                     % 导入反多播连接关系和每个接收多播的core收到的多播包数
    find_multi_from = find(LUT_M(:,i));
    multi_from_num(i) = length(find_multi_from);
    for k = 1:multi_from_num(i)
        node(i).multi_from_cores(k) = find_multi_from(k);
        node(i).multi_from_cores_num = sum(node(i).multi_from_cores>0);
        node(i).multi_from_packet_num(k) = LUT_M(find_multi_from(k),i);
    end
end

%% 路由仿真器接口1
i = 1;
for j = 1:nnode                                    % 在主函数将S（原节点）、D（目的节点）分别存储进 to_router_sim.mat，用于路由仿真器的输入
    for k = 1:512
        if LUTPost(k,j) > 0
            S(i) = j;
            D(i) = LUTPost(k,j);
            i = i + 1;
        end
    end
end

%% 初始化各个节点
for i=1:1:nnode
    node(i).width = 1;                      % 设置每个core的宽和高
    node(i).height = 1;
end

for i=1:1:nnode                             % 随机（顺序排列）初始化各节点坐标
    node(i).x = mod(i-1,X_DIM);
    node(i).y = floor((i-1)/X_DIM);
end

%% 统计发包总数
packet_sum = 0;                                 % 用于统计发包总数
for i=1:nnode
    for j=1:node(i).connected_to_cores_num
        packet_sum = packet_sum + node(i).connected_to_packet_num(j);   % 计算发送总包数
    end
end

%% 生成路由包信息
% count = 1;
% packet_info = [];
% for i = 1:size(LUT,1)
%     for j = 1:size(LUT,2)
%         if LUT(i,j) == 0
%             continue
%         else
%             packet_info(count).source = i;
%             packet_info(count).dest = j;
%             packet_info(count).num = LUT(i,j);
%             packet_info(count).src_x = mod(i-1,X_DIM);
%             packet_info(count).src_y = floor((i-1)/X_DIM);
%             packet_info(count).dest_x = mod(j-1,X_DIM);
%             packet_info(count).dest_y = floor((j-1)/X_DIM);
%             count = count + 1;
%         end
%     end
% end

count = 1;
packet_info = [];
for i = 1:length(node)
    for j = 1:node(i).connected_to_cores_num
        packet_info(count).source = i;
        packet_info(count).dest = node(i).connected_to_cores(j);
        packet_info(count).num = node(i).connected_to_packet_num(j);
        packet_info(count).src_x = mod(i-1,X_DIM);
        packet_info(count).src_y = floor((i-1)/X_DIM);
        packet_info(count).dest_x = mod(node(i).connected_to_cores(j)-1,X_DIM);
        packet_info(count).dest_y = floor((node(i).connected_to_cores(j)-1)/X_DIM);
        if ismember(node(i).connected_to_cores(j),node(i).multi_to_cores)
            packet_info(count).is_mul = 1;
        else
            packet_info(count).is_mul = 0;
        end
        count = count + 1;
    end
end
            

% del_vec = [];
% con_with_failed = packet_info;
% % find the connections with passing failed nodes'
% for j = 1:length(packet_info)
%     if isempty(failed_node_vec)
%         con_with_failed = [];
%     else
%         for i = 1:length(failed_node_vec)
%             x_failed = mod(failed_node_vec(i)-1,X_DIM);
%             y_failed = floor((failed_node_vec(i)-1)/X_DIM);
%             x_src = packet_info(j).src_x;
%             y_src = packet_info(j).src_y;
%             x_dest = packet_info(j).dest_x;
%             y_dest = packet_info(j).dest_y;
%             if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)... % node A, connected_to_cores
%                     ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
%                     ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
%                     ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed) 
%                 break
%             end
%             if i == length(failed_node_vec)
%                 del_vec = [del_vec j];
%             end
%         end
%     end
% end

% con_with_failed(del_vec) = []; 
% 
% fprintf('\n')
% str_num_con  = ['==> There are ' int2str(length(con_with_failed)) ' connections through failed node.'];
% disp(str_num_con);
% fprintf('\n')



