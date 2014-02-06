global BpodSystem
if BpodSystem.SerialPort.BytesAvailable > 0
    fread(BpodSystem.SerialPort, BpodSystem.SerialPort.BytesAvailable);
end
try
    close(BpodSystem.GUIHandles.LiveDispFig)
catch
end
if BpodSystem.BeingUsed == 0
    fwrite(BpodSystem.SerialPort, char('Z'));
    delete(BpodSystem.GUIHandles.MainFig);
    fclose(BpodSystem.SerialPort);
    delete(BpodSystem.SerialPort);
    BpodSystem.SerialPort = [];
    disp('Bpod successfully disconnected.')
else
    msgbox('There is a running protocol. Please stop it first.')
    BpodErrorSound;
end
clear BpodSystem