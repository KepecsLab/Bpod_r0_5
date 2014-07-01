function SoundDiscrimination

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.StimulusDelayDuration = 0; % Duration of initial delay (s)
    S.GUI.TimeForResponse = 3; % Time after sampling for subject to respond (s)
    S.GUI.RewardAmount = 5; % amount of large reward delivered to the mouse in microliters
    S.GUI.TimeoutDuration = 2; % Duration of punishment timeout (s)
    S.StimulusDuration = 1; % Duration of the sound
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ceil(rand(1,MaxTrials)*2);

%% Define stimuli and send to sound server
LeftSound = GenerateSineWave(44100, 500, 1); % Sampling freq (hz), Sine frequency (hz), duration (s)
RightSound = GenerateSineWave(44100, 2000, 1);
PunishSound = rand(1,44100);
% TeensySoundServer('init');
% TeensySoundServer('sendwaveform', 1, LeftSound); % Upload the left sound to slot 1 (of 254) 
% TeensySoundServer('sendwaveform', 2, RightSound); 
% TeensySoundServer('sendwaveform', 3, PunishSound); 

%% Main trial loop
for currentTrial = 1:MaxTrials 
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1
            OutputActionArgument = {'Serial1Code', 1}; 
            LeftActionState = 'Reward'; RightActionState = 'Punish';
            ValveCode = 1; ValveTime = LeftValveTime;
        case 2
            OutputActionArgument = {'Serial1Code', 2};
            LeftActionState = 'Punish'; RightActionState = 'Reward';
            ValveCode = 4; ValveTime = RightValveTime;
    end
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'WaitForCenterPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port2In', 'Delay'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', S.GUI.StimulusDelayDuration,...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', S.StimulusDuration,...
        'StateChangeConditions', {'Tup', 'WaitForResponse', 'Port2Out', 'EarlyWithdrawal'},...
        'OutputActions', OutputActionArgument);
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'Punish'},...
        'OutputActions', {'Serial1Code', 255});
    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', S.GUI.TimeForResponse,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1In', LeftActionState, 'Port3In', RightActionState},...
        'OutputActions', {'PWM1', 255, 'PWM3', 255});
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'ValveState', ValveCode});
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'Serial1Code', 3});
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook(BpodSystem.Data); % Sync with Bpod notebook plugin
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    if BpodSystem.BeingUsed == 0
        return
    end
end
