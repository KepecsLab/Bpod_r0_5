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
function Bpod(varargin)
try
    evalin('base', 'BpodSystem;');
    BpodErrorSound;
    disp('Bpod is already open.');
catch
    warning off
    global BpodSystem
    if exist('rng','file') == 2
        rng('shuffle', 'twister'); % Seed the random number generator by CPU clock
    else
        rand('twister', sum(100*fliplr(clock))); % For older versions of MATLAB
    end
    load SplashBGData;
    load SplashMessageData;
    BpodSystem = BpodObject;
    BpodSystem.SplashData.BG = SplashBGData;
    BpodSystem.SplashData.Messages = SplashMessageData;
    clear SplashBGData SplashMessageData
    BpodSystem.GUIHandles.SplashFig = figure('Position',[400 300 485 300],'name','Bpod','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.LastTimestamp = 0;
    BpodSystem.InStateMatrix = 0;
    BpodSystem.BonsaiSocket.Connected = 0;
    if exist('BpodSystemSettings.mat') > 0
        load BpodSystemSettings;
        BpodSystem.SystemSettings = BpodSystemSettings;
    else
        BpodSystem.SystemSettings = struct;
    end
    BpodSystem.BlankStateMatrix = GenerateBlankStateMatrix;
    BpodSystem.HostOS = system_dependent('getos');
    BpodSplashScreen(1);
    
    % Load Bpod path
    FullBpodPath = which('Bpod');
    BpodSystem.BpodPath = FullBpodPath(1:strfind(FullBpodPath, 'Bpod System Files')-1);
    
    %Check for Data folder
    dir_data = dir( fullfile(BpodSystem.BpodPath,'Data') );
    if length(dir_data) == 0, %then Data didn't exist.
        mkdir([BpodSystem.BpodPath,'/' 'Data']);
    end
    
    %Check for CalibrationFiles folder
    dir_calfiles = dir( fullfile(BpodSystem.BpodPath,'Calibration Files') );
    if length(dir_calfiles) == 0, %then Data didn't exist.
        mkdir([BpodSystem.BpodPath,'/' 'Calibration Files']);
        BpodSystem.CalibrationTables.LiquidCal = [];
    else
        try
        LiquidCalibrationFilePath = fullfile(BpodSystem.BpodPath, 'Calibration Files', 'LiquidCalibration.mat');
        load(LiquidCalibrationFilePath);
        BpodSystem.CalibrationTables.LiquidCal = LiquidCal;
        catch
          BpodSystem.CalibrationTables.LiquidCal = [];  
        end
    end
    
    % Load input channel settings
    BpodSystem.InputConfigPath = fullfile(BpodSystem.BpodPath, 'Settings Files', 'BpodInputConfig.mat');
    load(BpodSystem.InputConfigPath);
    BpodSystem.InputsEnabled = BpodInputConfig;
    
    % Determine if PsychToolbox is installed. If so, serial communication
    % will proceed through lower latency psychtoolbox IOport serial interface (compiled for each platform).
    % Otherwise, Bpod defaults to MATLAB's Java based serial interface.
    try
        V = PsychtoolboxVersion;
        BpodSystem.UsesPsychToolbox = 1;
    catch
        BpodSystem.UsesPsychToolbox = 0;
    end
    
    % Try to find hardware. If none, prompt to run emulation mode.
    try
        if nargin > 0
            if strcmp(varargin{1}, 'EMU')
                EmulatorDialog;
            else
                InitializeHardware(varargin{1})
            end
        else
            InitializeHardware;
            SetupBpod;
        end
    catch
        EmulatorDialog;
    end
    
end

function SetupBpod(hObject,event)
global BpodSystem
if BpodSystem.EmulatorMode == 1
    close(BpodSystem.GUIHandles.LaunchEmuFig);
    disp('Connection aborted. Bpod started in Emulator mode.')
end
BpodSplashScreen(2);
BpodSplashScreen(3);
if isfield(BpodSystem.SystemSettings, 'BonsaiAutoConnect')
    if BpodSystem.SystemSettings.BonsaiAutoConnect == 1
        try
            disp('Attempting to connect to Bonsai. Timeout in 10 seconds...')
            BpodSocketServer('connect', 11235);
            BpodSystem.BonsaiSocket.Connected = 1;
            disp('Connected to Bonsai on port: 11235')
        catch
            BpodErrorSound;
            disp('Warning: Auto-connect to Bonsai failed. Please connect manually.')
        end
    end
end
BpodSplashScreen(4);
BpodSplashScreen(5);
close(BpodSystem.GUIHandles.SplashFig);
InitializeBpodGUI;
BpodSystem.BeingUsed = 0;
BpodSystem.Live = 0;
BpodSystem.Pause = 0;
BpodSystem.HardwareState.Valves = zeros(1,8);
BpodSystem.HardwareState.PWMLines = zeros(1,8);
BpodSystem.HardwareState.PortSensors = zeros(1,8);
BpodSystem.HardwareState.BNCInputs = zeros(1,2);
BpodSystem.HardwareState.BNCOutputs = zeros(1,2);
BpodSystem.HardwareState.WireInputs = zeros(1,4);
BpodSystem.HardwareState.WireOutputs = zeros(1,4);
BpodSystem.HardwareState.Serial1Code = 0;
BpodSystem.HardwareState.Serial2Code = 0;
BpodSystem.HardwareState.SoftCode = 0;
BpodSystem.LastHardwareState = BpodSystem.HardwareState;
BpodSystem.BNCOverrideState = zeros(1,4);
BpodSystem.EventNames = {'Port1In', 'Port1Out', 'Port2In', 'Port2Out', 'Port3In', 'Port3Out', 'Port4In', 'Port4Out', 'Port5In', 'Port5Out', ...
    'Port6In', 'Port6Out', 'Port7In', 'Port7Out', 'Port8In', 'Port8Out', 'BNC1High', 'BNC1Low', 'BNC2High', 'BNC2Low', ...
    'Wire1High', 'Wire1Low', 'Wire2High', 'Wire2Low', 'Wire3High', 'Wire3Low', 'Wire4High', 'Wire4Low', ...
    'SoftCode1', 'SoftCode2', 'SoftCode3', 'SoftCode4', 'SoftCode5', 'SoftCode6', 'SoftCode7', 'SoftCode8', 'SoftCode9', 'SoftCode10', ...
    'Unused', 'Tup', 'GlobalTimer1_End', 'GlobalTimer2_End', 'GlobalTimer3_End', 'GlobalTimer4_End', 'GlobalTimer5_End', ...
    'GlobalCounter1_End', 'GlobalCounter2_End', 'GlobalCounter3_End', 'GlobalCounter4_End', 'GlobalCounter5_End'};
BpodSystem.OutputActionNames = {'ValveState', 'BNCState', 'WireState', 'Serial1Code', 'Serial2Code', 'SoftCode', ...
    'GlobalTimerTrig', 'GlobalTimerCancel', 'GlobalCounterReset', 'PWM1', 'PWM2', 'PWM3', 'PWM4', 'PWM5', 'PWM6', 'PWM7', 'PWM8'};
BpodSystem.Birthdate = now;
BpodSystem.CurrentProtocolName = '';
evalin('base', 'global BpodSystem')

function CloseBpodHWNotFound(hObject,event)
global BpodSystem
lasterr
close(BpodSystem.GUIHandles.LaunchEmuFig);
close(BpodSystem.GUIHandles.SplashFig);
delete(BpodSystem)
clear BpodSystem SplashData Img StimuliDef Ports ha serialInfo x
disp('Error: Bpod device not found.')

function EmulatorDialog
global BpodSystem
BpodErrorSound;
BpodSystem.GUIHandles.LaunchEmuFig = figure('Position',[500 350 300 125],'name','ERROR','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom'); BG = imread('DeviceNotFound.bmp'); image(BG); axis off;
BpodSystem.Graphics.CloseBpodButton = imread('CloseBpod.bmp');
BpodSystem.Graphics.LaunchEMUButton = imread('StartInEmuMode.bmp');
BpodSystem.GUIHandles.LaunchEmuModeButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [15 55 277 32], 'Callback', @SetupBpod, 'CData', BpodSystem.Graphics.LaunchEMUButton, 'TooltipString', 'Start Bpod in emulation mode');
BpodSystem.GUIHandles.CloseBpodButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [15 15 277 32], 'Callback', @CloseBpodHWNotFound, 'CData', BpodSystem.Graphics.CloseBpodButton,'TooltipString', 'Close Bpod');
BpodSystem.EmulatorMode = 1;