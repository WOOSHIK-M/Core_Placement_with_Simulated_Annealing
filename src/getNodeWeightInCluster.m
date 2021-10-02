function [weight] = getNodeWeightInCluster(nt_copy, node)

weight = 0;
for i = 1:length(nt_copy(node).node)
    if nt_copy(nt_copy(node).node(i)).community == nt_copy(node).community
        weight = weight + nt_copy(node).weight(i);
    end
end

end

