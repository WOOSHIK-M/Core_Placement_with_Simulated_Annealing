close all
clear all
clc

global mulcan
global dead_cycles
global infocell

global Nchip
global Ncore
global x_dim
global y_dim
global X_DIM
global Y_DIM
global nnode
global cycle_flag
global Turn_constraint
global Dead_lock_circle_constraint
global failed_node_vec
global iterate
global failed_node_num
% global change_num

%% Basic parameter
File_path = 'Dataset/LUTPost_4chips.mat';                     % 624 cores
% File_path = 'Dataset/MLP_154core_2048-1024-1024-1024-512-384 (2).mat';  % 156 cores
% File_path = 'Dataset/LUT_mingwang.mat';  % Chenmingwang
% File_path = 'sample.mat';

Nchip = 4;      % Chip level
Ncore = 156;
x_dim = 2;              
y_dim = 2;

X_DIM = 13;     % Core level
Y_DIM = 12;
nnode = X_DIM * Y_DIM;

string_0 = [' ===>  Data file path: ' File_path];
disp(string_0)
fprintf('\n')

%% Routing constraints
cycle_flag = 0;
Dead_lock_circle_constraint = 1;
Turn_constraint = 0;                                            % Only non-xy_routing
failed_node_num = 3;                                           % Only single chip
failed_node_all_vec = zeros(failed_node_num, Nchip);

%% START!!!
if Nchip == 1
    File_name = File_path;
    failed_node_vec = randperm(Ncore);
    failed_node_vec = failed_node_vec(1:failed_node_num);
    failed_node_vec = [64 86 129];
    tic
    SA;
    toc
else
    Build_net;
    FU;
    for iterate = 4:Nchip
        failed_node_vec = unidrnd(nnode, [1, failed_node_num]);
        failed_node_all_vec(:,iterate) = failed_node_vec;
        File_name = ['4_chip_after_chip' int2str(iterate) '.mat'];
        SA;
    end
end

save all.mat
routing_sim;
