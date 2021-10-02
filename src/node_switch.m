function node = node_switch(node,nnode,multi_vec,packet_info)
%% node_switch    
    global X_DIM;
    global Turn_constraint;
    global Dead_lock_circle_constraint;
    global adj_mat;
    global failed_node_vec
    
    for i=1:1:nnode
        node(i).node_covert = node(i).x + node(i).y * X_DIM + 1;
    end
    
    while 1
        flag1 = 1;
        flag2 = 1;
        flag3 = 1;
        flag4 = 1;
        cycle_flag1 = 1;
        failed_flag = 1;
        
        adj_mat = zeros(nnode,nnode);
        for i = 1:nnode
            j = node(i).node_covert;
            old_to = node(i).connected_to_cores;
            for k = 1:node(i).connected_to_cores_num
                new_to(k) = node(old_to(k)).node_covert;
                adj_mat(j,new_to(k)) = 1;
            end
        end
        
        ent_vec = linspace(1,nnode,nnode);
        for i = 1:length(failed_node_vec)
            ent_vec(ent_vec == failed_node_vec(i)) = [];
        end
        
        randd = randperm(length(ent_vec));
        node_from = ent_vec(randd(1));
        node_to = ent_vec(randd(2));
        
        if Turn_constraint
            x_src_to = node(node_to).x;
            y_src_to = node(node_to).y;
            x_src_from = node(node_from).x;
            y_src_from = node(node_from).y;

            for i = 1:node(node_to).connected_to_cores_num
                x_des_to(i) = node(node(node_to).connected_to_cores(i)).x;
                y_des_to(i) = node(node(node_to).connected_to_cores(i)).y;
                delta_x_to(i) = x_des_to(i) - x_src_from;
                delta_y_to(i) = y_des_to(i) - y_src_from;
                if ((~(delta_x_to(i) < 0 && delta_y_to(i) < 0)) && (~(delta_x_to(i) > 0 && delta_y_to(i) < 0)))
                    if i == node(node_to).connected_to_cores_num
                        flag1 = 1;
                        break;
                    else
                        continue;
                    end
                else
                    flag1 = 0;
                    break;
                end
            end

            for j = 1:node(node_from).connected_to_cores_num
                x_des_from(j) = node(node(node_from).connected_to_cores(j)).x;
                y_des_from(j) = node(node(node_from).connected_to_cores(j)).y;
                delta_x_from(j) = x_des_from(j) - x_src_to;
                delta_y_from(j) = y_des_from(j) - y_src_to;
                if ((~(delta_x_from(j) < 0 && delta_y_from(j) < 0)) && (~(delta_x_from(j) > 0 && delta_y_from(j) < 0)))
                    if j == node(node_from).connected_to_cores_num
                        flag2 = 1;
                        break;
                    else
                        continue;
                    end
                else
                    flag2 = 0;
                    break;
                end
            end

            for i = 1:node(node_to).connected_from_cores_num
                x_des_to_2(i) = node(node(node_to).connected_from_cores(i)).x;
                y_des_to_2(i) = node(node(node_to).connected_from_cores(i)).y;
                delta_x_to_2(i) = x_src_from - x_des_to_2(i);
                delta_y_to_2(i) = y_src_from - y_des_to_2(i);
                if ((~(delta_x_to_2(i) < 0 && delta_y_to_2(i) < 0)) && (~(delta_x_to_2(i) > 0 && delta_y_to_2(i) < 0)))
                    if i == node(node_to).connected_from_cores_num
                        flag3 = 1;
                        break;
                    else
                        continue;
                    end
                else
                    flag3 = 0;
                    break;
                end
            end

            for j = 1:node(node_from).connected_from_cores_num
                x_des_from_2(j) = node(node(node_from).connected_from_cores(j)).x;
                y_des_from_2(j) = node(node(node_from).connected_from_cores(j)).y;
                delta_x_from_2(j) = x_src_to - x_des_from_2(j);
                delta_y_from_2(j) = y_src_to - y_des_from_2(j);
                if ((~(delta_x_from_2(j) < 0 && delta_y_from_2(j) < 0)) && (~(delta_x_from_2(j) > 0 && delta_y_from_2(j) < 0)))
                    if j == node(node_from).connected_from_cores_num
                        flag4 = 1;
                        break;
                    else
                        continue;
                    end
                else
                    flag4 = 0;
                    break;
                end
            end
        end
        
        if isempty(failed_node_vec) == 0
            failed_flag = check_including_failed(node_from,node_to,node);            
        end
        
        if Dead_lock_circle_constraint && failed_flag
            node_co = node;
            node_co(node_from).x = node(node_to).x;
            node_co(node_from).y = node(node_to).y;
            node_co(node_to).x = node(node_from).x;
            node_co(node_to).x = node(node_from).y;
            
            nummpass = DETECT(node_co,multi_vec,packet_info);
             if isempty(nummpass)
                cycle_flag1 = 1;
            else
                cycle_flag1 = 0;
            end
        end

        if (flag1 && flag2 && flag3 && flag4 && cycle_flag1 && failed_flag)
            break;
        else
            continue;
        end
    end

    x_from = node(node_from).x;
    y_from = node(node_from).y;
    
    x_to = node(node_to).x;
    y_to = node(node_to).y;

    node(node_from).x = x_to;
    node(node_from).y = y_to;

    node(node_to).x = x_from;
    node(node_to).y = y_from;
    
    adj_mat = zeros(nnode,nnode);
end