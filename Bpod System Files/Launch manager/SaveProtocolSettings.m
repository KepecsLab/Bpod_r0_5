function SaveProtocolSettings(ProtocolSettings)
global BpodSystem
save(BpodSystem.SettingsPath, 'ProtocolSettings')
disp('Settings saved to: ')
disp(BpodSystem.SettingsPath)