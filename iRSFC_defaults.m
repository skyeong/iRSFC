function iRSFC_defaults

global FMRI

FMRI.subjList = '';
FMRI.dir = fileparts(which('iRSFC'));


% Parameters for temporal preprocessing

FMRI.prep.subjList = '';
FMRI.prep.DATApath = '';
FMRI.prep.TR = 2;             % TR time: volume acquisition time
FMRI.prep.BW = [0.009 0.08];  % frequency range for bandpass filter
FMRI.prep.dummyoff = 5;
FMRI.prep.fmridir = 'rest';
FMRI.prep.prefix = 's6w2';
FMRI.prep.HM  = 1;
FMRI.prep.CSF = 1;
FMRI.prep.WM  = 1;
FMRI.prep.GS  = 0;  % global signal
FMRI.prep.PCA = 0; 
FMRI.prep.nPCA= 5;  % Suggested by X.J. Chai et al. / NeuroImage 59 (2012) 1420?1428


% Parameters for rsfmri analysis

FMRI.anal.mode = 'Preprocess';
FMRI.anal.selected_atlas = '';
FMRI.anal.checkbox_isSeedmode = 1;
FMRI.anal.checkbox_isNetworkmode = 0;

FMRI.anal.FC.ids = [];
FMRI.anal.FC.OUTpath = '';
FMRI.anal.FC.nROIimgs = 0;
FMRI.anal.FC.ROIimgs = struct([]);
FMRI.anal.FC.FDthr = 0.2;
FMRI.anal.FC.doScrubbing = 0;

FMRI.anal.FC.winSize     = 30;  % in [scans]
FMRI.anal.FC.slidingSteps = 15;  % in [scans] 

FMRI.anal.LFF.BW = [0.009 0.08];
FMRI.anal.LFF.TR = 2;
FMRI.anal.LFF.OUTpath = '';

