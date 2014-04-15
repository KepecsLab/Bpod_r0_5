function InitializeHardware

clc
global BpodSystem
BaudRate = 115200;
if ~isempty(BpodSystem.SerialPort)
    fclose(BpodSystem.SerialPort);
    delete(BpodSystem.SerialPort);
    BpodSystem.SerialPort = [];
end

loadBpodPath

if ispc
    Ports = FindArduinoPorts;
else
    % Mac
end
if isempty(Ports)
    try
        fclose(instrfind)
    catch
        error('Error: Bpod not found.');
    end
    clear instrfind
end

% Make it search on the last successful port first
ComPortPath = fullfile(BpodPath,'Bpod System Files','LastComPortUsed.mat');
if exist(ComPortPath) == 2
    load(ComPortPath);
     pos = strmatch(LastComPortUsed, Ports, 'exact'); 
    if ~isempty(pos)
        Temp = Ports;
        Ports{1} = LastComPortUsed;
        Ports(2:length(Temp)) = Temp(find(1:length(Temp) ~= pos));
    end
end

Found = 0;
x = 0;
while (Found == 0) && (x < length(Ports)) && ~isempty(Ports{1})
    x = x + 1;
    disp(['Trying port ' Ports{x}])
    TestSer = serial(Ports{x}, 'BaudRate', BaudRate, 'Timeout', 1, 'DataTerminalReady', 'on');
    fopen(TestSer);
    set(TestSer, 'RequestToSend', 'on')
    if ~strcmp(system_dependent('getos'), 'Microsoft Windows Vista')  
      pause(1);
    end
    fprintf(TestSer, char(54));
    tic
    g = 0;
    try
        g = fread(TestSer, 1);
    catch
        % ok
    end
    if g == '5'
        Found = x;
        fclose(TestSer);
        delete(TestSer)
        clear TestSer
        clc
    end
end
pause(.1);
if Found ~= 0
BpodSystem.SerialPort = serial(Ports{Found}, 'BaudRate', BaudRate, 'Timeout', 1, 'DataTerminalReady', 'on');
else
    error('Could not find a Bpod device.');
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
clc
disp(['Bpod connected on port ' Ports{Found}])
LastComPortUsed = Ports{Found};
save(ComPortPath, 'LastComPortUsed');
if BpodSystem.SerialPort.BytesAvailable > 0
    trash = fread(BpodSystem.SerialPort, BpodSystem.SerialPort.BytesAvailable);
end
fwrite(BpodSystem.SerialPort,char('F'));
BpodSystem.FirmwareBuild = fread(BpodSystem.SerialPort, 1);