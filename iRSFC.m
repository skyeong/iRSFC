function varargout = iRSFC(varargin)
%iRSFC
% Requirements:
%   Before using iRSFC, SPM should be installed previously.
%   Refer to SPM website
%   http://www.fil.ion.ucl.ac.uk/spm/


global FMRI;
warning('off','all');

if nargin == 0  % LAUNCH GUI
    
    exepath=which('iRSFC');
    [p,f,e]=fileparts(exepath);
    FMRI.iRSFCpath = p;
    
    addpath(genpath(p));
    spm_dir = which('spm');
    if isempty(spm_dir),
        errordlg('SPM path should be added before executing this program.');
        return;
    end
    FMRI.spmVer = spm('ver');
    
    license=fullfile(p,'license.txt');
    if exist(license,'file')==0, fprintf('No license file...\n'); return; end;
    
    
    % Generate a structure of handles to pass to callbacks, and store it.
    fig = openfig(mfilename,'new');
    handles = guihandles(fig);
    guidata(fig, handles);
    set(fig, 'Name','Expanding your insight with iRSFC');
    
    iRSFC_defaults;
    iRSFC_init(handles);
    
    FMRI.handle=fig;
    FMRI.figure.handles=handles;
    
    fprintf('--------------------------------------------------\n');
    fprintf('  Welcome to iRSFC\n');
    fprintf('  Copyright (c) 2015 Sunghyon Kyeong \n');
    fprintf('--------------------------------------------------\n');
    
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end




%**************************************************************************
% INITIALIZE
%**************************************************************************

function iRSFC_init(handles)
global FMRI

set(handles.checkbox_WM,  'Value', FMRI.prep.WM);
set(handles.checkbox_CSF, 'Value', FMRI.prep.CSF);
set(handles.checkbox_GS,  'Value', FMRI.prep.GS);
set(handles.checkbox_PCA, 'Value', FMRI.prep.PCA);
set(handles.edit_nPCA,    'Value', FMRI.prep.nPCA);


% Default mode: HM, PCA (3 components)
if get(handles.checkbox_PCA,'Value')~=1,
    set(handles.edit_nPCA, 'Enable','off');
end


set(handles.checkbox_isSeedmode, 'Value',FMRI.anal.checkbox_isSeedmode);
set(handles.checkbox_isNetworkmode, 'Value',FMRI.anal.checkbox_isNetworkmode);

set(handles.edit_prep_dummy, 'String', num2str(FMRI.prep.dummyoff));
seed_Atlas = sprintf('%d, ',FMRI.anal.FC.ids);
seed_Atlas = sprintf('[%s]',seed_Atlas(1,1:(end-2)));
set(handles.edit_seed_from_Atlas, 'String', seed_Atlas);
set(handles.edit_prefix, 'String', FMRI.prep.prefix);




%**************************************************************************
% LOAD SUBJECT INFORMATION
%**************************************************************************
function select_subjinfo_Callback(hObject, eventdata, handles)
global FMRI

[fn,fp]=uigetfile({'*.xls;*.xlsx','Excel Files (*.xls,*.xlsx)';'*.csv','Comma Seperated Value (*.csv)' },'Select file');
FMRI.fp = fullfile(fp, fn);
set(handles.load_subjlist_info,'String',FMRI.fp);

subjList = iRSFC_subjInfo(FMRI.fp);
FMRI.prep.subjList=subjList;
fprintf('  # of subjs: %d\n\n',length(FMRI.prep.subjList));

% guidata(hObject, handles);


function select_fmripath_Callback(hObject, eventdata, handles)
global FMRI
DATApath = uigetdir(pwd,'Select DATA path');
set(handles.DATApath,'String',DATApath);
FMRI.prep.DATApath = DATApath;


function load_subjlist_info_Callback(hObject, eventdata, handles)
global FMRI
subjList = get(hObject,'String');
FMRI.prep.subjList = subjList;




%**************************************************************************
% TEMPORAL PREPROCESSING CALLBACK FUNCTIONS
%**************************************************************************
function edit_prefix_Callback(hObject, eventdata, handles)
global FMRI
FMRI.prep.prefix = get(hObject,'String');


function checkbox_CSF_Callback(hObject, eventdata, handles)
global FMRI
FMRI.prep.CSF = get(hObject,'Value');


function checkbox_WM_Callback(hObject, eventdata, handles)
global FMRI
FMRI.prep.WM = get(hObject,'Value');


function checkbox_GS_Callback(hObject, eventdata, handles)
global FMRI
FMRI.prep.GS = get(hObject,'Value');
if FMRI.prep.GS==1,
    set(handles.checkbox_PCA, 'Enable','off');
else
    set(handles.checkbox_PCA, 'Enable','on');
end
    
    

% --- Executes on selection change in popupmenu_HM.
function popupmenu_HM_Callback(hObject, eventdata, handles)
global FMRI
button_state = get(hObject,'Value');
if button_state == 1
    nHM = 24;
elseif button_state == 2
    nHM = 12;
elseif button_state == 3
    nHM = 6;
end
FMRI.prep.nHM = nHM;
fprintf('Number of head motions: %d \n',nHM);




% --- Executes on button press in checkbox_PCA.
function checkbox_PCA_Callback(hObject, eventdata, handles)
global FMRI;
FMRI.prep.PCA = get(hObject,'Value'); 
if get(hObject,'Value')==1,
    set(handles.edit_nPCA,   'Enable','on');
    set(handles.checkbox_GS, 'Enable','off');
else
    set(handles.edit_nPCA,   'Enable','off');
    set(handles.checkbox_GS, 'Enable','on');
end



function edit_nPCA_Callback(hObject, eventdata, handles)
global FMRI;

try
    nPCA = str2double(get(hObject,'String'));
catch
    error('Positive integer should be entered.')
end

if nPCA<1
    error('Positive integer should be entered.')
end

FMRI.prep.nPCA = nPCA;




function edit_prep_BW_Callback(hObject, eventdata, handles)
global FMRI
BW = get(hObject,'String');
FMRI.prep.BW = eval(BW);


function edit_prep_dummy_Callback(hObject, eventdata, handles)
global FMRI
dummyoff = get(hObject,'String');
FMRI.prep.dummyoff = eval(dummyoff);


function edit_prep_TR_Callback(hObject, eventdata, handles)
global FMRI
TR = get(hObject,'String');
FMRI.prep.TR = eval(TR);


function DATApath_Callback(hObject, eventdata, handles)
global FMRI
DATApath = get(hObject,'String');
if ~exist(DATApath,'dir')
    errordlg([DATApath ' does not exist.'])
end
FMRI.prep.DATApath = DATApath;


function edit_prefix_CreateFcn(hObject, eventdata, handles)
global FMRI
prefix = get(hObject,'String');
FMRI.prep.prefix = prefix;



function edit_fmripath_Callback(hObject, eventdata, handles)
global FMRI

fmripath = get(hObject,'String');
FMRI.prep.fmridir = fmripath;




% --- Executes on button press in pushbutton_ROI_Images.
function pushbutton_ROI_Images_Callback(hObject, eventdata, handles)
global FMRI
[fns, ROIpath] = uigetfile( ...
    {'*.img;*.nii','Imaging File (*.img,*.nii)'}, ...
    'Pick a file',...
    'MultiSelect', 'on');
ROIimgs = struct([]);
if iscell(fns)==0,
    ROIimgs{1} = fullfile(ROIpath,fns);
    show_fns = fns;
    nROIimgs=1;
elseif length(fns)>1 && iscell(fns),
    for i=1:length(fns),
        ROIimgs{i} = fullfile(ROIpath,fns{i});
        if i==1,
            show_fns = fns{i};
        else
            show_fns = [show_fns, ', ', fns{i}];
        end
    end
    nROIimgs = length(fns);
end
set(handles.edit_ROI_Images,'String',show_fns);
FMRI.anal.FC.ROIimgs = ROIimgs;
FMRI.anal.FC.nROIimgs = nROIimgs;



function checkbox_isSeedmode_Callback(hObject, eventdata, handles)
global FMRI
FMRI.anal.checkbox_isSeedmode = get(hObject,'Value');


function checkbox_isNetworkmode_Callback(hObject, eventdata, handles)
global FMRI
FMRI.anal.checkbox_isNetworkmode = get(hObject,'Value');





%**************************************************************************
% FUNCTIONAL CONNECTIVITY CALLBACK FUNCTIONS
%**************************************************************************
function edit_seed_from_Atlas_Callback(hObject, eventdata, handles)
global FMRI
seed_ids = get(hObject,'String');
FMRI.anal.FC.ids = eval(seed_ids);
fprintf('atlas_num = %s\n',seed_ids);



% --- Executes on button press in select_Atlas_regions.
function select_Atlas_regions_Callback(hObject, eventdata, handles)
global FMRI

if strcmpi(FMRI.anal.selected_atlas,'AAL')
    [a,b,data]=xlsread('AAL.xls');
elseif strcmpi(FMRI.anal.selected_atlas,'shen_268')
    [a,b,data]=xlsread('shen_268.xls');
elseif strcmpi(FMRI.anal.selected_atlas,'Dosenbach')
    [a,b,data]=xlsread('Dosenbach.xls');
elseif strcmpi(FMRI.anal.selected_atlas,'HarvardOxford')
    [a,b,data]=xlsread('HarvardOxford.xls');
else
    errordlg('Select Atlas!!','Error Dialog');
    return
end

hdr = data(1,:);
Atlas = data(2:end,2);

[seed_Atlas,ok] = listdlg('PromptString','Select ROIs:','ListString',Atlas);
if ok==1
    FMRI.anal.FC.ids = seed_Atlas;
    seed_Atlas = num2str(seed_Atlas);
    seed_Atlas = sprintf('[%s]',seed_Atlas(1,1:end));
    set(handles.edit_seed_from_Atlas, 'String', seed_Atlas);
end


function select_seedcorr_Callback(hObject, eventdata, handles)
global FMRI
OUTpath = uigetdir(pwd,'Select OUT path 1');

set(handles.OUTpath_seedcorr,'String',OUTpath);
FMRI.anal.FC.OUTpath = OUTpath;


function OUTpath_seedcorr_Callback(hObject, eventdata, handles)
global FMRI
OUTpath = get(hObject,'String');
if ~exist(OUTpath,'dir'),
    errordlg([OUTpath ' does not exist.'])
end
FMRI.anal.FC.OUTpath = OUTpath;


function popupmenu_selectAtlas_Callback(hObject, eventdata, handles)
global FMRI
button_state = get(hObject,'Value');
if button_state == 2
    selected_atlas = 'AAL';
elseif button_state == 3
    selected_atlas = 'shen_268';
elseif button_state == 4
    selected_atlas = 'Dosenbach';
elseif button_state == 5
    selected_atlas = 'HarvardOxford';
end
FMRI.anal.selected_atlas = selected_atlas;




function run_analysis_Callback(hObject, eventdata, handles)
global FMRI

if strcmpi(FMRI.anal.mode,'Preprocess')
    if check_iRSFC_params(0)==1
        run_preprocess;
    end
    
elseif strcmpi(FMRI.anal.mode,'staticFC')
    if check_iRSFC_params(1)==1
        run_staticFC;
    end
    
elseif strcmpi(FMRI.anal.mode,'dynamicFC')
    fprintf('dynamic FC is selected\n');
    if check_iRSFC_params(1)==1
        run_dynamicFC;
    end
    
elseif strcmpi(FMRI.anal.mode,'ALFF')
    fprintf('ALFF analysis is selected\n');
    if check_iRSFC_params(1)==1
        run_ALFF;
    end
elseif strcmpi(FMRI.anal.mode,'RLFF')
    fprintf('RLFF analysis is selected\n');
    if check_iRSFC_params(1)==1
        run_RLFF;
    end
else
    errordlg('Specify parameters correctly!!','Error Dialog');
    return
end






% --- Executes on selection change in popupmenu_analmode.
function popupmenu_analmode_Callback(hObject, eventdata, handles)
global FMRI
button_state = get(hObject,'Value');
if button_state == 1
    analmode = 'Preprocess';
elseif button_state == 2
    analmode = 'staticFC';
elseif button_state == 3
    analmode = 'dynamicFC';
elseif button_state == 4
    analmode = 'ALFF';
elseif button_state == 5
    analmode = 'RLFF';
end
FMRI.anal.mode = analmode;
fprintf('analysis mode: %s \n',analmode);



function edit_winSize_Callback(hObject, eventdata, handles)
global FMRI
winSize = str2double(get(hObject,'String'));
FMRI.anal.FC.winSize = winSize;
fprintf('Window size: %d scans\n',winSize);



function edit_slidingSteps_Callback(hObject, eventdata, handles)
global FMRI
slidingSteps = str2double(get(hObject,'String'));
FMRI.anal.FC.slidingSteps = slidingSteps;
fprintf('Sliding steps: %d scans\n',slidingSteps);




%**************************************************************************
% Utilities
%**************************************************************************
function pushbutton_extract_ROIs_Callback(hObject, eventdata, handles)
extract


function pushbutton_make_ROI_mask_Callback(hObject, eventdata, handles)
create_ROI_mask


function pushbutton_graphAnal_Callback(hObject, eventdata, handles)
graphanal


% --- Executes on button press in checkbox_scrubbing.
function checkbox_scrubbing_Callback(hObject, eventdata, handles)
global FMRI
FMRI.anal.FC.doScrubbing = get(hObject,'Value');



function edit_FDthr_Callback(hObject, eventdata, handles)
global FMRI
FMRI.anal.FC.FDthr = str2double(get(hObject,'String'));
