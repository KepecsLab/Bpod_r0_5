function ManualOverride(TargetCode, ChannelCode)
global BpodSystem

%% Determine which graphics element to update
switch TargetCode
    case 1
        ButtonHandle = BpodSystem.GUIHandles.PortValveButton(ChannelCode);
    case 2
        ButtonHandle = BpodSystem.GUIHandles.PortLEDButton(ChannelCode);
    case 3
        ButtonHandle = BpodSystem.GUIHandles.PortvPokeButton(ChannelCode);
    case 4
        ButtonHandle = BpodSystem.GUIHandles.BNCInputButton(ChannelCode);
    case 5
        ButtonHandle = BpodSystem.GUIHandles.BNCOutputButton(ChannelCode);
    case 6
        ButtonHandle = BpodSystem.GUIHandles.InputWireButton(ChannelCode);
    case 7
        ButtonHandle = BpodSystem.GUIHandles.OutputWireButton(ChannelCode);
    case 8
        ButtonHandle = BpodSystem.GUIHandles.SoftTriggerButton;
end

%% Determine the new state of the system
switch TargetCode
    case 1
        if BpodSystem.HardwareState.Valves(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.Valves(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.Valves(ChannelCode) = 0;
        end
    case 2
        if BpodSystem.HardwareState.PWMLines(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.PWMLines(ChannelCode) = 255;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.PWMLines(ChannelCode) = 0;
        end
    case 3
        if BpodSystem.HardwareState.PortSensors(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.PortSensors(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.PortSensors(ChannelCode) = 0;
        end
    case 4
        if BpodSystem.HardwareState.BNCInputs(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.BNCInputs(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.BNCInputs(ChannelCode) = 0;
        end
    case 5
        if BpodSystem.HardwareState.BNCOutputs(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.BNCOutputs(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.BNCOutputs(ChannelCode) = 0;
        end
    case 6
        if BpodSystem.HardwareState.WireInputs(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.WireInputs(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.WireInputs(ChannelCode) = 0;
        end
    case 7
        if BpodSystem.HardwareState.WireOutputs(ChannelCode) == 0
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OnButton);
            BpodSystem.HardwareState.WireOutputs(ChannelCode) = 1;
        else
            set(ButtonHandle, 'CData', BpodSystem.Graphics.OffButton);
            BpodSystem.HardwareState.WireOutputs(ChannelCode) = 0;
        end
end

%% Determine override message prefix (V for virtual event, O for hardware override, S for soft event)
% Also append output type byte (V for valves, P for PWM, B for BNC, W for Wire

switch TargetCode
    case 1
        Databyte = bin2dec(num2str(BpodSystem.HardwareState.Valves(8:-1:1)));
        OverrideMessage = ['OV' Databyte];
    case 2
        DataString = uint8(BpodSystem.HardwareState.PWMLines);
        OverrideMessage = ['OP' DataString];
    case 3
        OverrideMessage = ['VP' ChannelCode];
    case 4
        OverrideMessage = ['VB' ChannelCode];
    case 5
        Databyte = bin2dec(num2str(BpodSystem.HardwareState.BNCOutputs(2:-1:1)));
        OverrideMessage = ['OB' Databyte];
    case 6
        OverrideMessage = ['VW' ChannelCode];
    case 7
        Databyte = bin2dec(num2str(BpodSystem.HardwareState.WireOutputs(4:-1:1)));
        OverrideMessage = ['OW' Databyte];
end

%% Send message to Bpod

fwrite(BpodSystem.SerialPort, OverrideMessage, 'uint8');


%% If one water valve is open, disable all others
if TargetCode == 1
    Channels = 1:8;
    InactiveChannels = Channels(Channels ~= ChannelCode);
    for x = 1:7
        if BpodSystem.HardwareState.Valves(ChannelCode) == 1
            set(BpodSystem.GUIHandles.PortValveButton(InactiveChannels(x)), 'Enable', 'off');
        else
            set(BpodSystem.GUIHandles.PortValveButton(InactiveChannels(x)), 'Enable', 'on');
        end
    end
end
drawnow;