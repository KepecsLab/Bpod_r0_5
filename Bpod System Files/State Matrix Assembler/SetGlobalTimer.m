function sma = SetGlobalTimer(sma, TimerNumber, Duration)

% JS October 2013
% Example usage:
% sma = SetGlobalTimer(sma, 1, 0.025); % sets timer 1 for 25ms

if ischar(Duration)
    error('Global timer durations must be numbers, in seconds')
end
if Duration < 0
    error('When setting global timers, time (in seconds) must be positive.')
end
if Duration > 3600
    error('Global timers can not exceed 1 hour');
end
nTimers = length(sma.GlobalTimers);
if TimerNumber > nTimers
    error(['Only ' num2str(nTimers) ' global timers are available in the current revision.']);
end
sma.GlobalTimers(TimerNumber) = Duration;
sma.GlobalTimersSet(TimerNumber) = 1;