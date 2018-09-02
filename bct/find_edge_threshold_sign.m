function [threshold_pos, threshold_neg] = find_edge_threshold_sign(R, sparsity)


% sort positive r-values in descending order
sorted_Gp = sort(R(R>0),'descend');
n_edge_pos = length(sorted_Gp);
n_cut_pos = round(n_edge_pos*sparsity);
threshold_pos = sorted_Gp(n_cut_pos);

% sort |negative r-values| in descending order
sorted_Gn = sort(abs(R(R<0)),'descend');
n_edge_neg = length(sorted_Gn);
n_cut_neg = round(n_edge_neg*sparsity);
threshold_neg = -sorted_Gn(n_cut_neg);