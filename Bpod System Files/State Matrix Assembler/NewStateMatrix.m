function sma = NewStateMatrix


% This function returns the final state (always = state 1). All subsequent calls to "AddState" will
% append to this.

sma.StateNames = {'Placeholder'};
sma.InputMatrix = ones(1,40);
sma.OutputMatrix = zeros(1,17);
sma.GlobalTimerMatrix = ones(1,5);
sma.GlobalTimers = zeros(1,5);
sma.GlobalTimerSet = zeros(1,5); % Changed to 1 when the timer is given a duration with SetGlobalTimer
sma.GlobalCounterMatrix = ones(1,5);
sma.GlobalCounterEvents = ones(1,5)*254; % Default event of 254 is code for "no event attached".
sma.GlobalCounterThresholds = zeros(1,5);
sma.GlobalCounterSet = zeros(1,5); % Changed to 1 when the counter event is identified and given a threshold with SetGlobalCounter
sma.StateTimers = 0;
sma.StatesDefined = 1; % Referenced states are set to 0. Defined states are set to 1. Both occur with AddState
