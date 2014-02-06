function InputStatus = ReadBpodInput(Target, Channel)
% Target = 'BNC', 'Wire', 'Port'
global BpodSystem
Message = 'I';
switch Target
    case 'BNC'
        Message = [Message 'B'];
    case 'Wire'
        Message = [Message 'W'];
    case 'Port'
        Message = [Message 'P'];
    otherwise
        error('Target must be equal to ''BNC'', ''Wire'', or ''Port''');
end
Message = [Message Channel];
fwrite(BpodSystem.SerialPort, Message);
InputStatus = fread(BpodSystem.SerialPort, 1);