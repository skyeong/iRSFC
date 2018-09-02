function [Z,R,P]=fmri_network_static(Y,DIM,seeds,idbrainmask)
% Y : either volume with DIM
%     or npoint x nscans
% SEEDs : either nseed x num of neighbor points
%         or nseed x nscans


dim1=size(Y);
if length(dim1)==4,
    Y  = reshape(Y,dim1(1:3),dim1(4));
    Y=Y(idbrainmask,:);
end;

npoint=size(Y,1);
nscans=size(Y,2);

sz=size(seeds,2);
nseed=sz(1);


% PCA for extracting Seed region Time Course
% zSEEDs= zeros(nscans,nseed);
% for s=1:nseed,
%     a1 = zeros([DIM(1:3),nscans]);
%     a1 = reshape(a1, prod(DIM(1:3)), nscans);
%     a1(idbrainmask,:) = Y;
%     
%     idroi=seeds{s}.idroi;
%     TC = a1(idroi,:);
%     [PCs,dwM,L,V,whiteM,sumAll] = icatb_calculate_pca(TC', 1);
%     mTC = mean(TC);
%     r = corrcoef(PCs(:),mTC(:));
%     if r(1,2)<0, PCs = -PCs; end;
%     
%     zSEEDs(:,s) = PCs(:,1);
% end
% clear a1 PCs TC;


% Averating for extracting Seed region Time Course
zSEEDs= zeros(nscans,nseed);
a1 = zeros(DIM(1:3));
for k=1:nscans,
    a1(idbrainmask)=Y(:,k);
    for s=1:nseed,
        idroi = seeds{s}.idroi;
        zSEEDs(k,s) = mean(a1(idroi));
    end;
end
clear a1;


[R,P] = corrcoef(zSEEDs);
R(eye(nseed)==1)=0;
Z = 0.5 * (log(1+R) - log(1-R+eps));


