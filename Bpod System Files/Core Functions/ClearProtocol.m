global BpodSystem

SMStatus = BpodSystem.BeingUsed;
if SMStatus == 1
    set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.GoButton);
    BpodSystem.BeingUsed = 0;
    BpodSystem.CurrentProtocolName = '';
    BpodSystem.SettingsPath = '';
    BpodSystem.Live = 0;
    fwrite(BpodSystem.SerialPort, 'X');
    pause(.1);
    if BpodSystem.SerialPort.BytesAvailable > 0
        fread(BpodSystem.SerialPort,BpodSystem.SerialPort.BytesAvailable);
    end
    % Close Live Display, gracefully
    if isfield(BpodSystem.GUIHandles,'LiveDispFig')
        set(BpodSystem.GUIHandles.LiveDispFig, 'CloseRequestFcn', 'closereq');
        close(BpodSystem.GUIHandles.LiveDispFig);
        BpodSystem.GUIHandles.LiveDispFig = [];
    end
end