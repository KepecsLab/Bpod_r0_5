%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}
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
    if BpodSystem.EmulatorMode == 0
        BpodSerialWrite('X', 'uint8');
        pause(.1);
        if BpodSerialBytesAvailable > 0
            BpodSerialRead(BpodSerialBytesAvailable, 'uint8');
        end

        if isfield(BpodSystem.PluginSerialPorts, 'TeensySoundServer')
            TeensySoundServer('end');
        end
    else
        BpodSystem.ManualOverrideFlag = 1;
        BpodSystem.VirtualManualOverrideBytes = 'VXX';
    end
    % Shut down protocol and plugin figures (should be made more general)
    try
        Figs = fields(BpodSystem.ProtocolFigures);
        nFigs = length(Figs);
        for x = 1:nFigs
            try
                close(eval(['BpodSystem.ProtocolFigures.' Figs{x}]));
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