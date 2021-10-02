dan_node = [];

node_switched = zeros(1,length(node));
for i = 1:length(node) % verify whether switched node is multicast node + && length(node(i).connected_from_cores) > 1
    if ~isempty(node(i).multi_to_cores) 
        node_switched(i) = 1;
    end
end

for i = 1:length(node) % check the directions of connected_to_cores and multi_to_cores
    if node_switched(i)

        veri_x = node(i).x;
        veri_y = node(i).y;

        vec_con = node(i).connected_to_cores;
        vec_con(vec_con == node(i).multi_to_cores) = [];
        dir_con = zeros(1,length(vec_con));
        for j = 1:length(vec_con) % 1-left // 2-right // 3-up // 4-down
            vec_con_x = node(vec_con(j)).x;
            vec_con_y = node(vec_con(j)).y;
            if veri_x > vec_con_x
                dir_con(j) = 1;
            elseif veri_x < vec_con_x
                dir_con(j) = 2;
            elseif veri_x == vec_con_x
                if veri_y > vec_con_y
                    dir_con(j) = 3;
                elseif veri_y < vec_con_y
                    dir_con(j) = 4;
                elseif veri_y == vec_con_y
                    disp('fuck!!!!')
                end
            end
        end

        vec_mul_num = node(i).multi_to_cores;
        vec_mul_x = node(vec_mul_num).x;
        vec_mul_y = node(vec_mul_num).y;
        dir_mul = 0;
        if veri_x > vec_mul_x
            dir_mul = 1;
        elseif veri_x < vec_mul_x
            dir_mul = 2;
        elseif veri_x == vec_mul_x
            if veri_y > vec_mul_y
                dir_mul = 3;
            elseif veri_y < vec_mul_y
                dir_mul = 4;
            elseif veri_y == vec_con_y
                disp('fuck!!!!')
            end
        end
        if ismember(dir_mul,dir_con)
%             keepgoing = 0;
            dan_node = [dan_node i];
        end
    end
end
