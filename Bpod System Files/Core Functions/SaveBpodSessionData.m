function SaveBpodSessionData
global BpodSystem
SessionData = BpodSystem.Data;
save(BpodSystem.DataPath, 'SessionData');
