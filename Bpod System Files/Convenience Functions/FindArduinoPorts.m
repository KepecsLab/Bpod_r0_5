function ArduinoPorts = FindArduinoPorts
[Status RawString] = system('wmic path Win32_SerialPort Where "Caption LIKE ''%Arduino%''" Get DeviceID'); % Search for Arduino on USB Serial
PortLocations = strfind(RawString, 'COM');
ArduinoPorts = cell(1,100);
nPorts = length(PortLocations);
for x = 1:nPorts
    Clip = RawString(PortLocations(x):PortLocations(x)+6);
    ArduinoPorts{x} = Clip(1:find(Clip == 32,1, 'first')-1);
end
ArduinoPorts = ArduinoPorts(1:nPorts);