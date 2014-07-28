% Example state matrix: Writes a command byte to serial devices 1 and 2. 

Command = 3;

sma = NewStateMatrix();

sma = AddState(sma, 'Name', 'SendSerial1', 'Timer', 0, ... 
                    'StateChangeConditions', {'Tup', 'exit'}, ... 
                    'OutputActions', {'Serial1Code', Command, 'Serial2Code', Command});