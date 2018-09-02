function LFFs_create_models(subjname,studies,Emode)

% SPECIFICATION DCMs "attentional modulation of backward/forward connection"
%--------------------------------------------------------------------------
% To specify a DCM, you might want to create a template one using the GUI
% then use spm_dcm_U.m and spm_dcm_voi.m to insert new inputs and new
% regions. The following code creates a DCM file from scratch, which
% involves some technical subtleties and a deeper knowledge of the DCM
% structure.
%
% downloaded from spm web-page

if nargin<3, Emode='csd'; end


OUTpath = studies{1}.OUTpath;

for fmri=1:length(studies{1}.func)
    
    fmriName = studies{1}.func{fmri};
    DCMdir = fullfile(OUTpath,'1stlevel',subjname,fmriName);
    load(fullfile(DCMdir,'SPM.mat'));
    
    clear DCM
    
    
    % Load regions of interest
    %----------------------------------------------------------------------
    
    load(fullfile(DCMdir,'VOI_MPFC_1.mat'),'xY');   DCM.xY(1) = xY;
    load(fullfile(DCMdir,'VOI_PCC_1.mat'),'xY');    DCM.xY(2) = xY;
    load(fullfile(DCMdir,'VOI_LIPL_1.mat'),'xY');   DCM.xY(3) = xY;
    load(fullfile(DCMdir,'VOI_RIPL_1.mat'),'xY');   DCM.xY(4) = xY;
    
    DCM.n = length(DCM.xY);        % number of regions
    DCM.v = length(DCM.xY(1).u);   % number of time points
    
    
    % Time series
    %--------------------------------------------------------------------------
    DCM.Y.dt  = SPM.xY.RT;
    DCM.Y.X0  = DCM.xY(1).X0;
    for i = 1:DCM.n
        DCM.Y.y(:,i)  = DCM.xY(i).u;
        DCM.Y.name{i} = DCM.xY(i).name;
    end
    
    DCM.Y.Q    = spm_Ce(ones(1,DCM.n)*DCM.v);
    
    % Experimental inputs
    %--------------------------------------------------------------------------
    DCM.U.name = {'null'};
    DCM.U.u    = zeros(DCM.v,1);
    
    
    % DCM parameters and options
    %----------------------------------------------------------------------
    DCM.delays = repmat(SPM.xY.RT/2,DCM.n,1);
    DCM.TE     = 0.03;  % 30 ms
    
    DCM.options.nonlinear  = 0;
    DCM.options.two_state  = 0;
    DCM.options.stochastic = 1;
    DCM.options.nograph    = 1;
    
    
    % Connectivity matrices for model with backward modulation
    %----------------------------------------------------------------------
    for i=1:30,
        fprintf('\n-----------------------------------------------------------------------\n');
        fprintf('  Create and Estimate DCM Model, %s (%02d) ... %g min. \n',subjname,i,toc/60);
        fprintf('-----------------------------------------------------------------------\n');
        
        fn_model = fullfile(OUTpath,'models',sprintf('model_%02d.mat',i));
        model = load(fn_model);
        DCM.a = model.a;
        DCM.b = zeros(4,4,0);
        DCM.c = zeros(4,0);
        DCM.d = zeros(4,4,0);
        
        save(fullfile(DCMdir,model.fn_dcm),'DCM');
        
        
        % DCM Estimation
        %--------------------------------------------------------------------------
        clear matlabbatch
        matlabbatch{1}.spm.dcm.fmri.estimate.dcmmat = {fullfile(DCMdir,model.fn_dcm)};
        matlabbatch{1}.spm.dcm.fmri.estimate.analysis = Emode;  % csd: cross spectral density
        spm_jobman('run',matlabbatch);
    end
end

