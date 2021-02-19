function ws_dfs_visit(adj_mat, start)

global wsw wsg wsb wscolor
global wscir
global dead_cycles
global dead_num

wscolor(start) = wsg;
ns = find(adj_mat(start,:));

wscir = [wscir start];

for v = ns(:)'
    switch wscolor(v)           % new neighbor
        case wsw
            ws_dfs_visit(adj_mat,v);
        case wsg            % find cycle
%             add1 = 0;
%             if isempty(dead_cycles)
%                 add2 = 1;
%             else
%                 add2 = 0;
%             end
  
            fi = wscir(find(wscir==v):end);
            
%             for i = 1:length(dead_cycles)
%                 comp1 = dead_cycles(i).nodes;
%                 comp2 = fi;
%                 
%                 comp1 = sort(comp1);
%                 comp2 = sort(comp2);
%                 
%                 if ~isequal(comp1,comp2)
%                     add2 = 1;
%                 end
%             end
            
            fi = [fi v];
            
%             if length(fi) > 3
%                 add1 = 1;
%             end

%             if add1&&add2
                dead_num = dead_num + 1;
                dead_cycles(dead_num).nodes = fi;
                wscir(find(wscir==start)+1:end) = [];
%             end
        case wsb            % have been checked
    end
end

wscir(end) = [];
wscolor(start) = wsb;

end

