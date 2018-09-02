function fmri_graph_analysis(handles)
global GRAPH



%  Path for Adjacency Matrix
%__________________________________________________________________________

tic;
thr_method = GRAPH.thr_method;
OUTpath    = GRAPH.OUTpath;
path_adj   = GRAPH.Aijpath;
subjlist   = GRAPH.subjList;
nsubj      = length(subjlist);
nRnd       = 1000;



%  Load basic information of the functional network
%__________________________________________________________________________

fn_mat = sprintf('network_%s.mat',subjlist{1});
MAT = load(fullfile(path_adj,fn_mat),'R','Z','P');
R_ref = MAT.R; nrois = length(R_ref); clear MAT;


%  index for upper triangular matrix
%__________________________________________________________________________

U = ones(nrois,nrois);
U = triu(U,1);
idxU = find(U>0);


%  Load basic information of the functional network
%__________________________________________________________________________

fn_mat = sprintf('network_%s.mat',subjlist{1});
MAT = load(fullfile(path_adj,fn_mat),'R','Z','P');
R_ref = MAT.R; nrois = length(R_ref); clear MAT;


% network property
SWN            = zeros(nsubj,6);
linkCollection = struct();


fprintf('\n\n=======================================================================\n');
fprintf('  COMPUTE SMALL WORLD NETWORK PROPERTIES\n');
fprintf('=======================================================================\n');

for c=1:nsubj,
    fprintf('    : [%03d/%03d] subj%s is in analyzing... (%.1f min.) \n',c,nsubj,subjlist{c},toc/60);
    msg_on_handle = sprintf('%s is analyzing.',subjlist{c}); pause(0.1);
    set(handles.text_status,'String',msg_on_handle);
    
    fn_mat = sprintf('network_%s.mat',subjlist{c});
    load(fullfile(path_adj,fn_mat),'R','Z','P');
    
    % Thresholding link weights (FDR)
    Wij = zeros(nrois,nrois);
    if strcmp(thr_method,'FDR'),
        idvalid     = intersect(find(R>0), idxU);
        pvals       = P(idvalid);
        [h, crit_p] = fdr_bh(pvals,0.05);
        idxthr      = intersect(find(P<crit_p), find(R>0));
        idxthr      = intersect(idxthr, idxU);
        Wij(idxthr) = R(idxthr);
    elseif strcmp(thr_method,'Bonferroni'),
        alpha       = 0.05/length(idxU);
        idxthr      = intersect(find(P<alpha), find(R>0));
        idxthr      = intersect(idxthr, idxU);
        Wij(idxthr) = R(idxthr);
    end
    Wij = Wij + Wij';
    
    % Collect Link Weights
    linkCollection(c).weight = R(idxthr);
    linkCollection(c).nLink  = length(idxthr);
    
    
    % Compute Small World Properties   
    [Eg, Eloc, pathlen, Cg, nConnected] = calc_swn_property(Wij);
    [ci,Q] = modularity_und(Wij);
    SWN(c,:) = [Eg, Eloc, pathlen, Cg, Q, nConnected];
    
    % Compute Nodal Properties
    DEG(c,:) = sum(Wij);
end



% Generate Random Network
%______________________________________________________________________

set(handles.text_status,'String','Generate random network'); pause(0.1);
SWNrnd = zeros(nRnd,4);
parfor i=1:nRnd,
    subjid = randperm(nsubj);
    n_edges = linkCollection(subjid(1)).nLink;
    idxmix = randperm(n_edges);
    weights = linkCollection(subjid(1)).weight;
    Grnd = makerandCij_wu(nrois, n_edges, weights(idxmix));    % Generate the Random Network
    [eg_, eloc_, lambda_, gamma_] = calc_swn_property(Grnd);
    SWNrnd(i,:) = [eg_, eloc_, lambda_, gamma_];
end
RND = mean(SWNrnd);
nSWN = bsxfun(@rdivide, SWN(:,1:4), RND);


% Write results
%______________________________________________________________________

set(handles.text_status,'String','Write results'); pause(0.1);

if strcmp(thr_method,'FDR'),
    fn_out = fullfile(OUTpath,'FC_swn_fdr.mat');
elseif strcmp(thr_method,'Bonferroni'),
    fn_out = fullfile(OUTpath,'FC_swn_bonferroni.mat');
end
swnvars = {'Eg','Eloc','pathlen','Cg','modularity','nConnedted'};
save(fn_out,'SWN','nSWN','SWNrnd','DEG','swnvars','subjlist');

set(handles.text_status,'String','Done.'); pause(0.1);




function [Eg, Eloc, Lambda, Cg, nConnected, gCom] = calc_swn_property(Wij)

[C, Cg] = clustering_coef_wu(Wij);        % clustering coefficients

n = length(Wij);
invWij = Wij;
invWij(invWij>0) = 1./invWij(invWij>0);   % inverse matrix 1./wij
D = dijkstra_shortest_path(single(invWij),1,n);
D(D>=(n-1))=inf;
gCom = find(isfinite(D(1,:)));
nConnected = length(gCom);
Lambda = charpath(D);                     % characteristic path length

Eg = efficiency_wei(invWij,0);            % global efficiency
leff_ = efficiency_wei(invWij,1);         % local efficiency
Eloc = mean(leff_);                       % averaged local efficiency
