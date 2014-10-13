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
function Confirmed = SendStateMatrix(sma)
global BpodSystem

nStates = length(sma.StateNames);
%% Check to make sure the Placeholder state was replaced
if strcmp(sma.StateNames{1},'Placeholder')
    error('Error: could not send an empty matrix. You must define at least one state first.')
end

%% Check to make sure the State Matrix doesn't have undefined states
if sum(sma.StatesDefined == 0) > 0
    disp('Error: The state matrix contains references to the following undefined states: ');
    UndefinedStates = find(sma.StatesDefined == 0);
    nUndefinedStates = length(UndefinedStates);
    for x = 1:nUndefinedStates
        disp(sma.StateNames{UndefinedStates(x)});
    end
    error('Please define these states using the AddState function before sending.')
end

%% Check to make sure the state matrix does not exceed 128 states
if nStates > 128
    error('Error: the state matrix can have a maximum of 128 states.');
end

%% Add exit state codes to transition matrices
sma.InputMatrix(isnan(sma.InputMatrix)) = nStates+1;
sma.GlobalTimerMatrix(isnan(sma.GlobalTimerMatrix)) = nStates+1;
sma.GlobalCounterMatrix(isnan(sma.GlobalCounterMatrix)) = nStates+1;

%% Format input, output and wave matrices into linear byte vectors for transfer
if nStates > 1 % More elegant solution needed here - prevents 1:end from returning a column vector for one state (returns row for matrix)
    RotMatrix = (sma.InputMatrix-1)'; % Subtract 1 from all states to convert to c++ (base 0) 
else
    RotMatrix = (sma.InputMatrix-1);
end
InputMatrix = uint8(RotMatrix(1:end));
if nStates > 1
    RotMatrix = sma.OutputMatrix';
else
    RotMatrix = sma.OutputMatrix;
end
OutputMatrix = uint8(RotMatrix(1:end));
if nStates > 1
    RotMatrix = (sma.GlobalTimerMatrix-1)';
else
    RotMatrix = (sma.GlobalTimerMatrix-1);
end
GlobalTimerMatrix = uint8(RotMatrix(1:end));
if nStates > 1
    RotMatrix = (sma.GlobalCounterMatrix-1)';
else
    RotMatrix = (sma.GlobalCounterMatrix-1);
end
GlobalCounterMatrix = uint8(RotMatrix(1:end));
GlobalCounterAttachedEvents = uint8(sma.GlobalCounterEvents);
GlobalCounterThresholds = uint32(sma.GlobalCounterThresholds);

%% Format timers (doubles in seconds) into 32 bit int vectors in milliseconds
StateTimers = uint32(sma.StateTimers*1000000);
GlobalTimers = uint32(sma.GlobalTimers*1000000);

%% Add input channel configuration
InputChannelConfig = [BpodSystem.InputsEnabled.PortsEnabled BpodSystem.InputsEnabled.WiresEnabled];

%% Create vectors of 8-bit and 32-bit data
EightBitMatrix = ['P' nStates InputMatrix OutputMatrix GlobalTimerMatrix GlobalCounterMatrix GlobalCounterAttachedEvents InputChannelConfig];
ThirtyTwoBitMatrix = [StateTimers GlobalTimers GlobalCounterThresholds];

%% Send state matrix to Bpod device
ByteString = [EightBitMatrix typecast(ThirtyTwoBitMatrix, 'uint8')];
BpodSerialWrite(ByteString, 'uint8');

%% Recieve Acknowledgement
Confirmed = BpodSerialRead(1, 'uint8'); % Confirm that it has been received
if isempty(Confirmed)
    Confirmed = 0;
end
%% Update State Machine Object
BpodSystem.StateMatrix = sma;
set(BpodSystem.GUIHandles.CxnDisplay, 'String', 'Idle');