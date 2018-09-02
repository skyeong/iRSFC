function varargout = graphanal(varargin)
% GRAPHANAL MATLAB code for graphanal.fig
%      GRAPHANAL, by itself, creates a new GRAPHANAL or raises the existing
%      singleton*.
%
%      H = GRAPHANAL returns the handle to a new GRAPHANAL or the handle to
%      the existing singleton*.
%
%      GRAPHANAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAPHANAL.M with the given input arguments.
%
%      GRAPHANAL('Property','Value',...) creates a new GRAPHANAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before graphanal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to graphanal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help graphanal

% Last Modified by GUIDE v2.5 14-Jul-2016 17:03:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @graphanal_OpeningFcn, ...
    'gui_OutputFcn',  @graphanal_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);

if nargin && ischar(varargin{1}),
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT


% --- Executes just before graphanal is made visible.
function graphanal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to graphanal (see VARARGIN)

% Choose default command line output for graphanal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes graphanal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = graphanal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_subjlist_Callback(hObject, eventdata, handles)
global GRAPH
GRAPH.fp = get(hObject,'String');
GRAPH.subjList = iRSFC_subjInfo(GRAPH.fp);



function edit_Aijpath_Callback(hObject, eventdata, handles)
global GRAPH
GRAPH.Aijpath = get(hObject,'String');


function edit_OUTpath_Callback(hObject, eventdata, handles)
global GRAPH
GRAPH.OUTpath = get(hObject,'String');


% --- Executes on button press in pushbutton_OUTpath.
function pushbutton_OUTpath_Callback(hObject, eventdata, handles)
global GRAPH
OUTpath = uigetdir(pwd,'Select a directory');
set(handles.edit_OUTpath,'String',OUTpath);
GRAPH.OUTpath = OUTpath;




% --- Executes on button press in pushbutton_subjlist.
function pushbutton_subjlist_Callback(hObject, eventdata, handles)
global GRAPH

[fn,fp] = uigetfile({'*.xls;*.xlsx','Excel Files (*.xls,*.xlsx)';'*.csv','Comma Seperated Value (*.csv)' },'Select file');
GRAPH.fp = fullfile(fp, fn);
set(handles.edit_subjlist,'String',GRAPH.fp);

GRAPH.subjList = iRSFC_subjInfo(GRAPH.fp);
fprintf('Number of subjects in the list: %d\n',length(GRAPH.subjList));



% --- Executes on button press in pushbutton_Aijpath.
function pushbutton_Aijpath_Callback(hObject, eventdata, handles)
global GRAPH
Aijpath = uigetdir(pwd,'Select a directory');
set(handles.edit_Aijpath,'String',Aijpath);
GRAPH.Aijpath = Aijpath;



% --- Executes on button press in pushbutton_runAnal.
function pushbutton_runAnal_Callback(hObject, eventdata, handles)
fmri_graph_analysis(handles)


% --- Executes on selection change in popupmenu_threshold.
function popupmenu_threshold_Callback(hObject, eventdata, handles)
global GRAPH
button_state = get(hObject,'Value');
if button_state == 1,
    selected_thr = 'FDR';
elseif button_state == 2,
    selected_thr = 'Bonferroni';
end
GRAPH.thr_method = selected_thr;
