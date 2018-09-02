function [EBC BC] = edge_betweenness(Cij, weightmode)


if (weightmode),
    [EBC BC] = edge_betweenness_wei(Cij);
else
    [EBC BC] = edge_betweenness_bin(Cij);
end



