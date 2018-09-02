function RLFF_1stlevel_regressors(subjname,fmridir)
global FMRI

%  SPECIFY your own study
%__________________________________________________________________________

DATApath   = FMRI.prep.DATApath;
DATAprefix = FMRI.prep.prefix;




%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%__________________________________________________________________________

TR        = FMRI.prep.TR;        % TR time: volume acquisition time
BW        = FMRI.prep.BW;        % frequency range for bandpass filter
dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning



%  REGRESSORS SELECTION
%__________________________________________________________________________

REGRESSORS(1) = FMRI.prep.GS;
REGRESSORS(2) = FMRI.prep.WM;
REGRESSORS(3) = FMRI.prep.CSF;
REGRESSORS(4) = FMRI.prep.HM;
doCompCor     = FMRI.prep.PCA;
nCompCor      = FMRI.prep.nPCA;



fmripath = fullfile(DATApath,subjname,fmridir);
fprintf('::: Create sine/cosine regressors : %s ...\n', upper(fmridir));


%  Resting State Functional Images
%__________________________________________________________________


fns = dir(fullfile(fmripath,[DATAprefix 'rest*.nii']));
fns = [fns; dir(fullfile(fmripath,[DATAprefix 'rest*.img']))];
vs = spm_vol(fullfile(fmripath,fns.name));
IMG = spm_read_vols(vs);
IMG = reshape(IMG, prod(vs(1).dim), length(vs));


%  Extract Confounding Factors: WM and CSF effects
%__________________________________________________________________

[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vs(1));
IMG = spm_detrend(IMG',1)';
GS = mean(IMG(idbrainmask,:)); GS = GS(:);
WM = mean(IMG(idwm,:));        WM = WM(:);
CSF = mean(IMG(idcsf,:));      CSF = CSF(:);



%  Low-Frequency Fluctuation Modeling
%__________________________________________________________________

nscan = length(vs);
LFF_model = modeling_RLFF(TR, nscan-dummyoff);



%  Read Motion Parameters
%__________________________________________________________________

rpname = fullfile(fmripath,'rp_*.txt');
rpname = dir(rpname);
rpname = fullfile(fmripath, rpname(1).name);
MOTION = dlmread(rpname);



%  Select Types of regressors
%__________________________________________________________________

st = dummyoff+1;
PARAMS = LFF_model;
if REGRESSORS(4),  PARAMS = [PARAMS, MOTION(st:end,:)];       end

if doCompCor==1,
    % Extract Physiological Noise using CompCor method
    noisePhy = [];
    if REGRESSORS(2), noisePhy = [noisePhy; IMG(idwm, st:end)]; end
    if REGRESSORS(3), noisePhy = [noisePhy; IMG(idcsf,st:end)]; end
    
    [noiseComp, score] = pca(noisePhy,'NumComponents',nCompCor);
    PARAMS = [PARAMS, noiseComp];
else
    % Extract Physiological Noise using mean value
    if REGRESSORS(1), PARAMS = [PARAMS, GS(st:end)];         end
    if REGRESSORS(2), PARAMS = [PARAMS, WM(st:end)];         end
    if REGRESSORS(3), PARAMS = [PARAMS, CSF(st:end)];        end
end


%  Write New Regressors including sine/cosine waves
%__________________________________________________________________

fn_out = fullfile(fmripath,'regressors.txt');
dlmwrite(fn_out,PARAMS);

