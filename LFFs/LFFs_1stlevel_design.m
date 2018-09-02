function  LFFs_1stlevel_design(subjname,fmridir)
global FMRI

%  SPECIFY your own study
%__________________________________________________________________________

DATApath    = FMRI.prep.DATApath;
DATAprefix  = FMRI.prep.prefix;
OUTpath     = fullfile(FMRI.anal.FC.OUTpath,'LFFs_1stlevel'); 


%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%__________________________________________________________________________

dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning
TR        = FMRI.prep.TR;     % in second




%  Resting State Functional Images
%__________________________________________________________________

fmripath = fullfile(DATApath,subjname,fmridir);
fprintf('::: LFF modeling : %s ...\n', upper(fmridir));
fns = dir(fullfile(fmripath,[DATAprefix 'rest*.nii']));
fns = [fns; dir(fullfile(fmripath,[DATAprefix 'rest*.img']))];
f_mri = get_filepath(fmripath, fns);
f_mri = {f_mri{dummyoff+1:end}};


%  Select Regressors 
%__________________________________________________________________

fn_regressor = fullfile(fmripath, 'regressors.txt');



%  SPM 1st Level Design
%__________________________________________________________________

clear jobs;
outdir = fullfile(OUTpath,subjname,fmridir); mkdir(outdir);
jobs{1}.stats{1}.fmri_spec.dir = cellstr(outdir);
jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
jobs{1}.stats{1}.fmri_spec.timing.RT = TR;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

jobs{1}.stats{1}.fmri_spec.sess.scans = cellstr(f_mri');
jobs{1}.stats{1}.fmri_spec.sess.multi_reg = cellstr(fn_regressor);
jobs{1}.stats{1}.fmri_spec.sess.hpf = 100;  % high pass filter (>0.01 Hz)

% jobs{1}.stats{1}.fmri_spec.bases.fir.length = 1;
% jobs{1}.stats{1}.fmri_spec.bases.fir.order = 1;


% spm_jobman('interactive',jobs);  % open a GUI containing all the setup
spm_jobman('run',jobs);

