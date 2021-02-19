global failed_node_vec


%% free failed node mapping
if isempty(failed_node_vec)
    disp('Thereare not failed nodes...')
else
    string1 = [int2str(failed_node_vec) ' are failded'];
    disp(string1)
end

node_bb = node;

del_vec = [];
con_with_failed = packet_info;
for j=1:length(packet_info)
    if isempty(failed_node_vec)
        con_with_failed = [];
    else
        for i = 1:length(failed_node_vec)
            x_failed = node(failed_node_vec(i)).x;
            y_failed = node(failed_node_vec(i)).y;
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
string0 = ['==> There are ' int2str(length(con_with_failed)) ' connections through failed node.'];
disp(string0)
fprintf('\n')

% Start Delete ----------------------------------------------------------------------------------------------------------------------
while ~isempty(con_with_failed)        % Delete ALL connections including failed_node
    ent_vec = linspace(1,all_node_num,all_node_num);
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
        if Ablee
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
                        x_failed = node(failed_node_vec(i)).x;
                        y_failed = node(failed_node_vec(i)).y;
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
%         disp(string0)
        % ==================================================================
        if isempty(con_with_failed)
            disp('<< All connections including failed node already are deleted >>')
            break
        end
        
    end
end

% figure()
% axis ij;
% title('After Opt');
% netplot(node,nnode);

% test
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























