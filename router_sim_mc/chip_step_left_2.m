function out = chip_step_left_2(curr_chip,j,NODE_NUM,M)
%description: paket move towards right one step
global pack;
global node;
global chip;
global inuse;
global net;
global busy;

temp_node = (curr_chip-1)*NODE_NUM + pack(j).src_x + pack(j).src_y * M + 1;
last_node = curr_chip*NODE_NUM + 0 + pack(j).src_y * M + 1;
out = 0;

if node(temp_node).right_full == 0 && inuse(last_node,temp_node) == 0
    busy = 1;
    pack(j).move = 1;
    if pack(j).cross_time < 10
        pack(j).cross_time = pack(j).cross_time + 1;
    else
        node(temp_node).right = node(temp_node).right + 1;
        node(temp_node).right_pack = [node(temp_node).right_pack j];
        pack(j).cross_time = 0;

        switch pack(j).buff_pos
            case 6
                chip(curr_chip).left = chip(curr_chip).left -1;
                chip(curr_chip).left_out = chip(curr_chip).left_out + 1;
            case 7
                chip(curr_chip).right = chip(curr_chip).right -1;
                chip(curr_chip).right_out = chip(curr_chip).right_out + 1;
            case 8
                chip(curr_chip).up = chip(curr_chip).up -1;
                chip(curr_chip).up_out = chip(curr_chip).up_out + 1;
            case 9
                chip(curr_chip).down = chip(curr_chip).down -1;
                chip(curr_chip).down_out = chip(curr_chip).down_out + 1;
        end
        pack(j).buff_pos = 2;
        inuse(last_node,temp_node) = 1;
        net(last_node,temp_node) = net(last_node,temp_node) +1;   
        out = 1;

        pack(j).last_node = last_node;   %update pack(j).last_node
    end
end

end
