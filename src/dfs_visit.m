function dfs_visit(adj_mat, u)

global visited;
visited = [];
global cycle_flag
global white gray black color

visited = [visited u];
color(u) = gray;
ns = find(adj_mat(u,:));

for v = ns(:)'
    switch color(v)
        case white
            dfs_visit(adj_mat, v);
        case gray
            cycle_flag = 1;
        case black
    end
end

color(u) = black;
