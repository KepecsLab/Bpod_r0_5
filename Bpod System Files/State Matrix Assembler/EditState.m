function sma_out = EditState(sma, StateName, ParameterName, ParameterValue)
% JS, October 2013
% Edits one parameter of a state in an existing state matrix.
%
% ParameterName can be ONE of the following:
% 1. 'Timer'
% 2. 'StateChangeConditions'
% 3. 'OutputActions'
%
% Edits do not clear existing parameters - for instance, changing 'Tup' to
% 'State7' for state 'State6' will not affect the matrix's entries for other events in State6.
% To clear a state's parameters (to set all events or outputs to do nothing), use the
% SetState2Default function.
%
% Examples:
%  sma = EditState(sma, 'State6', 'StateChangeConditions', {'Tup', 'State7'});
%  sma = EditState(sma, 'Deliver_Stimulus', 'OutputActions', {'LEDState', 0});
%

TargetStateNumber = find(strcmp(StateName,sma.StateNames));
if isempty(TargetStateNumber)
    error(['Error: no state called "' StateName '" was found in the state matrix.'])
end

switch ParameterName
    case 'Timer'
        if ischar(ParameterValue)
            error('State timer durations must be numbers, in seconds')
        end
        if ParameterValue < 0
            error('When setting state timers, time (in seconds) must be positive.')
        end
        if ParameterValue > 3600
            error('State timers can not exceed 1 hour');
        end
        sma.StateTimers(TargetStateNumber) = ParameterValue;
    case 'StateChangeConditions'
        if ~iscell(ParameterValue)
            error('Incorrect format for state change conditions - must be a cell array of strings. Example: {''Port2Out'', ''WaitForResponse'', ''Tup'', ''ITI''}')
        end
        nConditions = length(ParameterValue);
        for x = 1:2:nConditions
            PossibleTransitions = {'Port1In', 'Port1Out', 'Port2In', 'Port2Out', 'Port3In', 'Port3Out', 'Port4In', 'Port4Out', 'Port5In', 'Port5Out', 'Port6In', 'Port6Out', 'Port7In', 'Port7Out', 'Port8In', 'Port8Out', 'BNC1High', 'BNC1Low', 'BNC2High', 'BNC2Low', 'Wire1High', 'Wire1Low', 'Wire2High', 'Wire2Low', 'Wire3High', 'Wire3Low', 'Wire4High', 'Wire4Low', 'SoftCode1', 'SoftCode2', 'SoftCode3', 'SoftCode4', 'SoftCode5', 'SoftCode6', 'SoftCode7', 'SoftCode8', 'SoftCode9', 'SoftCode10', 'Unused', 'Tup'};
            CandidateEvent = ParameterValue{x};
            CandidateEventCode = find(strcmp(CandidateEvent,PossibleTransitions));
            RedirectedStateNumber = find(strcmp(ParameterValue{x+1},sma.StateNames));
            if isempty(RedirectedStateNumber)
                error(['The state "' ParameterValue{x+1} '" does not exist in the matrix you tried to edit.'])
            end
            if isempty(CandidateEventCode)
                CandidateEventName = CandidateEvent;
                if length(CandidateEventName > 4)
                    if sum(CandidateEventName(length(CandidateEventName)-3:length(CandidateEventName)) == '_End') == 4
                        % This is a transition for a global timer. Add to global timer matrix.
                        GlobalTimerNumber = str2double(CandidateEventName(length(CandidateEventName) - 4));
                        if ~isnan(GlobalTimerNumber)
                            sma.GlobalTimerMatrix(CurrentState, GlobalTimerNumber) = TargetStateNumber;
                        else
                            EventSpellingErrorMessage(ThisStateName);
                        end
                    else
                        EventSpellingErrorMessage(ThisStateName);
                    end
                else
                    EventSpellingErrorMessage(ThisStateName);
                end
            else
                sma.InputMatrix(TargetStateNumber,CandidateEventCode) = RedirectedStateNumber;
            end
        end
    case 'OutputActions'
        if ~iscell(ParameterValue)
            error('Incorrect format for output actions - must be a cell array of strings. Example: {''LEDState'', ''1'', ''ValveState'', ''3''}')
        end
        PossibleOutputActions = {'LEDState', 'ValveState', 'BNCState', 'WireState', 'Serial1Code', 'Serial2Code', 'SoftCode', 'GlobalTimerTrig', 'GlobalTimerCancel'};
        for x = 1:2:length(ParameterValue)
            if sum(strcmp(ParameterValue{x}, PossibleOutputActions)) > 0
                EventCode = strcmp(ParameterValue{x}, PossibleOutputActions);
                Value = ParameterValue{x+1};
                sma.OutputMatrix(TargetStateNumber,EventCode) = Value;
            else
                error(['Check spelling of your output actions for state: ' Name '. Valid spellings: LEDState, ValveState, BNCState, WireState, Serial1Code, Serial2Code, SoftCode, GlobalTimerTrig, GlobalTimerCancel']);
            end
        end
    otherwise
        error('ParameterName must be one of the following: ''Timer'', ''StateChangeConditions'', ''OutputActions''')
end
sma_out = sma;
%%%%%%%%%%%%%% End Main Code. Functions below. %%%%%%%%%%%%%%
    
function EventSpellingErrorMessage(ThisStateName)
        error(['Check spelling of your state transition events for state: ' ThisStateName '. Valid events (% is an index): Port%In Port%Out BNC%High BNC%Low Wire%High Wire%Low SoftCode% GlobalTimer%End Tup'])