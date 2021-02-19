function [num,list] = Try1(node)
%% multicast only up or down

num = 0;
list = [];
for i = 1:length(node)
    if node(i).multi_to_cores_num > 0
        mulx = node(i).x;
        muly = node(i).y;
        muldx = node(node(i).multi_to_cores).x;
        muldy = node(node(i).multi_to_cores).y;
        dis = abs(muly - muldy);
        
        if mulx ~= muldx || dis ~= 1
            num = num + 1;
            list = [list i]; % list can help more speed iterate
        end
    end
end

end

