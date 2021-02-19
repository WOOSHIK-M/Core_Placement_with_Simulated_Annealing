%Description：基于time cylce的路由仿真器, using random xy routing stategy
% clear
% close all

%% 构建网络 
load('data.mat');
flag = 0;       % flag of routing done, changed to 1 in process means undone, keeps in 0 means done
busy = 0;       % 0 for no routing active occur, 1 for routing active
global net;
net = zeros(M*N, M*N);      % for path count of xy routing

%% 构建路由包
global pack;
pack = pack_org;

%% 构建节点
global node;
node = node_org;

%% 构建网络参数矩阵
global inuse;
inuse = zeros(M*N, M*N);    % current time step, channel in use will be set to 1, only one packet will be...
                            % -allowed on each channel per cycle
                            
%% 开始路由仿真
str = sprintf('random_xy sim start: \n');
disp(str);

for i = 1: STEP
    disp(i);
    inuse(:,:) = 0;         % clear channel in use signal
    
    for j = 1:NODE_NUM
        
        if node(j).local_out_empty == 0                          % LOCAL_OUT方向
            local_out_pack_num = length(node(j).local_out_pack);
            delet_pack = [];
            for n = 1: local_out_pack_num
                k = node(j).local_out_pack(n);
                if pack(k).move == 0
                    if node(j).mul_en == 1
                        pack(k).dst_x = node(j).multi_dst_x;
                        pack(k).dst_y = node(j).multi_dst_y;
                        
                        temp = rand();
                        if temp>= 0.5       %choose next step x or y according to rand r
                            r = 1;          % 0 for x, 1 for y 
                        else
                            r = 0;
                        end

                        if pack(k).dst_x == pack(k).src_x           %only y routing is available
                            if pack(k).dst_y > pack(k).src_y
                                if(step_down(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            elseif pack(k).dst_y < pack(k).src_y
                                if(step_up(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                            if pack(k).dst_x > pack(k).src_x
                                if(step_right(j,k)) 
                                    delet_pack = [delet_pack n];
                                end
                            elseif pack(k).dst_x < pack(k).src_x
                                if(step_left(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                            if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                            if(step_left(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        else
                            if r == 0           % 0 for x
                                if pack(k).dst_x > pack(k).src_x
                                    if(step_right(j,k))
                                        delet_pack = [delet_pack n];
                                    end
                                end
                                if pack(k).dst_x < pack(k).src_x
                                    if(step_left(j,k))
                                        delet_pack = [delet_pack n];
                                    end
                                end
                            elseif r == 1      % 1 for y
                                if pack(k).dst_y > pack(k).src_y
                                    if(step_down(j,k,M))
                                        delet_pack = [delet_pack n];
                                    end
                                end
                                if pack(k).dst_y < pack(k).src_y
                                    if(step_up(j,k,M))
                                        delet_pack = [delet_pack n];
                                    end
                                end
                            end
                        end
                    else
                        pack(k).arr = 1;
                        pack(k).in_route = 0;
                        pack(k).buff_pos = 5;
                        node(j).local_out = node(j).local_out - 1;
                        node(j).local_out_out = node(j).local_out_out + 1;
                        delet_pack = [delet_pack n];
                        busy = 1;
                    end
                end
            end
            node(j).local_out_pack(delet_pack) = [];
        end
        
        
        if node(j).local_in_empty == 0                          % LOCAL_IN方向
            k = node(j).local_in_pack(1);
            if pack(k).move == 0
                if pack(k).src_x == pack(k).dst_x && pack(k).src_y == pack(k).dst_y && pack(k).arr == 0;
                    if(step_local_out(j,k))
                        node(j).local_in_pack(1) = [];
                        busy = 1;
                    end
                end
                
                result = vir_channel_control(j,k,VIR_CHAN,INTERVAL);
                if result == 1
                    busy = 1;
                    continue;
                end
                
                temp = rand();
                if temp>= 0.5       %choose next step x or y according to rand r
                    r = 1;          % 0 for x, 1 for y 
                else
                    r = 0;
                end
                
                if pack(k).dst_x == pack(k).src_x           %only y routing is available
                    if pack(k).dst_y > pack(k).src_y
                        if(step_down(j,k,M))
                            node(j).local_in_pack(1) = [];
                            pack(k).in_route = 1;
                        end
                    elseif pack(k).dst_y < pack(k).src_y
                        if(step_up(j,k,M))
                            node(j).local_in_pack(1) = [];
                            pack(k).in_route = 1;
                        end
                    end
                elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                    if pack(k).dst_x > pack(k).src_x
                        if(step_right(j,k))
                            node(j).local_in_pack(1) = [];
                            pack(k).in_route = 1;
                        end
                    elseif pack(k).dst_x < pack(k).src_x
                        if(step_left(j,k))
                            node(j).local_in_pack(1) = [];
                            pack(k).in_route = 1;
                        end
                    end
                elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                    if(step_right(j,k)) 
                        node(j).local_in_pack(1) = [];
                        pack(k).in_route = 1;
                    end
                elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                    if(step_left(j,k)) 
                        node(j).local_in_pack(1) = [];
                        pack(k).in_route = 1;
                    end
                else
                    if r == 0           % 0 for x
                        if pack(k).dst_x > pack(k).src_x
                            if(step_right(j,k))
                                node(j).local_in_pack(1) = [];
                                pack(k).in_route = 1;
                            end
                        end
                        if pack(k).dst_x < pack(k).src_x
                            if(step_left(j,k))
                                node(j).local_in_pack(1) = [];
                                pack(k).in_route = 1;
                            end
                        end
                    elseif r == 1      % 1 for y
                        if pack(k).dst_y > pack(k).src_y
                            if(step_down(j,k,M))
                                node(j).local_in_pack(1) = [];
                                pack(k).in_route = 1;
                            end
                        end
                        if pack(k).dst_y < pack(k).src_y
                            if(step_up(j,k,M))
                                node(j).local_in_pack(1) = [];
                                pack(k).in_route = 1;
                            end
                        end
                    end
                end
            end
        end
        
        if node(j).left_empty == 0                          % WEST方向
            left_pack_num = length(node(j).left_pack);
            delet_pack = [];
            for n = 1: left_pack_num
                k = node(j).left_pack(n);
                if pack(k).move == 0
                    if pack(k).src_x == pack(k).dst_x && pack(k).src_y == pack(k).dst_y && pack(k).arr == 0;
                        if(step_local_out(j,k))
                            delet_pack = [delet_pack n];
                            busy = 1;
                        end
                    end

                    result = vir_channel_control(j,k,VIR_CHAN,INTERVAL);
                    if result == 1
                        busy = 1;
                        continue;
                    end
                    
                    temp = rand();
                    if temp>= 0.5       %choose next step x or y according to rand r
                        r = 1;          % 0 for x, 1 for y 
                    else
                        r = 0;
                    end
                    
                    if pack(k).dst_x == pack(k).src_x           %only y routing is available
                        if pack(k).dst_y > pack(k).src_y
                            if(step_down(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_y < pack(k).src_y
                            if(step_up(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                        if pack(k).dst_x > pack(k).src_x
                            if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_x < pack(k).src_x
                            if(step_left(j,k))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_left(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    else
                        if r == 0           % 0 for x
                            if pack(k).dst_x > pack(k).src_x
                                if(step_right(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_x < pack(k).src_x
                                if(step_left(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif r == 1      % 1 for y
                            if pack(k).dst_y > pack(k).src_y
                                if(step_down(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_y < pack(k).src_y
                                if(step_up(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        end
                    end
                end
            end
            node(j).left_pack(delet_pack) = [];
        end
        
        
        if node(j).right_empty == 0                          % EAST方向
            right_pack_num = length(node(j).right_pack);
            delet_pack = [];
            for n = 1: right_pack_num
                k = node(j).right_pack(n);
                if pack(k).move == 0
                    if pack(k).src_x == pack(k).dst_x && pack(k).src_y == pack(k).dst_y && pack(k).arr == 0;
                        if(step_local_out(j,k))
                            delet_pack = [delet_pack n];
                            busy = 1;
                        end
                    end

                    result = vir_channel_control(j,k,VIR_CHAN,INTERVAL);
                    if result == 1
                        busy = 1;
                        continue;
                    end
                    
                    temp = rand();
                    if temp>= 0.5       %choose next step x or y according to rand r
                        r = 1;          % 0 for x, 1 for y 
                    else
                        r = 0;
                    end
                    
                    if pack(k).dst_x == pack(k).src_x           %only y routing is available
                        if pack(k).dst_y > pack(k).src_y
                            if(step_down(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_y < pack(k).src_y
                            if(step_up(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                        if pack(k).dst_x > pack(k).src_x
                            if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_x < pack(k).src_x
                            if(step_left(j,k))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_left(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    else
                        if r == 0           % 0 for x
                            if pack(k).dst_x > pack(k).src_x
                                if(step_right(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_x < pack(k).src_x
                                if(step_left(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif r == 1      % 1 for y
                            if pack(k).dst_y > pack(k).src_y
                                if(step_down(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_y < pack(k).src_y
                                if(step_up(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        end
                    end
                end
            end
            node(j).right_pack(delet_pack) = [];
        end
        
        
        if node(j).up_empty == 0                          % NORTH方向
            up_pack_num = length(node(j).up_pack);
            delet_pack = [];
            for n = 1: up_pack_num
                k = node(j).up_pack(n);
                if pack(k).move == 0
                    if pack(k).src_x == pack(k).dst_x && pack(k).src_y == pack(k).dst_y && pack(k).arr == 0;
                        if(step_local_out(j,k))
                            delet_pack = [delet_pack n];
                            busy = 1;
                        end
                    end

                    result = vir_channel_control(j,k,VIR_CHAN,INTERVAL);
                    if result == 1
                        busy = 1;
                        continue;
                    end
                    
                    temp = rand();
                    if temp>= 0.5       %choose next step x or y according to rand r
                        r = 1;          % 0 for x, 1 for y 
                    else
                        r = 0;
                    end
                    
                    if pack(k).dst_x == pack(k).src_x           %only y routing is available
                        if pack(k).dst_y > pack(k).src_y
                            if(step_down(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_y < pack(k).src_y
                            if(step_up(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                        if pack(k).dst_x > pack(k).src_x
                            if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_x < pack(k).src_x
                            if(step_left(j,k))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_left(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    else
                        if r == 0           % 0 for x
                            if pack(k).dst_x > pack(k).src_x
                                if(step_right(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_x < pack(k).src_x
                                if(step_left(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif r == 1      % 1 for y
                            if pack(k).dst_y > pack(k).src_y
                                if(step_down(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_y < pack(k).src_y
                                if(step_up(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        end
                    end
                end
            end
            node(j).up_pack(delet_pack) = [];
        end
        
        
        if node(j).down_empty == 0                          % SOUTH方向
            down_pack_num = length(node(j).down_pack);
            delet_pack = [];
            for n = 1: down_pack_num
                k = node(j).down_pack(n);
                if pack(k).move == 0
                    if pack(k).src_x == pack(k).dst_x && pack(k).src_y == pack(k).dst_y && pack(k).arr == 0;
                        if(step_local_out(j,k))
                            delet_pack = [delet_pack n];
                            busy = 1;
                        end
                    end

                    result = vir_channel_control(j,k,VIR_CHAN,INTERVAL);
                    if result == 1
                        busy = 1;
                        continue;
                    end
                    
                   temp = rand();
                    if temp>= 0.5       %choose next step x or y according to rand r
                        r = 1;          % 0 for x, 1 for y 
                    else
                        r = 0;
                    end
                    
                    if pack(k).dst_x == pack(k).src_x           %only y routing is available
                        if pack(k).dst_y > pack(k).src_y
                            if(step_down(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_y < pack(k).src_y
                            if(step_up(j,k,M))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_y == pack(k).src_y       %only x routing is available
                        if pack(k).dst_x > pack(k).src_x
                            if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                            end
                        elseif pack(k).dst_x < pack(k).src_x
                            if(step_left(j,k))
                                delet_pack = [delet_pack n];
                            end
                        end
                    elseif pack(k).dst_x > pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_right(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    elseif pack(k).dst_x < pack(k).src_x && pack(k).dst_y < pack(k).src_y
                        if(step_left(j,k)) 
                                delet_pack = [delet_pack n];
                        end
                    else
                        if r == 0           % 0 for x
                            if pack(k).dst_x > pack(k).src_x
                                if(step_right(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_x < pack(k).src_x
                                if(step_left(j,k))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        elseif r == 1      % 1 for y
                            if pack(k).dst_y > pack(k).src_y
                                if(step_down(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                            if pack(k).dst_y < pack(k).src_y
                                if(step_up(j,k,M))
                                    delet_pack = [delet_pack n];
                                end
                            end
                        end
                    end
                end
            end
            node(j).down_pack(delet_pack) = [];
        end
        
    end
    
    if sum([pack.arr]) < PACK_NUM
        flag = 1;                   % routing undone
    end
%     max_time(3) = max(max_time(3),max([pack.time]));     %max deliver time
    max_time = 0;
    max_time = max(max_time,max([pack.time]));     %max deliver time
    
    for j = 1:NODE_NUM
        node(j).left_out = 0;
        node(j).right_out = 0;
        node(j).up_out = 0;
        node(j).down_out = 0;
        node(j).local_in_out = 0;
        node(j).local_out_out = 0;
        
        
        if node(j).left == BUFF_SIZE
            node(j).left_full = 1;
            node(j).left_empty = 0;
        elseif node(j).left == 0
            node(j).left_empty = 1;
            node(j).left_full = 0;
        else
            node(j).left_full = 0;
            node(j).left_empty = 0;
        end
        
        if node(j).right == BUFF_SIZE
            node(j).right_full = 1;
            node(j).right_empty = 0;
        elseif node(j).right == 0
            node(j).right_empty = 1;
            node(j).right_full = 0;
        else
            node(j).right_full = 0;
            node(j).right_empty = 0;
        end
        
        if node(j).up == BUFF_SIZE
            node(j).up_full = 1;
            node(j).up_empty = 0;
        elseif node(j).up == 0
            node(j).up_empty = 1;
            node(j).up_full = 0;
        else
            node(j).up_full = 0;
            node(j).up_empty = 0;
        end
        
        if node(j).down == BUFF_SIZE
            node(j).down_full = 1;
            node(j).down_empty = 0;
        elseif node(j).down == 0
            node(j).down_empty = 1;
            node(j).down_full = 0;
        else
            node(j).down_full = 0;
            node(j).down_empty = 0;
        end
        
        if node(j).local_out == BUFF_SIZE
            node(j).local_out_full = 1;
            node(j).local_out_empty = 0;
        elseif node(j).local_out == 0
            node(j).local_out_empty = 1;
            node(j).local_out_full = 0;
        else
            node(j).local_out_full = 0;
            node(j).local_out_empty = 0;
        end
        
        node(j).local_in_empty = isempty(node(j).local_in_pack);
    end
    
    
    dy_inuse(3,i) = sum(sum(inuse));    %dynamic inuse statistic
    if sum(sum(inuse)) > 0
        busy = 1;
    end
    
    if flag == 0        %flag 0 means all packet have been sent, routing process end
    	str = sprintf('Routing Done   ');
        disp(str);
        total_cycle = i;
        break;
    elseif flag == 1 && busy == 0   %dead lock
    	str = sprintf('Dead Lock ...  ');
        disp(str);
        break;
    end
    
    flag = 0;
    busy = 0;
    for j = 1 : PACK_NUM
        pack(j).move = 0;
        if pack(j).in_route == 1
            pack(j).time = pack(j).time + 1;
        end
    end
end
