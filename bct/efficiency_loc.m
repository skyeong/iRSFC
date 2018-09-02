function Eloc = efficiency_loc(Cij, weightmode)

N=length(Cij);                        % number of nodes
Eloc=zeros(N,1);                      % local efficiency

if (weightmode),
    for u=1:N
        V=find(Cij(u,:));                 % neighbors
        k=length(V);                      % degree
        if k>=2;
            %ed = length(Cij(V,V));
            %D = dijkstra_shortest_path(single(Cij(V,V)), 1, ed); % degree must be at least two
            D = distance_wei(Cij(V,V));
            [~, leff] = charpath(D);
            Eloc(u)=leff;                 % local efficiency
        end
    end
    
else
    for u=1:N
        V=find(Cij(u,:));                 % neighbors
        k=length(V);                      % degree
        if k>=2;                          % degree must be at least two
            D = distance_bin(Cij(V,V));
            [~, leff] = charpath(D);
            Eloc(u) = leff;                 % local efficiency
        end
    end
end
