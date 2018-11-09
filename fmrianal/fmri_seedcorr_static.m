function Z=fmri_seedcorr_static(Y,DIM,seeds,idbrainmask)
% Y : either volume with DIM
%     or npoint x nscans
% SEEDs : either nseed x num of neighbor points
%         or nseed x nscans


dim1=size(Y);
if length(dim1)==4
    Y = reshape(Y,dim1(1:3),dim1(4));
    Y = Y(idbrainmask,:);
end

npoint=size(Y,1);
nscans=size(Y,2);

sz=size(seeds,2);
nseed=sz(1);


% Averating for extracting Seed region Time Course
zSEEDs = zeros(nseed,nscans);
a1 = zeros(DIM(1:3));
for k=1:nscans
    a1(idbrainmask)=Y(:,k);
    for s=1:nseed
        idroi=seeds{s}.idroi;
        zSEEDs(s,k) = mean(a1(idroi));
    end
end
clear a1;



% CALCULATE CROSS-CORRELATION
%--------------------------------------------------------------------------

R = zeros(npoint,nseed);
for s=1:nseed
    zroi1=zSEEDs(s,:)';
    Rs=zeros(npoint,1);
    parfor j=1:npoint
        XX = Y(j,:)';
        r = corrcoef(XX,zroi1);
        Rs(j)= r(1,2);
    end
    R(:,s)=Rs;
end


% FISHER'S R-TO-Z CONVERT
%--------------------------------------------------------------------------

Z = (log(1+R) - log(1-R+eps)) .* 0.5;
