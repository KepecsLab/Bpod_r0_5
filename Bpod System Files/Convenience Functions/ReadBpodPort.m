function LogicValue = ReadBpodPort(PortNumber)
try
BpodSystem.SerialPort = evalin('base', 'BpodSystem.SerialPort');
catch
    error('Bpod not connected')
end
fwrite(BpodSystem.SerialPort, [char('A') char(35+PortNumber)])
LogicValue = fread(BpodSystem.SerialPort, 1);