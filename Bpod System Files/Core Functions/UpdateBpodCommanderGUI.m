% Update gui reads BpodSystem.HardwareState and updates the commander GUI
% to reflect it.
function UpdateBpodCommanderGUI
global BpodSystem

if ~isempty(BpodSystem.StateMatrix)
    EventNames = BpodSystem.EventNames;
    StateNames = BpodSystem.StateMatrix.StateNames;
    set(BpodSystem.GUIHandles.PreviousStateDisplay, 'String', get(BpodSystem.GUIHandles.CurrentStateDisplay, 'String'));
    set(BpodSystem.GUIHandles.CurrentStateDisplay, 'String', StateNames{BpodSystem.CurrentStateCode});
    if ~isempty(BpodSystem.LastEvent)
        if BpodSystem.LastEvent <= length(EventNames)
            set(BpodSystem.GUIHandles.LastEventDisplay, 'String', EventNames{BpodSystem.LastEvent});
        end
    end
end

TimeElapsed = ceil((now - BpodSystem.Birthdate)*100000);
set(BpodSystem.GUIHandles.TimeDisplay, 'String', TimeElapsed);
% Set GUI valve state indicators
for x = 1:8
    if BpodSystem.HardwareState.Valves(x) ~= BpodSystem.LastHardwareState.Valves(x)
    ButtonHandle = BpodSystem.GUIHandles.PortValveButton(x);
        if BpodSystem.HardwareState.Valves(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
% Set GUI PWM/LED-on indicators
for x = 1:8
    if BpodSystem.HardwareState.PWMLines(x) ~= BpodSystem.LastHardwareState.PWMLines(x)
        ButtonHandle = BpodSystem.GUIHandles.PortLEDButton(x);
        if BpodSystem.HardwareState.PWMLines(x) > 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
% Set virtual event indicators
for x = 1:8
    if BpodSystem.HardwareState.PortSensors(x) ~= BpodSystem.LastHardwareState.PortSensors(x)
        ButtonHandle = BpodSystem.GUIHandles.PortvPokeButton(x);
        if BpodSystem.HardwareState.PortSensors(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
% Set GUI BNC state indicators
for x = 1:2
    if BpodSystem.HardwareState.BNCInputs(x) ~= BpodSystem.LastHardwareState.BNCInputs(x)
        ButtonHandle = BpodSystem.GUIHandles.BNCInputButton(x);
        if BpodSystem.HardwareState.BNCInputs(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
for x = 1:2
    if BpodSystem.HardwareState.BNCOutputs(x) ~= BpodSystem.LastHardwareState.BNCOutputs(x)
        ButtonHandle = BpodSystem.GUIHandles.BNCOutputButton(x);
        if BpodSystem.HardwareState.BNCOutputs(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
% Set GUI Wire state indicators
for x = 1:4
    if BpodSystem.HardwareState.WireInputs(x) ~= BpodSystem.LastHardwareState.WireInputs(x)
        ButtonHandle = BpodSystem.GUIHandles.InputWireButton(x);
        if BpodSystem.HardwareState.WireInputs(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
for x = 1:4
    if BpodSystem.HardwareState.WireOutputs(x) ~= BpodSystem.LastHardwareState.WireOutputs(x)
        ButtonHandle = BpodSystem.GUIHandles.OutputWireButton(x);
        if BpodSystem.HardwareState.WireOutputs(x) == 1
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
        end
    end
end
BpodSystem.LastHardwareState = BpodSystem.HardwareState;
