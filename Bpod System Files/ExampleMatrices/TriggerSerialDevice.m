% Example state matrix: Writes a command byte to serial devices 1 and 2, while pulsing Wire 1 for 1ms. 

sma = NewStateMatrix();


sma = AddState(sma, 'Name', 'SendSerial1', 'Timer', 0, 'StateChangeConditions', {'Tup', 'SendSerial2'}, 'OutputActions', {'Serial1Code', 65, 'WireState', 1});
sma = AddState(sma, 'Name', 'SendSerial2', 'Timer', 0, 'StateChangeConditions', {'Tup', 'Delay'}, 'OutputActions', {'Serial2Code', 65});
sma = AddState(sma, 'Name', 'Delay', 'Timer', .001, 'StateChangeConditions', {'Tup', 'final_state'}, 'OutputActions', {});