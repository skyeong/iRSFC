function [geff, leff, pathlen, Cg] = calc_swn_property(rthr,R)

% Options for pathlenth evaluation
diagonal_dist=0;
infinite_dist=0;

n = length(R);
nthr = length(rthr);
geff = zeros(nthr,1);
leff = zeros(nthr,1);
pathlen = zeros(nthr,1);
Cg = zeros(nthr,1);

for i=1:nthr,
    G = R;                               % clone data from un-thresholded graph
    G(G<rthr(i)) = 0;                    % thresholding
    G(G>0) = 1;                          % binarize
    
    Ci = clustering_coef_bu(G);          % clustering coefficients
    D = dijkstra_shortest_path(single(G),1,n);
    % D = distance_bin(G);               % distance matrix
    D(D>=(n-1))=inf;
   
    [pathlen_,Eg] = charpath(D,diagonal_dist,infinite_dist);              % characteristic path length
    Ei = efficiency_bin(G,1);         % local efficiency
    
    geff(i) = Eg;
    leff(i) = mean(Ei);
    pathlen(i) = pathlen_;
    Cg(i) = mean(Ci);
end

