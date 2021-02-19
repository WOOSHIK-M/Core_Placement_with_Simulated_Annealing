function out = step_local_out(curr,j)
%description: paket move towards local_out one step
global pack;
global node;
global BUFF_SIZE;

out = 0;
if node(curr).local_out < BUFF_SIZE
    node(curr).local_out = node(curr).local_out + 1;
    node(curr).local_out_pack = [node(curr).local_out_pack j];
    pack(j).move = 1;
    
    switch pack(j).buff_pos
        case 0 
            node(curr).local_in = node(curr).local_in -1;
            node(curr).local_in_out = node(curr).local_in_out + 1;
        case 1  
            node(curr).left = node(curr).left -1;
            node(curr).left_out = node(curr).left_out + 1;
        case 2  
            node(curr).right = node(curr).right -1;
            node(curr).right_out = node(curr).right_out + 1;
        case 3 
            node(curr).up = node(curr).up -1;
            node(curr).up_out = node(curr).up_out + 1;
        case 4  
            node(curr).down = node(curr).down -1; 
            node(curr).down_out = node(curr).down_out + 1;
        case 5
            node(curr).local_out = node(curr).local_out -1; 
            node(curr).local_out_out = node(curr).local_out_out + 1;
    end
    pack(j).buff_pos = 5;
    out = 1;
end  

end
