function avgSWN = fmri_generate_rndnet(S,n,niter)

% sparsity threshold
% n = 142;
e = n*(n-1)/2;
thr = to_sparsity_threshold(n,S);
nthr = length(thr);



% network property
SWN   = zeros(niter,nthr,4);
swnvars = {'Eg','Eloc','pathlen','Cg'};

fprintf('\n\n=======================================================================\n');
fprintf('  GENERATE RANDOM NETWORK\n');
fprintf('=======================================================================\n');

% K = round(e*S(end));
for i=1:nthr,
    
    K = round(e*S(i));
    
    Eg      = zeros(niter,1);
    Eloc    = zeros(niter,1);
    Cg      = zeros(niter,1);
    pathlen = zeros(niter,1);
    
    parfor j=1:niter,
        
        [geff_, leff_, pathlen_, cg_] = parallel_processing(n,K);
        Eg(j) = geff_;
        Eloc(j) = leff_;
        Cg(j) = cg_;
        pathlen(j) = pathlen_;
        
    end
    SWN(:,i,:) = [Eg, Eloc, pathlen, Cg];
    fprintf('    : random network with sparsity = %.2f is generated.\n',S(i));
end


avgSWN = squeeze(mean(SWN,1));

function [Eg, Eloc, pathlen, Cg] = parallel_processing(n,K)

G = makerandCIJ_und(n,K);            % Generate the Random Network

Ci = clustering_coef_bu(G);          % clustering coefficients
D = dijkstra_shortest_path(single(G),1,n);
D(D>=(n-1))=inf;

% Options for pathlenth evaluation
diagonal_dist=0;
infinite_dist=0;
[pathlen_,Eg] = charpath(D,diagonal_dist,infinite_dist);

Ei = efficiency_bin(G,1);            % local efficiency
Eloc = mean(Ei);                     % averaged local efficiency
pathlen = pathlen_;               % characteristic path length
Cg = mean(Ci);

