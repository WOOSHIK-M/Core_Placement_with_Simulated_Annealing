%% Find the max weight of all net

global Nchip
global x_dim
global y_dim

for i = 1:2
    max_weight = 0;
    if i == 1
        load('4_chip_prev.mat');
    else
        load('4_chip_after.mat');
    end
    %% consider mesh structure

    chips.cores = [];
    chips.weight = [];
    chips.x = [];
    chips.y = [];

    chip = chips;

    for i = 1:Nchip
        chip(i).x = mod(i+1,x_dim) + 1;
        chip(i).y = floor((i-1)/x_dim + 1);
    end

    for i = 1:length(net_chip)
        for j = 1:length(net_chip)
            if net_chip(i,j) ~= 0
                chip(i).cores = [chip(i).cores j];
                chip(i).weight = [chip(i).weight net_chip(i,j)];
            end
        end
    end 

    set_net = cell(y_dim, x_dim);

    for i = 1:y_dim
        for j = 1:x_dim
            rel.e = 0;
            rel.w = 0;
            rel.s = 0;
            rel.n = 0;
            set_net{i,j} = rel;
        end
    end

    for i = 1:length(chip)
        for j =1:length(chip(i).cores)
            source = i;
            dest = chip(i).cores(j);

            if chip(source).x == chip(dest).x + 1 && chip(source).y == chip(dest).y % west
                node = set_net{chip(source).y,chip(source).x};
                node.w = node.w + chip(source).weight(j);
                set_net{chip(source).y,chip(source).x} = node;
            elseif chip(source).x == chip(dest).x - 1 && chip(source).y == chip(dest).y % east
                node = set_net{chip(source).y,chip(source).x};
                node.e = node.e + chip(source).weight(j);
                set_net{chip(source).y,chip(source).x} = node;
            elseif chip(source).x == chip(dest).x && chip(source).y == chip(dest).y + 1% north
                node = set_net{chip(source).y,chip(source).x};
                node.n = node.n + chip(source).weight(j);
                set_net{chip(source).y,chip(source).x} = node;
            elseif chip(source).x == chip(dest).x && chip(source).y == chip(dest).y - 1% south
                node = set_net{chip(source).y,chip(source).x};
                node.s = node.s + chip(source).weight(j);
                set_net{chip(source).y,chip(source).x} = node;
            else
                if chip(source).x >= chip(dest).x && chip(source).y >= chip(dest).y % north-west
                    for k = chip(dest).x+1:chip(source).x
                        set_net{chip(source).y,k}.w = set_net{chip(source).y,k}.w + chip(source).weight(j);
                    end
                    for k = chip(dest).y+1:chip(source).y
                        set_net{k,chip(dest).x}.n = set_net{k,chip(dest).x}.n +  + chip(source).weight(j);
                    end
                elseif chip(source).x >= chip(dest).x && chip(source).y < chip(dest).y % south-west
                    for k = chip(dest).x+1:chip(source).x
                        set_net{chip(source).y,k}.w = set_net{chip(source).y,k}.w + chip(source).weight(j);
                    end
                    for k = chip(source).y:chip(dest).y-1
                        set_net{k,chip(dest).x}.s = set_net{k,chip(dest).x}.s +  + chip(source).weight(j);
                    end
                elseif chip(source).x < chip(dest).x && chip(source).y < chip(dest).y % south-east
                    for k = chip(source).x:chip(dest).x-1
                        set_net{chip(source).y,k}.e = set_net{chip(source).y,k}.e + chip(source).weight(j);
                    end
                    for k = chip(source).y:chip(dest).y-1
                        set_net{k,chip(dest).x}.s = set_net{k,chip(dest).x}.s +  + chip(source).weight(j);
                    end
                elseif chip(source).x < chip(dest).x && chip(source).y >= chip(dest).y % nouth-east
                    for k = chip(source).x:chip(dest).x-1
                        set_net{chip(source).y,k}.e = set_net{chip(source).y,k}.e + chip(source).weight(j);
                    end
                    for k = chip(dest).y+1:chip(source).y
                        set_net{k,chip(dest).x}.n = set_net{k,chip(dest).x}.n +  + chip(source).weight(j);
                    end
                end
            end        
        end
    end

    %% calculate max_weight

    net_chip = zeros(Nchip+2*x_dim);
    for i = 1:y_dim
        for j = 1:x_dim
            node_num = (i-1)*y_dim + j + x_dim;
            net_chip(node_num, node_num+1) = net_chip(node_num, node_num+1) + set_net{i,j}.e;
            net_chip(node_num, node_num-1) = net_chip(node_num, node_num-1) + set_net{i,j}.w;
            net_chip(node_num, node_num+x_dim) = net_chip(node_num, node_num+x_dim) + set_net{i,j}.s;
            net_chip(node_num, node_num-x_dim) = net_chip(node_num, node_num-x_dim) + set_net{i,j}.n;
        end
    end
    max_weight = max(max_weight,max(max(net_chip)));

    net_chip = net_chip(x_dim+1:length(net_chip)-x_dim,y_dim+1:length(net_chip)-y_dim);

    %% Plot the zigzag traffic figure

    figure('position',[300 300 600 450]);
    plot_traffic(net_chip,max_weight);
    caxis([0 max_weight]);
    axis off;
    set(gcf, 'color', [1 1 1]);
    set(gca,'position',[0 0 0.9 1]);
    colorbar('position',[0.9 0.1 0.015 0.8]);
end