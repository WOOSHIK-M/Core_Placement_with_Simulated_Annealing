function [x,y,chip_num,X,Y] = coordinate(node_num)

global Initmap

global X_DIM
global x_dim
global Ncore

switch Initmap
    case 1              % Zigzag
        chip_num = 1;
        if node_num>Ncore
            chip_num = chip_num + 1;
            node_num = node_num - Ncore;
        end
        x = mod(node_num-1,x_dim);
        y = floor((node_num-1)/x_dim);
        X = mod(chip_num-1,X_DIM);
        Y = floor((chip_num-1)/X_DIM);
    case 2              % Neighbor
        
end

end

