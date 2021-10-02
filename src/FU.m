global back
global cnt
global com_info_name
global com_info_name_name
global Nchip
global Ncore
global save_delta
global save_nt
global save_net
global net_count

keep_run = 1;
phase = 1;
back = 0;

iso_node = [];
for i = 1:length(net)
    if all(net(i,:) == 0) && all(net(:,i) == 0)
        iso_node = [iso_node i];
    end
end

disp('Base Information of network & Conditions:')
strr_0 = ['--> Number of physical chip = ' int2str(Nchip) ', Max number of each chip = ' int2str(Ncore)];
disp(strr_0)
strr_1 = ['--> All ' int2str(length(iso_node)) ' isolated node exist.']; % Node number: ' int2str(iso_node)];
disp(strr_1)
strr = ['--> Number of node = ' int2str(length(net)) ', Members: 1 ~ ' int2str(length(net))];
disp(strr)

com_all_result = [];

prev_num_com = length(net);
cnt = 0;
dispp = 0;

save_net = cell([1,100]);
net_count = 1;
% save_net{net_count} = net;
% net_count = net_count + 1;

while keep_run
    net_copy = net;

   % FAST UNFOLDING
    [nt, com_info, cnt] = FirstPhase(net_copy, phase, com_all_result, cnt);
    [net,cnt, z_final] = SecondPhase(com_info, net_copy, cnt); % Run Second Phase

    % make the com_all_result(struct)
    com_info_name = ['Iter_' int2str(phase)];
    for i = 1:length(com_info)
        com_all_result(i).(com_info_name) = com_info(i).cores;
    end

    com_info_name_name = ['Iter_' int2str(phase) '_num'];

    if phase == 1
        for i = 1:length(com_all_result)
            com_all_result(i).(com_info_name_name) = length(com_all_result(i).(com_info_name));
        end
    else
        com_prev = ['Iter_' int2str(phase - 1) '_num'];
        for i = 1:length(com_all_result)
            com_all_result(i).(com_info_name_name) = 0;
            if isempty(com_all_result(i).(com_info_name))
                continue
            else
                for j = 1:length(com_all_result(i).(com_info_name))
                    com_all_result(i).(com_info_name_name) = com_all_result(i).(com_info_name_name) + com_all_result(com_all_result(i).(com_info_name)(j)).(com_prev);
                end
            end
        end
    end

    phase = phase + 1;

    % calculate the number of communites
    num_com = 0;
    for i = 1:length(com_info)
        if isempty(com_info(i).cores)
            continue
        else
            num_com = num_com + 1;
        end
    end

    if prev_num_com ~= num_com
        prev_num_com = num_com;
        cnt = 0;
    else
        cnt = cnt + 1;
    end

    % condition stop iterate
    if num_com <= Nchip
        break
    end
    
    if cnt == 2
        back = 1;
    end
    
    if cnt == 3
%         disp('Cannot devide')
%         fprintf('\n')
        break
    end


end

%% Post processing
z_final_result.cores = [];
numm = 1;

for i = 1:length(com_info)
    if isempty(com_info)
        continue
    else
        z_final_result(numm).cores = com_info(i).cores;
        numm = numm + 1;
    end
end

iter = phase - 2;
pos_final = [];

% make struct including all node's position
while 1
    field_name = ['Iter_' int2str(iter)];
    for i = 1:length(z_final_result)
        cores = [];
        if isempty(z_final_result(i).cores)
            continue
        else
            pos_final = [pos_final i];
            cores = [cores com_all_result(z_final_result(i).cores).(field_name)];
            z_final_result(i).cores = sort(cores);
        end
    end

    iter = iter - 1;
    if iter == 0
        z_final_result = z_final_result(unique(pos_final));
        for i = 1:length(z_final_result)
            stst = ['     "Node_' int2str(pos_final(i)) '" Cluster has ' int2str(length(z_final_result(i).cores)) ' members'];
            disp(stst)
        end
        break
    end
end
fprintf('\n')

node_num = [];
for i = 1:length(z_final)
    node_num = [node_num z_final(i).source z_final(i).dest];
end
node_num = unique(node_num);

node_num_list = perms(node_num);
para_vec = [];
net_chip_cell = cell(length(node_num_list));

for ii = 1:length(node_num_list)
    node_num = node_num_list(i,:);
    net_chip = zeros(length(node_num));
    for i = 1:length(z_final)
        row = find(ismember(node_num,z_final(i).source)==1);
        col = find(ismember(node_num,z_final(i).dest)==1);
        net_chip(row,col) = z_final(i).weight;
    end

    para = 0;
    for i = 1:length(net_chip)
        para = para + net_chip(i,length(net_chip)-i+1);
    end
    para_vec = [para_vec para];
    net_chip_cell{ii} = net_chip;
end
[mini,pos] = min(para_vec);
net_chip = net_chip_cell{pos};

%% When cnt == 3
if cnt == 3
    many = length(z_final_result) - Nchip;
    extra_vec = [];
    for i = 1:many
        extra_vec = [extra_vec z_final_result(Nchip + i).cores];
    end

    z_final_result(Nchip+1:end).cores = [];

    for i = 1:Nchip
        mod_vec = z_final_result(Nchip - (i-1)).cores;
        siz = Ncore - length(mod_vec);

        if siz > length(extra_vec)
            siz = length(extra_vec);
        end

        add = extra_vec(1:siz);
        mod_vec = [mod_vec add];
        extra_vec(1:siz) = [];
        z_final_result(Nchip - (i-1)).cores = mod_vec;
        if isempty(extra_vec)
            break
        end
    end
    
    % Repeat compute all parameter ( net_chip / z_final )
    chip1 = z_final_result(1).cores;
    chip2 = z_final_result(2).cores;
    chip3 = z_final_result(3).cores;
    chip4 = z_final_result(4).cores;
    
    net_chip = zeros(Nchip);
    for i = 1:length(node_org)
        if ismember(i,chip1)
            node_org(i).after_FU = 1;
        elseif ismember(i,chip2)
            node_org(i).after_FU = 2;
        elseif ismember(i,chip3)
            node_org(i).after_FU = 3;
        elseif ismember(i,chip4)
            node_org(i).after_FU = 4;
        end
    end
    
    for i = 1:length(node_org)
        for j = 1:length(node_org(i).all_cores)
            srcc = node_org(i).after_FU;
            dett = node_org(node_org(i).all_cores(j)).after_FU;
            if srcc ~= dett
                net_chip(srcc,dett) = net_chip(srcc,dett) + node_org(i).all_packets(j);
            end
        end
    end
    
    z_final = [];
    cccc = 1;
    disp('==> Traffic Packet info:')
    for i = 1:Nchip
        for j = 1:Nchip
            if net_chip(i,j) ~= 0
                z_final(cccc).source = i;
                z_final(cccc).dest = j;
                z_final(cccc).weight = net_chip(i,j);
                san_1 = ['     "Chip_' int2str(i) '"and "Chip_' int2str(j) '" have connection: "' int2str(net_chip(i,j)) ' packets"'];
                disp(san_1)
            end
        end
    end
    
    fprintf('\n')
    san_2 = ['     Final network has ' int2str(sum(sum(net_chip))) ' edge weight !'];
    disp(san_2)
    fprintf('\n')
    
    for i = 1:Nchip
        san_3 = ['     "Chip_' int2str(i) ' Cluster has ' int2str(length(z_final_result(i).cores)) ' members'];
        disp(san_3)
    end
    
end

save 4_chip_after.mat net_chip
save z_final_result.mat z_final_result

Plot_result
top % draw plot
%% For doing SA

load('z_final_result.mat')

new_num_line = zeros(1,size(LUTPost,2));
new_LUTPost = zeros(size(LUTPost));

for i = 1:length(z_final_result)
    st_line = i+156*(i-1);
    new_num_line(st_line:st_line+length(z_final_result(i).cores)-1) = z_final_result(i).cores;
    new_LUTPost(:,st_line:st_line+length(z_final_result(i).cores)-1) = LUTPost(:,z_final_result(i).cores);
end

for i = 1:size(new_LUTPost,1)
    for j = 1:size(new_LUTPost,2)
        if new_LUTPost(i,j) ~= 0
            
            new_num = find(new_num_line == new_LUTPost(i,j));
            new_LUTPost(i,j) = new_num;
        end
    end
end

backup_new_LUTPost = new_LUTPost;
save router_sim_mc/backup_new_LUTPost.mat backup_new_LUTPost

for i = 1:size(new_LUTPost,1)
    for j = 1:size(new_LUTPost,2)
        if new_LUTPost(i,j) ~= 0
            new_LUTPost(i,j) = new_LUTPost(i,j) - 156*floor((j+1)/156);
            if new_LUTPost(i,j) > 156 || new_LUTPost(i,j) < 0
                new_LUTPost(i,j) = 0;
            end
        end
    end
end


for i = 1:Nchip
    LUTPost = new_LUTPost(:,(i-1) * Ncore + 1:i*Ncore);
    lutfilename = [int2str(Nchip) '_chip_after_chip' num2str(i) '.mat'];
    save(lutfilename,'LUTPost');
%     eval(['save ' int2str(Nchip) '_chip_after_chip' num2str(i) '.mat LUTPost -ASCII'])
end
