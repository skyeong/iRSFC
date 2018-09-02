function Z=iRSFC_NUIS_regress(Y,NUIS)
% Y : input spatio-temporal data,  scans x voxels
% Z : regressed data,  scans x voxels

nscans = size(Y,1);
if ~isempty(NUIS),
    Z = (eye(nscans) - NUIS*pinv(NUIS))*Y;
else
    Z = Y;
end
