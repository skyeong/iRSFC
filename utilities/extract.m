function varargout = extract(varargin)
% EXTRACT MATLAB code for extract.fig
%      EXTRACT, by itself, creates a new EXTRACT or raises the existing
%      singleton*.
%
%      H = EXTRACT returns the handle to a new EXTRACT or the handle to
%      the existing singleton*.
%
%      EXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACT.M with the given input arguments.
%
%      EXTRACT('Property','Value',...) creates a new EXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help extract

% Last Modified by GUIDE v2.5 03-Apr-2016 10:09:20

% Begin initialization code - DO NOT EDIT
global UTIL

if nargin == 0  % LAUNCH GUI
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @extract_OpeningFcn, ...
        'gui_OutputFcn',  @extract_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    
    % Generate a structure of handles to pass to callbacks, and store it.
    fig = openfig(mfilename,'reuse');
    handles = guihandles(fig);
    guidata(fig, handles);
    set(fig, 'Name','iRSFC Utility');
    
    % Defaults seeting
    UTIL.seed = 'PCC';
    UTIL.fmripath = 'rest';
    
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



% End initialization code - DO NOT EDIT





% --- Executes just before extract is made visible.
function extract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to extract (see VARARGIN)

% Choose default command line output for extract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = extract_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_datapath_Callback(hObject, eventdata, handles)
global UTIL
UTIL.DATApath = get(hObject,'String');


function edit_outpath_Callback(hObject, eventdata, handles)
global UTIL
UTIL.OUTpath = get(hObject,'String');


function edit_fmri_Callback(hObject, eventdata, handles)
global UTIL
UTIL.fmripath = get(hObject,'String');


function edit_subjlist_Callback(hObject, eventdata, handles)
global UTIL
UTIL.fp = get(hObject,'String');
UTIL.subjList = iRSFC_subjInfo(UTIL.fp);


function edit_seed_Callback(hObject, eventdata, handles)
global UTIL
UTIL.seed = get(hObject,'String');


% --- Executes on button press in pushbutton_subjlist.
function pushbutton_subjlist_Callback(hObject, eventdata, handles)
global UTIL

[fn,fp] = uigetfile({'*.xls;*.xlsx','Excel Files (*.xls,*.xlsx)';'*.csv','Comma Seperated Value (*.csv)' },'Select file');
UTIL.fp = fullfile(fp, fn);
set(handles.edit_subjlist,'String',UTIL.fp);

UTIL.subjList = iRSFC_subjInfo(UTIL.fp);
fprintf('Number of subjects in the list: %d\n',length(UTIL.subjList));



% --- Executes on button press in pushbutton_ROIs.
function pushbutton_ROIs_Callback(hObject, eventdata, handles)
global UTIL
[fns, ROIpath] = uigetfile({'*.nii;*.img', 'All Imaging Files (*.img, *.nii)'},'Select a mask image file','MultiSelect', 'on');

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

set(handles.text_ROI_Images,'String',show_fns);
UTIL.ROIimgs = ROIimgs;
UTIL.nROIimgs = nROIimgs;




% --- Executes on button press in pushbutton_DATApath.
function pushbutton_DATApath_Callback(hObject, eventdata, handles)
global UTIL
DATApath = uigetdir();
UTIL.DATApath = DATApath;
set(handles.edit_datapath, 'String', DATApath);



% --- Executes on button press in pushbutton_OUTpath.
function pushbutton_OUTpath_Callback(hObject, eventdata, handles)
global UTIL
OUTpath = uigetdir();
UTIL.OUTpath = OUTpath;
set(handles.edit_outpath, 'String', OUTpath);


% --- Executes on button press in pushbutton_extract.
function pushbutton_extract_Callback(hObject, eventdata, handles)
global UTIL
set(handles.text_status,'String','Extracting ...'); pause(0.5);

% Subject's List
subjlist = UTIL.subjList; 
nsubj = length(subjlist);

% Get User Setings
seedname  = UTIL.seed; 
fn_ROIs   = UTIL.ROIimgs; 
nROIimgs  = UTIL.nROIimgs;
DATApath  = UTIL.DATApath;
fmripath  = UTIL.fmripath;
imgPath   = fullfile(DATApath,seedname,fmripath);
OUTpath   = UTIL.OUTpath;

Zmean = zeros(nsubj,nROIimgs);
for c=1:nsubj,
    subjname = subjlist{c};
    
    status_message = sprintf('[%03d/%03d] Extract from %s...',c,nsubj,subjname);
    set(handles.text_status,'String',status_message); pause(0.5);
    
    imgName = sprintf('*%s*.nii', subjname);
    fn_zmap = fullfile(imgPath,imgName);
    imgName = dir(fn_zmap);
    fn_zmap = fullfile(imgPath,imgName(1).name);
    
    VOL = spm_vol(fn_zmap);
    IMG = spm_read_vols(VOL);
    
    for r=1:nROIimgs,
        fn_ROI = fn_ROIs{r};
        vo_ROI = spm_vol(fn_ROI);
        ROI = spm_read_vols(vo_ROI);
        idroi = find(ROI>0);
        [vx, vy, vz] = ind2sub(vo_ROI.dim, idroi);
        ROIxyz = [vx, vy, vz, ones(size(vx))];
        Rxyz = vo_ROI.mat*ROIxyz';
        IMGxyz = pinv(VOL.mat)*Rxyz;
        
        zvals = spm_sample_vol(IMG, IMGxyz(1,:), IMGxyz(2,:), IMGxyz(3,:), 0);
        Zmean(c,r) = mean(zvals(isfinite(zvals)));
    end
end

% Define output file name
set(handles.text_status,'String','Writing results.');
fn_out = fullfile(OUTpath,sprintf('%s_%s.csv',seedname,fmripath));
fid = fopen(fn_out,'w+');


% Writing Resulting Values
fprintf(fid,'subjname,');
for i=1:nROIimgs,
    fn_ROI = fn_ROIs{i};
    [p,f,e] = fileparts(fn_ROI);
    if i==nROIimgs,
        fprintf(fid,'%s_%s\n',f,fmripath);
    else
        fprintf(fid,'%s_%s,',f,fmripath);
    end
end


fmt = repmat('%.2f,',1,nROIimgs);
fmt(end) = ''; fmt = ['%s,' fmt, '\n'];

for c=1:nsubj,
    subjname = subjlist{c};
    fprintf(fid, fmt, subjname, Zmean(c,:));
end
fclose(fid);
set(handles.text_status,'String','Done.');
