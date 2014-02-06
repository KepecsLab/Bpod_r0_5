function varargout = LiquidCalibrationGUI(varargin)
% LIQUIDCALIBRATIONGUI M-file for LiquidCalibrationGUI.fig
%      LIQUIDCALIBRATIONGUI, by itself, creates a new LIQUIDCALIBRATIONGUI or raises the existing
%      singleton*.
%
%      H = LIQUIDCALIBRATIONGUI returns the handle to a new LIQUIDCALIBRATIONGUI or the handle to
%      the existing singleton*.
%
%      LIQUIDCALIBRATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIQUIDCALIBRATIONGUI.M with the given input arguments.
%
%      LIQUIDCALIBRATIONGUI('Property','Value',...) creates a new LIQUIDCALIBRATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LiquidCalibrationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LiquidCalibrationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LiquidCalibrationGUI

% Last Modified by GUIDE v2.5 23-Oct-2012 02:09:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LiquidCalibrationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LiquidCalibrationGUI_OutputFcn, ...
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


% --- Executes just before LiquidCalibrationGUI is made visible.
function LiquidCalibrationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LiquidCalibrationGUI (see VARARGIN)
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
BG = imread('RewardCalMain.bmp');
image(BG); axis off;
AddAnimalButtonGFX = imread('PlusButton.bmp');
DelAnimalButtonGFX = imread('MinusButton.bmp');
set(handles.pushbutton1, 'CData', AddAnimalButtonGFX);
set(handles.pushbutton2, 'CData', DelAnimalButtonGFX);



% Choose default command line output for LiquidCalibrationGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LiquidCalibrationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LiquidCalibrationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function CommandMenu_Callback(hObject, eventdata, handles)
% hObject    handle to CommandMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RunPendingMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to RunPendingMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
beep

% --------------------------------------------------------------------
function AddRecommendedMeasurements_Callback(hObject, eventdata, handles)
% hObject    handle to RunPendingMeasurements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TestSpecificAmount_Callback(hObject, eventdata, handles)
% hObject    handle to TestSpecificAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ViewCalibrationCurves_Callback(hObject, eventdata, handles)
% hObject    handle to ViewCalibrationCurves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
