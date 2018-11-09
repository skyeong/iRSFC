function ALFF_1stlevel_analysis(subjname,fmridir)
global FMRI

%  SPECIFY your own study
%--------------------------------------------------------------------------

DATApath   = FMRI.prep.DATApath;
DATAprefix = FMRI.prep.prefix;
OUTpath    = FMRI.anal.FC.OUTpath;




%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%--------------------------------------------------------------------------

dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning
TR        = FMRI.prep.TR;        % TR time: volume acquisition time
f_lp      = FMRI.prep.BW(1);
f_hp      = FMRI.prep.BW(2);


%  Resting State Functional Images
%--------------------------------------------------------------------------
fmripath = fullfile(DATApath,subjname,fmridir);
fprintf('%s (%s) is loading and analyzing:  ...\n', subjname, fmridir);
fns = spm_select('FPList',fmripath,[DATAprefix 'rest_cleaned.nii']);
vs = spm_vol(fns);
DIM = vs(1).dim;
vs = vs(dummyoff+1:end); vref = vs(1);
IMG = spm_read_vols(vs);
IMG = reshape(IMG, prod(DIM), length(vs));
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);



%  Compute ALFF
%--------------------------------------------------------------------------
fprintf('    : Compute ALFF and fALFF ...\n');
nvox = length(idbrainmask);
ts = IMG(idbrainmask,:);
tmpfALFF = nan(nvox,1);
tmpALFF  = nan(nvox,1);
parfor j=1:nvox
    if std(ts(j,:))<0.1
        cALFF=nan;
        cFALFF=nan;
    else
        [cALFF, cFALFF] = LFCD_alff(ts(j,:), TR, f_lp, f_hp );
    end
    tmpALFF(j) = cALFF;
    tmpfALFF(j) = cFALFF;
end


%--------------------------------------------------------------------------
%  ALFF: Z-transformation
%--------------------------------------------------------------------------
fprintf('    : Writing ALFF results in zmap ...\n');
ALFF = zeros(DIM);
ALFF(idbrainmask) = (tmpALFF-nanmean(tmpALFF))./nanstd(tmpALFF);  % standard z-transform

% ALFF: Writing results
path_ALFF = fullfile(OUTpath,'staticFC_zmaps','ALFF',fmridir); mkdir(path_ALFF);
vout = vs(1);
vout.dt = [16 1];
vout.n = [1 1];
try, vout = rmfield(vout,'dat'); end
vout.fname = fullfile(path_ALFF,sprintf('zscore_ALFF_%s.nii',subjname));
spm_write_vol(vout,ALFF);


%--------------------------------------------------------------------------
%  fALFF: Z-transformation
%--------------------------------------------------------------------------
fprintf('    : Writing fALFF results in zmap ...\n\n');
fALFF = zeros(DIM);
fALFF(idbrainmask) = (tmpfALFF-nanmean(tmpfALFF))./nanstd(tmpfALFF);  % standard z-transform

% fALFF: Writing results
path_fALFF = fullfile(OUTpath,'staticFC_zmaps','fALFF',fmridir); mkdir(path_fALFF);
vout = vs(1);
vout.dt = [16 1];
vout.n = [1 1];
try, vout = rmfield(vout,'dat'); end
vout.fname = fullfile(path_fALFF,sprintf('zscore_fALFF_%s.nii',subjname));
spm_write_vol(vout,fALFF);

