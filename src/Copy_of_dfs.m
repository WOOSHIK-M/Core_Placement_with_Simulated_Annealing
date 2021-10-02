function Copy_of_dfs(adj_mat, start)

n = length(adj_mat);

global visited;
visited = [];
global cycle_flag
cycle_flag = 0;
global white gray black color
global test_cir


white = 0;
gray = 1;
black = 2;
color = white * ones(1,n);

if ~isempty(start)
    test_cir = [];
    Copy_of_dfs_visit(adj_mat, start);
end

% for i = 1:n
%     if color(i) == white
%         dfs_visit(adj_mat, i);
%     end
%     if cycle_flag
%         break
%     end
% end