function  LFFs_1stlevel_logTrans(subjname,fmridir)
global FMRI


%  SPECIFY your own study
%__________________________________________________________________________

OUTpath  = fullfile(FMRI.anal.FC.OUTpath,'LFFs_1stlevel');



%  Logarithmic transformed F-contrast images of each subject
%__________________________________________________________________

outdir = fullfile(OUTpath,subjname,fmridir);
fn1 = fullfile(outdir,'spmF_0001.nii');
vref = spm_vol(fn1);
idbrainmask = fmri_load_maskindex(vref);

v1 = spm_vol(fn1);
I = spm_read_vols(v1);
idx = find(I>0);
idmask = intersect(idx,idbrainmask);

IMG = zeros(v1.dim);
IMG(idmask) = log(I(idmask));  % log

fn_out = sprintf('zscore_LFF_%s.nii',subjname);
vo = v1;
vo.fname = fullfile(outdir,fn_out);
spm_write_vol(vo,IMG);
