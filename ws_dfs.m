function ws_dfs(adj_mat, start)

n = length(adj_mat);

global wsw wsg wsb wscolor
global wscir

wsw = 0;
wsg = 1;
wsb = 2;
wscolor = wsw*ones(1,n);

if ~isempty(start)
    wscir = [];
    ws_dfs_visit(adj_mat, start);
end

end
