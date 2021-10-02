clear all
close all
clc

%% sample `~~

global X_DIM
global Y_DIM
X_DIM = 4;     % Core level
Y_DIM = 4;
global nnode
nnode = X_DIM*Y_DIM;
global failed_node_num
failed_node_num = 0;
global failed_node_vec
failed_node_vec = [];
global Dead_lock_circle_constraint 
Dead_lock_circle_constraint = 0;
global Turn_constraint
Turn_constraint = 0;
global Nchip
Nchip = 1;

% load('Dataset/MLP_154core_2048-1024-1024-1024-512-384 (2).mat')
% 
LUTPost = zeros(512,nnode);

% LUTPost(1:256,12) = 5; % 4x4
% LUTPost(1:256,9) = 1;
% LUTPost(257,1) = 11;
% LUTPost(257,11) = 9;

LUTPost(1:256,2) = 11; % 4x4
LUTPost(1:256,12) = 5;
LUTPost(1:256,9) = 1;
LUTPost(257,1) = 4;
LUTPost(257,11) = 9;

% LUTPost(1:256,1) = 5; % 3x3
% LUTPost(1:256,5) = 1;
% LUTPost(1:256,2) = 5;
% LUTPost(1:256,4) = 1;
% LUTPost(257,1) = 2;
% LUTPost(257,5) = 4;

save sample.mat LUTPost
global File_path
File_path = 'sample.mat';
% SA

% xy;