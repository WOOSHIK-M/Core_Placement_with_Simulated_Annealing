function dfs_visit_Deadlock(adj_mat, u)

global visited;
visited = [];
global cycle_flag
global white gray black color
global test_cir
global dead_num
global dead_cycles

visited = [visited u];
color(u) = gray;
ns = find(adj_mat(u,:));

if ~isempty(test_cir)
    if test_cir(1) == 128
        disp(u)
    end
end


test_cir = [test_cir u];
if length(test_cir) >= 2
    ns(ns == test_cir(end-1)) = [];
elseif length(test_cir) == 1
    ns(ns == test_cir) = [];
end


for v = ns(:)'
    switch color(v)
        case white        
            test_cir(find(test_cir==u)+1:end) = [];
            dfs_visit_Deadlock(adj_mat, v);
            
        case gray
            cycle_flag = 1;
            fi = [];
            fi = test_cir(find(test_cir==v):end);
            fi = [fi v];
            
            add = 1;
            for ver = 1:length(dead_cycles)
                if length(fi) == length(dead_cycles(ver).nodes)
                    vectorr = sort(dead_cycles(ver).nodes(1:end-1));
                    if vectorr == sort(fi(1:end-1))
                        add = 0;
                    end
                end
            end
            if add
                dead_num = dead_num + 1;
                dead_cycles(dead_num).nodes = fi;
            end
            
        case black
    end
end

color(u) = black;
