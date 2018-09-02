function [Cij] = makerandCij_wu(N,K,R)
%MAKERANDCij_UND        Synthetic directed random network
%
%   Cij = makerandCij_wu(N,K);
%
%   This function generates an undirected random network
%
%   Inputs:     N,      number of vertices
%               K,      number of edges
%
%   Output:     Cij,    undirected random connection matrix
%
%   Note: no connections are placed on the main diagonal.
%
%
% Olaf Sporns, Indiana University, 2007/2008

ind = triu(~eye(N));
i = find(ind);
rp = randperm(length(i));
irp = i(rp);

Cij = zeros(N);
Cij(irp(1:K)) = 1;

idx = find(Cij>0); K = length(idx);
Rval = R(1:K);
Cij(idx) = Rval(randperm(K));
Cij = Cij+Cij';         % symmetrize
