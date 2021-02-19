close all
clear all
clc

global Nchip
global X_DIM
global Y_DIM
global Ncore
global x_dim
global y_dim

global all_node_num

global Initmap
global failed_node_vec

File_path = 'Data/LUTPost_4chips.mat';                                                              % 4 chips + 624 cores
% File_path = 'Data/MLP_154core_2048-1024-1024-1024-512-384 (2).mat';         %1chip + 156cores 

%% Basic Parameter
Initmap = 1;                                                        % 1-Zigzag / 2-Neighbor

X_DIM = 2;                                                          % Chip Level Info
Y_DIM = 2;

x_dim = 13;                                                         % Core Level Info
y_dim = 12;

failed_node_num = 1;

Nchip = X_DIM*Y_DIM;
Ncore = x_dim*y_dim;
all_node_num  = Ncore*Nchip;

string0 = [' ===> Data File Path: ' File_path];
disp(string0)
fprintf('\n')


select_mode = [2,3,4];                                     %  1-Free Failed node / 2-Fast Unfolding(Only multichip) / 3-Simulated Annealing / 4-Simulate Routing

%% Run

failed_node_vec = randperm(all_node_num);
failed_node_vec = failed_node_vec(1:failed_node_num);
netlist;
    
if ismember(1,select_mode)
    FreeFailedNodeMapping    % Not multichip Now....
end

if ismember(2,select_mode)
    if Nchip>1
        Buildnet
        FastUnfolding

        SimulatedAnnealing
    else
        SimulatedAnnealing
    end
end
















