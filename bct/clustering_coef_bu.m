function [C, Cg, tn]=clustering_coef_bu(G)
%CLUSTERING_COEF_BU     Clustering coefficient
%
%   C = clustering_coef_bu(G);
%
%   The clustering coefficient is the fraction of triangles around a node
%   Input:      G,      binary undirected connection matrix
%
%   Output:     C,      clustering coefficient of node i
%   Output:     Cg,     average of C
%   Output:     tn,     number of triangles
%
%   Reference: Watts and Strogatz (1998) Nature 393:440-442.
%   Mika Rubinov, UNSW, 2007-2010


% motif: number of triangles
n = length(G);            % number f nodes
k = sum(G,2);             % degree of each node
tn = diag(G*triu(G)*G);   % number of triangles for each node

% local clustering coefficient
C = zeros(size(k));
C(k>1) = 2*tn(k>1)./(k(k>1).*(k(k>1)-1));  % C = 0 if k<2;

% global clustering coefficient
Cg = sum(C(k>1))/n;

