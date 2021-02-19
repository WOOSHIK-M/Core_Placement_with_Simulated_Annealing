%% test after

wsp = pack;
stay = [wsp.stay];
wsp(stay == 0) = [];

netpack = zeros(X_DIM*Y_DIM);
for i = 1:length(wsp)
    curpos = wsp(i).last_node;
    ntpos = 0;
    switch wsp(i).buff_pos
        case 1
            ntpos = curpos + 1;
        case 2
            ntpos = curpos - 1;
        case 3
            ntpos = curpos + X_DIM;
        case 4
            ntpos = curpos - X_DIM;
    end
    if ntpos ~= 0
        netpack(curpos,ntpos) = 1;
    end
end

buff5 = [wsp.buff_pos];
buff5pos = find(buff5 == 5);

for i = length(buff5pos)
    

% MWS_plot_traffic(netpack)

% global dead_cycles
% global dead_num
%             
% dead_num = 0;
% dead_cycles = [];
% for i = 1:length(netpack)
%     ws_dfs(netpack,i);
% end






