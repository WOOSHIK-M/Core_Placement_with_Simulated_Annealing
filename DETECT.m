function nummpass = DETECT(node,multi_vec,packet_info)
%% DETECT
global X_DIM
% Detect Deadlock Circle (Upgrade)

packet_info_use = packet_info;

ismul = [packet_info_use.is_mul];
posmul = find(ismul == 1);

% Generate cell 1 X node
infocell = cell(1,length(node));
buff.right = [];
buff.left = [];
buff.up = [];
buff.down = [];
buff.local = [];

for i = 1:length(infocell)
    infocell{1,i} = buff;
end

for i = 1:length(packet_info_use)
    sx = node(packet_info(i).source).x;         % source node
    sy = node(packet_info(i).source).y;

    dx = node(packet_info(i).dest).x;           % dest node
    dy = node(packet_info(i).dest).y;

    onx = linspace(sx,dx,abs(sx-dx)+1);             % pass node
    ony = linspace(sy,dy,abs(sy-dy)+1);

    if ~isempty(ony)
        ony(1) = [];
    end
    onnode = [];

    for j = onx   % horizonal direction
        onnode = [onnode  j+sy*X_DIM+1];
    end

    for j = ony   % vertical direction
        onnode = [onnode dx+j*X_DIM+1];
    end

    packet_info_use(i).path = onnode;

    % fill the cell
    for j = 1:length(onnode)-1
        if j == length(onnode)-1
            local = infocell{1,onnode(j+1)}.local;
            local  = [local i];
            infocell{1,onnode(j+1)}.local = local;
        else
             if onnode(j+1) == onnode(j) - 1 % 1-right buffer
                right = infocell{1,onnode(j+1)}.right;
                right = [right i];
                infocell{1,onnode(j+1)}.right = right;
            elseif onnode(j+1) == onnode(j) + 1 % 2-left buffer
                left = infocell{1,onnode(j+1)}.left;
                left = [left i];
                infocell{1,onnode(j+1)}.left = left;
            elseif onnode(j+1) == onnode(j) - X_DIM % 3-down buffer
                down = infocell{1,onnode(j+1)}.down;
                down = [down i];
                infocell{1,onnode(j+1)}.down = down;
            elseif onnode(j+1) == onnode(j) + X_DIM % 4-up buffer
                up = infocell{1,onnode(j+1)}.up;
                up = [up i];
                infocell{1,onnode(j+1)}.up = up;
             end
        end
    end
end

mulstr = [];
cc = 1;

for i = 1:length(multi_vec)
    for j = 1:length(multi_vec)
        if i ~= j
            mul1 = multi_vec(i);
            mul2 = multi_vec(j);
            mulstr(cc).nodes = [mul1 mul2];
            if ismember(mul2,node(mul1).multi_to_cores)
                mulstr(cc).ismul = 1;
                mulstr(cc).canmake = 1;
            else
                mulstr(cc).ismul = 0;
                mulstr(cc).canmake = 0;
            end
            cc = cc+1;
        end
    end
end

connected = [];
for i = 1:length(mulstr)
    if ~mulstr(i).ismul
        x1 = node(mulstr(i).nodes(1)).x;
        y1 = node(mulstr(i).nodes(1)).y;
        xd1 = node(node(mulstr(i).nodes(1)).multi_to_cores).x;
        x2 = node(mulstr(i).nodes(2)).x;
        y2 = node(mulstr(i).nodes(2)).y;
        fromy = zeros(length(node(mulstr(i).nodes(2)).connected_from_cores));
        for j = 1:length(node(mulstr(i).nodes(2)).connected_from_cores)
            if y2 > node(node(mulstr(i).nodes(2)).connected_from_cores(j)).y
                fromy(j) = 1; % up buffer
            elseif y2 < node(node(mulstr(i).nodes(2)).connected_from_cores(j)).y
                fromy(j) = 2; % down buffer
            else
                fromy(j) = 3; % same y
            end
        end

        Ablecon1 = 0;
        Ablecon2 = 0;
        idx1 = x1-x2;
        idx2 = x1-xd1;
        if sign(idx1) == sign(idx2)
            Ablecon1 = 1;
        end
        if y2 > y1
            yiyi = 1;
        elseif y2 < y1
            yiyi = 2;
        elseif y2 == y1
            yiyi =3;
        end
        if ismember(yiyi,fromy)
            Ablecon2 = 1;
        end
    
        if Ablecon1 && Ablecon2
            cirx = linspace(x1,x2,abs(x1-x2)+1);
            ciry = linspace(y1,y2,abs(y1-y2)+1);

            if ~isempty(ciry)
                ciry(1) = [];
            end
            
            if ~isempty(ciry)
                ciry(end) = [];
            end
            
            cirnode = [];
             for j = cirx   % horizonal direction
                cirnode = [cirnode  j+y1*X_DIM+1];
            end

            for j = ciry   % vertical direction
                cirnode = [cirnode x2+j*X_DIM+1];
            end

            noneffect = 0;
            for k = 1:length(packet_info_use)
                breakpoint = 0;
                sdvec = [packet_info_use(k).source packet_info_use(k).dest];
                if ~ismember(1,ismember(sdvec,mulstr(i).nodes))
                    for o = 1:length(cirnode) - 1
                        if ~ismember(cirnode(o+1),multi_vec)
                            if cirnode(o+1) == cirnode(o) - 1 % right buffer
                                buffer = infocell{1,cirnode(o+1)}.right;
                            elseif cirnode(o+1) == cirnode(o) + 1 % left buffer
                                buffer = infocell{1,cirnode(o+1)}.left;
                            elseif cirnode(o+1) == cirnode(o) - X_DIM % down buffer
                                buffer = infocell{1,cirnode(o+1)}.down;
                            elseif cirnode(o+1) == cirnode(o) + X_DIM % up buffer
                                buffer = infocell{1,cirnode(o+1)}.up;
                            end

                            if isempty(buffer)
                                noneffect = 1; 
                                break
                            end
                        end
                        if o == length(cirnode)-1 && noneffect == 0
                            mulstr(i).canmake = 1;
                            breakpoint = 1;
                        end
                    end
                    if noneffect || breakpoint
                        break
                    end
                end
            end
        end
    end
end

global mulcan
canpos = [mulstr.canmake];
mulcan = mulstr(canpos == 1);

adjmat = zeros(length(node));
for i = 1:length(mulcan)
    adjmat(mulcan(i).nodes(1),mulcan(i).nodes(2)) = 1;
end

global dead_cycles
global dead_num
dead_cycles = [];
dead_num = 0;
canno = [mulcan.nodes];
canno = unique(canno);

for i = canno
    ws_dfs(adjmat,i)
end

nummpass = dead_cycles;

end









    
