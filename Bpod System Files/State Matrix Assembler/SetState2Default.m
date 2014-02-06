function sma_out = SetState2Default(sma, StateName, ParameterName)
% JS, October 2013
% Sets a single state's state change conditions, output actions or both to defaults.
%
% ParameterName can be ONE of the following:
% 1. 'StateChangeConditions'
% 2. 'OutputActions'
% 3. 'All'
%
% Examples:
%  This example sets all state change conditions for the "WaitForResponse" state to the same state (i.e. do nothing for all events):
%  sma = SetState2Default(sma, 'WaitForResponse', 'StateChangeConditions');
%
%  This example sets all events in the state Deliver_Stimulus to do nothing, AND sets OutputActions to {} (i.e. no output actions);
%  sma = SetState2Default(sma, 'Deliver_Stimulus', 'All');
%

TargetStateNumber = find(strcmp(StateName,sma.StateNames));
if isempty(TargetStateNumber)
    error(['Error: no state called "' StateName '" was found in the state matrix.'])
end

switch ParameterName
    case 'StateChangeConditions'
         sma.InputMatrix(TargetStateNumber,:)= ones(1,40)*TargetStateNumber;
    case 'OutputActions'
        sma.OutputMatrix(TargetStateNumber,:) = zeros(1,10);
    case 'All'
        sma.InputMatrix(TargetStateNumber,:)= ones(1,40)*TargetStateNumber;
        sma.OutputMatrix(TargetStateNumber,:) = zeros(1,10);
    otherwise
        error('ParameterName must be one of the following: ''StateChangeConditions'', ''OutputActions'', ''All''')
end
sma_out = sma;
