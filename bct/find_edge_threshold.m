function rthr = find_edge_threshold(R, sparsity)

% sort positive r-values in descending order

[m, n] = size(R);

if m==n,
    n = length(R);
    e = n*(n-1);
else
    e = m*n;
end
sorted_Gp = sort(R(:),'descend');
n_cut_pos = round(e*sparsity);
rthr = sorted_Gp(n_cut_pos);