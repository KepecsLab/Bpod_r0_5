function LiquidRewardCal(nPulses, TargetValves, PulseDurations, PulseInterval)
% TargetValves = vector listing valves (in range 1-8) that are to be calibrated
% PulseDurations = for each valid valve, specify the time (in ms) for the valve to remain open.
% Pulse Interval = fixed delay between valve pulses
global StateMachine
% Replace with settings
DIO = DIOmap;
ValvePhysicalAddress(1) = DIO.Port1Valve;
ValvePhysicalAddress(2) = DIO.Port2Valve;
ValvePhysicalAddress(3) = DIO.Port3Valve;
ValvePhysicalAddress(4) = DIO.Port4Valve;
ValvePhysicalAddress(5) = DIO.Port5Valve;
ValvePhysicalAddress(6) = DIO.Port6Valve;
ValvePhysicalAddress(7) = DIO.Port7Valve;
ValvePhysicalAddress(8) = DIO.Port8Valve;
nValves = length(TargetValves);
PulseDurations = NaNOutZeros(PulseDurations);
if sum(PulseDurations < 1) > 0
    error('Pulse durations should be specified in milliseconds.')
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
            sma = AddState(sma, 'name', ['PulseValve' num2str(TargetValves(y))], ...
                'self_timer', PulseDurations(y),...
                'input_to_statechange', ...
                {'Tup', ['Delay' num2str(y)]},...
                'output_actions', {'Dout', ValvePhysicalAddress(TargetValves(y))});
            if y < nValves
            sma = AddState(sma, 'name', ['Delay' num2str(y)], ...
                'self_timer', PulseInterval,...
                'input_to_statechange', ...
                {'Tup', ['PulseValve' num2str(TargetValves(y+1))]},...
                'output_actions', {});
            else
                sma = AddState(sma, 'name', ['Delay' num2str(y)], ...
                'self_timer', PulseInterval,...
                'input_to_statechange', ...
                {'Tup', 'final_state'},...
                'output_actions', {});
            end
    end
    SendStateMatrix(sma);
    [RawTrialEvents] = RunStateMatrix();
    pause(.5);
end
StateMachine.BeingUsed = 0;