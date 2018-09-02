function [Cij] = makelatticeCij_wu(N,K,R)
%MAKELATTICECij     Synthetic lattice network
%
%   Cij = makelatticeCij_wu(N,K);
%
%   This function generates a directed lattice network without toroidal
%   boundary counditions (i.e. no ring-like "wrapping around").
%
%   Inputs:     N,      number of vertices
%               K,      number of edges
%
%   Outputs:    Cij,    connection matrix
%
%   Note: The lattice is made by placing connections as close as possible
%   to the main diagonal, without wrapping around. No connections are made
%   on the main diagonal. In/Outdegree is kept approx. constant at K/N.
%
%
%   Olaf Sporns, Indiana University, 2005/2007

% initialize
Cij = zeros(N);
Cij1 = ones(N);
KK = 0;
cnt = 0;
seq = 1:N-1;

% fill in
while (KK<K)
    cnt = cnt + 1;
    dCij = triu(Cij1,seq(cnt))-triu(Cij1,seq(cnt)+1);
    dCij = dCij+dCij';
    Cij = Cij + dCij;
    KK = sum(sum(Cij));
end;

% remove excess connections
overby = KK-K;
if(overby>0)
    [i j] = find(dCij);
    rp = randperm(length(i));
    for ii=1:overby
        Cij(i(rp(ii)),j(rp(ii))) = 0;
    end;
end;
Cij = triu(Cij,1);
idx = find(Cij>0); K = length(idx);

Rval = R(1:K);

Cij(idx) = Rval(randperm(K));
Cij = Cij + Cij';
