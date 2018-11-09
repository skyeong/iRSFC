
%  SPECIFY your own study
%__________________________________________________________________________

global FMRI
DATApath  = FMRI.prep.DATApath;
subjnames = FMRI.prep.subjList;
fmridir   = FMRI.prep.fmridir;   % fmri directory
nsubj     = length(subjnames);




%  EXCUTE the preprocessing
%__________________________________________________________________________

tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Analysis of amplitude of low frequency fluctuation ...\n');
fprintf('=======================================================================\n\n');


colorsalmon = [234, 100, 100]/255.;
set(handles.run_analysis,'ForegroundColor',[1 1 1]);
set(handles.run_analysis,'BackgroundColor',[234 100 100]./256);
pause(0.2);


%  START THE SPM BATCH JOBS
%__________________________________________________________________________

for i = 1:length(subjnames)
    subjname = subjnames{i};
    
    msg_on_handle=sprintf('subj %03d/%03d (ALFF analysis ...)',i,nsubj);
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor',colorsalmon);
    set(handles.analcorr_status,'FontWeight','bold'); pause(1);
    
    ALFF_1stlevel_analysis(subjname,fmridir);
end


set(handles.run_analysis,'ForegroundColor',[234 100 100]./256);
set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);

ET = clock;
fprintf('=======================================================================\n');
fprintf('    Started Time : %g-%g-%g  %g:%g:%d \n', round(ST));
fprintf('        End Time : %g-%g-%g  %g:%g:%d \n', round(ET));
fprintf('    Elapsed Time : %g min.\n',toc/60);
fprintf('=======================================================================\n\n');



msg_on_handle=sprintf('ALFF was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');
