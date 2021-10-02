function node = Copy_of_node_switch(node,nnode)
    %% 随机置换两个不同core的坐标
    
    global X_DIM;
    global Turn_constraint;     % 转弯限制开关，避免死锁；1为执行转弯限制，0为不执行转弯限制
    global Dead_lock_circle_constraint; % 死锁环路约束；1为检测死锁环路并避免，0为不检测
    global cycle_flag;          % 路由成环标志位；1为有环，0为无环
    global adj_mat;             % 全局邻接表
    global failed_node_vec
    global detected
    global numm
    
    for i=1:1:nnode             % 节点转换，最新节点序号
        node(i).covert = node(i).x + node(i).y * X_DIM + 1;
    end
    
    while 1
        flag1 = 1;              % 清空所有标志位
        flag2 = 1;
        flag3 = 1;
        flag4 = 1;
        cycle_flag1 = 1;
        cycle_flag2 = 1;
        failed_flag = 1;
        
        adj_mat = zeros(nnode);           % 清空邻接表
        for i = 1:nnode                         % 更新邻接表
            j = node(i).covert;
            old_to = node(i).connected_to_cores;
            for k = 1:node(i).connected_to_cores_num
                new_to(k) = node(old_to(k)).covert;
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
        
        keepgoing = 1;
        node_co = node;
        node_co(node_to).x = node(node_from).x;
        node_co(node_to).y = node(node_from).y;
        node_co(node_from).x = node(node_to).x;
        node_co(node_from).y = node(node_to).y;
        
        if Dead_lock_circle_constraint          % 执行死锁环路约束，使所有多播节点无环路
            nodenode = node; % back up parameters
            node = node_co;
            numm_bk = numm;
            DETECT;
            if length(numm_bk) >= length(numm)
                keepgoing = 1;
            else
                keepgoing = 0;
                node = nodenode;
                numm = numm_bk;
            end   
        end

        
        if Turn_constraint                  % 执行转弯约束，限制转弯5、12
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
        
        if ~isempty(failed_node_vec)
            failed_flag = check_including_failed(node_from,node_to,node);            
        end
                    
        if (flag1 && flag2 && flag3 && flag4 && keepgoing && failed_flag)
            x_from = node(node_from).x;     % 若符合以上约束，进行节点交换
            y_from = node(node_from).y;

            x_to = node(node_to).x;
            y_to = node(node_to).y;

            node(node_from).x = x_to;
            node(node_from).y = y_to;

            node(node_to).x = x_from;
            node(node_to).y = y_from;
            break;
        else
            continue;
        end
    end


    
    adj_mat = zeros(nnode,nnode);   % 清空邻接表
end