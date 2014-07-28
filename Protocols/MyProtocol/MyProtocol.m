function MyProtocol

global BpodSystem
TrialTypes = ceil(rand(1,5000)*2);

for currentTrial = 1:5000
    disp(['TrialType ' num2str(TrialTypes(currentTrial))])
    sma = NewStateMatrix(); % Assemble state matrix
    if TrialTypes(currentTrial) == 1
        sma = AddState(sma, 'Name', 'State1', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'PWM1', 255});
    else
        sma = AddState(sma, 'Name', 'State1', ...
            'Timer', 1,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'PWM3', 255});
    end
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    if BpodSystem.BeingUsed == 0
        return
    end
    pause(.2)
end