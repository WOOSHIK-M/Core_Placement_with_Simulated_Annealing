%% netlist
load(File_path)

LUTPost_backup = LUTPost;

unused_node_vec = [];                                                                   % Verify unused nodes
for i = 1:size(LUTPost,2)
    if ismember(~1,LUTPost(:,i) == 0) == 0 && ismember(~0,LUTPost == i) == 0
        unused_node_vec = [unused_node_vec i];
    end
end

if length(unused_node_vec)<length(failed_node_vec)
    error('Failed node have to less than unused node')
end

used_failed = linspace(1,Ncore,Ncore);
used_failed(ismember(used_failed,unused_node_vec)==1)=[];
used_failed(ismember(used_failed,failed_node_vec)==0)=[];        %used + failed -> need to move to unused + unfailed

unused_non_failed=unused_node_vec(ismember(unused_node_vec,failed_node_vec)==0);

if isempty(failed_node_vec)
    string1 = ['"' int2str(length(unused_non_failed)) '" core(s) is(are) unused (except for failed nodes). Unused node: ' int2str(unused_non_failed)];
    disp(string1)
end

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
string2= ['This network has(have) "' int2str(length(multi_vec)) '" multi-cast core(s).'];
disp(string2)

save SaveFile/after_move.mat LUTPost

LUT = zeros(Ncore);
LUT_M = zeros(Ncore);

for i = 1:all_node_num                                                       
    for j = 1:all_node_num
        LUT(i,j) = sum(LUTPost(:,i) == j);                               % single-cast Look-up-table
        LUT_M(i,j) = sum(LUTPost(257:512,i) == j);              % multi-cast Look-up-table
    end
end

%% generate Node sturcture
for i = 1:all_node_num                                                     
    find_to = find(LUT(i,:));                                                    % node.connected_to_cores
    send_node_num(i) = length(find_to);
    for k = 1:send_node_num(i)
        node(i).connected_to_cores(k) = find_to(k);
        node(i).connected_to_cores_num = sum(node(i).connected_to_cores>0);
        node(i).connected_to_packet_num(k) = LUT(i,find_to(k));
    end
    
    find_from = find(LUT(:,i));                                               % node.connected_from_cores
    receive_node_num(i) = length(find_from); 
    for k = 1:receive_node_num(i)
        node(i).connected_from_cores(k) = find_from(k);
        node(i).connected_from_cores_num = sum(node(i).connected_from_cores>0);
    end
    
    find_multi_to = find(LUT_M(i,:));                                  % node.multi_to_cores 
    multi_to_num(i) = length(find_multi_to);
    for k = 1:multi_to_num(i)
        node(i).multi_to_cores(k) = find_multi_to(k);
        node(i).multi_to_cores_num = sum(node(i).multi_to_cores>0);
        node(i).multi_to_packet_num(k) = LUT_M(i,find_multi_to(k));
    end
    
    find_multi_from = find(LUT_M(:,i));                             % node.multi_from_cores
    multi_from_num(i) = length(find_multi_from);
    for k = 1:multi_from_num(i)
        node(i).multi_from_cores(k) = find_multi_from(k);
        node(i).multi_from_cores_num = sum(node(i).multi_from_cores>0);
        node(i).multi_from_packet_num(k) = LUT_M(find_multi_from(k),i);
    end
    
    [node(i).x, node(i).y, node(i).chip_num, node(i).chip_x, node(i).chip_y] = coordinate(i);
end

%% generate packet structure
count = 1;
for i = 1:length(node)
    for j = 1:node(i).connected_to_cores_num
        packet_info(count).source = i;
        packet_info(count).dest = node(i).connected_to_cores(j);
        packet_info(count).num = node(i).connected_to_packet_num(j);
        packet_info(count).src_x = node(i).x;
        packet_info(count).src_y = node(i).y;
        packet_info(count).dest_x = node(node(i).connected_to_cores(j)).x;
        packet_info(count).dest_y = node(node(i).connected_to_cores(j)).y;
        if ismember(node(i).connected_to_cores(j),node(i).multi_to_cores)
            packet_info(count).is_mul = 1;
        else
            packet_info(count).is_mul = 0;
        end
        count = count + 1;
    end
end





















