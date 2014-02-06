function RunSelectedProtocolBuilder
global BpodSystem
SelectedBuilder = get(BpodSystem.GUIHandles.ProtocolBuilderSelect, 'Value');
close(BpodSystem.GUIHandles.ProtocolBuilderSelectFig)
switch SelectedBuilder
    case 1
        %CreateLowLevelProtocolFromTemplate
    case 2
        TwoAFCSessionEditor
    case 3
        msgbox('The advanced task builder is still under development.')
end