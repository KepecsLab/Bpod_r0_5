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
function InitializeHardware (varargin)

global BpodSystem
BaudRate = 115200;
if ~isempty(BpodSystem.SerialPort)
    switch BpodSystem.UsesPsychToolbox
        case 0
            fclose(BpodSystem.SerialPort);
            delete(BpodSystem.SerialPort);
        case 1
    end
    BpodSystem.SerialPort = [];
end

loadBpodPath

if ~ispc && ~ismac
    % Ensure access to serial ports under ubuntu
    if exist(['/usr/local/MATLAB/R' version('-release') '/bin/glnxa64/java.opts']) ~= 2
        disp(' ');
        disp('**ALERT**')
        disp('Linux64 detected. A file must be copied to the MATLAB root, to gain access to virtual serial ports.')
        disp('This file only needs to be copied once.')
        input('Bpod will try to copy this file from the repository automatically. Press return... ')
        try
            system(['sudo cp ''' BpodPath 'Bpod System Files/Internal Functions/java.opts'' /usr/local/MATLAB/R' version('-release') '/bin/glnxa64']);
            disp(' ');
            disp('**SUCCESS**')
            disp('File copied! Please restart MATLAB and run Bpod again.')
            return
        catch
            disp('File copy error! MATLAB may not have administrative privileges.')
            disp('Please copy /PulsePal/MATLAB/java.opts to the MATLAB java library path.')
            disp('The path is typically /usr/local/MATLAB/R2014a/bin/glnxa64, where r2014a is your MATLAB release.')
            return
        end
    end
end

if nargin > 0
    Ports = cell(1,1);
    Ports{1} = varargin{1};
else
    
    Ports = FindArduinoPorts;
    
    if isempty(Ports)
        %error('Error: Bpod not found.');
    end
    
    % Make it search on the last successful port first
    if isfield(BpodSystem.SystemSettings, 'LastCOMPort')
        LastCOMPort = BpodSystem.SystemSettings.LastCOMPort;
        pos = strmatch(LastCOMPort, Ports, 'exact');
        if ~isempty(pos)
            Temp = Ports;
            Ports{1} = LastCOMPort;
            Ports(2:length(Temp)) = Temp(find(1:length(Temp) ~= pos));
        end
    end
end
Found = 0;
x = 0;
switch BpodSystem.UsesPsychToolbox
    case 0 % Java serial interface (MATLAB default)
        disp('Connecting with MATLAB/Java serial interface (high latency).')
        while (Found == 0) && (x < length(Ports)) && ~isempty(Ports{1})
            x = x + 1;
            disp(['Trying port ' Ports{x}])
            TestPort = serial(Ports{x}, 'BaudRate', BaudRate, 'Timeout', 1, 'DataTerminalReady', 'on');
            fopen(TestPort);
            set(TestPort, 'RequestToSend', 'on')
            if ~strcmp(system_dependent('getos'), 'Microsoft Windows Vista')
                pause(1);
            end
            fprintf(TestPort, char(54));
            tic
            g = 0;
            try
                g = fread(TestPort, 1);
            catch
                % ok
            end
            if g == '5'
                Found = x;
                fclose(TestPort);
                delete(TestPort)
                clear TestSer
                clc
            end
        end
        pause(.1);
        if Found ~= 0
            BpodSystem.SerialPort = serial(Ports{Found}, 'BaudRate', BaudRate, 'Timeout', 1, 'DataTerminalReady', 'on');
        else
            %error('Could not find a Bpod device.');
        end
        set(BpodSystem.SerialPort, 'OutputBufferSize', 8000);
        set(BpodSystem.SerialPort, 'InputBufferSize', 8000);
        fopen(BpodSystem.SerialPort);
        set(BpodSystem.SerialPort, 'RequestToSend', 'on');
        fwrite(BpodSystem.SerialPort, char(54));
        tic
        while BpodSystem.SerialPort.BytesAvailable == 0
            if toc > 1
                break
            end
        end
        fread(BpodSystem.SerialPort, BpodSystem.SerialPort.BytesAvailable);
        set(BpodSystem.SerialPort, 'RequestToSend', 'off')
    case 1 % Psych toolbox serial interface
        disp('Connecting with PsychToolbox serial interface (low latency).')
        oldlevel = IOPort('Verbosity', 0);
         while (Found == 0) && (x < length(Ports)) && ~isempty(Ports{1})
            x = x + 1;
            disp(['Trying port ' Ports{x}])
            try
                if ispc
                    PortString = ['\\.\' Ports{x}];
                else
                    PortString = Ports{x};
                end
                TestPort = IOPort('OpenSerialPort', PortString, 'BaudRate=115200, OutputBufferSize=8000, DTR=1');
                pause(.1);
                IOPort('Write', TestPort, char(54), 1);
                pause(.1);
                Byte = IOPort('Read', TestPort, 1, 1);
                if Byte == 53
                    Found = x;
                end
                IOPort('Close', TestPort);
                
            catch
            end
         end
         if Found ~= 0
             if ispc
                 PortString = ['\\.\' Ports{Found}];
             else
                 PortString = Ports{Found};
             end
             BpodSystem.SerialPort = IOPort('OpenSerialPort', PortString, 'BaudRate=115200, OutputBufferSize=8000, DTR=1');
         else
             error('No valid Bpod serial port detected.')
         end
         BpodSerialWrite(char(54), 'uint8');
         tic
         while BpodSerialBytesAvailable == 0
             if toc > 1
                 break
             end
         end
         BpodSerialRead(BpodSerialBytesAvailable, 'uint8');
end


disp(['Bpod connected on port ' Ports{Found}])
BpodSystem.SystemSettings.LastCOMPort = Ports{Found};
SaveBpodSystemSettings;
if BpodSerialBytesAvailable > 0
    BpodSerialRead(BpodSerialBytesAvailable, 'uint8');
end
BpodSerialWrite('F', 'uint8');
BpodSystem.EmulatorMode = 0;
BpodSystem.FirmwareBuild = BpodSerialRead(1, 'uint8');