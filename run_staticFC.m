%  EXCUTE the preprocessing
%__________________________________________________________________________

global FMRI
tic;  ST = clock;

fprintf('\n=======================================================================\n');
fprintf('  Static Functional Connectivity ...\n');
fprintf('=======================================================================\n\n');


%  OPEN MATLABPOOL IF POSSIBLE
%__________________________________________________________________________

try parpool; end;



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



%  SEED SELECTION
%__________________________________________________________________________

selected_atlas = FMRI.anal.selected_atlas;
SEEDATLAS      = FMRI.anal.FC.ids;



%  About ROI Images
%__________________________________________________________________________

ROIimgs  = FMRI.anal.FC.ROIimgs;
nROIimgs = FMRI.anal.FC.nROIimgs;



%  Scrubbing option
%__________________________________________________________________________

FDthr       = FMRI.anal.FC.FDthr;
doScrubbing = FMRI.anal.FC.doScrubbing;



%  FIND REFERENCE FILE
%__________________________________________________________________________

subjpath = fullfile(DATApath,subjnames{1},fmridir);
fn_nii = sprintf('^%s.*._cleaned_bpf.nii$',prefix);
fns = spm_select('FPList',subjpath,fn_nii);
if isempty(fns)
    fn_nii = sprintf('^%s.*._cleaned_bpf.img$',prefix);
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
if length(vref)>1,vref=vref(1);end
DIM = vref.dim(1:3);
[idbrainmask, idgm, idwm, idcsf] = fmri_load_maskindex(vref);




%  GET SEED INFORMATION
%__________________________________________________________________________

seeds = get_seed_ROIs(ANApath,vref,DEBUGmode);
nrois = length(seeds);



%  CORRELATION ANALYSIS USING TIME SERIES
%__________________________________________________________________________

colorsalmon = [234, 100, 100]/255.;
if (nrois)
    fprintf('\n=======================================================================\n');
    fprintf('  R-FMRI ANALYSES ARE NOW RUNNING ...\n');
    fprintf('=======================================================================\n');
    
    set(handles.run_analysis,'ForegroundColor',[1 1 1]);
    set(handles.run_analysis,'BackgroundColor',[234 100 100]./256);
    pause(0.2);
    
    
    nsubj = length(subjnames);
    
    % Initialize Network data
    if FMRI.anal.checkbox_isNetworkmode==1
        ZZ = zeros(nsubj,nrois,nrois);
    end
    
    
    for c=1:nsubj
        
        subj = subjnames{c};
        fprintf('  [%03d/%03d] subj %s is in analyzing ... (%.1f min.) \n',c,nsubj,subj,toc/60);
        
        
        %  Functional Connectivity
        %__________________________________________________________________
        
        msg_on_handle=sprintf('subj %03d/%03d (Loading images...)  ',c,nsubj);
        set(handles.analcorr_status,'String',msg_on_handle);
        set(handles.analcorr_status,'ForegroundColor',colorsalmon);
        set(handles.analcorr_status,'FontWeight','bold'); pause(1);
        
        
        subjpath = fullfile(DATApath,subj,fmridir);
        fn_nii = sprintf('^%s.*._cleaned_bpf.nii$',prefix);
        fns = spm_select('FPList',subjpath,fn_nii);
        if isempty(fns)
            fn_img = sprintf('^%s.*._cleaned_bpf.img$',prefix);
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
        
        if doScrubbing
            
            %  Compute Frame-wise displacement for scrubbing time-series
            %______________________________________________________________
          
            fprintf('    : calculating seed based connectivity ...\n');
            fn_motion = dir(fullfile(subjpath,'rp_*.txt'));
            fn_motion = fullfile(subjpath,fn_motion(1).name);
            
            if ~exist(fn_motion,'file')
                fprintf('Cannot find rp*.txt file in\n%s\n',subjpath);
                break;
            end
            motion = dlmread(fn_motion);
            FD_val = compute_fd(motion(dummyoff+1:end,:),'spm');
            
            % scrubbing 1 back and 2 forward neighbors as performed by Power et al
            idxScrubbing = find(FD_val>FDthr);
            idxScrubbing_b1 = idxScrubbing-1;
            idxScrubbing_a1 = idxScrubbing+1;
            idxScrubbing_a2 = idxScrubbing+2;
            idxScrubbing = [idxScrubbing(:); idxScrubbing_b1(:); idxScrubbing_a1(:); idxScrubbing_a2(:)];
            idxScrubbing = unique(idxScrubbing);
            idxScrubbing(idxScrubbing==0)=[];
            Z(:,idxScrubbing) = [];
            fprintf('    : scrubbing %d scans by FD>%.1f ...\n', length(idxScrubbing), FDthr);
        end
        
        %  SEED BASED CORRELATION
        %__________________________________________________________________
        
        if FMRI.anal.checkbox_isSeedmode==1
            msg_on_handle=sprintf('subj %03d/%03d (Analysis ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            zs=fmri_seedcorr_static(Z(idbrainmask,:),DIM,seeds,idbrainmask);
            
            
            %  WRITE RESULTS ...
            %__________________________________________________________________
            
            msg_on_handle=sprintf('subj %03d/%03d (Write vols ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            for s=1:length(seeds)
                atlasname = seeds{s}.name;
                
                vo = vref;
                SAVEpath=fullfile(ANApath,'staticFC_zmaps',atlasname,FMRI.prep.fmridir); mkdir(SAVEpath);
                SAVEname=sprintf('zscore_%s_%s.nii',atlasname,subj);
                    
                vo.fname=fullfile(SAVEpath, SAVEname);
                vo.dt=[16 0];
                IMG = zeros(vref.dim);
                IMG(idbrainmask) = zs(:,s);
                spm_write_vol(vo,IMG);
                
            end
        end
        
        if FMRI.anal.checkbox_isNetworkmode==1
            msg_on_handle=sprintf('subj %03d/%03d (Network analysis ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            fprintf('    : calculating functional network ...\n');
            [Z,R,P]=fmri_network_static(Z(idbrainmask,:),DIM,seeds,idbrainmask);
            
            
            %  WRITE RESULTS ...
            %__________________________________________________________________
            
            msg_on_handle=sprintf('subj %03d/%03d (Write Aij ...)',c,nsubj);
            set(handles.analcorr_status,'String',msg_on_handle);
            set(handles.analcorr_status,'ForegroundColor',colorsalmon);
            set(handles.analcorr_status,'FontWeight','bold'); pause(1);
            
            nseed = length(seeds);
            SAVEpath = fullfile(ANApath,'staticFC_Aij',['roi_n' num2str(nseed)],FMRI.prep.fmridir); mkdir(SAVEpath);
            SAVEname = sprintf('network_%s.mat',subj);
            SAVEname = fullfile(SAVEpath,SAVEname);
            
            save(SAVEname,'Z','R','P','seeds');
            ZZ(c,:,:) = Z; clear Z R P;
        end
        fprintf('\n');
        
    end
    
    % Write results in .csv format
    if FMRI.anal.checkbox_isNetworkmode==1
        % Write headers
        SAVEpath = fullfile(ANApath,'network',['roi_n' num2str(nseed)],FMRI.prep.fmridir); mkdir(SAVEpath);
        fn_hdr = fullfile(SAVEpath,'FC_ROInames.csv');
        fid = fopen(fn_hdr,'w+');
        fprintf(fid,'node number, ROI file name\n');
        for i=1:length(seeds)
            fprintf(fid,'%d, %s\n', i,seeds{i}.name);
        end
        fclose(fid);
        
        % Write FC data
        fn_dat = fullfile(SAVEpath,'FC_data.csv');
        fid = fopen(fn_dat,'w+');
        fprintf(fid,'subjname,');
        for i=1:nrois
            for j=(i+1):nrois
                if i==(nrois-1) && j==nrois
                    fprintf(fid,'ROI_%d-%d\n',i,j);
                else
                    fprintf(fid,'ROI_%d-%d,',i,j);
                end
            end
        end
        for c=1:nsubj
            fprintf(fid,'%s,',subjnames{c});
            for i=1:nrois
                for j=(i+1):nrois
                    if i==(nrois-1) && j==nrois
                        fprintf(fid,'%.3f\n',ZZ(c,i,j));
                    else
                        fprintf(fid,'%.3f,',ZZ(c,i,j));
                    end
                end
            end
        end
        fclose(fid);
    end
    
    set(handles.run_analysis,'ForegroundColor',[234 100 100]./256);
    set(handles.run_analysis,'BackgroundColor',[248 248 248]./256);
    pause(0.2);
end


msg_on_handle=sprintf('Static FC was done ...  ');
set(handles.analcorr_status,'String',msg_on_handle);
set(handles.analcorr_status,'ForegroundColor','k');
set(handles.analcorr_status,'FontWeight','normal');


