global PATH_LOAD
global adj_mat
global X_DIM
global Dead_lock_circle_constraint

if ~isempty(failed_node_vec)
    disp_san = ['"' int2str(failed_node_num) '" core(s) is(are) failed. Failed node: ' int2str(failed_node_vec)];
    disp(disp_san)
end

netlist; % BUILD!!!!

node_bb = node;

if length(used_failed)>length(unused_non_failed)
    error('===> There are too many failed cores. Stop SA mapping')
end

%% Initialize 邻接表 & setting parameters of algorithm
adj_mat = zeros(nnode);
init_temperature = 0.01;
% 1*nnode
final_temp = 0.01;
iter = 50;
temperature = init_temperature;

% figure()
% axis ij;
% title('初始布局');
% netplot(node,nnode);
% % saveas(1, '初始布局.jpg');

%% Preprocessing
cost_init = compute_cost(node,nnode);   % Compute Initial temperature
path_init = PATH_LOAD;                  % Path weight of first state

l = 1;                                  % number of iterate
cost(l) = cost_init;                    % the list of cost of each iterate
path_load(l) = max(max(PATH_LOAD));     % the list of path_load of each iterate

%% Preprocessing before SA, avoiding << Deleting all connections including failed node>>
% ================================================================================
del_vec = [];
con_with_failed = packet_info;
% find the connections with passing failed nodes'
for j = 1:length(packet_info)
    if isempty(failed_node_vec)
        con_with_failed = [];
    else
        for i = 1:length(failed_node_vec)
            x_failed = mod(failed_node_vec(i)-1,X_DIM);
            y_failed = floor((failed_node_vec(i)-1)/X_DIM);
            x_src = packet_info(j).src_x;
            y_src = packet_info(j).src_y;
            x_dest = packet_info(j).dest_x;
            y_dest = packet_info(j).dest_y;
            if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)...
                    ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                    ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                    ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed) 
                break
            end
            if i == length(failed_node_vec)
                del_vec = [del_vec j];
            end
        end
    end
end
con_with_failed(del_vec) = []; 
str_num_con  = ['==> There are ' int2str(length(con_with_failed)) ' connections through failed node.'];
disp(str_num_con);
fprintf('\n')
% ================================================================================

while ~isempty(con_with_failed)        % Delete ALL connections including failed_node
    ent_vec = linspace(1,nnode,nnode);
    for i = 1:length(failed_node_vec)
        ent_vec(ent_vec == failed_node_vec(i)) = [];
    end
    
    while 1
        randg = randperm(length(con_with_failed));
        randg = randg(1);
        node_from = con_with_failed(randg).source;
        node_from2 = con_with_failed(randg).dest;
        
        ent_copy = ent_vec;
        del = [];
        for i = 1:length(ent_copy)
            if ent_copy(i) == node_from || ent_copy(i) == node_from2
                del = [del i];
            end
        end
        ent_copy(del) = []; % delete node_from1,2 from ent_vec
        
        random_pos = randperm(length(ent_copy));
        node_to = ent_copy(random_pos(1));   % change with src of node_from
        node_to2 = ent_copy(random_pos(2));  % change with dest of node_from
        
        node_copy = node;
        node_copy1 = node;
        node_co = node;
        
        % ======== deadlock cycle1 (node_to, node_from) ==========
        node_co(node_from2).x = node(node_to2).x;
        node_co(node_from2).y = node(node_to2).y;
        node_co(node_to2).x = node(node_from2).x;
        node_co(node_to2).y = node(node_from2).y; 
        
        node_co(node_from).x = node(node_to).x;
        node_co(node_from).y = node(node_to).y;
        node_co(node_to).x = node(node_from).x;
        node_co(node_to).y = node(node_from).y;

        % =============================================
        
        Able = 0;
        node_copy(node_from2).x = node(node_to2).x;
        node_copy(node_from2).y = node(node_to2).y;
        node_copy(node_to2).x = node(node_from2).x;
        node_copy(node_to2).y = node(node_from2).y; 

        node_copy(node_from).connected_to_cores = node_from2;
        node_copy(node_from).connected_to_cores_num = 1;

        Able = check_including_failed(node_to,node_from,node_copy);

        Ablee = 0;
        if Able   
            node_copy1(node_from).x = node(node_to).x;
            node_copy1(node_from).y = node(node_to).y;
            node_copy1(node_to).x = node(node_from).x;
            node_copy1(node_to).y = node(node_from).y; 
            
            node_copy1(node_from2).connected_from_cores = node_from;
            node_copy1(node_from2).connected_from_cores_num = 1;
            
            Ablee = check_including_failed(node_to2,node_from2,node_copy1);            

            if Ablee
                node = node_co;
                san = ['Delete a connection: ' int2str(con_with_failed(randg).source) ' to ' int2str(con_with_failed(randg).dest)];
                disp(san)
                con_with_failed(randg) = [];
            end
        end
        
        % ==================================================================
        if Ablee == 1
            packet_info_copy = packet_info;
            for i = 1:length(packet_info)
                packet_info(i).src_x = node(packet_info_copy(i).source).x;
                packet_info(i).src_y = node(packet_info_copy(i).source).y;
                packet_info(i).dest_x = node(packet_info_copy(i).dest).x;
                packet_info(i).dest_y = node(packet_info_copy(i).dest).y;
            end
            
            con_with_failed = packet_info;
            del_vec = [];
            for j = 1:length(packet_info)
                if isempty(failed_node_vec)
                    con_with_failed = [];
                else
                    for i = 1:length(failed_node_vec)
                        x_failed = mod(failed_node_vec(i)-1,X_DIM);
                        y_failed = floor((failed_node_vec(i)-1)/X_DIM);
                        x_src = packet_info(j).src_x;
                        y_src = packet_info(j).src_y;
                        x_dest = packet_info(j).dest_x;
                        y_dest = packet_info(j).dest_y;
                        if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)...
                                ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                                ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                                ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed) 
                            break
                        end
                        if i == length(failed_node_vec)
                            del_vec = [del_vec j];
                        end
                    end
                end
            end

            con_with_failed(del_vec) = []; 
        end
        % ==================================================================
        
        if isempty(con_with_failed)
            disp('<< All connections including failed node already are deleted >>')
            break
        end
        
    end
end

cost_failed = compute_cost(node,nnode);
l = l + 1;
cost(l) = cost_failed;


% Untitled;
% xy;
% 
% error()

% figure()
% axis ij;
% title('After Opt');
% netplot(node,nnode);

%% Try

save infodetect.mat node multi_vec packet_info
tic
nummpass = DETECT(node,multi_vec,packet_info);
str_numm = [' nummpass = ' int2str(length(nummpass))];
disp(str_numm)
toc

lastt = 0;

ent_vec = linspace(1,nnode,nnode);
for i = 1:length(failed_node_vec)
    ent_vec(ent_vec == failed_node_vec(i)) = [];
end

while ~isempty(nummpass) && Dead_lock_circle_constraint
    numchange = 1;
    while numchange == 1
        numchange = randperm(floor(length(node)/2));
        numchange = numchange(1);
    end
    random_pos = randperm(length(ent_vec));
    idx = random_pos(1:numchange);
    nodechange = ent_vec(idx);
    
    node_sa = node;
    for i = 1:length(nodechange)
        curno = nodechange(i);
        if i == length(nodechange)
            nextno = nodechange(1);
        else
            nextno = nodechange(i+1);
        end
        node(curno).x = node_sa(nextno).x;
        node(curno).y = node_sa(nextno).y;
    end
    failed_flag = 1;
    Able = 1;
    
    for i = 1:length(node)
        for j = node(i).connected_to_cores
            for k = failed_node_vec
                x_src = node(i).x;
                y_src = node(i).y;
                x_dest = node(j).x;
                y_dest = node(j).y;
                x_failed = node(k).x;
                y_failed = node(k).y;

                if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)... % node ~ connected_to_cores
                        ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                        ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                        ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed)                            
                    Able = 0;
                    break
                end
            end
        end
        if Able == 0
            break
        end
    end

    if Able
        nummpass_bf = nummpass;
        nummpass = DETECT(node,multi_vec,packet_info); % Modify here~~~~ (free deadlock constraint)
        
        if length(nummpass_bf) > length(nummpass)
            str_numm = [' nummpass = ' int2str(length(nummpass))];
            disp(str_numm)
            lastt = 0;
        else
            lastt = lastt + 1;
            node = node_sa;
            nummpass = nummpass_bf;
        end
    else
        lastt = lastt + 1;
        node = node_sa;
    end

end

node_covert = [];
for i = 1:length(node)
    node(i).covert = node(i).x + node(i).y * X_DIM + 1;
end
node_covert = [node.covert];
if length(node_covert) ~= length(unique(node_covert))
    error('what')
end

nummpass_final = DETECT(node,multi_vec,packet_info);

%% testtt
connected_to_cores = [];
connected_to_cores_after = [];
connected_from_cores = [];
connected_from_cores_after = [];


connected_to_cores = [node_bb.connected_to_cores];
connected_to_cores_after = [node.connected_to_cores];
connected_from_cores = [node_bb.connected_from_cores];
connected_from_cores_after = [node.connected_from_cores];


if isequal(connected_to_cores,connected_to_cores_after) && isequal(connected_from_cores,connected_from_cores_after)
    disp('!!!!RIGHT!!!!')
else
    disp('ERROR!!!!')
end

packet_info_copy = packet_info;
for i = 1:length(packet_info_copy)
    packet_info_copy(i).src_x = node(packet_info_copy(i).source).x;
    packet_info_copy(i).src_y = node(packet_info_copy(i).source).y;
    packet_info_copy(i).dest_x = node(packet_info_copy(i).dest).x;
    packet_info_copy(i).dest_y = node(packet_info_copy(i).dest).y;
end

check = 0;
for j = 1:length(failed_node_vec)
    x_failed = node(failed_node_vec(j)).x;
    y_failed = node(failed_node_vec(j)).y;
    for i = 1:length(packet_info_copy)
        x_src = packet_info_copy(i).src_x;
        y_src = packet_info_copy(i).src_y;
        x_dest = packet_info_copy(i).dest_x;
        y_dest = packet_info_copy(i).dest_y;
        if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)... 
                ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed)
            check = check + 1;
        end
    end
end

sa = ['==> Check the number of connections including failed node: "' int2str(check) '"'];
disp(sa)

Untitled;
xy;


error()

%% REAL SA algorithm~~~~ + Deadlock constraints & failed constraint
% DETECT;
% disp(length(numm))
% detected = [];

while temperature > final_temp
    for i = 1:iter
        cost_old = compute_cost(node,nnode);
        cost_temp = cost_old; 
        path_temp = max(max(PATH_LOAD));
        
        new_node = node_switch(node,nnode,multi_vec,packet_info);
        cost_new = compute_cost(new_node,nnode); 
        
        delta_e = cost_new - cost_old;
        
        if delta_e <= 0
            node = new_node;                        
            cost_temp = cost_new;
            path_temp = max(max(PATH_LOAD));
        else
            if exp(-delta_e / temperature) > rand()
                node = new_node;
                cost_temp = cost_new;
                path_temp = max(max(PATH_LOAD));
            end
        end
    end
    
    disp(['Temperature = ' num2str(temperature)]);
    
    l = l + 1;
    cost(l) = cost_temp;
    path_load(l) = path_temp;
    
    temperature = temperature * 0.9;
end

cost_final = compute_cost(node,nnode);
path_final = PATH_LOAD;

%% After SA algorithm, Evaluate the performance

for i = 1:length(node)
    node(i).covert = node(i).x + node(i).y * X_DIM + 1;
end

node_covert = [node.covert];
if length(node_covert) ~= length(unique(node_covert))
    error('PROBLEM!!!!!')
end

if Nchip == 1
    save node_covert.mat node_covert
    load('node_covert.mat')

    copy_LUT = LUTPost;

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
    filesaname = ['router_sim_mc/node_covert_chip' num2str(iterate) '.mat'];
    save(filesaname,'LUTPost');
end
