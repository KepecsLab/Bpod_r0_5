function varargout = LaunchManager(varargin)
% LAUNCHMANAGER M-file for LaunchManager.fig
%      LAUNCHMANAGER, by itself, creates a new LAUNCHMANAGER or raises the existing
%      singleton*.
%
%      H = LAUNCHMANAGER returns the handle to a new LAUNCHMANAGER or the handle to
%      the existing singleton*.
%
%      LAUNCHMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAUNCHMANAGER.M with the given input arguments.
%
%      LAUNCHMANAGER('Property','Value',...) creates a new LAUNCHMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LaunchManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LaunchManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LaunchManager

% Last Modified by GUIDE v2.5 13-Apr-2012 23:57:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LaunchManager_OpeningFcn, ...
                   'gui_OutputFcn',  @LaunchManager_OutputFcn, ...
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


% --- Executes just before LaunchManager is made visible.
function LaunchManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LaunchManager (see VARARGIN)
global BpodSystem
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
BG = imread('LaunchManagerBG.bmp');
image(BG); axis off;
ButtonGFX = imread('LaunchButton.bmp');
set(handles.pushbutton1, 'CData', ButtonGFX);
AddAnimalButtonGFX = imread('PlusButton.bmp');
set(handles.pushbutton2, 'CData', AddAnimalButtonGFX);
DelAnimalButtonGFX = imread('MinusButton.bmp');
EditAnimalButtonGFX = imread('EditButton.bmp');
ImportButtonGFX = imread('ImportButton.bmp');
set(handles.pushbutton3, 'CData', DelAnimalButtonGFX);
set(handles.pushbutton4, 'CData', AddAnimalButtonGFX);
set(handles.pushbutton5, 'CData', DelAnimalButtonGFX);
set(handles.pushbutton6, 'CData', EditAnimalButtonGFX);
set(handles.pushbutton7, 'CData', ImportButtonGFX);
% Check to see if a folder for this protocol's name exists, and if not, make one
% along with default files for the default test subject named "Test Session"
loadBpodPath;
DataPath = fullfile(BpodPath,'Data','Test Session');
CandidateProtocols = dir(DataPath);
ProtocolName = BpodSystem.CurrentProtocolName;
ProtocolPath = fullfile(BpodPath,'Protocols',ProtocolName);
SettingsPath = fullfile(DataPath,ProtocolName,'Session Settings');
DefaultSettingsPath = fullfile(ProtocolPath,'SessionSettings.mat');
DefaultOverridePath = fullfile(ProtocolPath,'Override.m');
DefaultPlotFilePath = fullfile(ProtocolPath,'PlotFile.m');


%Make standard folders for this protocol.  This will fail silently if the folders exist
mkdir(DataPath, ProtocolName);
mkdir( fullfile(DataPath,ProtocolName,'Session Data'))
mkdir( fullfile(DataPath,ProtocolName,'Session Settings'))

%Check whether default files exist, and repopulate them if they don't.
if ~exist(fullfile(SettingsPath,'Default.mat'))
    copyfile(DefaultSettingsPath, fullfile(SettingsPath,'Default.mat'))
end
if ~exist(fullfile(SettingsPath,'Default_Override.m'))
    copyfile(DefaultOverridePath, fullfile(SettingsPath,'Default_Override.m'))
end
if ~exist(fullfile(SettingsPath,'Default_PlotFile.m'))
    copyfile(DefaultPlotFilePath, fullfile(SettingsPath,'Default_PlotFile.m'))
end

% Sync the test session default file
SettingsFolder = fullfile(BpodPath,'Data','Test Session',ProtocolName,'Session Settings');
SettingsPath = fullfile(SettingsFolder,'Default.mat');
mkdir(SettingsFolder)
copyfile(DefaultSettingsPath, SettingsPath);

% Make a list of the names of all subjects who already have a folder for this
% protocol.

DataPath = fullfile(BpodPath,'Data');
CandidateSubjects = dir(DataPath);
SubjectNames = cell(1);
nSubjects = 1;
SubjectNames{1} = 'Test Session';
for x = 1:length(CandidateSubjects)
    if x > 2
        if CandidateSubjects(x).isdir
            if ~strcmp(CandidateSubjects(x).name, 'Test Session')
                Testpath = fullfile(DataPath,CandidateSubjects(x).name,ProtocolName);
                if exist(Testpath) == 7
                    nSubjects = nSubjects + 1;
                    SubjectNames{nSubjects} = CandidateSubjects(x).name;
                    % Copy default settings from original protocol folder
                    % to keep locals in sync with updates
                    SettingsPath = fullfile(BpodPath,'Data',CandidateSubjects(x).name,ProtocolName,'Session Settings');
                    copyfile(DefaultSettingsPath, fullfile(SettingsPath,'Default.mat'))
                end
            end
        end
    end
end
set(handles.listbox1,'String',SubjectNames);

SettingsPath = fullfile(BpodPath,'Data','Test Session', ProtocolName,'Session Settings');
Candidates = dir(SettingsPath);
nSettingsFiles = 0;
SettingsFileNames = cell(1);
for x = 3:length(Candidates)
    Extension = Candidates(x).name;
    Extension = Extension(length(Extension)-2:length(Extension));
    if strcmp(Extension, 'mat')
        nSettingsFiles = nSettingsFiles + 1;
        Name = Candidates(x).name;
        SettingsFileNames{nSettingsFiles} = Name(1:end-4);
    end
end
set(handles.listbox2, 'String', SettingsFileNames);



% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LaunchManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LaunchManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
k = 5;

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


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global BpodSystem
loadBpodPath;
ProtocolName = BpodSystem.CurrentProtocolName;
NameList = get(handles.listbox1, 'String');
Selected = get(handles.listbox1, 'Value');
    if iscell(NameList)
        SelectedName = NameList{Selected};
    else
        SelectedName = NameList;
    end
SettingsPath = fullfile(BpodPath,'Data',SelectedName,ProtocolName,'Session Settings');
Candidates = dir(SettingsPath);
nSettingsFiles = 0;
SettingsFileNames = cell(1);
for x = 3:length(Candidates)
    Extension = Candidates(x).name;
    Extension = Extension(length(Extension)-2:length(Extension));
    if strcmp(Extension, 'mat')
        nSettingsFiles = nSettingsFiles + 1;
        Name = Candidates(x).name;
        SettingsFileNames{nSettingsFiles} = Name(1:end-4);
    end
end
set(handles.listbox2, 'String', SettingsFileNames);
set(handles.listbox2, 'Value', 1);
% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
NameList = get(handles.listbox1, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox1, 'Value');
SubjectName = NameList{Selected};
NameList = get(handles.listbox2, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox2, 'Value');
SettingsFileName = NameList{Selected};
ProtocolName = BpodSystem.CurrentProtocolName;
loadBpodPath;
FormattedDate = [datestr(now, 3) datestr(now, 7) '_' datestr(now, 10)];
DataFolder = fullfile(BpodPath,'Data',SubjectName,ProtocolName, 'Session Data');
Candidates = dir(DataFolder);
nSessionsToday = 0;
for x = 1:length(Candidates)
    if x > 2
        if strfind(Candidates(x).name, FormattedDate)
            nSessionsToday = nSessionsToday + 1;
        end
    end
end

DataPath = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Data',[SubjectName '_' ProtocolName '_' FormattedDate '_Session' num2str(nSessionsToday+1) '.mat']);
SettingsPath = fullfile(BpodPath,'Data',SubjectName,ProtocolName, 'Session Settings',[SettingsFileName '.mat']);
BpodSystem.DataPath = DataPath;
BpodSystem.SettingsPath = SettingsPath;
ProtocolPath = fullfile(BpodPath,'Protocols',ProtocolName,[ProtocolName '.m']);
close(LaunchManager)
BpodSystem.Live = 1;
LiveSessionDisplay;
set(BpodSystem.GUIHandles.ProtocolNameDisplay, 'String', ProtocolName);
set(BpodSystem.GUIHandles.SubjectNameDisplay, 'String', SubjectName);
set(BpodSystem.GUIHandles.SettingsFileDisplay, 'String', SettingsFileName);
run(ProtocolPath);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
% Add Subject
NewSubjectGFX = imread('NameInputBG.bmp');
NameInputFig = figure('Position',[550 600 200 100],'name','New test subject','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
image(NewSubjectGFX); axis off;
NewAnimalName = uicontrol('Style', 'edit', 'String', '', 'Position', [25 25 150 25], 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', [1 1 1]);
uicontrol(NewAnimalName)
waitfor(NewAnimalName,'String')
NameList = get(handles.listbox1, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
%try
NewName = get(NewAnimalName, 'String');
NewName = Spaces2Underscores(NewName);
% Check to see if subject already exists
loadBpodPath;
ProtocolName = BpodSystem.CurrentProtocolName;
Testpath = fullfile(BpodPath,'Data',NewName);
Testpath2 = fullfile(Testpath,ProtocolName);
ProtocolPath = fullfile(BpodPath,'Protocols',ProtocolName);
DefaultMatrixPath = 	fullfile(ProtocolPath ,'SessionSettings.mat');
DefaultOverridePath = 	fullfile(ProtocolPath ,'Override.m');
DefaultPlotFilePath = 	fullfile(ProtocolPath ,'PlotFile.m');
NewAnimal = 0;
if exist(Testpath) ~= 7
    mkdir(Testpath);
    NewAnimal = 1;
end
if exist(Testpath2) ~= 7
NameList{length(NameList)+1} = NewName;
set(handles.listbox1, 'String', NameList);
mkdir( fullfile(Testpath,ProtocolName));
mkdir( fullfile(Testpath,ProtocolName,'Session Data'))
mkdir( fullfile(Testpath,ProtocolName,'Session Settings'))
copyfile(DefaultMatrixPath, 	fullfile(Testpath,ProtocolName,'Session Settings','Default.mat'));
copyfile(DefaultOverridePath, 	fullfile(Testpath,ProtocolName,'Session Settings','Default_Override.m'));
copyfile(DefaultPlotFilePath, 	fullfile(Testpath,ProtocolName,'Session Settings','Default_PlotFile.m'))
close(NameInputFig);
if NewAnimal == 0
    msgbox(['Existing test subject ' NewName ' has now been registered for ' ProtocolName '.'], 'Modal')
end
else
    close(NameInputFig);
    BpodErrorSound;
    msgbox('Subject already exists in this task. No entry made.', 'Modal')
end
%catch
%end

% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
% Add Subject
NameList = get(handles.listbox1, 'String');
Selected = get(handles.listbox1, 'Value');
if Selected > 1
    if iscell(NameList)
        SelectedName = NameList{Selected};
    else
        SelectedName = NameList;
    end
    
    DeleteFig = figure('Position',[550 600 250 150],'name','Delete test subject','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    Warning = uicontrol('Style', 'text', 'String', ['Warning! You are about to delete all data, folders and settings for ' SelectedName '!'], 'Position', [1 110 250 30], 'FontWeight', 'bold', 'FontSize', 8, 'BackgroundColor', [1 0 0]);
    BpodErrorSound;
    BackupCheck = uicontrol('Style', 'checkbox', 'String', ['I have backed up necessary files'], 'Position', [25 80 200 30], 'FontWeight', 'bold', 'FontSize', 8);
    IntentCheck = uicontrol('Style', 'checkbox', 'String', ['I really want to do this'], 'Position', [25 50 200 30], 'FontWeight', 'bold', 'FontSize', 8);
    ZapButton = uicontrol('Style', 'togglebutton', 'String', ['Ok'], 'Position', [75 10 100 30], 'FontWeight', 'bold', 'FontSize', 8);
    waitfor(ZapButton, 'Value')
    OkToDelete = 0;
    try
    OkToDelete = sum(get(BackupCheck, 'Value') + get(IntentCheck, 'Value') == 2);
    catch
    end
    if ((OkToDelete == 1) && (~isempty(SelectedName)))
        loadBpodPath;
        DeletePath = fullfile(BpodPath,'Data',SelectedName);
%         rmdir(DeletePath,'s')
        BpodErrorSound;
%         msgbox(['       Entry  for ' SelectedName ' deleted!'], 'Modal');
        msgbox('Delete function disabled until further testing', 'Modal')
        close(DeleteFig);  
        [trash, Pos] = FastWordDetect(SelectedName, NameList);
        NameList = NameList([1:Pos-1 Pos+1:length(NameList)]);
        set(handles.listbox1, 'String', NameList);   
        set(handles.listbox1, 'Value', 1); 
    else
        BpodErrorSound;
        msgbox('           Entry NOT deleted.', 'Modal');
        try
        close(DeleteFig);
        catch
        end
    end
else
     msgbox('The test session cannot be deleted.');
     BpodErrorSound;
end

% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global BpodSystem

NewSubjectGFX = imread('NameInput_S.bmp');
NameInputFig = figure('Position',[550 600 200 100],'name','New settings file','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
image(NewSubjectGFX); axis off;
NewSettingsName = uicontrol('Style', 'edit', 'String', '', 'Position', [25 25 150 25], 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', [1 1 1]);
uicontrol(NewSettingsName)
waitfor(NewSettingsName,'String')
SettingsNameList = get(handles.listbox2, 'String');
if ~iscell(SettingsNameList)
    Temp{1} = SettingsNameList;
    SettingsNameList = Temp;
end
NewSettingsName = get(NewSettingsName, 'String');
NewSettingsName = Spaces2Underscores(NewSettingsName);
% Check to see if settings file already exists



SubjectNameList = get(handles.listbox1, 'String');
SubjectNameValue = get(handles.listbox1, 'Value');
if ~iscell(SubjectNameList)
    Temp{1} = SubjectNameList;
    SubjectNameList = Temp;
end
SubjectName = SubjectNameList{SubjectNameValue};
% Check to see if subject already exists
loadBpodPath;

ProtocolName = BpodSystem.CurrentProtocolName;
Testpath = 			fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[NewSettingsName '.mat' ]);
OverridePath = 		fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[NewSettingsName '_Override.m' ]);
PlotFilePath = 		fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[NewSettingsName '_PlotFile.m' ]);
DefaultMatrixPath = fullfile(BpodPath,'Protocols',ProtocolName,'SessionSettings.mat');
ProtocolPath = 		fullfile(BpodPath,'Protocols',ProtocolName);

NewAnimal = 0;
if exist(Testpath) == 0
    SettingsPath = Testpath;
    copyfile(DefaultMatrixPath, SettingsPath);
    DefaultOverridePath = fullfile(ProtocolPath,'Override.m');
    DefaultPlotFilePath = fullfile(ProtocolPath,'PlotFile.m');
    copyfile(DefaultOverridePath, OverridePath);
    copyfile(DefaultPlotFilePath, PlotFilePath);
    SettingsNameList{length(SettingsNameList)+1} = NewSettingsName;
    set(handles.listbox2, 'String', SettingsNameList);
    set(handles.listbox2, 'Value', length(SettingsNameList));
    close(NameInputFig);
    ProtocolName = BpodSystem.CurrentProtocolName;
    BpodSystem.SettingsPath = SettingsPath;
    % Choose default command line output for LaunchManager
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    TwoAFCSessionEditor;
else
    close(NameInputFig);
    BpodErrorSound;
    msgbox('A settings file with this name exists. No entry made.', 'Modal')
end

% --- Executes on button press in pushbutton5 (Delete Settings button).
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
loadBpodPath
NameList = get(handles.listbox1, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox1, 'Value');
SubjectName = NameList{Selected};
NameList = get(handles.listbox2, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox2, 'Value');
[isthere, DefaultIndex] = FastWordDetect('Default', NameList);
if Selected ~=  DefaultIndex
SettingsFileName = NameList{Selected};
ProtocolName = BpodSystem.CurrentProtocolName;
SettingsPath = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsFileName '.mat']);
OverridePath = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsFileName '_Override.m']);
PlotFilePath = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsFileName '_PlotFile.m']);
delete(SettingsPath);
delete(OverridePath);
delete(PlotFilePath);
BpodErrorSound;
msgbox(['Settings file ' SettingsFileName ' deleted!'], 'Modal');
[trash, Pos] = FastWordDetect(NameList{Selected}, NameList);
NameList = NameList([1:Pos-1 Pos+1:length(NameList)]);
set(handles.listbox2, 'String', NameList);
set(handles.listbox2, 'Value', 1);
% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
else
BpodErrorSound;
msgbox('The default settings file can not be deleted.', 'Modal')
end
% --- Executes on button press in pushbutton6 (Edit Settings button).
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
loadBpodPath
NameList = get(handles.listbox1, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox1, 'Value');
SubjectName = NameList{Selected};
NameList = get(handles.listbox2, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox2, 'Value');
[isthere, DefaultIndex] = FastWordDetect('Default', NameList);
if Selected ~= DefaultIndex
    SettingsFileName = NameList{Selected};
    ProtocolName = BpodSystem.CurrentProtocolName;
    SettingsPath = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsFileName '.mat']);
    BpodSystem.SettingsPath = SettingsPath;
    TwoAFCSessionEditor;
else
    BpodErrorSound;
    msgbox('The default settings file can not be modified.', 'Modal')
end


% --- Executes on button press in pushbutton7 (Import Settings button).
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BpodSystem;
loadBpodPath
SearchStartPath = fullfile(BpodPath, 'Data');
[Filename Pathname Junk] = uigetfile('*.mat', 'Select settings to import', SearchStartPath);
SettingsName = Filename(1:(length(Filename)-4));
TargetSessionMatrix = [Pathname Filename];
TargetOverride = [Pathname SettingsName '_Override.m'];
TargetPlotFile = [Pathname SettingsName '_PlotFile.m'];
TargetSubjectName = 5;
TargetProtocolName = 5;
if ~exist(TargetSessionMatrix) || ~exist(TargetOverride) || ~exist(TargetPlotFile)
error(['Plot file or override script not found for ' SettingsName])
end
NameList = get(handles.listbox1, 'String');
if ~iscell(NameList)
    Temp{1} = NameList;
    NameList = Temp;
end
Selected = get(handles.listbox1, 'Value');
SubjectName = NameList{Selected};
ProtocolName = BpodSystem.CurrentProtocolName;
DestinationSessionMatrix = fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsName '.mat']);
DestinationOverride =  fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsName '_Override.m']);
DestinationPlotFile =  fullfile(BpodPath,'Data',SubjectName,ProtocolName,'Session Settings',[ SettingsName '_PlotFile.m']);



if (exist(DestinationSessionMatrix) == 2) || (exist(DestinationOverride) == 2) || (exist(DestinationPlotFile) == 2)
    msgbox(['"' SettingsName '"' ' already exists in the target folder. Import aborted.'])
    BpodErrorSound
end

% Copy files
copyfile(TargetSessionMatrix, DestinationSessionMatrix);
copyfile(TargetOverride, DestinationOverride);
copyfile(TargetPlotFile, DestinationPlotFile);

% Update UI with new settings
SettingsPath = fullfile(BpodPath,'Data','Test Session', ProtocolName,'Session Settings');
Candidates = dir(SettingsPath);
nSettingsFiles = 0;
SettingsFileNames = cell(1);
for x = 3:length(Candidates)
    Extension = Candidates(x).name;
    Extension = Extension(length(Extension)-2:length(Extension));
    if strcmp(Extension, 'mat')
        nSettingsFiles = nSettingsFiles + 1;
        Name = Candidates(x).name;
        SettingsFileNames{nSettingsFiles} = Name(1:end-4);
    end
end
set(handles.listbox2, 'String', SettingsFileNames);



% Choose default command line output for LaunchManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
