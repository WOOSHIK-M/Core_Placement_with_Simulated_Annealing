%% 
function deadnum = dead_cycle(node)

global X_DIM
% global multi_chains

deadnum = 0;
conchain = [];
prevmat = zeros(length(node));
la = 1;
for i = 1:length(node)  
    for j = node(i).connected_to_cores
%         for k = node(j).connected_to_cores
            vec = [i j];
            no = j;
            while node(no).multi_to_cores_num > 0
                vec = [vec node(no).multi_to_cores];
                no = node(no).multi_to_cores;
            end
            conchain(la).nodes = vec;
            la = la + 1;
%         end
    end  
%     for j = node(i).connected_to_cores
%         prevmat(i,j) = 1;
%     end
end

allchains = conchain;
% allchains = [];
% for i = 1:length(node)
%     ws_dfs(prevmat,i);
%     allchains(length(allchains)+1:length(allchains)+length(conchain)) = multi_chains;
% end

for i = 1:length(allchains)
    chainvec = allchains(i).nodes;
    passvec = [];
    for k = 1:length(chainvec)-1                    
        stndx = node(chainvec(k)).x;
        stndy = node(chainvec(k)).y;
        landx = node(chainvec(k+1)).x;
        landy = node(chainvec(k+1)).y;

        stco = stndx + stndy*X_DIM + 1;
        passint = stco;

        while stndx~=landx
            stco = stndx + stndy*X_DIM + 1;
            if stndx > landx
                passint = [passint stco-1];
                stndx = stndx - 1;
            elseif stndx < landx
                passint = [passint stco+1];
                stndx = stndx + 1;
            end
        end

        while stndy~=landy && stndx==landx
            stco = stndx + stndy*X_DIM + 1;
            if stndy > landy
                passint = [passint stco-X_DIM];
                stndy = stndy - 1;
            elseif stndy < landy
                passint = [passint stco+X_DIM];
                stndy = stndy + 1;
            end
        end
        passvec = [passvec passint(1:end-1)];
    end
    lavec = chainvec(end);
    lavecco = node(lavec).x + node(lavec).y*X_DIM + 1;
    passvec = [passvec lavecco];

    if length(passvec) ~= length(unique(passvec))
        deadnum = deadnum + 1;
    end
    
end

