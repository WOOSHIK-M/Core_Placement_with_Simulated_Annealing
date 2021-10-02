function netplot(node,nnode)
    %% 画图
global X_DIM;
global Y_DIM;
    hold on;
    
    for i=1:nnode
        [x,y]=meshgrid(0:1:X_DIM,0:1:Y_DIM);
        plot(x,y,'k',x',y','k');
        axis tight;
        plot(node(i).x + 0.5, node(i).y + 0.5, 'r*');
        text(node(i).x + 0.5, node(i).y + 0.5, num2str(i), 'Fontsize', 16, 'color', 'r');     %显示点的序号
        if(node(i).connected_to_cores_num > 0)
            for j=1:node(i).connected_to_cores_num
                c = num2str(node(i).connected_to_packet_num(j));
                text((node(i).x + 0.5 + node(node(i).connected_to_cores(j)).x + 0.5)/2 , (node(i).y + 0.5 + node(node(i).connected_to_cores(j)).y + 0.5) / 2 , c ,'Fontsize',12);          %显示边的权值
                line([node(i).x + 0.5 node(node(i).connected_to_cores(j)).x + 0.5] , [node(i).y + 0.5 node(node(i).connected_to_cores(j)).y + 0.5],'linewidth',1,'color','b');
            end
        end
    end

    hold off;
end