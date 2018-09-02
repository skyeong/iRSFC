function [idbrainmask,idgm,idwm,idcsf] = fmri_load_maskindex(vref)

% mask image was obtained from REST toolbox
% journal: DPARSF: A MATLAB Toolbox for ?Pipeline? Data Analysis of Resting-State fMRI
% nearest neighbour
idbrainmask = iRSF_resample_from(vref,'mask_ICV.nii');  
idgm        = iRSF_resample_from(vref,'GreyMask_02_91x109x91.img');
idwm        = iRSF_resample_from(vref,'WhiteMask_09_91x109x91.img');
idcsf       = iRSF_resample_from(vref,'CsfMask_07_91x109x91.img');


function idroi = iRSF_resample_from(vref,mask_name)

global FMRI
iRSFCpath = FMRI.iRSFCpath;

if nargin<2,
    error('Modality should be correctly specified ....');
end

% Read reference image
if ischar(vref),Masking
    vo_ref = spm_vol(vref);
else
    vo_ref = vref;
end;

% Mask image: Get XYZ-Coordinates
fn_mask = fullfile(iRSFCpath,'brainmask',mask_name);
vo_mask = spm_vol_nifti(fn_mask);
MASK    = spm_read_vols(vo_mask);
idmask  = find(MASK>0);
[vx, vy, vz] = ind2sub(vo_mask.dim,idmask);
Vxyz = [vx, vy, vz, ones(size(vx,1),1)];

% Resampled in standard normalized space
Rxyz = vo_mask.mat*Vxyz';
Vxyz = round(vo_ref.mat\Rxyz);

% To remove data lying in the boundaries
idzeros = union(find(Vxyz(1,:)==0), find(Vxyz(2,:)==0));
idzeros = union(find(Vxyz(3,:)==0), idzeros);
Vxyz(:,idzeros) = [];

% Transformation from original MASK space to the reference space
idroi = sub2ind(vo_ref.dim, Vxyz(1,:), Vxyz(2,:), Vxyz(3,:));
idroi = unique(idroi);


