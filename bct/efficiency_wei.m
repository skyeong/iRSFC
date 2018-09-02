function E=efficiency_wei(G,local)
%EFFICIENCY     Global efficiency, local efficiency.
%
%   Eglob = efficiency(A);
%   Eloc = efficiency(A,1);
%
%   The global efficiency is the average of inverse shortest path length,
%   and is inversely related to the characteristic path length.
%
%   The local efficiency is the global efficiency computed on the
%   neighborhood of the node, and is related to the clustering coefficient.
%
%   Inputs:     A,              weighted directed/undirected connection matrix
%               local,          optional argument
%                               (local=1 computes local efficiency)
%
%   Output:     Eglob,          global efficiency (scalar)
%               Eloc,           local efficiency (vector)
%
%
%   Jinhua Sheng, 2010

if ~exist('local','var')
    local=0;
end

if local                                %local efficiency
    N=length(G);                        %number of nodes
    E=zeros(N,1);                       %local efficiency
    
    parfor u=1:N
        V=find(G(u,:));                 %neighbors
        k=length(V);                    %degree
        if k>=2;                        %degree must be at least two
            e=distance_inv(G(V,V));
            E(u)=sum(e(:))./(k^2-k);	%local efficiency
        end
    end
else
    N=length(G);
    e=distance_inv(G);
    E=sum(e(:))./(N^2-N);               %global efficiency
end




function D=distance_inv(g)

n=length(g);
D=zeros(n); D(~eye(n))=inf;                 %distance matrix

for u=1:n
    
    S=true(1,n);                            %distance permanence (true is temporary)
    G1=g;
    V=u;
    while 1
        S(V)=0;                             %distance u->V is now permanent
        G1(:,V)=0;                          %no in-edges as already shortest
        for v=V
            W=find(G1(v,:));                %neighbours of shortest nodes
            D(u,W)=min([D(u,W);D(u,v)+G1(v,W)]); %smallest of old/new path lengths
        end
        
        minD=min(D(u,S));
        if isempty(minD)||isinf(minD),      %isempty: all nodes reached;
            break,                          %isinf: some nodes cannot be reached
        end;
        
        V=find(D(u,:)==minD);
    end
end
D(~D)=inf;                      %disconnected nodes are assigned d=inf;
D=1./D;                         %invert distance
