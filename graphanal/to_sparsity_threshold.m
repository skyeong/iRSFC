function rank_thr = to_sparsity_threshold(n,S)
%TO_SPARSITY_THRESHOLD
%
% Input
%  - n : the number of nodes
%  - S : network sparsity (percent scale)
%
% Output
%  - cost : the number of edges corresponding to network cost
%
% Example :
%  S = 0.05:0.01:0.5;
%  n = 90;
%  thr = TO_SPARSITY_THRESHOLD(n,S);


rank_thr  = size(S,2);
for j=1:length(S),
    sparsity = S(j);
    c = round(sparsity*(n*(n-1)/2));
    rank_thr(j) = c;
end