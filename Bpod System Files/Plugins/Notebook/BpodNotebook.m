%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
function varargout = BpodNotebook(varargin)
% BPODNOTEBOOK M-file for BpodNotebook.fig
%      BPODNOTEBOOK, by itself, creates a new BPODNOTEBOOK or raises the existing
%      singleton*.
%
%      H = BPODNOTEBOOK returns the handle to a new BPODNOTEBOOK or the handle to
%      the existing singleton*.
%
%      BPODNOTEBOOK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BPODNOTEBOOK.M with the given input arguments.
%
%      BPODNOTEBOOK('Property','Value',...) creates a new BPODNOTEBOOK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BpodNotebook_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BpodNotebook_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BpodNotebook

% Last Modified by GUIDE v2.5 19-Dec-2012 13:06:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BpodNotebook_OpeningFcn, ...
                   'gui_OutputFcn',  @BpodNotebook_OutputFcn, ...
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


% --- Executes just before BpodNotebook is made visible.
function BpodNotebook_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BpodNotebook (see VARARGIN)
% ha = axes('units','normalized', 'position',[0 0 1 1]);
% uistack(ha,'bottom');
% BG = imread('NotebookBG.bmp');
% imagesc(BG); axis off;
if ~isfield(handles, 'Notes')
    handles.Notes = cell(1,1);
end
if ~isfield(handles, 'TrialMarkerCodes')
    handles.TrialMarkerCodes = 0;
end
if nargin > 3
    handles.TE = varargin{1};
    handles.TE.Notes = handles.Notes;
    handles.TE.TrialMarkerCodes = handles.TrialMarkerCodes;
%     varargout{1} = handles.TE;
    if handles.TE.nTrials == 1
        set(handles.edit2, 'String', num2str(handles.TE.nTrials));
    end
    if length(handles.Notes) < handles.TE.nTrials+1
        handles.Notes((length(handles.Notes)+1):handles.TE.nTrials+1) = {[]};
    end
    if length(handles.TrialMarkerCodes) < handles.TE.nTrials+1
        handles.TrialMarkerCodes((length(handles.TrialMarkerCodes)+1):handles.TE.nTrials+1) = 0;
    end
end
k = 5;
% Choose default command line output for BpodNotebook
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BpodNotebook wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BpodNotebook_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global BpodSystem
if isfield(handles, 'TE')
    varargout{1} = handles.TE;
else
    varargout{1} = handles.output;
end
if ~isempty(BpodSystem)
    if BpodSystem.Live == 0
        close(hObject);
    end
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
handles.Notes{CurrentTrialViewing} = get(handles.edit1, 'String');
drawnow;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
MaxTrials = length(handles.Notes);
Num = ceil(str2double(get(handles.edit2, 'String')));
if ~isnan(Num)
    if Num < 1
        msgbox('Invalid trial number.')
        BpodErrorSound
        Num = 1;
    elseif Num > MaxTrials
        msgbox('Invalid trial number.')
        BpodErrorSound
        Num = MaxTrials;
    end
else
    msgbox('Invalid trial number.')
    BpodErrorSound
    Num = MaxTrials;
end
Str = handles.Notes{Num};
set(handles.edit2, 'String', num2str(Num));
set(handles.edit1, 'String', Str);
drawnow;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
CBval = get(handles.checkbox1, 'Value');
if CBval == 1
    handles.TrialMarkerCodes(CurrentTrialViewing) = get(handles.popupmenu1, 'Value');
else
    handles.TrialMarkerCodes(CurrentTrialViewing) = 0;
end
k = 5;
drawnow;
guidata(hObject, handles);
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
if get(handles.checkbox1, 'Value')
    handles.TrialMarkerCodes(CurrentTrialViewing) = get(handles.popupmenu1, 'Value');
end
drawnow;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
handles.Notes{CurrentTrialViewing} = get(handles.edit1, 'String');
msgbox('Note saved.')
drawnow;
guidata(hObject, handles);
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
if CurrentTrialViewing > 1
    CurrentTrialViewing = CurrentTrialViewing - 1;
end
set(handles.edit1, 'String', handles.Notes{CurrentTrialViewing});
set(handles.edit2, 'String', num2str(CurrentTrialViewing));
set(handles.checkbox1, 'Value', handles.TrialMarkerCodes(CurrentTrialViewing) > 0)
if handles.TrialMarkerCodes(CurrentTrialViewing) > 0
    set(handles.popupmenu1, 'Value', handles.TrialMarkerCodes(CurrentTrialViewing))
else
    set(handles.popupmenu1, 'Value', 1)
end
drawnow;
guidata(hObject, handles);
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CurrentTrialViewing = str2double(get(handles.edit2, 'String'));
MaxTrials = length(handles.Notes);
if CurrentTrialViewing < MaxTrials
    CurrentTrialViewing = CurrentTrialViewing + 1;
end
set(handles.edit1, 'String', handles.Notes{CurrentTrialViewing});
set(handles.edit2, 'String', num2str(CurrentTrialViewing));
set(handles.checkbox1, 'Value', handles.TrialMarkerCodes(CurrentTrialViewing) > 0)
if handles.TrialMarkerCodes(CurrentTrialViewing) > 0
    set(handles.popupmenu1, 'Value', handles.TrialMarkerCodes(CurrentTrialViewing))
else
    set(handles.popupmenu1, 'Value', 1)
end
drawnow;
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MaxTrials = length(handles.Notes);
set(handles.edit1, 'String', handles.Notes{MaxTrials});
set(handles.edit2, 'String', num2str(MaxTrials));
set(handles.checkbox1, 'Value', handles.TrialMarkerCodes(MaxTrials) > 0)
if handles.TrialMarkerCodes(MaxTrials) > 0
    set(handles.popupmenu1, 'Value', handles.TrialMarkerCodes(MaxTrials))
else
    set(handles.popupmenu1, 'Value', 1)
end
drawnow;
guidata(hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1, 'String', handles.Notes{1});
set(handles.edit2, 'String', num2str(1));
set(handles.checkbox1, 'Value', handles.TrialMarkerCodes(1) > 0)
if handles.TrialMarkerCodes(1) > 0
    set(handles.popupmenu1, 'Value', handles.TrialMarkerCodes(1))
else
    set(handles.popupmenu1, 'Value', 1)
end
drawnow;
guidata(hObject, handles);
