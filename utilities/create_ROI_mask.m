function varargout = create_ROI_mask(varargin)
% CRATE_ROI_MASK MATLAB code for crate_ROI_mask.fig
%      CRATE_ROI_MASK, by itself, creates a new CRATE_ROI_MASK or raises the existing
%      singleton*.
%
%      H = CRATE_ROI_MASK returns the handle to a new CRATE_ROI_MASK or the handle to
%      the existing singleton*.
%
%      CRATE_ROI_MASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRATE_ROI_MASK.M with the given input arguments.
%
%      CRATE_ROI_MASK('Property','Value',...) creates a new CRATE_ROI_MASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before crate_ROI_mask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to crate_ROI_mask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help crate_ROI_mask

% Last Modified by GUIDE v2.5 03-Jan-2015 10:25:29

% Begin initialization code - DO NOT EDIT


global ROI
[p,f,e]=fileparts(which('create_ROI_mask'));
ROI.UTILpath=p;

if nargin == 0  % LAUNCH GUI
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @create_ROI_mask_OpeningFcn, ...
        'gui_OutputFcn',  @create_ROI_mask_OutputFcn, ...
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
    
    
    ROI.radius = 4;
    ROI.ROIshape = 'sphere';
    ROI.coordinate = 'MNI';
    
    
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







% --- Executes just before extract is made visible.
function create_ROI_mask_OpeningFcn(hObject, eventdata, handles, varargin)
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
function varargout = create_ROI_mask_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes just before crate_ROI_mask is made visible.
function crate_ROI_mask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to crate_ROI_mask (see VARARGIN)

% Choose default command line output for crate_ROI_mask
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes crate_ROI_mask wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function edit_center_Callback(hObject, eventdata, handles)
global ROI
cmd = sprintf('center=%s;',get(hObject,'String'));
try
    eval(cmd);
catch
    errordlg('Specify ROI center position correctly.','My Error Dialog');
    ROI.center=[];
    return;
end

if size(center)~=3,
    errordlg('Specify ROI center position correctly.','My Error Dialog');
    ROI.center=[];
    return;
end
ROI.center = center;



function edit_radius_Callback(hObject, eventdata, handles)
global ROI
ROI.radius = str2double(get(hObject,'String'));



% --- Executes on selection change in popupmenu_ROIshape.
function popupmenu_ROIshape_Callback(hObject, eventdata, handles)
global ROI
button_state = get(hObject,'Value');
if button_state == 1,
    ROIshape = 'sphere';
elseif button_state == 2,
    ROIshape = 'box';
end
ROI.ROIshape = ROIshape;



% --- Executes on selection change in popupmenu_coordinate.
function popupmenu_coordinate_Callback(hObject, eventdata, handles)
global ROI
button_state = get(hObject,'Value');
if button_state == 1,
    coordinate = 'MNI';
elseif button_state == 2,
    coordinate = 'Talairach';
end
ROI.coordinate = coordinate;



% --- Executes on button press in pushbutton_createROImask.
function pushbutton_createROImask_Callback(hObject, eventdata, handles)
global ROI

try
    SAVEpath = ROI.OUTpath;
catch
    errordlg('OUT path does not specified.');
    return
end
ROIshape   = ROI.ROIshape;
radius     = ROI.radius;

% Convert Talairach to MNI space
coordinate = ROI.coordinate;
center=ROI.center;
if strcmpi(coordinate,'Talairach'),
    MNIcenter = floor(tal2icbm_spm(ROI.center));
else
    MNIcenter = ROI.center;
end




%  GENERATE SEED ROIS DEFINED ABOVE
%__________________________________________________________________________

fn_vref = fullfile(ROI.UTILpath,'brainmask_1x1x1.nii');
vref = spm_vol(fn_vref);

Vxyz=[];
for i=-radius:radius,
    for j=-radius:radius,
        for k=-radius:radius,
            RADIUS = sqrt(i*i + j*j + k*k);
            if strcmpi(ROIshape,'sphere'),
                if (RADIUS <= radius)
                    sROI1 = [MNIcenter(1)+i,MNIcenter(2)+j,MNIcenter(3)+k];
                    Vxyz = [Vxyz;sROI1];
                end
            else
                sROI1 = [MNIcenter(1)+i,MNIcenter(2)+j,MNIcenter(3)+k];
                Vxyz = [Vxyz;sROI1];
            end
        end
    end
end
Vxyz = [Vxyz, ones(size(Vxyz,1),1)];
Rxyz = round(inv(vref.mat)*Vxyz')';
idroi = sub2ind(vref.dim(1:3),Rxyz(:,1),Rxyz(:,2),Rxyz(:,3));
idroi = unique(idroi);


%  SAVE ROI AS NIFTI FILE FORMAT
%__________________________________________________________________________

vo = vref;
SAVEname=sprintf('%s_%d_%d_%d_%s_%dmm.nii',coordinate,center(1),center(2),center(3),ROIshape,radius);
vo.fname=fullfile(SAVEpath,SAVEname);
IMG = zeros(vref.dim);
IMG(idroi) = radius;
spm_write_vol(vo,IMG);

fprintf('ROI is saved at\n');
fprintf('%s\n',fullfile(SAVEpath,SAVEname));



function edit_OUTpath_Callback(hObject, eventdata, handles)
global ROI
OUTpath = get(hObject,'String');
try
    mkdir(OUTpath);
catch
    f = errordlg('Can not create directory', 'My Error Dialog');
    return;
end
ROI.OUTpath = OUTpath;



% --- Executes on button press in pushbutton_ROIpath.
function pushbutton_ROIpath_Callback(hObject, eventdata, handles)
global ROI

directoryname = uigetdir(pwd, 'Pick a Directory');
ROI.OUTpath = directoryname;
set(handles.edit_OUTpath, 'String',directoryname);
