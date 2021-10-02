%% After_deadlock

global dead_cycles
global dead_num

net_backup = net;

net_full = zeros(X_DIM*Y_DIM);

for i = 1:length(node)
    if node(i).left_full
        net_full(i-1,i) = net_backup(i-1,i);
    end
    if node(i).right_full
        net_full(i+1,i) = net_backup(i+1,i);
    end
    if node(i).up_full
        net_full(i-X_DIM,i) = net_backup(i-X_DIM,i);
    end
    if node(i).down_full
        net_full(i+X_DIM,i) = net_backup(i+X_DIM,i);
    end
end

MWS_plot_traffic(net_full);

net_full(net_full~=0) = 1;
dead_num = 0;
dead_cycles = [];
for i = 1:length(net)
    ws_dfs(net_full,i);
end

% error()
%% Plot all full_cycles

% dead_init = dead_cycles;
% for i = 1:length(dead_cycles)
%     new_net = zeros(X_DIM*Y_DIM);
%     for j = 1:length(dead_cycles(i).nodes)-1
%         new_net(dead_cycles(i).nodes(j),dead_cycles(i).nodes(j+1)) = 1;
%     end
% %     MWS_plot_traffic(new_net)
% end

disp(length(dead_cycles))

%% find real deadlock cycle

% First method (Find circle)
dead_backup = dead_cycles;
dead_vv = [];
for i = 1:length(dead_cycles)
    break_point = 0;
    dead_cycles(i).nodes = [dead_backup(i).nodes dead_backup(i).nodes(2)];
    for j = 2:length(dead_cycles(i).nodes) - 1
        nd = dead_cycles(i).nodes(j);
        nd_before = dead_cycles(i).nodes(j - 1);
        nd_next = dead_cycles(i).nodes(j + 1);
        if nd == nd_before + 1
            pack_nd = node(nd).left_pack;
        elseif nd == nd_before - 1
            pack_nd = node(nd).right_pack;
        elseif nd == nd_before + X_DIM
            pack_nd = node(nd).up_pack;
        elseif nd == nd_before - X_DIM
            pack_nd = node(nd).down_pack;
        end
        for k = 1:length(pack_nd)
            packk = pack(pack_nd(k));
            if packk.buff_pos == 5
                next_num = nd_next;
            else
                if packk.src_x > packk.dst_x % left
                    next_num = nd - 1;
                elseif packk.src_x < packk.dst_x % right
                    next_num = nd + 1;
                elseif packk.src_x == packk.dst_x
                    if packk.src_y > packk.dst_y % up
                        next_num = nd - X_DIM;
                    elseif packk.src_y < packk.dst_y % down
                        next_num = nd + X_DIM;
                    else
                        next_num = nd_next;                    
                    end
                end
            end
            if next_num ~= nd_next
                dead_vv = [dead_vv i];
                break_point = 1;
                break
            end
        end
        if break_point
            break
        end
    end
end

dead_backup(dead_vv) = [];
dead_cycles = dead_backup;
dead_num = length(dead_cycles);

str_9 = ['There are "' num2str(dead_num) '" full connections circles'];
disp(str_9)


% Second method
% 












