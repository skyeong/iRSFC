function RLFF_1stlevel_regressors(subjname,fmridir)
global FMRI

%  SPECIFY your own study
%--------------------------------------------------------------------------
DATApath   = FMRI.prep.DATApath;
DATAprefix = FMRI.prep.prefix;



%--------------------------------------------------------------------------
%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%--------------------------------------------------------------------------
TR        = FMRI.prep.TR;        % TR time: volume acquisition time
dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning


%--------------------------------------------------------------------------
%  Resting State Functional Images
%--------------------------------------------------------------------------
fmripath = fullfile(DATApath,subjname,fmridir);
fprintf('::: Create sine/cosine regressors : %s ...\n', upper(fmridir));


%--------------------------------------------------------------------------
%  Low-Frequency Fluctuation Modeling
%--------------------------------------------------------------------------
fns = spm_select('FPList',fmripath,[DATAprefix 'rest_cleaned.nii']);
vs = spm_vol(fns);
nscan = length(vs);
LFF_model = modeling_RLFF(TR, nscan-dummyoff);

    
%--------------------------------------------------------------------------
%  Write New Regressors including sine/cosine waves
%--------------------------------------------------------------------------
fn_out = fullfile(fmripath,'regressors.txt');
dlmwrite(fn_out,LFF_model);

