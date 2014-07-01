function [RawTrialEvents] = RunStateMatrix()
global BpodSystem
if isempty(BpodSystem.StateMatrix)
    error('Error: A state matrix must be sent prior to calling "RunStateMatrix".')
end
RawTrialEvents = struct;
if BpodSerialBytesAvailable > 0
        trash = fread(BpodSystem.SerialPort.BytesAvailable);
end
BpodSerialWrite('R', 'uint8'); % Send the code to run the loaded matrix (character "R" for Run)
BpodSystem.CurrentStateCode = 2;
EventNames = BpodSystem.EventNames;
MatrixFinished = 0;
MaxEvents = 1000;
nEvents = 0; nStates = 1;
Events = zeros(1,MaxEvents); States = zeros(1,MaxEvents);
CurrentEvent = zeros(1,10);
StateChangeIndexes = zeros(1,MaxEvents);
States(nStates) = 1;
BpodSystem.CurrentStateCode = 1;
InputMatrix = BpodSystem.StateMatrix.InputMatrix;
GlobalTimerMatrix = BpodSystem.StateMatrix.GlobalTimerMatrix;
GlobalCounterMatrix = BpodSystem.StateMatrix.GlobalCounterMatrix;
StateNames = BpodSystem.StateMatrix.StateNames;
nTotalStates = length(StateNames);
UpdateBpodCommanderGUI; % Reads BpodSystem.HardwareState and BpodSystem.LastEvent to commander GUI.
set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.PauseButton);
BpodSystem.BeingUsed = 1; BpodSystem.InStateMatrix = 1;
while MatrixFinished == 0
    drawnow;
    if BpodSerialBytesAvailable > 0
        opCodeBytes = BpodSerialRead(2, 'uint8');
        opCode = opCodeBytes(1);
        switch opCode
            case 1 % Receive and handle events
                nCurrentEvents = opCodeBytes(2);
                TempCurrentEvents = BpodSerialRead(nCurrentEvents, 'uint8');
                CurrentEvent(1:nCurrentEvents) = TempCurrentEvents(1:nCurrentEvents) + 1; % Read and convert from c++ index at 0 to MATLAB index at 1
                DominantEvent = CurrentEvent(1); % Of all events captured in a cycle, only the first event may trigger a state transition.
                if DominantEvent == 256
                    MatrixFinished = 1;
                    break
                elseif DominantEvent < 41
                    NewState = InputMatrix(BpodSystem.CurrentStateCode, DominantEvent);
                elseif DominantEvent < 46
                    NewState = GlobalTimerMatrix(BpodSystem.CurrentStateCode, DominantEvent-39);
                else
                    NewState = GlobalCounterMatrix(BpodSystem.CurrentStateCode, DominantEvent-44);
                end
                
                if NewState ~= BpodSystem.CurrentStateCode
                    if  NewState <= nTotalStates
                        StateChangeIndexes(nStates) = nEvents+1;
                        nStates = nStates + 1;
                        States(nStates) = NewState;
                        BpodSystem.CurrentStateCode = NewState;
                        BpodSystem.CurrentStateName = StateNames{NewState};
                        SetBpodHardwareMirror2CurrentState(NewState);
                        UpdateBpodCommanderGUI;
                    end
                end
                BpodSystem.LastEvent = EventNames{DominantEvent};
                Events(nEvents+1:(nEvents+nCurrentEvents)) = CurrentEvent(1:nCurrentEvents);
                CurrentEvent(1:nCurrentEvents) = 0;
                set(BpodSystem.GUIHandles.LastEventDisplay, 'string', BpodSystem.LastEvent);
                nEvents = nEvents + nCurrentEvents;
                drawnow;
            case 2 % Soft-code
                SoundID = opCodeBytes(2);
                if SoundID ~= 255
                    PsychToolboxSoundServer('Play', SoundID);
                else
                    PsychToolboxSoundServer('StopAll');
                end
        end
    else
        if BpodSystem.BeingUsed == 0
            MatrixFinished = 1;
        end
    end
end

if BpodSystem.BeingUsed == 1
    Events = Events(1:nEvents);
    States = States(1:nStates);
    % Accept Timestamps
    TrialStartTimestamp =  BpodSerialRead(1, 'uint32')/1000; % Start-time of the trial in milliseconds (immune to 32-bit clock rollover)
    TrialStartMicroseconds = BpodSerialRead(1, 'uint32'); % Time the trial started (in microseconds)
    TrialStartMilliseconds = TrialStartMicroseconds/1000;
    nTimeStamps = BpodSerialRead(1, 'uint16');
    TimeStamps = zeros(1,nTimeStamps);
    for x = 1:nTimeStamps
        TimeStamps(x) = BpodSerialRead(1, 'uint32');
    end
    if TimeStamps(end) < TrialStartMicroseconds
        % The 32-bit microsecond clock rolled over. Add 4294967295 to timestamps that occur after the roll-over.
        PostRollOverIndexes = (TimeStamps < TrialStartMicroseconds);
        TimeStamps(PostRollOverIndexes) = TimeStamps(PostRollOverIndexes) + 4294967295;
    end
    TimeStamps = TimeStamps/1000;
    StateChangeIndexes = StateChangeIndexes(1:nStates-1);
    EventTimeStamps = TimeStamps;
    StateTimeStamps = zeros(1,nStates);
    StateTimeStamps(2:nStates) = TimeStamps(StateChangeIndexes); % Figure out StateChangeIndexes has a "change" event for sma start (longer than nEvents)
    StateTimeStamps(1) = TrialStartMilliseconds;
    RawTrialEvents.States = States;
    RawTrialEvents.Events = Events;
    RawTrialEvents.StateTimestamps = Round2Millis(StateTimeStamps-TrialStartMilliseconds)/1000; % Convert to seconds
    RawTrialEvents.EventTimestamps = Round2Millis(EventTimeStamps-TrialStartMilliseconds)/1000;
    RawTrialEvents.TrialStartTimestamp = Round2Millis(TrialStartTimestamp);
    RawTrialEvents.StateTimestamps(end+1) = RawTrialEvents.EventTimestamps(end);
end
SetBpodHardwareMirror2CurrentState(0);
UpdateBpodCommanderGUI;
BpodSystem.InStateMatrix = 0;

function MilliOutput = Round2Millis(DecimalInput)
    MilliOutput = round(DecimalInput*(10^3))/(10^3);

function SetBpodHardwareMirror2CurrentState(CurrentState)
global BpodSystem
if CurrentState > 0
    ValveState = BpodSystem.StateMatrix.OutputMatrix(CurrentState, 1);
    for x = 1:8
        ThisValveState = bitget(ValveState,x);
        BpodSystem.HardwareState.Valves(x) = ThisValveState;
        if ThisValveState == 0
            set(BpodSystem.GUIHandles.PortValveButton(x), 'CData', BpodSystem.Graphics.OffButton);
        else
            set(BpodSystem.GUIHandles.PortValveButton(x), 'CData', BpodSystem.Graphics.OnButton);
        end
    end
    BNCState = BpodSystem.StateMatrix.OutputMatrix(CurrentState, 2);
    for x = 1:2
        BpodSystem.HardwareState.BNCOutputs(x) = bitget(BNCState,x);
    end
    WireState = BpodSystem.StateMatrix.OutputMatrix(CurrentState, 3);
    for x = 1:4
        BpodSystem.HardwareState.WireOutputs(x) = bitget(WireState,x);
    end
else
    BpodSystem.HardwareState.Valves = zeros(1,8);
    BpodSystem.HardwareState.PortSensors = zeros(1,8);
    BpodSystem.HardwareState.BNCOutputs = zeros(1,2);
    BpodSystem.HardwareState.WireOutputs = zeros(1,4);
end