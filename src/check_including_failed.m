function [Able,node] = check_including_failed(node_src,node_dest,node)

%% Can I switch the positions of node_src and node_dest?
global X_DIM
global nnode
global failed_node_vec


for i = 1:nnode
    node(i).covert = node(i).x + node(i).y * X_DIM + 1;
end

Able = 1;

for i = 1:length(failed_node_vec)
    x_failed = mod((failed_node_vec(i)-1),X_DIM);
    y_failed = floor((failed_node_vec(i)-1)/X_DIM);
    for j = 1:2 % j==1 --> node_src, j==2 --> node_dest
        if j == 1
            changed = node_dest;
            connections_to = node(node_src).connected_to_cores;
            connections_from = node(node_src).connected_from_cores;
        else
            changed = node_src;
            connections_to = node(node_dest).connected_to_cores;
            connections_from = node(node_dest).connected_from_cores;
        end
        
        for k = 1:length(connections_to) % connected_to_cores
            x_src = node(changed).x;
            y_src = node(changed).y;

            x_dest = node(connections_to(k)).x;
            y_dest = node(connections_to(k)).y;

            if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)... % node ~ connected_to_cores
                    ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                    ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                    ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed)                            
                Able = 0;
                break
            end
        end
        
        if Able == 0
            break
        end
        
        for k = 1:length(connections_from) % connected_from_cores

            x_src = node(connections_from(k)).x;
            y_src = node(connections_from(k)).y;
            
            x_dest = node(changed).x;
            y_dest = node(changed).y;

            if (x_dest==x_failed && y_dest>y_failed && y_src<=y_failed)... % node ~ connected_from_cores
                    ||(x_dest==x_failed && y_dest<y_failed && y_src>=y_failed)...
                    ||(y_src==y_failed && x_src<x_failed && x_dest>=x_failed)...
                    ||(y_src==y_failed && x_src>x_failed && x_dest<=x_failed)                            
                Able = 0;
                break
            end
        end
        
        if Able == 0
            break
        end
        
    end
    
    if Able == 0
        break
    end
    
end

if Able
    copy_src_x = node(node_src).x;
    copy_src_y = node(node_src).y;
    copy_src_covert = node(node_src).covert;
    
    node(node_src).x = node(node_dest).x;
    node(node_src).y = node(node_dest).y;
    node(node_src).covert = node(node_dest).covert;
    
    node(node_dest).x = copy_src_x;
    node(node_dest).y = copy_src_y;
    node(node_dest).covert = copy_src_covert;
end

end

