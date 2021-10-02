%%
global X_DIM
re = [];

pack_re = pack;
stay = [pack.stay];
buff = [pack.buff_pos];
arr = [pack.arr];

buff5 = find(buff==5);
arr1 = find(arr == 1);
buff5(ismember(buff5,arr1)==1) = [];
pack_re = pack_re(buff5);
for i = 1:length(pack_re)
    pack_re(i).original = buff5(i);
end
    
% max_stay = max(stay);
% max_pos = find(stay == max_stay);
% pack_re = pack_re(max_pos);

renet = zeros(length(node));

% ===== Edit =======
% dle = [1 2 3 4 5 143];
% pack_re(dle) = [];
% ===============

newpost = zeros(512,length(node));

for i = 1:length(pack_re)
    curnn = pack_re(i).src_x + pack_re(i).src_y*X_DIM + 1;
    if pack_re(i).src_x > pack_re(i).dst_x % left
        dir = 1;
        ntnn = curnn - 1;
        ntbu = 'right_pack';
    elseif pack_re(i).src_x < pack_re(i).dst_x % right
        dir = 2;
        ntnn = curnn + 1;
        ntbu = 'left_pack';
    else
        if pack_re(i).src_y > pack_re(i).dst_y % up
            dir = 3;
            ntnn = curnn - X_DIM;
            ntbu = 'down_pack';
        elseif pack_re(i).src_y < pack_re(i).dst_y % down
            dir = 4;
            ntnn = curnn + X_DIM;
            ntbu = 'up_pack';
        end
    end    
%     newnode = [newnode pack_org(pack_re(i).original).last_node];
%     newnode(pack_org(pack_re(i).original).src_x) = node(pack_org(pack_re(i).original).src_x);
    newpost(:,pack_org(pack_re(i).original).last_node) = LUTPost(:,pack_org(pack_re(i).original).last_node);
    renet(curnn,ntnn) = renet(curnn,ntnn) + 100;
    
    while 1
        if length(node(ntnn).(ntbu)) == 2      
            pack_number = node(ntnn).(ntbu);
            curnn = pack(pack_number(1)).src_x + pack(pack_number(1)).src_y*X_DIM + 1;
            if pack(pack_number(1)).src_x > pack(pack_number(1)).dst_x % left
                dir = 1;
                ntnn = curnn - 1;
                ntbu = 'right_pack';
            elseif pack(pack_number(1)).src_x < pack(pack_number(1)).dst_x % right
                dir = 2;
                ntnn = curnn + 1;
                ntbu = 'left_pack';
            else
                if pack(pack_number(1)).src_y > pack(pack_number(1)).dst_y % up
                    dir = 3;
                    ntnn = curnn - X_DIM;
                    ntbu = 'down_pack';
                elseif pack(pack_number(1)).src_y < pack(pack_number(1)).dst_y % down
                    dir = 4;
                    ntnn = curnn + X_DIM;
                    ntbu = 'up_pack';
                else
                    renet(curnn,curnn) = renet(curnn,curnn) + 200;
%                     newnode(pack_org(pack_number(1)).src_x) = node(pack_org(pack_number(1)).src_x);
%                     newnode = [newnode pack_org(pack_number(1)).last_node];
                    newpost(:,pack_org(pack_number(1)).last_node) = LUTPost(:,pack_org(pack_number(1)).last_node);
                    break
                end
            end
%             newnode(pack_org(pack_number(1)).src_x) = node(pack_org(pack_number(1)).src_x);
%             newnode = [newnode pack_org(pack_number(1)).last_node];
            newpost(:,pack_org(pack_number(1)).last_node) = LUTPost(:,pack_org(pack_number(1)).last_node);
            renet(curnn,ntnn) = renet(curnn,ntnn) + 1;
        else
            break
        end
    end
    
end
% newnode = node(unique(newnode));
renet = renet/2;
MWS_plot_traffic(renet)


% stay = [pack_re.stay];
% stay = unique(stay);
% 
% cont = [];
% ele = [];
% numb = 1;
% for i = 1:length(stay)-1
%     if (stay(i+1) - stay(i)) == 1
%         ele = [ele stay(i)];
%     else
%         ele = [ele stay(i)];
%         cont(numb).nodes = ele;
%         ele = [];
%         numb = numb + 1;
%     end
% end