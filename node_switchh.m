function node = node_switchh(node,nnode)
    %% ����û�������ͬcore������
    
    global X_DIM;
    global Turn_constraint;     % ת�����ƿ��أ�����������1Ϊִ��ת�����ƣ�0Ϊ��ִ��ת������
    global Dead_lock_circle_constraint; % ������·Լ����1Ϊ���������·�����⣬0Ϊ�����
    global cycle_flag;          % ·�ɳɻ���־λ��1Ϊ�л���0Ϊ�޻�
    global adj_mat;             % ȫ���ڽӱ�
    
    for i=1:1:nnode             % �ڵ�ת�������½ڵ����
        node(i).node_covert = node(i).x + node(i).y * X_DIM + 1;
    end
    
    while 1
        flag1 = 1;              % ������б�־λ
        flag2 = 1;
        flag3 = 1;
        flag4 = 1;
        cycle_flag1 = 1;
        cycle_flag2 = 1;
        
        adj_mat = zeros(nnode,nnode);           % ����ڽӱ�
        for i = 1:nnode                         % �����ڽӱ�
            j = node(i).node_covert;
            old_to = node(i).connected_to_cores;
            for k = 1:node(i).connected_to_cores_num
                new_to(k) = node(old_to(k)).node_covert;
                adj_mat(j,new_to(k)) = 1;
            end
        end
        
        node_from = floor(1 + nnode * rand());  % ���ѡ��ԭʼcore�����
        node_to = floor(1 + nnode * rand());    % ���ѡ���µ�core�����

        while node_from == node_to              % ��ֹ����core��ͬһcore
        node_from = floor(1 + nnode * rand());
        node_to = floor(1 + nnode * rand());
        end
        
        
        if Dead_lock_circle_constraint          % ִ��������·Լ����ʹ���жಥ�ڵ��޻�·
            temp_node_to_covert = node(node_to).node_covert;
            temp_node_from_covert = node(node_from).node_covert;
            
            j1 = temp_node_to_covert;
            adj_mat(j1,:) = 0;
            temp_old_to_cores1 = node(temp_node_from_covert).connected_to_cores;
            for k1 = 1:node(temp_node_from_covert).connected_to_cores_num
                temp_new_to_cores1(k1) = node(temp_old_to_cores1(k1)).node_covert;
                adj_mat(j1,temp_new_to_cores1(k1)) = 1;       % ���ڵ㽻�������µ��ڽӱ�
            end
            
            j2 = temp_node_from_covert;
            adj_mat(j2,:) = 0;
            temp_old_to_cores2 = node(temp_node_to_covert).connected_to_cores;
            for k2 = 1:node(temp_node_to_covert).connected_to_cores_num
                temp_new_to_cores2(k2) = node(temp_old_to_cores2(k2)).node_covert;
                adj_mat(j2,temp_new_to_cores2(k2)) = 1;       % ���ڵ㽻�������µ��ڽӱ�
            end
            
            if node(node_to).multi_to_cores_num > 0
                dfs(adj_mat,node(node_to).multi_to_cores);
                if cycle_flag
                    cycle_flag1 = 0;
                end
            end
            
            if node(node_from).multi_to_cores_num > 0
                dfs(adj_mat,node(node_from).multi_to_cores);
                if cycle_flag
                    cycle_flag2 = 0;
                end
            end
        end
        
%         if cycle_flag1 == 0 || cycle_flag2 == 0
%             disp('hi')
%         end
        
        if Turn_constraint                  % ִ��ת��Լ��������ת��5��12
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
        
        if (flag1 && flag2 && flag3 && flag4 && cycle_flag1 && cycle_flag2)
            break;
        else
            continue;
        end
    end

    x_from = node(node_from).x;     % ����������Լ�������нڵ㽻��
    y_from = node(node_from).y;
    
    x_to = node(node_to).x;
    y_to = node(node_to).y;

    node(node_from).x = x_to;
    node(node_from).y = y_to;

    node(node_to).x = x_from;
    node(node_to).y = y_from;
    
    adj_mat = zeros(nnode,nnode);   % ����ڽӱ�
end