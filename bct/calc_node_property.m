function [DC, BC, IC] = calc_node_property(G)

G(G<0)=0;
DC = degrees_und(G);
% IC = information_centrality(G);
% BC = betweenness_wei(G);

IC = [];
BC = [];