function  [Cij,K] = makefractalCij(mx_lvl,E,sz_cl)
%MAKEFRACTALCij     Synthetic hierarchical modular network
%
%   [Cij,K] = makefractalCij(mx_lvl,E,sz_cl);
%
%   This function generates a directed network with a hierarchical modular
%   organization. All modules are fully connected and connection density
%   decays as 1/(E^n), with n = index of hierarchical level.
%
%   Inputs:     mx_lvl,     number of hierarchical levels, N = 2^mx_lvl
%               E,          connection density fall-off per level
%               sz_cl,      size of clusters (power of 2)
%
%   Outputs:    Cij,        connection matrix
%               K,          number of connections present in the output Cij
%
%
% Olaf Sporns, Indiana University, 2005/2007

% make a little template
t = ones(2).*2;

% compute N and cluster size
N = 2^mx_lvl;
sz_cl = sz_cl-1;

n = [0 0 0:mx_lvl-3];

for lvl=1:mx_lvl-1
    Cij = ones(2^(lvl+1),2^(lvl+1));
    group1 = [1:size(Cij,1)/2];
    group2 = [size(Cij,1)/2+1:size(Cij,1)];
    Cij(group1,group1) = t;
    Cij(group2,group2) = t;
    Cij = Cij+ones(size(Cij,1),size(Cij,1));
    t = Cij;
end;
s = size(Cij,1);
Cij = Cij-ones(s,s)-mx_lvl.*eye(s);

% assign connection probablities
ee = mx_lvl-Cij-sz_cl;
ee = (ee>0).*ee;
prob = (1./(E.^ee)).*(ones(s,s)-eye(s));
Cij = (prob>rand(N));

% count connections
K = sum(sum(Cij));

