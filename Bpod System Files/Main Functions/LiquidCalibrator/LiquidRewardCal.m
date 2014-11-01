function LiquidRewardCal(nPulses, TargetValves, PulseDurations, PulseInterval)
% TargetValves = vector listing valves (in range 1-8) that are to be calibrated
% PulseDurations = for each valid valve, specify the time (in ms) for the valve to remain open.
% Pulse Interval = fixed delay between valve pulses
global BpodSystem
% Replace with settings
ValvePhysicalAddress(1) = 2^0;
ValvePhysicalAddress(2) = 2^1;
ValvePhysicalAddress(3) = 2^2;
ValvePhysicalAddress(4) = 2^3;
ValvePhysicalAddress(5) = 2^4;
ValvePhysicalAddress(6) = 2^5;
ValvePhysicalAddress(7) = 2^6;
ValvePhysicalAddress(8) = 2^7;
nValves = length(TargetValves);
PulseDurations = NanOutZeros(PulseDurations);
if sum(PulseDurations > 1) > 0
    error('Pulse durations should be specified in seconds.')
end
for x = 1:length(PulseDurations)
    if isnan(PulseDurations(x))
        PulseDurations(x) = 0;
    end
end

progressbar;
for x = 1:nPulses
    progressbar(x/nPulses)
    sma = NewStateMatrix();
    for y = 1:nValves
            sma = AddState(sma, 'Name', ['PulseValve' num2str(TargetValves(y))], ...
                'Timer', PulseDurations(y),...
                'StateChangeConditions', ...
                {'Tup', ['Delay' num2str(y)]},...
                'OutputActions', {'ValveState', ValvePhysicalAddress(TargetValves(y))});
            if y < nValves
            sma = AddState(sma, 'Name', ['Delay' num2str(y)], ...
                'Timer', PulseInterval,...
                'StateChangeConditions', ...
                {'Tup', ['PulseValve' num2str(TargetValves(y+1))]},...
                'OutputActions', {});
            else
                sma = AddState(sma, 'Name', ['Delay' num2str(y)], ...
                'Timer', PulseInterval,...
                'StateChangeConditions', ...
                {'Tup', 'exit'},...
                'OutputActions', {});
            end
    end
    if BpodSystem.EmulatorMode == 0
        SendStateMatrix(sma);
        RunStateMatrix;
        pause(.5);
    end
end
BpodSystem.BeingUsed = 0;