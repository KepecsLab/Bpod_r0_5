function Reinforcement

global BpodSystem

%% Program PulsePal
load(fullfile(BpodSystem.ProtocolPath, 'Reinforcement_PulsePalProgram.mat'));
ProgramPulsePal(ParameterMatrix);

%% Define parameters

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.LargeRewardAmount = 5; % amount of large reward delivered to the mouse in microliters
    S.GUI.SmallRewardAmount = 2.5; % amount of small reward delivered to the mouse in microliters
    S.GUI.LargePunishDuration = 1; % amount of time the air puff valve is open
    S.GUI.SmallPunishDuration = .25;
    S.GUI.InitialDelayMean = 3; % Mean of an exponential distribution for initial delay
    S.GUI.InitialDelayMax = 6;
    S.GUI.ReinforcementDelayMean = 1; % Mean of an exponential distribution for reinforcement delay
    S.GUI.ReinforcementDelayMax = 3; % Mean of an exponential distribution for reinforcement delay
    S.StimulusDuration = .25;
    S.TrialTypeProbs = [.25 .25 .25 .25]; %Probability of trial types 1-4 in the session
end
% Launch parameter GUI
BpodParameterGUI('init', S);
%% Define trials

maxTrials = 5000;
S.TrialTypes = zeros(1,maxTrials);
for x = 1:maxTrials
    P = rand;
    Cutoffs = cumsum(S.TrialTypeProbs);
    Found = 0;
    for y = 1:length(S.TrialTypeProbs)
        if P<Cutoffs(y) && Found == 0
            Found = 1;
            S.TrialTypes(x) = y;
        end
    end
end

%% Main loop
for currentTrial = 1:maxTrials 
    disp(['Trial # ' num2str(currentTrial) ': trial type ' num2str(S.TrialTypes(currentTrial))]);
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    if S.TrialTypes(currentTrial) == 1
        WaterTime =  GetValveTimes(S.GUI.LargeRewardAmount, [1]);
    elseif S.TrialTypes(currentTrial) == 2
        WaterTime =  GetValveTimes(S.GUI.SmallRewardAmount, [1]);
    else
        WaterTime = 0;
    end
    if S.TrialTypes(currentTrial) == 3
        PuffTime = S.GUI.LargePunishDuration;
    elseif S.TrialTypes(currentTrial) == 4
        PuffTime = S.GUI.SmallPunishDuration;
    else
        PuffTime = 0;
    end
    
    switch S.TrialTypes(currentTrial)
        case 1
            ReinforcementStateName = 'Reward';
            ParameterMatrix{5,2} = 0.0001; % Set PulsePal to 100us pulse width on output channel 1
            ParameterMatrix{8,2} = 0.0001; % Set PulsePal to 100us pulse interval on output channel 1
            OutputActionArgument = {'BNCState', 1};
        case 2
            ReinforcementStateName = 'Reward';
            ParameterMatrix{5,2} = 0.0002; % Set PulsePal to 100us pulse width on output channel 1
            ParameterMatrix{8,2} = 0.0002; % Set PulsePal to 100us pulse interval on output channel 1
            OutputActionArgument = {'BNCState', 1};
        case 3
            ReinforcementStateName = 'Punish';
            OutputActionArgument = {'PWM1', 255};
        case 4
            ReinforcementStateName = 'Punish';
            OutputActionArgument = {'PWM1', 16};
    end
    ProgramPulsePal(ParameterMatrix);
    Found = 0;
    while Found == 0
        CandidateDelay = S.GUI.InitialDelayMean;
        if CandidateDelay < S.GUI.InitialDelayMax
            Found = 1;
        end
    end
    S.InitialDelays(currentTrial) = CandidateDelay;
    Found = 0;
    while Found == 0
        CandidateDelay = S.GUI.ReinforcementDelayMean;
        if CandidateDelay < S.GUI.ReinforcementDelayMax
            Found = 1;
        end
    end
    S.ReinforcementDelays(currentTrial) = CandidateDelay;
    
    % Assemble state matrix
    sma = NewStateMatrix();
    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', S.InitialDelays(currentTrial),...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {'BNCState', 2}); % Send a TTL on BNC output 2 of Bpod for syncing with imaging system
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', S.StimulusDuration,...
        'StateChangeConditions', {'Tup', 'ReinforcementDelay'},...
        'OutputActions', OutputActionArgument);
    sma = AddState(sma, 'Name', 'ReinforcementDelay', ...
        'Timer', S.ReinforcementDelays(currentTrial),...
        'StateChangeConditions', {'Tup', ReinforcementStateName},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', WaterTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1In', 'StillDrinking'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'StillDrinking', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', PuffTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'ValveState', 2});
    BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
    BpodSystem.Data = BpodNotebook(BpodSystem.Data);
    SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    if BpodSystem.BeingUsed == 0
        return
    end
end
