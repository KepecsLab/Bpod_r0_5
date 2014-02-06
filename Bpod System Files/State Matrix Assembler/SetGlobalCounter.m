function sma = SetGlobalCounter(sma, CounterNumber, TargetEvent, Threshold)

% JS October 2013
% Example usage:
% sma = SetGlobalCounter(sma, 1, 'Port1in', 5); % sets counter 1 to trigger
% a threshold crossing event after 5 pokes in port 1, irrespective of state.

global BpodSystem
if ischar(Threshold)
    error('Global counter thresholds must be numbers')
end
if Threshold < 0
    error('Global counter thresholds must be positive.')
end
if rem(Threshold,1) > 0
    error('Global counter thresholds must be whole numbers.')
end
nCounters = length(sma.GlobalCounterThresholds);
if CounterNumber > nCounters
    error(['Only ' num2str(nCounters) ' global counters are available in the current Bpod version.']);
end
TargetEventCode = find(strcmp(TargetEvent, BpodSystem.EventNames));
if isempty(TargetEventCode)
    error(['Error setting global counter. Target event ''' TargetEvent ''' is invalid syntax.'])
end

sma.GlobalCounterThresholds(CounterNumber) = Threshold;
sma.GlobalCounterEvents(CounterNumber) = TargetEventCode;
sma.GlobalCounterSet(CounterNumber) = 1;