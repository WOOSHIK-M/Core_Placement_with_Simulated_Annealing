function out = step_down(curr,j,M)
%description: paket move towards down one step
global pack;
global node;
global inuse;
global net;
global delt;    %for BP weight update
global BUFF_SIZE;

temp = pack(j).src_x + M*(pack(j).src_y + 1) + 1;
out = 0;
if node(temp).up_full == 0 && inuse(curr,temp) == 0
    pack(j).src_y = pack(j).src_y + 1;
    node(temp).up = node(temp).up + 1;
    node(temp).up_pack = [node(temp).up_pack j];
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
    pack(j).buff_pos = 3;
    inuse(curr,temp) = 1;
    net(curr,temp) = net(curr,temp) +1;          
    out = 1;
    
    %BP weight update
    last = pack(j).last_node; 
    if node(temp).up == BUFF_SIZE
         if last == curr
            delt(curr,temp).grad = delt(curr,temp).grad + 1;
            delt(curr,temp).src = [delt(curr,temp).src,temp];
            delt(curr,temp).src_buff = [delt(curr,temp).src_buff,3];
        else
            delt(last,curr).grad = delt(last,curr).grad + 1; 
            delt(last,curr).src = [delt(last,curr).src,temp];
            delt(last,curr).src_buff = [delt(last,curr).src_buff,3];   
        end        
    end
    
    pack(j).last_node = curr;   %update pack(j).last_node
end

end
