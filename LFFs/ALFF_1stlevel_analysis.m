function ALFF_1stlevel_analysis(subjname,fmridir)
global FMRI

%  SPECIFY your own study
%__________________________________________________________________________

DATApath   = FMRI.prep.DATApath;
DATAprefix = FMRI.prep.prefix;
OUTpath    = FMRI.anal.FC.OUTpath;




%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%__________________________________________________________________________

dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning
TR        = FMRI.prep.TR;        % TR time: volume acquisition time
f_lp      = FMRI.prep.BW(1);
f_hp      = FMRI.prep.BW(2);

%  REGRESSORS SELECTION
%__________________________________________________________________________

REGRESSORS(1) = FMRI.prep.GS;
REGRESSORS(2) = FMRI.prep.WM;
REGRESSORS(3) = FMRI.prep.CSF;
REGRESSORS(4) = FMRI.prep.HM;
doCompCor     = FMRI.prep.PCA;
nCompCor      = FMRI.prep.nPCA;



fmripath = fullfile(DATApath,subjname,fmridir);
fprintf('::: Loading rsfMRI: %s (%s) ...\n', subjname, fmridir);


%  Resting State Functional Images
%__________________________________________________________________


fns = dir(fullfile(fmripath,[DATAprefix 'rest*.nii']));
fns = [fns; dir(fullfile(fmripath,[DATAprefix 'rest*.nii.gz']))];
vs = spm_vol(fullfile(fmripath,fns.name)); DIM = vs(1).dim;
vs = vs(dummyoff+1:end);
IMG = spm_read_vols(vs);
IMG = reshape(IMG, prod(vs(1).dim), length(vs));


%  Extract Confounding Factors: WM and CSF effects
%__________________________________________________________________

[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vs(1));
IMG = spm_detrend(IMG',1)';
GS = mean(IMG(idbrainmask,:)); GS = GS(:);
WM = mean(IMG(idwm,:));        WM = WM(:);
CSF = mean(IMG(idcsf,:));      CSF = CSF(:);



%  Read Motion Parameters
%__________________________________________________________________

rpname = fullfile(fmripath,'rp_*.txt');
rpname = dir(rpname);
rpname = fullfile(fmripath, rpname(1).name);
MOTION = dlmread(rpname);
MOTION = detrend(MOTION(dummyoff+1:end,:),'linear');



%  Select Types of regressors
%__________________________________________________________________

NUIS = [];
if REGRESSORS(4),  NUIS = [NUIS, MOTION];       end

if doCompCor==1,
    % Extract Physiological Noise using CompCor method
    noisePhy = [];
    if REGRESSORS(2), noisePhy = [noisePhy; IMG(idwm, :)]; end
    if REGRESSORS(3), noisePhy = [noisePhy; IMG(idcsf,:)]; end
    
    [noiseComp, score] = pca(noisePhy,'NumComponents',nCompCor);
    NUIS = [NUIS, noiseComp];
else
    % Extract Physiological Noise using mean value
    if REGRESSORS(1), NUIS = [NUIS, GS];         end
    if REGRESSORS(2), NUIS = [NUIS, WM];         end
    if REGRESSORS(3), NUIS = [NUIS, CSF];        end
end


%  Compute ALFF
%__________________________________________________________________

fprintf('::: Compute ALFF and fALFF ...\n');
nvox = length(idbrainmask);
ts = iRSFC_NUIS_regress(IMG(idbrainmask,:)',NUIS)';
tmpfALFF = zeros(nvox,1);
tmpALFF  = zeros(nvox,1);
parfor j=1:nvox,
    [cALFF, cFALFF] = LFCD_alff(ts(j,:), TR, f_lp, f_hp );
    tmpALFF(j) = cALFF;
    tmpfALFF(j) = cFALFF;
end

%--------------------------------------------------------------------------
%  ALFF: Z-transformation
%--------------------------------------------------------------------------
fprintf('::: Writing ALFF results in zmap ...\n');
ALFF = zeros(DIM);
ALFF(idbrainmask) = (tmpALFF-mean(tmpALFF))./std(tmpALFF);  % standard z-transform

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
fprintf('::: Writing fALFF results in zmap ...\n\n');
fALFF = zeros(DIM);
fALFF(idbrainmask) = (tmpfALFF-mean(tmpfALFF))./std(tmpfALFF);  % standard z-transform

% fALFF: Writing results
path_fALFF = fullfile(OUTpath,'staticFC_zmaps','fALFF',fmridir); mkdir(path_fALFF);
vout = vs(1);
vout.dt = [16 1];
vout.n = [1 1];
try, vout = rmfield(vout,'dat'); end
vout.fname = fullfile(path_fALFF,sprintf('zscore_fALFF_%s.nii',subjname));
spm_write_vol(vout,fALFF);

