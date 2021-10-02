%% Detect the direction connection_to and multi_dest
function Able = detect_direction(node,node1,node2)
    global detected
    
%     detected = [detected node1 node2];
%     detected = unique(detected);
    Able = 1;
%     node_switched = [node1 node2];
    for i = detected
        if ~isempty(node(i).multi_to_cores)
            for j = node(i).connected_to_cores
                node_x = node(i).x;
                node_y = node(i).y;
                xx = [node(j).x node(node(i).multi_to_cores).x];
                yy = [node(j).y node(node(i).multi_to_cores).y];
                
                dir = zeros(1,2); % 1-node_to // 2-node_mul
                
                for k = 1:length(dir)
                    if node_x < xx(k) % right-1
                        dir(k) = 1;
                    elseif node_x > xx(k) % left-2
                        dir(k) = 2;
                    elseif node_x == xx(k)
                        if node_y > yy(k) % up-3
                            dir(k) = 3;
                        elseif node_y < yy(k) % down-4
                            dir(k) = 4;
                        end
                    end
                end
                
                if dir(1) == dir(2)
                    Able = 0;
                    break
                end
            end
        end
        if ~Able
            break
        end
    end
end