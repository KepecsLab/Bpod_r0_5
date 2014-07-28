function HandleSoftCode(SoftCode)
global BpodSystem
eval([BpodSystem.SoftCodeHandlerFunction '(' num2str(SoftCode) ')'])
    