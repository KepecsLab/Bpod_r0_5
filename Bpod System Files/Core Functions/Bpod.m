function Bpod
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
    end
    
    % Load input channel settings
    BpodSystem.InputConfigPath = fullfile(BpodSystem.BpodPath, 'Settings Files', 'BpodInputConfig.mat');
    load(BpodSystem.InputConfigPath);
    BpodSystem.InputsEnabled = BpodInputConfig;
    
    try
        InitializeHardware
    catch
        lasterr
        close(BpodSystem.GUIHandles.SplashFig)
        delete(BpodSystem)
        clear BpodSystem SplashData Img StimuliDef Ports ha serialInfo x
        msgbox('Unable to connect to Bpod.', 'Modal')
        BpodErrorSound;
        clear BpodPath ComPortPath Found InList LastComPortUsed RegisteredPorts pos trash
        error('Error: Bpod device not found.')
    end
    BpodSplashScreen(2);
    BpodSplashScreen(3);
    BpodSplashScreen(4);
    BpodSplashScreen(5);
    close(BpodSystem.GUIHandles.SplashFig);
    InitializeBpodGUI;
    BpodSystem.BeingUsed = 0;
    BpodSystem.Live = 0;
    BpodSystem.HardwareState.Valves = zeros(1,8);
    BpodSystem.HardwareState.PWMLines = zeros(1,8);
    BpodSystem.HardwareState.PortSensors = zeros(1,8);
    BpodSystem.HardwareState.BNCInputs = zeros(1,2);
    BpodSystem.HardwareState.BNCOutputs = zeros(1,2);
    BpodSystem.HardwareState.WireInputs = zeros(1,4);
    BpodSystem.HardwareState.WireOutputs = zeros(1,4);
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
    clear ans
end