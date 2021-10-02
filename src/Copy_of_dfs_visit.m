function Copy_of_dfs_visit(adj_mat, u)

global visited;
visited = [];
global cycle_flag
global white gray black color
global test_cir
global circle_num
global circle_cycles

visited = [visited u];
color(u) = gray;
ns = find(adj_mat(u,:));


test_cir = [test_cir u];
% if length(test_cir) >= 2
%     ns(ns == test_cir(end-1)) = [];
% elseif length(test_cir) == 1
%     ns(ns == test_cir) = [];
% end

if isempty(ns)
    circle_num = circle_num + 1;
    circle_cycles(circle_num).nodes = test_cir;
end

for v = ns(:)'
    switch color(v)
        case white
            Copy_of_dfs_visit(adj_mat, v);
        case gray
            cycle_flag = 1;
        case black
            Copy_of_dfs_visit(adj_mat, v);
    end
end

color(u) = black;
test_cir(end) = [];
