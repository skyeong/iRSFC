tic;  ST = clock;
close all; warning('off','all');
addpath('/Users/skyeong/connectome');
addpath('/Users/skyeong/connectome/bct');


%__________________________________________________________________________
%
%  OPEN PARALLEL TOOLBOX
%__________________________________________________________________________

npar=matlabpool('size');
if npar<1, matlabpool('open'); end;

[studies, subjlist, phenotype] = load_study_info('ADHD');
sites= phenotype.dat(:,1);
site = unique(sites);

%__________________________________________________________________________
%
%  SETUP DATA PATH AND OUTPUT DIRECTORY
%__________________________________________________________________________


PROJpath = studies{1}.PROJpath;
DATAprefix = studies{1}.DATAprefix;
DATApath = sprintf('%s/fmriAnal%s', PROJpath, DATAprefix);


%__________________________________________________________________________
%
%  LOAD EDGE INFORMATION
%__________________________________________________________________________

path_Aij=sprintf('%s/adjacency/%d',DATApath,nrois);
nsubj = length(subjlist);

fprintf('\n============================================\n');
fprintf('         Network balence Analysis  \n');
fprintf('============================================\n');

std_data = zeros(nsubj,1);
std_site = zeros(length(site),1);

for s=1:length(site),
    ss = site(s);
    idsite = find(sites==ss);
    
    std_s = zeros(length(idsite),1);
    for c=1:length(idsite),
        cc = idsite(c);
        fn_adj = sprintf('adjacency_%s.mat',subjlist{cc});
        load_Aij = sprintf('%s/%s',path_Aij,fn_adj);
        load(load_Aij);
        
        std_s(c) = std(mT(:));
    end
    std_site(s) = mean(std_s);
end



centers = {'NYU','Peking','KKI','OHSU','Pitt'};
nscans = [176, 236, 124, 78, 78, 196]-4;
nsubjs = [208, 176, 79, 68, 67];

rng('default');
RR = zeros(nsubj,nrois,nrois);
mc = struct([]);

for s=1:length(site),
    Sigma = std_site(s);
    ss = site(s);
    idsite = find(sites==ss);
    for i=1:length(idsite),
        cc = idsite(i);
        mT = Sigma*randn(nscans(s), 116);
        RR(cc,:,:) = corrcoef(mT);
    end
end

sparsity = 0.01:0.01:1.0;
BAL_cnt = zeros(nsubj,length(sparsity), 4);
BAL_frac = zeros(nsubj,length(sparsity), 4);

tic
for c=1:nsubj,
    
    
    fprintf('   : [%04d/%04d] is processing ...\n',c,nsubj);
    
    
    %  positive and negative graph / cut values
    %______________________________________________________________________
    
    R = squeeze(RR(c,:,:));
    
    [rthr_pos, rthr_neg] = find_edge_threshold_sign(R, sparsity);
    
    
    %  Network balence Analysis
    %______________________________________________________________________
    
    balcnt = zeros(length(sparsity), 4);
    
    parfor s=1:length(sparsity),
        G = R;
        G(G>=rthr_neg(s) & G<=rthr_pos(s)) = 0;
        
        b_cnt = count_triangle_motif(G, 0);
        balcnt(s,:) = b_cnt(:);
    end
    
    BAL_cnt(c,:,:) = balcnt;
    BAL_frac(c,:,:) = calc_balence_fraction(balcnt);
end
toc
