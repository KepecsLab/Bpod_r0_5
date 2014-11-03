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
function Olfactory2AFC
% This protocol demonstrates control of the Island Motion olfactometer by using the hardware serial port to control an Arduino Leonardo Ethernet client. 
% Written by Josh Sanders, 10/2014.
%
% SETUP
% You will need:
% - An Island Motion olfactometer: http://island-motion.com/5.html
% - Arduino Leonardo double-stacked with the Arduino Ethernet shield and the Bpod shield
% - This computer connected to the olfactometer's Ethernet router
% - The Ethernet shield connected to the same router
% - Arduino Leonardo connected to this computer (note its COM port)
% - Arduino Leonardo programmed with the Serial Ethernet firmware (in /Bpod Firmware/SerialEthernetModule/)

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5;
    S.GUI.StimulusDelayDuration = 0;
    S.GUI.MaxOdorDuration = 1;
    S.GUI.TimeForResponse = 5;
    S.GUI.TimeoutDuration = 2;
end

% Initialize parameter GUI plugin
BpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ceil(rand(1,MaxTrials)*2);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [200 200 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',2-TrialTypes);
BpodNotebook('init');

%% Initialize Ethernet client on hardware serial port 1 and connect to olfactometer
SerialEthernet('Init', 'COM65'); % Set this to the correct COM port for Arduino Leonardo
pause(1);
OlfIP = [192 168 0 104];
SerialEthernet('Connect', OlfIP, 3336);
SerialEthernet('MessageMode', 1); % Force a connection release/renew after each string sent from the Ethernet module (necessary to prevent crashes for the Rechia olfactometer)

%% Define odors, program Ethernet server with commands for switching olfactometer valves
LeftOdor = [90 10]; % Flow rate on Banks 1 and 2 in ml/min
RightOdor = [10 90];
ValveOpenCommand = Valves2EthernetString('Bank1', 1, 'Bank2', 1); % From RechiaOlfactometer plugin. Simultaneously sets banks 1 and 2 to valve 1
ValveCloseCommand = Valves2EthernetString('Bank1', 0, 'Bank2', 0); % Simultaneously sets banks 1 and 2 to valve 0 (exhaust)
SerialEthernet('LoadString', 1, ValveOpenCommand); % Sets the "open" command as string 1
SerialEthernet('LoadString', 2, ValveCloseCommand); % Sets the "close" command as string 2

%% Main trial loop
for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    if TrialTypes(currentTrial) == 1
        SetBankFlowRate(OlfIP, 1, LeftOdor(1)); % Set bank 1 to 100ml/min (requires Bpod computer on same ethernet network as olfactometer)
        SetBankFlowRate(OlfIP, 2, LeftOdor(2)); % Set bank 2 to 0ml/min
    else
        SetBankFlowRate(OlfIP, 1, RightOdor(1)); % Set bank 1 to 100ml/min
        SetBankFlowRate(OlfIP, 2, RightOdor(2)); % Set bank 2 to 0ml/min
    end
    R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1
            LeftActionState = 'Reward'; RightActionState = 'Punish';
            ValveCode = 1; ValveTime = LeftValveTime;
        case 2
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
        'Timer', S.GUI.MaxOdorDuration,...
        'StateChangeConditions', {'Tup', 'WaitForResponse', 'Port2Out', 'WaitForResponse'},...
        'OutputActions', {'Serial1Code', 1}); 
    sma = AddState(sma, 'Name', 'WaitForResponse', ...
        'Timer', S.GUI.TimeForResponse,...
        'StateChangeConditions', {'Tup', 'exit', 'Port1In', LeftActionState, 'Port3In', RightActionState},...
        'OutputActions', {'Serial1Code', 2, 'PWM1', 255, 'PWM3', 255});
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'ValveState', ValveCode});
    sma = AddState(sma, 'Name', 'Punish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'EarlyWithdrawalPunish', ...
        'Timer', S.GUI.TimeoutDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
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
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    else
        Outcomes(x) = 3;
    end
end
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',Data.nTrials+1,2-TrialTypes,Outcomes)
