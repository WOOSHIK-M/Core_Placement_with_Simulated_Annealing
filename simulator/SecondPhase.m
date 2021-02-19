function [net, cnt, z_final] = SecondPhase(com_info, net, cnt)

global Nchip

%% runSecondPhase

z_final = [];
net_copy = net;

% delete weight in same cluster
for i = 1:length(com_info)
    if isempty(com_info(i).cores)
        continue
    else
        in_weight_vec = com_info(i).cores;
        net_copy(in_weight_vec, in_weight_vec) = 0;
    end
end

% Add row
net_coppy = zeros(length(com_info));
for i = 1:length(com_info)
    if isempty(com_info(i).cores)
        continue
    else
        for j = 1:length(com_info(i).cores)
            net_coppy(i,:) = net_coppy(i,:) + net_copy(com_info(i).cores(j),:);
        end
    end 
end

% Add column
net_copppy = zeros(length(com_info));
for i = 1:length(com_info)
    if isempty(com_info(i).cores)
        continue
    else
        for j = 1:length(com_info(i).cores)
            net_copppy(:,i) = net_copppy(:,i) + net_coppy(:,com_info(i).cores(j));
        end
    end
end

net = net_copppy;

M = net + net';

num_com = 0;
for i = 1:length(com_info)
    if isempty(com_info(i).cores) == 0
        num_com = num_com + 1;
    end
end

if cnt ~= 0 || num_com <= Nchip    
    count =1;
    for i = 1:length(net)
        for j = 1:length(net)
            if net(i,j) ~= 0
                z_final(count).source = i;
                z_final(count).dest = j;
                z_final(count).weight = net(i,j);
                count = count + 1;
            end
        end
    end
end

if num_com <= Nchip && cnt < 3
    fprintf('\n')
    disp('==> Traffic Packet info:')
    for i = 1:length(M)
        for j = i:length(M)
            if M(i,j) ~= 0
                strr = ['     "Node_' int2str(i)  '" and "Node_' int2str(j) '" have connection: "'  int2str(M(i,j)) ' packets"' ];
                disp(strr)
            end
        end
    end
    fprintf('\n')
    disp_final = ['     Final network has ' int2str(sum(sum(net))) ' edge weight !'];
    disp(disp_final)
    fprintf('\n')
end

end

