function seeds = get_seed_ROIs(ANApath,vref,DEBUGmode)
global FMRI



%  SEED SELECTION
%__________________________________________________________________________

selected_atlas = FMRI.anal.selected_atlas;
SEEDATLAS      = FMRI.anal.FC.ids;



%  About ROI Images
%__________________________________________________________________________

ROIimgs  = FMRI.anal.FC.ROIimgs;
nROIimgs = FMRI.anal.FC.nROIimgs;



seeds={};
if ~isempty(SEEDATLAS),
    
    %  LOAD BRAIN ATLAS
    %______________________________________________________________________
    
    fn_atlas = sprintf('%s.nii',selected_atlas);
    fn_atlas = fullfile(FMRI.dir,'atlas',fn_atlas); % ATLAS file name
    vol_ATLAS = spm_vol(fn_atlas);
    ATLAS = spm_read_vols(vol_ATLAS);
    
    [p,f,e]=fileparts(fn_atlas);
    atlastxt=fullfile(p,[f '.xls']);
    [a,b,data]=xlsread(atlastxt);
    atlasLabel=data(2:end,2);
    
    
    %  GENERATE SEED ROIS FROM ATLAS MAP
    %______________________________________________________________________
    
    s=1; nseed=0;
    for i=1:length(SEEDATLAS),
        ATLASnum=SEEDATLAS(i);
        atlasname=sprintf('%s_%s',selected_atlas,atlasLabel{ATLASnum});
        
        idroi = find(ATLAS==ATLASnum);
        [vx, vy, vz] = ind2sub(vol_ATLAS.dim,idroi);
        Vxyz = [vx, vy, vz, ones(size(vx))];
        Rxyz = vol_ATLAS.mat*Vxyz';
        Vxyz = round(pinv(vref.mat)*Rxyz); Rxyz = Rxyz(1:3,:)';
        
        % remove voxels in case of zero voxel indices
        i1 = find(Vxyz(1,:)<1);  i2 = find(Vxyz(2,:)<1);
        i3 = find(Vxyz(3,:)<1);
        idremove = union(i1,i2); idremove = union(idremove,i3);
        Vxyz(:,idremove)=[];
        
        idroi = sub2ind(vref.dim, Vxyz(1,:), Vxyz(2,:), Vxyz(3,:));
        idroi = unique(idroi);
        
        s = nseed+i;
        seeds{s}.idroi=idroi;
        seeds{s}.name=atlasname;
        seeds{s}.center=mean(Rxyz);
        
        
        %  SAVE ROI AS NIFTI FILE FORMAT
        %__________________________________________________________________
        
        if DEBUGmode,
            vo = vref;
            SAVEpath=fullfile(ANApath,'ROIs'); mkdir(SAVEpath);
            SAVEname=sprintf('%s.img',atlasname);
            vo.dt = [16, 0];
            vo.fname=fullfile(SAVEpath, SAVEname);
            IMG = zeros(vref.dim);
            IMG(idroi) = ATLASnum;
            spm_write_vol(vo,IMG);
        end
    end
end




%  Generate ROI from User Defined Mask Images
%__________________________________________________________________________

if nROIimgs && length(char(ROIimgs))>3,
    
    nseed=0;
    if exist('seeds','var'), nseed = length(seeds); end;
    
    for i=1:nROIimgs,
        fn_roi = ROIimgs{i};
        [p,f,e] = fileparts(fn_roi);
        
        % Get XYZ-Coordinates in user defined ROI image space
        v1 = spm_vol(fn_roi);
        IMG = spm_read_vols(v1);
        idx = find(IMG>0);
        [vx, vy, vz] = ind2sub(v1.dim,idx);
        Vxyz = [vx, vy, vz, ones(size(vx,1),1)];
        
        % Resampled in standard normalized space
        Rxyz = v1.mat*Vxyz';
        Vxyz = round(inv(vref.mat)*Rxyz); Rxyz = Rxyz(1:3,:)';
        idroi = sub2ind(vref.dim, Vxyz(1,:), Vxyz(2,:), Vxyz(3,:));
        idroi = unique(idroi);
        
        s = nseed+i;
        seeds{s}.idroi=idroi;
        seeds{s}.name=f;
        seeds{s}.center=mean(Rxyz);
        
        
        %  SAVE ROI AS NIFTI FILE FORMAT
        %__________________________________________________________________
        
        if DEBUGmode
            vo = vref;
            SAVEpath=fullfile(ANApath,'ROIs'); mkdir(SAVEpath);
            SAVEname=sprintf('ROIimg_%s.nii',f);
            vo.dt = [16, 0];
            vo.fname=fullfile(SAVEpath, SAVEname);
            IMG = zeros(vref.dim);
            IMG(idroi) = 1;
            spm_write_vol(vo,IMG);
        end
    end
end


fprintf('\n=======================================================================\n');
fprintf('  Seed ROIs from ATLAS and User defined\n');
fprintf('=======================================================================\n');
fprintf('  SEED ROIs: ')
nrois = length(seeds);
for s=1:nrois,
    fprintf('%s  ',seeds{s}.name);
end
fprintf('\n\n');
