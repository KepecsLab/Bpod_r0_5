global BpodSystem
if BpodSerialBytesAvailable > 0
    BpodSerialRead(BpodSerialBytesAvailable, 'uint8')
end
try
    close(BpodSystem.GUIHandles.LiveDispFig)
catch
end
if BpodSystem.BeingUsed == 0
    BpodSerialWrite('Z', 'uint8');
    pause(.1);
    delete(BpodSystem.GUIHandles.MainFig);
    switch BpodSystem.UsesPsychToolbox
    case 0
        fclose(BpodSystem.SerialPort);
        delete(BpodSystem.SerialPort);
    case 1
        IOPort('Close', BpodSystem.SerialPort);
    end
    BpodSystem.SerialPort = [];
    if isfield(BpodSystem.PluginSerialPorts, 'TeensySoundServer')
        TeensySoundServer('end');
    end
    disp('Bpod successfully disconnected.')
else
    msgbox('There is a running protocol. Please stop it first.')
    BpodErrorSound;
end
clear BpodSystem