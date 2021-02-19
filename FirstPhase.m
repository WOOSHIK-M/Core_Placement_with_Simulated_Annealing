function [nt, com_info, cnt] = FirstPhase(net, phase, com_all_result, cnt)

global Ncore
global nt_vec
global com_info_name
global com_info_name_name
global save_delta
global save_nt
global save_net
global net_count

%% PRE-PROCESSING

M = net;
M = M + M';
cc = 1;
pos = 1;

if cnt == 2
    for i = net_count - 3:net_count
        save_net{i} = [];
    end
    net_count = net_count - 4;
    net = save_net{net_count};
end

save_net{net_count} = net;
net_count = net_count + 1;

% make nt
% get neighbor nodes % weight
for  i = 1:length(M)
    nt(cc).node = [];
    nt(cc).weight = [];
    for j = 1:length(M)
        if M(i,j) ~= 0
            nt(cc).node = [nt(cc).node j];
            nt(cc).weight = [nt(cc).weight M(i,j)];
        end
    end
    cc = cc + 1;
end

% calculate all_edge_weight
all_edge_weights = sum(sum(net));
disp_edge = ['--> All edge weight is ' int2str(all_edge_weights) ' in current phase'];
disp(disp_edge)
fprintf('\n')
% get community number
del_row = [];
for i = 1:length(nt)
    if isempty(nt(i).node)
        del_row = [del_row i];
    end
    nt(i).community = i;
end

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% if cnt == 2
%     for i = 1:phase - 4
%         layer_name = ['Iter_' int2str(i)];
%         layer_name_num = ['Iter_' int2str(i) '_num'];
%         for j = 1:length(com_all_result)
%             copy_result(j).(layer_name) = com_all_result(j).(layer_name);
%             copy_result(j).(layer_name_num) = com_all_result(j).(layer_name_num);
%         end
%         if i == phase - 5
%             com_info_name = layer_name;
%             com_info_name_name = layer_name_num;
%         end
%     end
%     com_all_result = copy_result;
%     phase = phase - 4;
% end
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    

% calculate how many member are exist in current phase
if phase == 1
    for i = 1:length(nt)
        nt(i).num_member = 1;
    end
else
    for i = 1:length(nt)
        field_name = ['Iter_' int2str(phase-1) '_num'];
        nt(i).num_member = com_all_result(i).(field_name);
    end
end

for i = 1:length(nt)
    nt(i).org_num_member = nt(i).num_member;
end

%% RUN FIRST PHASE

node = 1;

while 1
    nodes_neigh = nt(node).node;
    if isempty(nodes_neigh)
        node = node + 1;
        if node > length(nt)
            break
        end
    else
        delta_vec = 0;
        nt_vec = cell(1, length(nodes_neigh)+1);
        nt_vec{1} = nt;
        
        param = 1;

        nt_copy_2 = nt;
        % calculate delta_q
        for i = 1:length(nodes_neigh)
            nt_copy = nt;
            node_neigh = nodes_neigh(i);

            com_org = nt_copy(node).community;
            com_num_org = nt_copy_2(node).org_num_member;
            com_aft = nt_copy(node_neigh).community;
            com_aft_org = nt_copy_2(node_neigh).org_num_member;

            node_weight = sum(nt_copy(node).weight);

            delta_q =0;

            if com_org == com_aft
                delta_q = 2*getNodeWeightInCluster(nt_copy,node) - (getToWeight(nt_copy, node)*node_weight/all_edge_weights)*param;
            else            
                if com_num_org + nt_copy(node_neigh).num_member <= Ncore
                    for j = 1:length(nt_copy)
                        if nt_copy(j).community == com_org
                            nt_copy(j).num_member = nt_copy(j).num_member - com_num_org;
                        elseif nt_copy(j).community == com_aft
                            nt_copy(j).num_member = nt_copy(j).num_member + com_num_org;
                        end
                    end

                    nt_copy(node).community = nt_copy(node_neigh).community;
                    nt_copy(node).num_member = nt_copy(node_neigh).num_member;

                    delta_q = 2*getNodeWeightInCluster(nt_copy,node) - (getToWeight(nt_copy, node)*node_weight/all_edge_weights)*param;
                end
            end

            delta_vec = [delta_vec delta_q];
            nt_vec{i+1} = nt_copy;

            [max_delta, max_pos] = max(delta_vec);
            if max_delta == 0 && cnt == 1 && min(delta_vec) ~= 0
                max_pos = find(delta_vec == max(delta_vec(delta_vec<0)));
            end
%             if cnt == 2
%                 sortt = sort(delta_vec);
%                 max_pos = find(delta_vec == sortt(end - pos));
%                 pos = pos + 1;
%                 cnt = 0;
%             end
            max_nt = nt_vec{max_pos};
            
        end

        nt = max_nt;        
        node = node + 1;
        
        % judge continue or stop
        community = [];
        for i = 1:length(nt)
            community = [community nt(i).community];
        end

        if node > length(nt)
            break
        end        
    end
end

%% POST PROCESSING

% count community num
com_vec = [];
for i = 1:length(nt)
    if isempty(nt(i).node)
        continue
    else
        com_vec = [com_vec nt(i).community];
    end
end

com_vec = unique(com_vec);
num_com = length(com_vec);

% make com_info
com_info(length(nt)).cores = [];

for i = 1:length(nt)
    if isempty(nt(i).node)
        continue
    else
        com_info(nt(i).community).cores = [com_info(nt(i).community).cores i];
    end
end

%% PRINT RESULT

string = ['*** "Iter_' int2str(phase) '" is finished (We have ' int2str(num_com) ' communities now)'];
disp(string)

end

