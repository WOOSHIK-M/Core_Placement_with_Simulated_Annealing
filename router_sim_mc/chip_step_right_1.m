function out = chip_step_right_1(curr_node,j)
%description: paket move towards right one step
global pack;
global node;
global chip;
global inuse_chip;
global net_chip;

curr_chip = pack(j).src_chip;
temp_chip = curr_chip + 1;
out = 0;

if chip(temp_chip).left_full == 0 && inuse_chip(curr_chip,temp_chip) == 0
    pack(j).move = 1;
    pack(j).src_x = 0;
    pack(j).coor_x = pack(j).coor_x + 1;
    pack(j).src_chip_x = pack(j).src_chip_x + 1;
    pack(j).src_chip = temp_chip;

    chip(temp_chip).left = chip(temp_chip).left + 1;
    chip(temp_chip).left_pack = [chip(temp_chip).left_pack j];

    switch pack(j).buff_pos
        case 0 
            node(curr_node).local_in = node(curr_node).local_in -1;
            node(curr_node).local_in_out = node(curr_node).local_in_out + 1;
        case 1  
            node(curr_node).left = node(curr_node).left -1;
            node(curr_node).left_out = node(curr_node).left_out + 1;
        case 2  
            node(curr_node).right = node(curr_node).right -1;
            node(curr_node).right_out = node(curr_node).right_out + 1;
        case 3 
            node(curr_node).up = node(curr_node).up -1;
            node(curr_node).up_out = node(curr_node).up_out + 1;
        case 4  
            node(curr_node).down = node(curr_node).down -1; 
            node(curr_node).down_out = node(curr_node).down_out + 1;
        case 5
            node(curr_node).local_out = node(curr_node).local_out -1; 
            node(curr_node).local_out_out = node(curr_node).local_out_out + 1;
    end
    pack(j).buff_pos = 6;
    inuse_chip(curr_chip,temp_chip) = 1;
    net_chip(curr_chip,temp_chip) = net_chip(curr_chip,temp_chip) + 1;
    out = 1;

    pack(j).last_node = curr_node;   %update pack(j).last_node
end

end
