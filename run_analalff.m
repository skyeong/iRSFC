
global FMRI




%  EXCUTE the preprocessing
%__________________________________________________________________________

tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Batch script for evaluating LFFs ...\n');
fprintf('=======================================================================\n\n');


%  OPEN MATLABPOOL IF POSSIBLE
%__________________________________________________________________________

npar=0; try npar=matlabpool('size'); end;
if npar<1, try matlabpool('open'); end; end;




%  SPECIFY your own study
%__________________________________________________________________________

DATApath  = FMRI.prep.DATApath;
subjnames = FMRI.prep.subjList;
ANApath   = FMRI.anal.alff.OUTpath;


%  LOAD INDIVIDUAL FILTERED TIME SERIES
%__________________________________________________________________________

TR        = FMRI.prep.TR;        % TR time: volume acquisition time
BW        = FMRI.prep.BW;        % frequency range for bandpass filter
dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning
fmridir   = FMRI.prep.fmridir;   % fmri directory
prefix    = FMRI.prep.prefix;
FILTPARAM = [TR BW];



%  REGRESSORS SELECTION
%__________________________________________________________________________

REGRESSORS(1) = FMRI.prep.GS;
REGRESSORS(2) = FMRI.prep.WM;
REGRESSORS(3) = FMRI.prep.CSF;
REGRESSORS(4) = FMRI.prep.HM;







%  FIND REFERENCE FILE
%__________________________________________________________________________

fn_prefix = sprintf('^%s.*\\.img$',prefix);
subjpath = fullfile(DATApath,subjnames{1},fmridir);
fns=spm_select('FPList',fullfile(subjpath),fn_prefix);
vref=spm_vol(fns(1,:));
if length(vref)>1,vref=vref(1);end;
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  LOAD BRAIN ATLAS
%__________________________________________________________________________

atlasnames = fullfile(FMRI.dir,'atlas','inia19','inia19-NeuroMaps.nii'); % ATLAS file name
vol_ATLAS = spm_vol(atlasnames);
ATLAS = spm_read_vols(vol_ATLAS);



%  LOAD INDIVIDUAL FILTERED TIME SERIES
%__________________________________________________________________________

colorblue = [186 212 244]/255.;

nsubj = length(subjnames);
for c=1:nsubj,
    
    subj = subjnames{c};
    
    fprintf('  subj %02d of %02d is in analyzing ... (%.1f min.) \n',c,nsubj,toc/60);
    msg_on_handle=sprintf('subj %03d/%03d (processing ...)  ',c,nsubj);
    set(handles.analalff_status,'String',msg_on_handle);
    set(handles.analalff_status,'ForegroundColor',colorblue);
    set(handles.analalff_status,'FontWeight','bold'); pause(1);
    
    
    %  LOAD INDIVIDUAL TIME SERIES DATA
    %__________________________________________________________________
    
    [~,Y] = fmri_prep_temporal(DATApath, fmridir, subj, REGRESSORS);
    X = spm_detrend(Y,1);
    
    
    %  AMPLITUDE OF LOW FREQUENCY FLUCTUATION (ALFF)
    %______________________________________________________________________
    
    msg_on_handle=sprintf('subj %03d/%03d (eval LFFs ...)',c,nsubj);
    set(handles.analalff_status,'String',msg_on_handle);
    set(handles.analalff_status,'ForegroundColor',colorblue);
    set(handles.analalff_status,'FontWeight','bold'); pause(1);
    
    fprintf('    : calculating the amplitute of low frequency fluctuation ...\n');
    [fALFF, ALFF] = fmri_calc_alff(X,TR,BW);
    
    
    ALFFname={'ALFF','fALFF'};
    IMGpath={};
    for s=1:length(ALFFname),
        vo = vref;
        cmd = sprintf('imgALFF = %s;',ALFFname{s}); eval(cmd);
        imgALFF = imgALFF';
        IMG = zeros(vref.dim);
        IMG(idbrainmask) = imgALFF;
        
        SAVEpath=fullfile(ANApath, 'zmap', ALFFname{s}); mkdir(SAVEpath);
        SAVEname=sprintf('zscore_%s_%s.img',ALFFname{s},subj);
        vo.fname=fullfile(SAVEpath, SAVEname);
        vo.dt=[16 0];
        
        IMG = zeros(vref.dim);
        IMG(idbrainmask) = imgALFF;
        spm_write_vol(vo,IMG);
    end
    
    fprintf('\n');
end



msg_on_handle=sprintf('LFFs evaluation was done ...  ');
set(handles.analalff_status,'String',msg_on_handle);
set(handles.analalff_status,'ForegroundColor','k');
set(handles.analalff_status,'FontWeight','normal');
