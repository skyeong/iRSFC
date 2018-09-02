function [Eg, Eloc, Gamma, Lambda] = calc_auc_swnvars(rthr,R)

n = length(R);
nthr = length(rthr);
geff = zeros(nthr,1);
leff = zeros(nthr,1);
lambda = zeros(nthr,1); % path length
gamma = zeros(nthr,1);  % clustering coeff

for i=1:nthr,
    G = R;                               % clone data from un-thresholded graph
    G(G<rthr(i)) = 0;                    % thresholding
    G(G>0) = 1;                          % binarize
    
    % clustering coefficients
    [~, Cg] = clustering_coef_bu(G);
    gamma(i) = Cg;
    
    % characteristic path length
    D = distance_bin(G);                 % distance matrix
    lambda(i) = charpath(D);
    
    
    Eg = efficiency_bin(G,0);            % global efficiency
    leff_ = efficiency_bin(G,1);         % local efficiency
    Eloc = sum(leff_) / n;               % averaged local efficiency
    
    geff(i) = Eg;
    leff(i) = Eloc;
end

Eg = sum(geff);
Eloc = sum(leff);
Gamma = sum(gamma);
Lambda = sum(lambda);

