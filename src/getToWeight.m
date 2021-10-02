function [weight] = getToWeight(nt_copy, node)

weight = 0;
node_com = nt_copy(node).community;
for i = 1:length(nt_copy)
    if node_com == nt_copy(i).community && i ~= node
        weight = weight + sum(nt_copy(i).weight);
    end
end

end

