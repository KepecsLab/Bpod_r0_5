global BpodSystem

SMStatus = BpodSystem.BeingUsed;
if SMStatus == 0
    clear PB
    BpodSystem.Birthdate = now;
    BpodSystem.TimerRolloverIndex = 0;
    BpodSystem.LastTimestamp = 0;
    ProtocolNames = get(BpodSystem.GUIHandles.ProtocolSelector, 'String');
    SelectedProtocol = get(BpodSystem.GUIHandles.ProtocolSelector, 'Value');
    SelectedProtocolName = ProtocolNames{SelectedProtocol};
    if SelectedProtocol ~= 1
        set(BpodSystem.GUIHandles.RunButton, 'CData', BpodSystem.Graphics.PauseButton);
        loadBpodPath
        %ProtocolPath = [BpodPath 'Protocols\' SelectedProtocolName '\' SelectedProtocolName '.m'];
        BpodSystem.BeingUsed = 1;
        BpodSystem.CurrentProtocolName = SelectedProtocolName;
        LaunchManager;
        %run(ProtocolPath);
    else
        BpodSystem.CurrentProtocolName = '';
        ClearProtocol;
        BpodSystem.SettingsPath = '';
        % Prompt which protocol builder to use
        BpodSystem.GUIHandles.ProtocolBuilderSelectFig = figure('Position', [580 200 400 250],'numbertitle','off', 'MenuBar', 'none', 'Resize', 'off' );
        ha = axes('units','normalized', 'position',[0 0 1 1]);
        uistack(ha,'bottom');
        BG = imread('ProtocolBuilderSelectBG.bmp');
        image(BG); axis off;
        OkButtonGFX = imread('ProtocolBuilderOk.bmp');
        BpodSystem.GUIHandles.ProtocolBuilderSelect = uicontrol('Style', 'listbox', 'String', {'Barebones from template' '2AFC / GO-NOGO task builder' 'Advanced task builder'}, 'Position', [25 80 355 110], 'FontWeight', 'bold', 'FontSize', 14, 'BackgroundColor', [.85 .85 .85], 'Value', 1);
        BpodSystem.GUIHandles.OkButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [170 15 70 50], 'Callback', 'RunSelectedProtocolBuilder', 'CData', OkButtonGFX, 'TooltipString', 'Use selected protocol builder');
        uicontrol(BpodSystem.GUIHandles.ProtocolBuilderSelect);
    end
else
    ClearProtocol;
end
clear SMStatus SelectedProtocol SelectedProtocolName ans ProtocolNames BpodPath ProtocolPath