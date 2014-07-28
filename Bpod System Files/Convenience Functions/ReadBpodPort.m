function LogicValue = ReadBpodPort(PortNumber)
try
BpodSystem.SerialPort = evalin('base', 'BpodSystem.SerialPort');
catch
    error('Bpod not connected')
end
BpodSerialWrite([char('A') char(35+PortNumber)], 'uint8');
LogicValue = fread(BpodSystem.SerialPort, 1);