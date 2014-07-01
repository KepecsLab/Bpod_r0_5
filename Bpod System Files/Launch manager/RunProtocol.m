function RunProtocol
global BpodSystem
SMStatus = BpodSystem.BeingUsed;
if SMStatus == 0
    clear PB
    ProtocolNames = get(BpodSystem.GUIHandles.ProtocolSelector, 'String');
    SelectedProtocol = get(BpodSystem.GUIHandles.ProtocolSelector, 'Value');
    SelectedProtocolName = ProtocolNames{SelectedProtocol};
    set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.PauseButton);
    BpodSystem.BeingUsed = 1;
    BpodSystem.CurrentProtocolName = SelectedProtocolName;
    addpath(fullfile(BpodSystem.BpodPath, 'Protocols', SelectedProtocolName));
    LaunchManager;
else
    disp(' ')
    if ~isempty(BpodSystem.CurrentProtocolName)
        disp([BpodSystem.CurrentProtocolName ' ended.'])
    end
    rmpath(fullfile(BpodSystem.BpodPath, 'Protocols', BpodSystem.CurrentProtocolName));
    BpodSystem.BeingUsed = 0;
    BpodSystem.CurrentProtocolName = '';
    BpodSystem.SettingsPath = '';
    BpodSystem.Live = 0;
    BpodSerialWrite('X', 'uint8');
    pause(.1);
    if BpodSerialBytesAvailable > 0
        BpodSerialRead(BpodSerialBytesAvailable, 'uint8');
    end
    % Shut down protocol and plugin figures (should be made more general)
    if isfield(BpodSystem.PluginSerialPorts, 'TeensySoundServer')
        TeensySoundServer('end');
    end
    try
        Figs = fields(BpodSystem.GUIHandles.Figures);
        nFigs = length(Figs);
        for x = 1:nFigs
            try
                close(eval(['BpodSystem.GUIHandles.Figures.' Figs{x}]));
            catch
                
            end
        end
        try
            close(BpodNotebook)
        catch
        end
    catch
    end
    % ---- end Shut down Plugins
    set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.GoButton);
end