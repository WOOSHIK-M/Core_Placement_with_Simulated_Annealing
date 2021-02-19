function MWS_plot_traffic(net)

global X_DIM
global Y_DIM
M = X_DIM;
N = Y_DIM;
NODE_NUM = M*N;

figure(200)
G=digraph(net);
is_zigzag = 1;

for i=1:NODE_NUM                             % 随机（顺序排列）初始化各节点坐标
    if is_zigzag == 1
        x(i) = mod(i-1,M);
    else
        if mod(floor((i-1)/M),2) == 1
            x(i) = M - 1 - mod(i-1,M);
        else
            x(i) = mod(i-1,M);
        end
    end
    y(i) = floor((i-1)/X_DIM);
end

max_weight = max(max(net));

% LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
LWidths = 5*G.Edges.Weight/max_weight;

p=plot(G,'Layout','force','EdgeLabel',G.Edges.Weight);
p.XData=x;
p.YData=y;
p.LineWidth = LWidths;
% p.EdgeLabel=G.Edges.Weight;
% p.EdgeCData = G.Edges.Weight/max_weight;
p.EdgeCData = G.Edges.Weight;
p.EdgeColor='flat';
p.EdgeAlpha=1;
p.Marker = 's';
p.MarkerSize = 10;
p.NodeLabel = cell(0);
p.NodeColor = 'k';
p.ArrowSize = 20;

colormap jet;

axis ij;
end