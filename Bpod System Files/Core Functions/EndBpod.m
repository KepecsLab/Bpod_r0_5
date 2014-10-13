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