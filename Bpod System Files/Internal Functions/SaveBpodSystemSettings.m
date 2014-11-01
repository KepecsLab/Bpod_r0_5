function SaveBpodSystemSettings
global BpodSystem
BpodSystemSettings = BpodSystem.SystemSettings;
save(fullfile(BpodSystem.BpodPath, 'Bpod System Files', 'BpodSystemSettings.mat'), 'BpodSystemSettings');