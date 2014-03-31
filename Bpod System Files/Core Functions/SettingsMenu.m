function varargout = SettingsMenu(varargin)
% SETTINGSMENU M-file for SettingsMenu.fig
%      SETTINGSMENU, by itself, creates a new SETTINGSMENU or raises the existing
%      singleton*.
%
%      H = SETTINGSMENU returns the handle to a new SETTINGSMENU or the handle to
%      the existing singleton*.
%
%      SETTINGSMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTINGSMENU.M with the given input arguments.
%
%      SETTINGSMENU('Property','Value',...) creates a new SETTINGSMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SettingsMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SettingsMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SettingsMenu

% Last Modified by GUIDE v2.5 11-Apr-2011 11:48:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SettingsMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @SettingsMenu_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before SettingsMenu is made visible.
function SettingsMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SettingsMenu (see VARARGIN)
global StateMachine
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
BG = imread('SettingsMenuBG.bmp');
image(BG); axis off;

LiquidCalButtonGFX = imread('WaterCalBW.bmp');
set(handles.pushbutton4, 'CData', LiquidCalButtonGFX, 'TooltipString', 'Liquid reward calibration');
SpeakerCalButtonGFX = imread('SpeakerCalButton.bmp');
set(handles.pushbutton3, 'CData', SpeakerCalButtonGFX, 'TooltipString', 'Sound Server setup and calibration');
OlfCalButtonGFX = imread('OlfButton.bmp');
set(handles.pushbutton2, 'CData', OlfCalButtonGFX, 'TooltipString', 'Olfactometer setup and calibration');
PortCalButtonGFX = imread('PortConfigButton.bmp');
set(handles.pushbutton1, 'CData', PortCalButtonGFX, 'TooltipString', 'Configure serial slave devices');
% Choose default command line output for SettingsMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SettingsMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SettingsMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) % Port configuration
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BpodPortConfig;
close(SettingsMenu)

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(SettingsMenu)
OlfactometerConfig;

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(SettingsMenu)
LiquidCalibrationManager;
