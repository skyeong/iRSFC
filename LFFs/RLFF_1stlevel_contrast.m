function  RLFF_1stlevel_contrast(subjname,fmridir)
global FMRI


%  SPECIFY your own study
%__________________________________________________________________________

OUTpath  = fullfile(FMRI.anal.FC.OUTpath,'LFFs_1stlevel');



fprintf('\n-----------------------------------------------------------------------\n');
fprintf('  %s,  LFF modeling... \n', upper(subjname));
fprintf('-----------------------------------------------------------------------\n');


%  Contrasts for SPM 1st Level
%__________________________________________________________________

F_contrast = [1 zeros(1,13);
    0 1 zeros(1,12);
    0 0 1 zeros(1,11);
    0 0 0 1 zeros(1,10);
    0 0 0 0 1 zeros(1,9);
    0 0 0 0 0 1 zeros(1,8);
    0 0 0 0 0 0 1 zeros(1,7);
    0 0 0 0 0 0 0 1 zeros(1,6);];


clear jobs;
outdir = fullfile(OUTpath,subjname,fmridir);
SPMmat = fullfile(outdir,'SPM.mat');

jobs{1}.stats{1}.con.spmmat = cellstr(SPMmat);
jobs{1}.stats{1}.con.consess{1}.fcon.name = 'LFFs';
jobs{1}.stats{1}.con.consess{1}.fcon.convec = {F_contrast};
jobs{1}.stats{1}.con.consess{1}.fcon.sessrep = 'repl';
jobs{1}.stats{1}.con.delete = 1;


% spm_jobman('interactive',jobs);  % open a GUI containing all the setup
spm_jobman('run',jobs);
