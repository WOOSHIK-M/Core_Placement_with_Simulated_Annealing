function cost=compute_cost(node,nnode)
    %% 计算当前布局的cost
global PATH_LOAD;

cost=0;
compute_path;
for i=1:nnode
    for j=1:node(i).connected_to_cores_num
        delta_x = node(node(i).connected_to_cores(j)).x - node(i).x;
        delta_y = node(node(i).connected_to_cores(j)).y - node(i).y;
        delta_c = (abs(delta_x) + abs(delta_y)) * node(i).connected_to_packet_num(j);
        cost = cost + delta_c + max(max(PATH_LOAD));
    end
end
end