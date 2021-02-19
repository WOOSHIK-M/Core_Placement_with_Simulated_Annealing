G=digraph(net);
figure();

for i=1:1:nnode                             % 随机（顺序排列）初始化各节点坐标
    x(i) = mod(i-1,X_DIM);
    y(i) = floor((i-1)/X_DIM);
end

LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);

p=plot(G);
p.XData=x;
p.YData=y;
p.LineWidth=LWidths;
% p.EdgeLabel=G.Edges.Weight;
p.EdgeCData=G.Edges.Weight/max(G.Edges.Weight);
p.EdgeColor='flat';
p.EdgeAlpha=0.8;
p.Marker = 's';
p.MarkerSize = 10;
% p.NodeLabel = node_covert;
p.NodeColor = 'k';
p.ArrowSize=12;

colormap jet;

axis ij;