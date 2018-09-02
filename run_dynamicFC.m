%  EXCUTE the preprocessing
%__________________________________________________________________________

global FMRI
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Dynaimic Functional Connectivity ...\n');
fprintf('=======================================================================\n\n');


%  OPEN MATLABPOOL IF POSSIBLE
%__________________________________________________________________________

npar=0; try npar=matlabpool('size'); end;
if npar<1, try matlabpool('open'); end; end;



%  Flag for Debug mode
%__________________________________________________________________________

DEBUGmode = 0;



%  SPECIFY your own study
%__________________________________________________________________________

DATApath  = FMRI.prep.DATApath;
subjnames = FMRI.prep.subjList;
ANApath   = FMRI.anal.FC.OUTpath;
prefix    = FMRI.prep.prefix;




%  Parameters for dynamic FC
%__________________________________________________________________________

winSize      = FMRI.anal.FC.winSize;      % in [scans]
slidingSteps = FMRI.anal.FC.slidingSteps; % in [scans]




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
fn_nii = sprintf('^%srest_cleaned_bpf.nii$',prefix);
fns = spm_select('FPList',subjpath,fn_nii);
if isempty(fns)
    fn_nii = sprintf('^%srest_cleaned_bpf.nii.gz$',prefix);
    fns = spm_select('FPList',subjpath,fn_nii);
end
try
    vref=spm_vol(fns(1,:));
catch
    fprintf('Cannot find cleaned_bpf image in [%s] folder.\n',fmridir);
    msg_on_handle=sprintf('Preprocessing first!');
    set(handles.analcorr_status,'String',msg_on_handle);
    set(handles.analcorr_status,'ForegroundColor','k');
    set(handles.analcorr_status,'FontWeight','normal');    return
end
if length(vref)>1,vref=vref(1);end;
DIM = vref.dim(1:3);
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  GET SEED INFORMATION
%__________________________________________________________________________

seeds = get_seed_ROIs(ANApath,vref,DEBUGmode);
nrois = length(seeds);





%  CORRELATION ANALYSIS USING TIME SERIES
%__________________________________________________________________________

colorsalmon = [234, 100, 100]/255.;
if (nrois),
    fprintf('\n=======================================================================\n');
    fprintf('  R-FMRI ANALYSES ARE NOW RUNNING ...\n');
    fprintf('=======================================================================\n');
    
    set(handles.run_analysis,'ForegroundColor',[1 1 1]);
    set(handles.run_analysis,'BackgroundColor',[234 100 100]./256);
    pause(0.2);
    
    
    nsubj = length(subjnames);
    
    % Initialize Network data
    if FMRI.anal.checkbox_isNetworkmode==1,
        ZZ = zeros(1,nsubj,nrois,nrois);
    end
    
    
    for c=1:nsubj,
        
        subj = subjnames{c};
        fprintf('  [%03d/%03d] subj %s is in analyzing ... (%.1f min.) \n',c,nsubj,subj,toc/60);
        
        
        msg_on_handle=sprintf('subj %03d/%03d (estimating dynamic FC ...)  ',c,nsubj);
        set(handles.analcorr_status,'String',msg_on_handle);
        set(handles.analcorr_status,'ForegroundColor',colorsalmon);
        set(handles.analcorr_status,'FontWeight','bold'); pause(1);        
        
        
        %  Get preprocessed rs-fMRI data
        %__________________________________________________________________
        
        subjpath = fullfile(DATApath,subj,fmridir);
        fn_nii = sprintf('^%srest_cleaned_bpf.nii$',prefix);
        fns = spm_select('FPList',subjpath,fn_nii);
        if isempty(fns)
            fn_img = sprintf('^%srest_cleaned_bpf.nii.gz$',prefix);
            fns = spm_select('FPList',subjpath,fn_img);
        end
        try
            vs = spm_vol(fns);
        catch
            fprintf('Cannot find _cleaned_bpf file in [%s] directory.\n',fmridir);
            msg_on_handle=sprintf('Preprocessing first!');
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor','k');
            set(handles.analcorr_status,'FontWeight','normal');
            return;
        end
        Z = spm_read_vols(vs);
        Z = reshape(Z, prod(vs(1).dim), length(vs));
        
        
        
        %  Dynamic FC
        %__________________________________________________________________
        
        if FMRI.anal.checkbox_isSeedmode==1,
            msg_on_handle=sprintf('subj %03d/%03d (connectivity analysis ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            fprintf('    : calculating seed based connectivity ...\n');
            Dyns = fmri_seedcorr_dynamic(Z(idbrainmask,:),vref.dim(1:3),seeds,idbrainmask,winSize,slidingSteps);
            
            
            %  WRITE RESULTS ...
            %__________________________________________________________________
            
            msg_on_handle=sprintf('subj %03d/%03d (write vols ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            for i=1:length(Dyns),
                st = Dyns(i).st;
                ed = Dyns(i).ed;
                zs = Dyns(i).Z;
                
                for s=1:length(seeds),
                    atlasname = seeds{s}.name;
                    
                    vo = vref;
                    SAVEpath=fullfile(ANApath,'dynamicFC_zmaps',atlasname,FMRI.prep.fmridir); mkdir(SAVEpath);
                    SAVEname=sprintf('zscore_%s_%s_st%03d_ed%03d.nii',atlasname,subj,st,ed);
                    vo.fname=fullfile(SAVEpath, SAVEname);
                    vo.dt=[16 0];
                    IMG = zeros(vref.dim);
                    IMG(idbrainmask) = zs(:,s);
                    spm_write_vol(vo,IMG);
                    
                end
            end
        end
        
        if FMRI.anal.checkbox_isNetworkmode==1,
            msg_on_handle=sprintf('subj %03d/%03d (network analysis ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            fprintf('    : calculating functional network ...\n');
            Dyns = fmri_network_dynamic(Z(idbrainmask,:),vref.dim(1:3),seeds,idbrainmask,winSize,slidingSteps);
            
            
            %  WRITE RESULTS ...
            %__________________________________________________________________
            
            msg_on_handle=sprintf('subj %03d/%03d (write Aij ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            nseed = length(seeds);
            for i=1:length(Dyns),
                st = Dyns(i).st;
                ed = Dyns(i).ed;
                Z = Dyns(i).Z;
                R = Dyns(i).R;
                
                SAVEpath = fullfile(ANApath,'dynamicFC_Aij',['roi_n' num2str(nseed)],FMRI.prep.fmridir); mkdir(SAVEpath);
                SAVEname = sprintf('network_%s_st%03d_ed%03d.mat',subj,st,ed);
                SAVEname = fullfile(SAVEpath,SAVEname);
                
                save(SAVEname,'Z','R','seeds');
                ZZ(i,c,:,:) = Z; clear Z R st ed;
            end
        end
        fprintf('\n');
        
    end
    
    % Write results in .csv format
    if FMRI.anal.checkbox_isNetworkmode==1,
       
        % Write headers
        fn_hdr = fullfile(ANApath,'dynamicFC_Aij',['roi_n' num2str(nseed)],FMRI.prep.fmridir,'FC_ROInames.csv');
        fid = fopen(fn_hdr,'w+');
        fprintf(fid,'node number, ROI file name\n');
        for i=1:length(seeds),
            fprintf(fid,'%d, %s\n', i,seeds{i}.name);
        end
        fclose(fid);
        
        % Write FC data
        for d=1:length(Dyns),
            
            fn_dat = fullfile(ANApath,'dynamicFC_Aij',['roi_n' num2str(nseed)],FMRI.prep.fmridir,'FC_data.csv');
            fid = fopen(fn_dat,'w+');
            fprintf(fid,'subjname,');
            for i=1:nrois,
                for j=(i+1):nrois,
                    if i==(nrois-1) && j==nrois,
                        fprintf(fid,'ROI_%d-%d\n',i,j);
                    else
                        fprintf(fid,'ROI_%d-%d,',i,j);
                    end
                end
            end
            for c=1:nsubj,
                fprintf(fid,'%s,',subjnames{c});
                for i=1:nrois,
                    for j=(i+1):nrois,
                        if i==(nrois-1) && j==nrois,
                            fprintf(fid,'%.3f\n',ZZ(d,c,i,j));
                        else
                            fprintf(fid,'%.3f,',ZZ(d,c,i,j));
                        end
                    end
                end
            end
            fclose(fid);
        end
    end
    
    set(handles.run_analysis,'ForegroundColor',[234 100 100]./256);
    set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);
    pause(0.2);
end


msg_on_handle=sprintf('Connectivity evaluation was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');


