function MyProtocol % On each trial, at random, either port 1 or 3 will blink.
global BpodSystem % Allows access to Bpod device from this function
TrialTypes = ceil(rand(1,5000)*2); % Make 5000 future trial types
for currentTrial = 1:5000
    pause(0.5) % delay between trials so light flashes are visible
    disp(['Trial#' num2str(currentTrial) ' TrialType ' num2str(TrialTypes(currentTrial))]) % Print trial details to screen
    if TrialTypes(currentTrial) == 1 % Determine which LED to set to max brightness (255)
        LEDcode = {'PWM1', 255};
    else
        LEDcode = {'PWM3', 255};
    end
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'State1', ...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', LEDcode);
    SendStateMatrix(sma); RawEvents = RunStateMatrix; % Send and run state matrix
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    if BpodSystem.BeingUsed == 0
        return
    end
end