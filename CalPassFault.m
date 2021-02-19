%% Calculate the number of connections passing failed node
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
