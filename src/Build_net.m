load(File_path)
% LUTPost = LUTOpt;
% global m
global Nchip
global Ncore

%% Build node_org
node_org.connected_to_cores = [];
node_org.connected_to_packets = [];
node_org.is_mul = 0;
node_org.mul_dest = [];
node_org.mul_packets = [];
packet_org.source = [];

for i = 1:size(LUTPost, 2)
    connected_to_cores = [];
    mul_dest = [];
    % Single Route
    for j = 1:size(LUTPost, 1)
        if LUTPost(j,i) ~= 0
            if j <= length(LUTPost)/2
                connected_to_cores = [connected_to_cores LUTPost(j,i)];
            else
                mul_dest = [mul_dest LUTPost(j,i)];
            end
        end
    end
    connect = unique(connected_to_cores);
    node_org(i).connected_to_cores = connect;
    for k = 1:length(node_org(i).connected_to_cores)
        node_org(i).connected_to_packets = [node_org(i).connected_to_packets length(find(connect(k) == connected_to_cores))];
    end
    % Multicast
    if isempty(mul_dest) == 1
        node_org(i).is_mul = 0;
    else
        node_org(i).is_mul = 1;
    end
    connect_mul = unique(mul_dest);
    node_org(i).mul_dest = connect_mul;
    for k = 1:length(node_org(i).mul_dest)
        node_org(i).mul_packets = [node_org(i).mul_packets length(find(connect_mul(k) == mul_dest))];
    end
    node_org(i).community = i;
    node_org(i).community_member = i;
    % ALL
    node_org(i).all_cores = [node_org(i).connected_to_cores node_org(i).mul_dest];
    node_org(i).all_packets = [node_org(i).connected_to_packets node_org(i).mul_packets];
end

%% Build net
net = zeros(length(node_org));
for i = 1:length(node_org)
    for j = 1:length(node_org(i).connected_to_cores)
        net(i, node_org(i).connected_to_cores(j)) = node_org(i).connected_to_packets(j);
    end
    if node_org(i).is_mul == 1
        for j = 1:length(node_org(i).mul_dest)
            net(i, node_org(i).mul_dest) = net(i, node_org(i).mul_dest) + node_org(i).mul_packets(j);
        end
    end
end

net_chip = zeros(Nchip);
for i = 1:length(net)
    for j = 1:length(net)
        if net(i,j) ~= 0 && floor((i-1)/Ncore) ~= floor((j-1)/Ncore)
            net_chip(floor((i-1)/Ncore)+1, floor((j-1)/Ncore)+1) = net_chip(floor((i-1)/Ncore)+1, floor((j-1)/Ncore)+1) + net(i,j);
        end
    end
end        

save 4_chip_prev.mat net_chip

%% Build packet_org (no consider multicast) & connection
packet_org.source = [];
packet_org.dest = [];
count_packet_org = 1;
count_connection_struct = 1;

connection_org.cores = [];
connection_org.weight = [];

m = 0;

for i = 1:length(net)
    for j = 1:length(net)
        if net(i,j) ~= 0
            for k = 1:net(i,j)
                packet_org(count_packet_org).source = i;
                packet_org(count_packet_org).dest = j;
                count_packet_org = count_packet_org + 1;
            end
            connection_org(count_connection_struct).cores = sort([i,j]);
            connection_org(count_connection_struct).weight = 2*net(i,j);
            connection_org(count_connection_struct).is_same_community = 0;
            connection_org(count_connection_struct).community_member = [];
            count_connection_struct = count_connection_struct + 1;
            m = m + net(i,j);
        end
    end
end

%% Build community info.
for i = 1:length(node_org)
    community_org(i).node = i;
end

% Delete blank lines
% if is_del == 1
%     del_i = [];
%     for i = 1:length(net)
%         if all(net(i,:) == 0) && all(net(:,i) == 0)
%             del_i = [del_i i];
%         end
%     end
%     net(del_i,:) = [];
%     net(:,del_i) = [];
% end

