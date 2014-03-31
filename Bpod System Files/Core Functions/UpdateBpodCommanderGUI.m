% Update gui reads BpodSystem.HardwareState and updates the commander GUI
% to reflect it.
function UpdateBpodCommanderGUI
global BpodSystem
EventNames = BpodSystem.EventNames;
StateNames = BpodSystem.StateMatrix.StateNames;
set(BpodSystem.GUIHandles.PreviousStateDisplay, 'String', get(BpodSystem.GUIHandles.CurrentStateDisplay, 'String'));
set(BpodSystem.GUIHandles.CurrentStateDisplay, 'String', StateNames{BpodSystem.CurrentStateCode});
if BpodSystem.LastEvent <= length(EventNames)
    set(BpodSystem.GUIHandles.LastEventDisplay, 'String', EventNames{BpodSystem.LastEvent});
end
TimeElapsed = ceil((now - BpodSystem.Birthdate)*100000);
set(BpodSystem.GUIHandles.TimeDisplay, 'String', num2str(TimeElapsed));
% Set GUI valve state indicators
for x = 1:8
    ButtonHandle = BpodSystem.GUIHandles.PortValveButton(x);
    if BpodSystem.HardwareState.Valves(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
% Set GUI PWM/LED-on indicators
for x = 1:8
    ButtonHandle = BpodSystem.GUIHandles.PortLEDButton(x);
    if BpodSystem.HardwareState.PWMLines(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
% Set GUI BNC state indicators
for x = 1:2
    ButtonHandle = BpodSystem.GUIHandles.BNCInputButton(x);
    if BpodSystem.HardwareState.BNCInputs(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
for x = 1:2
    ButtonHandle = BpodSystem.GUIHandles.BNCOutputButton(x);
    if BpodSystem.HardwareState.BNCOutputs(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
% Set GUI Wire state indicators
for x = 1:4
    ButtonHandle = BpodSystem.GUIHandles.InputWireButton(x);
    if BpodSystem.HardwareState.WireInputs(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
for x = 1:4
    ButtonHandle = BpodSystem.GUIHandles.OutputWireButton(x);
    if BpodSystem.HardwareState.WireOutputs(x) == 1
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
    else
        set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
    end
end
drawnow;