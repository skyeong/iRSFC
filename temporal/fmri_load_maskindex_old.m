function [idbrainmask,idgm,idwm,idcsf] = fmri_load_maskindex(vref)
    
[v,idbrainmask] = rsn_brainmask(vref,0.1,0);    % nearest neighbour

[vgm,idgm]    = rsn_apriorimask(vref,0.2,0.5,0.5,'gm');
[vwm,idwm]    = rsn_apriorimask(vref,0.3,0.2,0.4,'wm');
[vcsf,idcsf]  = rsn_apriorimask(vref,0.3,0.7,0.4,'csf');






function [vol,idbrainmask] = rsn_brainmask(vref,prob,sorder)

global FMRI
iRSFCpath = FMRI.iRSFCpath;

%  GENERATE WHOLE BRAIN MASK
%__________________________________________________________________________

maskbm = fullfile(iRSFCpath,'apriori','brainmask.nii');
vmask  = spm_vol_nifti(maskbm);
BM     = spm_read_vols(vmask);

if ischar(vref),
    vol = spm_vol(vref);
else
    vol=vref;
end;

vol = vol(1);

[x,y,z]= meshgrid(1:vol.dim(2),1:vol.dim(1),1:vol.dim(3));
x = x(:); y = y(:); z = z(:);
xyz = [y x z ones(size(x,1),1)]';% Coord. in fmri : x & y ! in SPM5, SPM8
xyz = inv(vmask.mat)*vol.mat * xyz;
xyz = xyz';  % Coord. in template

bmsample  = spm_sample_vol(BM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
idbrainmask = find(bmsample>prob);







function [vol,idvol,gmsample] = rsn_apriorimask(vref,gmprob,whprob,csfprob,modality)

global FMRI
iRSFCpath = FMRI.iRSFCpath;
    

%  GENERATE BRAIN MASK FOR GM / WM / CSF
%__________________________________________________________________________


if nargin<5,
    error('Modality should be correctly specified ....');
end

sorder = 1; % trilinear interpolation

maskgm = fullfile(iRSFCpath,'apriori','grey.nii');
vgm  = spm_vol_nifti(maskgm);
GM   = spm_read_vols(vgm);

maskwm = fullfile(iRSFCpath, 'apriori','white.nii');
vwm  = spm_vol_nifti(maskwm);
WM   = spm_read_vols(vwm);

maskcsf = fullfile(iRSFCpath, 'apriori','csf.nii');
vcsf  = spm_vol_nifti(maskcsf);
CSF   = spm_read_vols(vcsf);

if ischar(vref),Masking
    vol = spm_vol(vref);
else
    vol=vref;
end;
vol = vol(1);

[x,y,z]= meshgrid(1:vol.dim(2),1:vol.dim(1),1:vol.dim(3));
x = x(:); y = y(:); z = z(:);
xyz = [y x z ones(size(x,1),1)]';% Coord. in fmri : x & y ! in SPM5, SPM8
xyz = inv(vgm.mat)*vol.mat * xyz;
xyz = xyz'; % Coord. in template

gmsample  = spm_sample_vol(GM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
wmsample  = spm_sample_vol(WM,xyz(:,1),xyz(:,2),xyz(:,3),sorder);
csfsample = spm_sample_vol(CSF,xyz(:,1),xyz(:,2),xyz(:,3),sorder);

idwm = find(gmsample<gmprob & wmsample>whprob & csfsample<csfprob);
idgm = find(gmsample>gmprob & wmsample<whprob & csfsample<csfprob);
idcsf = find(gmsample<gmprob & wmsample<whprob & csfsample>csfprob);

switch lower(modality),
    case('wm'),
        idvol = idwm;
    case('gm'),
        idvol = idgm;
    case('csf'),
        idvol = idcsf;
end
