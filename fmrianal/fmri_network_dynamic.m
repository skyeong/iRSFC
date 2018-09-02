function Dyns = fmri_network_dynamic(Y,DIM,seeds,idbrainmask,winSize,slidingSteps);
% Y : either volume with DIM
%     or Nvox x Ndyn
% SEEDs : either nseed x num of neighbor points
%         or nseed x Ndyn


dim1=size(Y);
if length(dim1)==4,
    Y  = reshape(Y,dim1(1:3),dim1(4));
    Y=Y(idbrainmask,:);
end;



% Averating for extracting Seed region Time Course
%--------------------------------------------------------------------------

Ndyn  = size(Y,2);
st = [1:slidingSteps:Ndyn]';
ed = st+winSize-1;
steds = [st(ed<=Ndyn) ed(ed<=Ndyn)];


% Extract timecourse within a window and seed ROI
%--------------------------------------------------------------------------

Dyns = struct();
for i=1:length(steds),
    st = steds(i,1);
    ed = steds(i,2);
    
    fprintf('    : dynamic FC for %02d-th window (%03d-%03d scans)\n',i,st,ed);
    [Z, R] = parallel_processing(Y, DIM, seeds, idbrainmask, st, ed);
    
    Dyns(i).Z = Z;
    Dyns(i).R = R;
    Dyns(i).st = st;
    Dyns(i).ed = ed;
end




function [Z, R] = parallel_processing(Y, DIM, seeds, idbrainmask, st, ed)

winSize = ed - st + 1;
nseed = length(seeds);
a1 = zeros(DIM(1:3));


% Extract timecourse within a window and seed ROI
%--------------------------------------------------------------------------

zSEEDs = zeros(nseed,winSize);
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


R = corrcoef(zSEEDs');
R(eye(nseed)==1)=0;
Z = 0.5 * (log(1+R) - log(1-R+eps));


