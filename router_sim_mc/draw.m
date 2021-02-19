%path statistic
load('data.mat');
pack = struct();

for i = 1:PACK_NUM
    pack(i).src_x = mod( S(i)-1, M);
    pack(i).src_y = floor( (S(i)-1)/M);
    pack(i).dst_x = mod( D(i)-1, M);
    pack(i).dst_y = floor( (D(i)-1)/M);
    pack(i).last_node = S(i);
end

path = zeros(1,9);

for i = 1:PACK_NUM
    if pack(i).dst_x == pack(i).src_x 
        if pack(i).dst_y == pack(i).src_y
            path(9) = path(9) + 1;
            continue;
        else
            if pack(i).dst_y > pack(i).src_y
            	path(3) = path(3)+1;
                continue;  
            else
                path(4) = path(4)+1;
                continue;
            end
        end
    end
    
    if pack(i).dst_x > pack(i).src_x 
        if pack(i).dst_y == pack(i).src_y
            path(1) = path(1)+1;
            continue;
        else
            if pack(i).dst_y > pack(i).src_y
            	path(5) = path(5)+1;
            else
                path(6) = path(6)+1;
            end
        end
    end
    
    if pack(i).dst_x < pack(i).src_x 
        if pack(i).dst_y == pack(i).src_y
            path(2) = path(2)+1;
            continue;
        else
            if pack(i).dst_y > pack(i).src_y
            	path(8) = path(8)+1;
            else
                path(7) = path(7)+1;
            end
        end
    end
end
figure();
bar(1:9,path);
x = [1:9];
set(gca,'xtick',x);
xt = {'A','B','C','D','E','F','G','H','I'};
set(gca,'xticklabel',xt);
ylabel('连接关系数量');
xlabel('连接关系种类');
title('连接关系统计');