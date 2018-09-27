%  EXCUTE the preprocessing
%__________________________________________________________________________

global FMRI
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Preprocessing in temporal domain ...\n');
fprintf('=======================================================================\n');


%  Flag for Debug mode
%__________________________________________________________________________

DEBUGmode = 0;



%  SPECIFY your own study
%__________________________________________________________________________

DATApath  = FMRI.prep.DATApath;
subjnames = FMRI.prep.subjList;
ANApath   = FMRI.anal.FC.OUTpath;
prefix    = FMRI.prep.prefix;




%  PARAMETERS FOR TEMPORAL FMRI DATA PROCESSING
%__________________________________________________________________________

TR        = FMRI.prep.TR;        % TR time: volume acquisition time
BW        = FMRI.prep.BW;        % frequency range for bandpass filter
dummyoff  = FMRI.prep.dummyoff;  % num. of dummy data from beginning
fmridir   = FMRI.prep.fmridir;   % fmri directory
FILTPARAM = [TR BW];             % set filtering parameters



%  REGRESSORS SELECTION
%__________________________________________________________________________

REGRESSORS(1) = FMRI.prep.GS;
REGRESSORS(2) = FMRI.prep.WM;
REGRESSORS(3) = FMRI.prep.CSF;




%  FIND REFERENCE FILE
%__________________________________________________________________________

subjpath = fullfile(DATApath,subjnames{1},fmridir);
fn_nii = sprintf('^%srest.*.nii$',prefix);
fns = spm_select('FPList',subjpath,fn_nii);
if isempty(fns)
    fn_img = sprintf('^%srest.*.img$',prefix);
    fns = spm_select('FPList',subjpath,fn_img);
end

vref=spm_vol(fns(1,:));
if length(vref)>1,vref=vref(1);end
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  CORRELATION ANALYSIS USING TIME SERIES
%__________________________________________________________________________

colorsalmon = [234, 100, 100]/255.;
set(handles.run_analysis,'ForegroundColor',[1 1 1]);
set(handles.run_analysis,'BackgroundColor',[234 100 100]./256);
pause(0.2);


nsubj = length(subjnames);


for c=1:nsubj
    
    subj = subjnames{c};
    fprintf('  [%03d/%03d] subj %s is in analyzing ... (%.1f min.) \n',c,nsubj,subj,toc/60);
    
    
    %  TEMPORAL PREPROCESSING
    %__________________________________________________________________
    
    msg_on_handle=sprintf('subj %03d/%03d (Preprocessing ...)  ',c,nsubj);
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor',colorsalmon);
    set(handles.analcorr_status,'FontWeight','bold'); pause(1);
    Z = fmri_prep_temporal(DATApath, fmridir, subj, REGRESSORS);
  
    set(handles.run_analysis,'ForegroundColor',[234 100 100]./256);
    set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);
    
    fprintf('\n')
    pause(0.2);
end


msg_on_handle=sprintf('Preprocessing was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');


