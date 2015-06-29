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
function SoundSamp
% This protocol introduces a mouse that has completed the Operant protocol to the center port.
% Written by Josh Sanders, 5/2015.
%
% SETUP
% You will need:
% - A Bpod MouseBox (or equivalent) configured with 3 ports.


global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5; %ul
    S.GUI.MinCenterPoke = 0; % How long the mouse must poke in the center to activate the side ports
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 1000;
nDirectDeliveryTrials = 30;
nPreSoundTrials = 20;
TrialTypes = [ones(1,nDirectDeliveryTrials) ones(1,nPreSoundTrials)*2 ones(1,50)*3 ones(1,50)*4 ones(1,50)*5 ones(1,50)*6 ones(1,50)*7 ones(1,1000)*8];
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [200 200 1000 300],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',TrialTypes);
BpodNotebook('init');
% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%Generate white noise
SF = 192000; % Sound card sampling rate
WNSound = (rand(1,SF*.5)*2) - 1;
PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load', 1, WNSound);
%% Main trial loop
for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1
            PostSamplingState = 'LeftReward'; PostRewardState = 'RightReward'; ResponseOutputAction = {}; S.GUI.MinCenterPoke = 0;
        case 2
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {}; S.GUI.MinCenterPoke = 0;
        case 3
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0;
        case 4
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0.1;
        case 5
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0.2;
        case 6
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0.3;
        case 7
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0.3;
        case 8
            PostSamplingState = 'WaitForResponse'; PostRewardState = 'Drinking'; ResponseOutputAction = {'SoftCode', 1}; S.GUI.MinCenterPoke = 0.3;
    end
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port2In', 'WaitMinPokeTime'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'WaitMinPokeTime', ...
        'Timer', S.GUI.MinCenterPoke,...
        'StateChangeConditions', {'Port2Out', 'WaitForPoke', 'Tup', PostSamplingState},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'LeftReward', 'Port3In', 'RightReward'},...
        'OutputActions', ResponseOutputAction);
    sma = AddState(sma, 'Name', 'LeftReward', ...
        'Timer', LeftValveTime,...
        'StateChangeConditions', {'Tup', PostRewardState},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'RightReward', ...
        'Timer', RightValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 4});
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', .5,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1Out', 'ConfirmPortOut', 'Port3Out', 'ConfirmPortOut'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'ConfirmPortOut', ...
        'Timer', .1,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1In', 'Drinking', 'Port3In', 'Drinking'},...
        'OutputActions', {});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        UpdateOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.Drinking(1))
        Outcomes(x) = 1;
    else
        Outcomes(x) = 3;
    end
end
TrialTypeOutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
