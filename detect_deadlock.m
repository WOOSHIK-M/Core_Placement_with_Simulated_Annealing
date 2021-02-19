%% test

global test_cir
global dead_num
global dead_cycles
global X_DIM
test_cir = [];
dead_num = 0;
dead_cycles = [];

dead_mat = zeros(156);
for idx = 1:length(node)
    if node(idx).left_full == 1
        dead_mat(idx-1,idx) = 1;
    end
    if node(idx).right_full == 1
        dead_mat(idx+1,idx) = 1;
    end
    if node(idx).up_full == 1
        dead_mat(idx-X_DIM,idx) = 1;
    end
    if node(idx).down_full == 1
        dead_mat(idx+X_DIM,idx) = 1;
    end
end

cycle_flag = 0;
for iin = 1:length(node)
    dfs_Deadlock(dead_mat,iin);
    if cycle_flag == 1
        break
    end
end

dead_backup = dead_cycles;
dead_ba = dead_cycles;
% find real dead_lock circles
dead_vv = [];
for ij = 1:length(dead_cycles)
    break_point = 0;
    dead_cycles(ij).nodes = [dead_backup(ij).nodes dead_backup(ij).nodes(2:end-1)];
    for ji = 2:length(dead_cycles(ij).nodes) - 1
        nd = dead_cycles(ij).nodes(ji);
        nd_before = dead_cycles(ij).nodes(ji - 1);
        nd_next = dead_cycles(ij).nodes(ji + 1);
        if nd == nd_before + 1
            pack_nd = node(nd).left_pack;
        elseif nd == nd_before - 1
            pack_nd = node(nd).right_pack;
        elseif nd == nd_before + X_DIM
            pack_nd = node(nd).up_pack;
        elseif nd == nd_before - X_DIM
            pack_nd = node(nd).down_pack;
        end
        for ijj = 1:length(pack_nd)
            packk = pack(pack_nd(ijj));
            if packk.src_x > packk.dst_x % left
                next_num = packk.src_x + packk.src_y*X_DIM;
            elseif packk.src_x < packk.dst_x % right
                next_num = packk.src_x + packk.src_y*X_DIM + 2;
            elseif packk.src_x == packk.dst_x
                if packk.src_y > packk.dst_y % up
                    next_num = packk.src_x + packk.src_y*X_DIM - (X_DIM - 1);
                elseif packk.src_y < packk.dst_y % down
                    next_num = packk.src_x + packk.src_y*X_DIM + (X_DIM + 1);
                else
                    if isempty(node(nd_next).mul_en)
                        next_num = nd_next;
                    else
                        next_num = 0;
                    end
                end
            end
            if next_num ~= nd_next
                dead_vv = [dead_vv ij];
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
if isempty(test_cir) == 1
    disp('NO FIND') 
else
    str_9 = ['There are "' num2str(dead_num) '" full connections circles'];
    disp(str_9)
end
