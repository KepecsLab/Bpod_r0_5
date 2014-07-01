function PsychToolboxSound

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SoundDuration = 1; % Duration of sound (s)
    S.GUI.SoundTypeA = 1; % 0 = noise, 1 = zero mean sine wave
    S.GUI.SoundTypeB = 0; % 0 = noise, 1 = zero mean sine wave
    S.GUI.SinWaveFreqLeft = 500;
    S.GUI.SinWaveFreqRight = 2000;
    S.GUI.RewardAmount = 5;
    S.GUI.StimulusDelayDuration = 0;
    S.GUI.TimeForResponse = 5;
    S.GUI.TimeoutDuration = 2;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ceil(rand(1,MaxTrials)*2);

%% Define stimuli and send to sound server
SF = 96000;
LeftSound = GenerateSineWave(SF, S.GUI.SinWaveFreqLeft, S.GUI.SoundDuration); % Sampling freq (hz), Sine frequency (hz), duration (s)
RightSound = GenerateSineWave(SF, S.GUI.SinWaveFreqRight, S.GUI.SoundDuration); % Sampling freq (hz), Sine frequency (hz), duration (s)
PunishSound = (rand(1,SF*.5)*2) - 1;
% Generate early withdrawal sound
W1 = GenerateSineWave(SF, 1000, .5); W2 = GenerateSineWave(SF, 1200, .5); EarlyWithdrawalSound = W1+W2;
P = 1000;
for x = 1:24
    EarlyWithdrawalSound(P:P+1000) = 0;
    P = P+2000;
end

% Program sound server
PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load', 1, LeftSound);
PsychToolboxSoundServer('Load', 2, RightSound);
PsychToolboxSoundServer('Load', 3, PunishSound);
PsychToolboxSoundServer('Load', 4, EarlyWithdrawalSound);

%% Main trial loop
for currentTrial = 1:MaxTrials 
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1
            OutputActionArgument = {'SoftCode', 1, 'BNCState', 1}; 
            LeftActionState = 'Reward'; RightActionState = 'Punish';
            ValveCode = 1; ValveTime = LeftValveTime;
        case 2
            OutputActionArgument = {'SoftCode', 2, 'BNCState', 1};
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
        'Timer', S.GUI.SoundDuration,...
        'StateChangeConditions', {'Tup', 'WaitForResponse', 'Port2Out', 'EarlyWithdrawal'},...
        'OutputActions', OutputActionArgument);
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawalPunish'},...
        'OutputActions', {'SoftCode', 255});
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
        'OutputActions', {'SoftCode', 3});
    sma = AddState(sma, 'Name', 'EarlyWithdrawalPunish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'SoftCode', 4});
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
