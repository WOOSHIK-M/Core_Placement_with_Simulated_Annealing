% Description：初始化连接关系

%% 定义芯片参数

CHIP_M = 2;         % X方向的chip数量
CHIP_N = 2;         % Y方向的chip数量
CHIP_NUM = CHIP_M * CHIP_N;     %总的chip数量

M = 13;             % 每个芯片中X方向的core数量
N = 12;             % 每个芯片中Y方向的core数量
NODE_NUM = M*N;     % 每个芯片中总的core数量

ALL_NODE_NUM = NODE_NUM * CHIP_NUM;     % 板子上总的core数量

LUTTemp = LUTPost;
% placement = 'random';       % 布局选择

global BUFF_SIZE;
BUFF_SIZE = 2;      % buffer size

STEP = 5000000;     % based on time cycles
VIR_CHAN = 1;       % virtual channel number
INTERVAL = 0;       % injection interval

% dy_inuse = zeros(5,STEP);   % for dynamic inuse statistic
% total_cycle = zeros(1,5);
% max_time = zeros(1,5);

save data.mat M N NODE_NUM CHIP_M CHIP_N CHIP_NUM ALL_NODE_NUM BUFF_SIZE STEP VIR_CHAN INTERVAL;

%% 定义连接关系

% if strcmp(placement,'random')
%     load('LUT_random.mat');
%     LUTTemp = LUT_random;
% elseif strcmp(placement,'zigzag')
%     load('LUT_zigzag.mat');
%     LUTTemp = LUT_zigzag;
% elseif strcmp(placement,'opt_cyclic')
%     load('LUT_opt_cyclic.mat');
%     LUTTemp = LUT_opt;
% elseif strcmp(placement,'opt_two')
%     load('LUT_opt_two.mat');
%     LUTTemp = LUT_opt; 
% end

i = 1;
for j = 1:ALL_NODE_NUM
    for k = 1:256
        if LUTTemp(k,j) > 0
            S(i) = j;
            D(i) = LUTTemp(k,j);
            i = i + 1;
        end
    end
end

for i = 1:ALL_NODE_NUM                               % 生成路由表 LUT
    for j = 1:ALL_NODE_NUM
        LUT(i,j) = sum(LUTTemp(1:256,i) == j);
    end
end

for i = 1:ALL_NODE_NUM                              % 生成多播表 LUT_M
    for j = 1:ALL_NODE_NUM
        LUT_M(i,j) = sum(LUTTemp(257:512,i) == j);
    end
end

%% 构建节点

for i = 1:ALL_NODE_NUM                               % 导入连接关系和每个节点发送的包数
    find_to = find(LUT(i,:));
    send_node_num(i) = length(find_to);
    for k = 1:send_node_num(i)
        node_org(i).connected_to_cores(k) = find_to(k);
        node_org(i).connected_to_cores_num = sum(node_org(i).connected_to_cores>0);
        node_org(i).connected_to_packet_num(k) = LUT(i,find_to(k));
    end
end

 for i = 1:ALL_NODE_NUM                              % 导入多播连接关系和每个多播core发送的包数
     node_org(i).mul_en = 0;
 end
 
%  for i = 1:ALL_NODE_NUM                              % 导入多播连接关系和每个多播core发送的包数
%     find_multi_to = find(LUT_M(i,:));
%     multi_to_num(i) = length(find_multi_to);
%     for k = 1:multi_to_num(i)
%         node_org(i).multi_to_cores(k) = find_multi_to(k);
%         node_org(i).mul_en = ~isempty(node_org(i).multi_to_cores);
%         if node_org(i).mul_en
%             node_org(i).multi_chip = floor((node_org(i).multi_to_cores(k)-1)/NODE_NUM);
%             node_org(i).multi_chip_x = mod(node_org(i).multi_chip, CHIP_M);
%             node_org(i).multi_chip_y = floor(node_org(i).multi_chip/CHIP_M);
%             node_org(i).multi_dst_x = mod(node_org(i).multi_to_cores(k)-1,M);
%             node_org(i).multi_dst_y = floor((node_org(i).multi_to_cores(k)-1)/M) - node_org(i).multi_chip(k)*N;
%         end
%     end
%  end

for i = 1:ALL_NODE_NUM
    node_org(i).left = 0;       % left buffer, number of packets in this buffer in current cycle
    node_org(i).left_pack = []; % the packets in left buffer
    node_org(i).left_out = 0;   % number of packets being processed from this buffer, used in virtual channel
    node_org(i).left_full = 0;  % left buffer full
    node_org(i).left_empty = 1; % left buffer empty
    node_org(i).right = 0;
    node_org(i).right_pack = [];
    node_org(i).right_out = 0;
    node_org(i).right_full = 0;
    node_org(i).right_empty = 1;
    node_org(i).up = 0;
    node_org(i).up_pack = [];
    node_org(i).up_out = 0;
    node_org(i).up_full = 0;
    node_org(i).up_empty = 1;
    node_org(i).down = 0;
    node_org(i).down_pack = [];
    node_org(i).down_out = 0;
    node_org(i).down_full = 0;
    node_org(i).down_empty = 1;
    node_org(i).local_in = sum(node_org(i).connected_to_packet_num);   % local buffer, number of packets in local, buffer size is infinite
    node_org(i).local_in_pack = [];    % the packets in local buffer(the packets waiting send to network)
    node_org(i).local_in_out = 0;      % each source node can send out only one packet in each cycle
    node_org(i).local_in_empty = 1;
    node_org(i).local_out = 0;
    node_org(i).local_out_pack = [];
    node_org(i).local_out_out = 0;
    node_org(i).local_out_full = 0;
    node_org(i).local_out_empty = 1;

    node_org(i).time = 0;       % injection time counter 
end

for i = 1:ALL_NODE_NUM
    nnn = 0;
    mmm = 0;
    for j = 1:i-1 
        nnn = nnn + node_org(j).local_in;
    end
    mmm = nnn + node_org(i).local_in;
    node_org(i).local_in_pack = [nnn + 1 : mmm];
    node_org(i).local_in_empty = isempty(node_org(i).local_in_pack);
end



%% 统计发包总数
PACK_NUM = 0;
for i=1:ALL_NODE_NUM
    for j=1:node_org(i).connected_to_cores_num
        PACK_NUM = PACK_NUM + node_org(i).connected_to_packet_num(j);   % 计算发送总包数
    end
end

%% 构建路由包
for i = 1:PACK_NUM
    
    pack_org(i).src_chip = floor((S(i)-1)/NODE_NUM) + 1;         % source node chip
    pack_org(i).src_chip_x = mod(pack_org(i).src_chip-1, CHIP_M);         % source node chip x
    pack_org(i).src_chip_y = floor((pack_org(i).src_chip-1)/CHIP_M);         % source node chip y
    
    pack_org(i).src_x = mod(S(i)-1, M);         % source node x
    pack_org(i).src_y = floor((S(i)-1)/M) - (pack_org(i).src_chip-1) * N;      % source node y
    
    pack_org(i).dst_chip = floor((D(i)-1)/NODE_NUM) + 1;         % destination node chip
    pack_org(i).dst_chip_x = mod(pack_org(i).dst_chip-1, CHIP_M);         % source node chip x
    pack_org(i).dst_chip_y = floor((pack_org(i).dst_chip-1)/CHIP_M);         % source node chip y
    
    pack_org(i).dst_x = mod(D(i)-1, M);         % destination node x
    pack_org(i).dst_y = floor((D(i)-1)/M) - (pack_org(i).dst_chip-1) * N;      % destination node y
    
    pack_org(i).coor_x = pack_org(i).src_chip_x * M + pack_org(i).src_x;         % source node x
    pack_org(i).coor_y = pack_org(i).src_chip_y * N + pack_org(i).src_y;      % source node y
    
    pack_org(i).cross_time = 0;
    pack_org(i).last_node = S(i);               % the last node of this packet
    pack_org(i).move = 0;                       % one packet can route one step per cycle
                                                % 1 if this packet route in this cycle, 0 if this packet not route in this cycle
    
    pack_org(i).arr = 0;                        % 0 packet not arrive destination, 1 packet arrived destination
    pack_org(i).in_route = 0;                   % 0 packet is not in routing, 1 packet is in routing
    pack_org(i).time = 0;                       % packet transfer time
    pack_org(i).buff_pos = 0;                   % current buffer position
                                                % core: 0 for local_in, 1 for left, 2 for right, 3 for up, 4 for down, 5 for local_out
                                                % chip: 6 for chip left, 7 for chip right, 8 for chip up, 9 for chip down
end

%% 构建chip
for i = 1:CHIP_NUM
    chip_org(i).left = 0;
    chip_org(i).left_pack = [];
    chip_org(i).left_out = 0;
    chip_org(i).left_full = 0;
    chip_org(i).left_empty = 1;
    chip_org(i).right = 0;
    chip_org(i).right_pack = [];
    chip_org(i).right_out = 0;
    chip_org(i).right_full = 0;
    chip_org(i).right_empty = 1;
    chip_org(i).up = 0;
    chip_org(i).up_pack = [];
    chip_org(i).up_out = 0;
    chip_org(i).up_full = 0;
    chip_org(i).up_empty = 1;
    chip_org(i).down = 0;
    chip_org(i).down_pack = [];
    chip_org(i).down_out = 0;
    chip_org(i).down_full = 0;
    chip_org(i).down_empty = 1;
end

save('data.mat','S','D','PACK_NUM','pack_org','node_org','chip_org','-append');