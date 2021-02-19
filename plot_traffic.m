function result = plot_traffic(net,max_weight)

global Nchip
G=digraph(net);

for i=1:1:Nchip
    x(i) = mod(i-1,2);
    y(i) = floor((i-1)/2);
end

% LWidths = 5*G.Edges.Weight/max(G.Edges.Weight);
LWidths = 5*G.Edges.Weight/max_weight;

p=plot(G);
p.XData=x;
p.YData=y;
p.LineWidth = LWidths;
p.EdgeLabel=G.Edges.Weight;
% p.EdgeCData = G.Edges.Weight/max_weight;
p.EdgeCData = G.Edges.Weight;
p.EdgeColor='flat';
p.EdgeAlpha=1;
p.Marker = 's';
p.MarkerSize = 50;
p.NodeLabel = cell(0);
p.NodeColor = 'k';
p.ArrowSize = 20;

colormap jet;

axis ij;

end