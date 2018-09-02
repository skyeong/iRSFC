function Dyns = fmri_seedcorr_dynamic(Y,DIM,seeds,idbrainmask,winSize,slidingSteps)
% Y : either volume with DIM
%     or Nvox x Ndyn
% SEEDs : either nseed x num of neighbor points
%         or nseed x Ndyn


dim1 = size(Y);
if length(dim1)==4,
    Y = reshape(Y,dim1(1:3),dim1(4));
    Y = Y(idbrainmask,:);
end;




% Averating for extracting Seed region Time Course
%--------------------------------------------------------------------------

Ndyn = size(Y,2);  % number of dynamics (or scans)
st = [1:slidingSteps:Ndyn]';
ed = st+winSize-1;
steds = [st(ed<=Ndyn) ed(ed<=Ndyn)];

Dyns = struct();
parfor i=1:length(steds),
    st = steds(i,1);
    ed = steds(i,2);
    
    fprintf('    : dynamic FC for %02d-th window (%03d-%03d scans)\n',i,st,ed);
    Z = parallel_processing(Y, DIM, seeds, idbrainmask, st, ed);
    
    Dyns(i).Z = Z;
    Dyns(i).st = st;
    Dyns(i).ed = ed;
end




function Z = parallel_processing(Y, DIM, seeds, idbrainmask, st, ed)

winSize = ed - st + 1;
Nvox = size(Y,1);  % number of voxels
nseed = length(seeds);
zSEEDs = zeros(nseed,winSize);
a1 = zeros(DIM(1:3));


% Extract timecourse within a window and seed ROI
%--------------------------------------------------------------------------

cnt = 1;
for k=st:ed,
    a1(idbrainmask)=Y(:,k);
    for s=1:nseed,
        idroi = seeds{s}.idroi;
        zSEEDs(s,cnt) = mean(a1(idroi));
    end;
    cnt = cnt+1;
end
clear a1;



% CALCULATE CROSS-CORRELATION
%--------------------------------------------------------------------------

R = zeros(Nvox, nseed);
for s=1:nseed,
    zroi1=zSEEDs(s,:)';
    Rs=zeros(Nvox,1);
    for j=1:Nvox,
        XX    = Y(j,st:ed)';
        r     = corrcoef(XX,zroi1);
        Rs(j) = r(1,2);
    end;
    R(:,s) = Rs;
end;



% FISHER'S R-TO-Z CONVERT
%--------------------------------------------------------------------------

Z = (log(1+R) - log(1-R+eps)) .* 0.5;
