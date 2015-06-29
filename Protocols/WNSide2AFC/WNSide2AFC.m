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
function WNSide2AFC


global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 3; %ul
    S.GUI.DebounceTime = 0.01; % How long the system observes the mouse in the center port before acknowledging a poke in
    S.GUI.CueDelay = 0; % How long the mouse must poke in the center to activate the stimulus
    S.GUI.CueDuration = 0.1;
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    S.GUI.RewardDelay = 0; % How long the mouse must wait in the goal port for reward to be delivered
    S.GUI.PunishDelay = 3; % How long the mouse must wait in the goal port for reward to be delivered
    S.GUI.EWithdrawalDelay = 3; % How long the mouse has to wait to start the next trial after early withdrawal
    S.GUI.AntiBias = 1;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 1000;
TrialTypes = ceil(rand(1,1000)*2);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.SideOutcomePlot = axes('Position', [.075 .3 .89 .6]);
SideOutcomePlot(BpodSystem.GUIHandles.SideOutcomePlot,'init',2-TrialTypes);
BpodNotebook('init');
TotalRewardDisplay('init');

%% Create and upload sounds
SF = 192000; % Sound card sampling rate
PsychToolboxSoundServer('init')
WNSound = (rand(2,SF*S.GUI.CueDuration)*2) - 1;
LeftSound = WNSound; LeftSound(2,:) = 0;
RightSound = WNSound; RightSound(1,:) = 0;
EarlyWithdrawalSound = GenerateSineWave(SF, 16000, .1);
PsychToolboxSoundServer('Load', 1, LeftSound);
PsychToolboxSoundServer('Load', 2, RightSound);
PsychToolboxSoundServer('Load', 3, EarlyWithdrawalSound);

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Main trial loop
for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    %Update sounds from param GUI
    WNSound = (rand(2,SF*S.GUI.CueDuration)*2) - 1;
    LeftSound = WNSound; LeftSound(2,:) = 0;
    RightSound = WNSound; RightSound(1,:) = 0;
    PsychToolboxSoundServer('Load', 1, LeftSound);
    PsychToolboxSoundServer('Load', 2, RightSound);
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1
            LeftPokeAction = 'LeftRewardDelay'; RightPokeAction = 'Punish'; StimulusOutput = {'SoftCode', 1};
        case 2
            LeftPokeAction = 'Punish'; RightPokeAction = 'RightRewardDelay'; StimulusOutput = {'SoftCode', 2};
    end
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port2In', 'Debounce'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Debounce', ...
        'Timer', S.GUI.DebounceTime,...
        'StateChangeConditions', {'Tup', 'CueDelay', 'Port2Out', 'WaitForPoke'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'CueDelay', ...
        'Timer', S.GUI.CueDelay,...
        'StateChangeConditions', {'Port2Out', 'EarlyWithdrawalPunish', 'Tup', 'DeliverStimulus'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', S.GUI.CueDuration,...
        'StateChangeConditions', {'Port2Out', 'WaitForResponse', 'Tup', 'WaitForPortOut'},...
        'OutputActions', StimulusOutput);
    sma = AddState(sma, 'Name', 'WaitForPortOut', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port2Out', 'WaitForResponse'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', S.GUI.ResponseTime,...
        'StateChangeConditions', {'Port1In', LeftPokeAction, 'Port3In', RightPokeAction, 'Tup', 'exit'},...
        'OutputActions', {'SoftCode', 255});
    sma = AddState(sma, 'Name', 'LeftRewardDelay', ...
        'Timer', S.GUI.RewardDelay,...
        'StateChangeConditions', {'Tup', 'LeftReward', 'Port1Out', 'RewardEarlyWithdrawal'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'RightRewardDelay', ...
        'Timer', S.GUI.RewardDelay,...
        'StateChangeConditions', {'Tup', 'RightReward', 'Port3Out', 'RewardEarlyWithdrawal'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', LeftValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 4});
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1Out', 'DrinkingGrace', 'Port3Out', 'DrinkingGrace'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'DrinkingGrace', ...
        'Timer', .5,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1In', 'Drinking', 'Port3In', 'Drinking'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.GUI.PunishDelay,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'EarlyWithdrawalPunish', ...
        'Timer', S.GUI.EWithdrawalDelay,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'SoftCode', 3});
    sma = AddState(sma, 'Name', 'RewardEarlyWithdrawal', ...
        'Timer', 0,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        if S.GUI.AntiBias == 1
            if (~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Punish(1))) || (~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.EarlyWithdrawalPunish(1))) 
              TrialTypes(currentTrial+1) = TrialTypes(currentTrial);
            end
        end
        UpdateSideOutcomePlot(TrialTypes, BpodSystem.Data);
        UpdateTotalRewardDisplay(S.GUI.RewardAmount, currentTrial);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateSideOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.Drinking(1))
        Outcomes(x) = 1;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.RewardEarlyWithdrawal(1))
        Outcomes(x) = 2;
    else
        Outcomes(x) = 3;
    end
end
SideOutcomePlot(BpodSystem.GUIHandles.SideOutcomePlot,'update',Data.nTrials+1,2-TrialTypes,Outcomes);

function UpdateTotalRewardDisplay(RewardAmount, currentTrial)
global BpodSystem
if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Drinking(1))
    TotalRewardDisplay('add', RewardAmount);
end
