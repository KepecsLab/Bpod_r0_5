function RunProtocol
global BpodSystem
SMStatus = BpodSystem.BeingUsed;
if SMStatus == 0
    clear PB
    ProtocolNames = get(BpodSystem.GUIHandles.ProtocolSelector, 'String');
    SelectedProtocol = get(BpodSystem.GUIHandles.ProtocolSelector, 'Value');
    SelectedProtocolName = ProtocolNames{SelectedProtocol};
    set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.PauseButton);
    BpodSystem.BeingUsed = 1;
    BpodSystem.CurrentProtocolName = SelectedProtocolName;
    LaunchManager;
else
    disp(' ')
    disp([BpodSystem.CurrentProtocolName ' ended. All data saved.'])
    BpodSystem.BeingUsed = 0;
    BpodSystem.CurrentProtocolName = '';
    BpodSystem.SettingsPath = '';
    BpodSystem.Live = 0;
    fwrite(BpodSystem.SerialPort, 'X');
    pause(.1);
    if BpodSystem.SerialPort.BytesAvailable > 0
        fread(BpodSystem.SerialPort,BpodSystem.SerialPort.BytesAvailable);
    end
    set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.GoButton);
end