function nummpass = DETECT2(node,multi_vec,packet_info)
%% DETECT
% multicast dir == connected_from_cores dir

global X_DIM

nummpass = [];
count = 1;

for i = multi_vec
    muldir = 0;             % 1-left, 2-right, 3-up, 4-down
    fromdir = 0;
    for j = node(i).connected_from_cores
        muldest = node(i).multi_to_cores;
        fromnode = j;
        
        nodex = node(i).x;
        nodey = node(i).y;
        
        mulx = node(muldest).x;
        muly = node(muldest).y;
        
        fromx = node(fromnode).x;
        fromy = node(fromnode).y;
        
        if fromy == nodey
            if fromx < nodex
                fromdir = 1;
            else
                fromdir = 2;
            end
        elseif fromy > nodey
            fromdir = 3;
        else
            fromdir = 4;
        end
        
        if mulx < nodex
            muldir = 1;
        elseif mulx > nodex
            muldir = 2;
        else
            if muly > nodey
                muldir = 3;
            else
                muldir = 4;
            end
        end
        
        if muldir ~= fromdir
            nummpass(count).nodes = i;
            count = count + 1;
            break;
        end
    end
end









    
