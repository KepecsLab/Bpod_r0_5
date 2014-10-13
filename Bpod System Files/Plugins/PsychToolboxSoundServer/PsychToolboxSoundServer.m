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
function PsychToolboxSoundServer(Function, varargin)
% Note: On some Ubuntu systems with Xonar DX, L&R audio seem to be remapped
% to the third plug on the card (from the second plug where they're
% supposed to be). A modified version of this plugin for those systems is
% available upon request. -JS 8/27/2014
global BpodSystem
SF = 192000; % Sound card sampling rate
nSlaves = 10;
Function = lower(Function);
switch Function
    case 'init'
        if ~isfield(BpodSystem.SystemSettings, 'SoundDeviceID')
            BpodSystem.SystemSettings.SoundDeviceID = [];
        end
        PsychPortAudio('Verbosity', 0);
        if isfield(BpodSystem.PluginObjects, 'SoundServer')
            try
                PsychPortAudio('Close', BpodSystem.PluginObjects.SoundServer);
            catch
            end
        else
            InitializePsychSound(1);
        end
        PsychPortAudio('Close');
        AudioDevices = PsychPortAudio('GetDevices');
        nDevices = length(AudioDevices);
        CandidateDevices = []; nCandidates = 0;
        if ispc
            for x = 1:nDevices
                if strcmp(AudioDevices(x).HostAudioAPIName, 'ASIO')
                    nCandidates = nCandidates + 1;
                    CandidateDevices(nCandidates) = AudioDevices(x).DeviceIndex;
                end
            end
        elseif ismac
        else
            for x = 1:nDevices
                if ~isempty(strfind(AudioDevices(x).DeviceName, 'Xonar DX: Multichannel')) % Assumes ASUS Xonar DX Soundcard    
                %if ~isempty(strfind(AudioDevices(x).DeviceName, 'Xonar U7')) % Assumes ASUS Xonar U7 Soundcard
                    nCandidates = nCandidates + 1;
                    CandidateDevices(nCandidates) = AudioDevices(x).DeviceIndex;
                end
            end
        end
        
        if nCandidates > 0
            for x = 1:nCandidates
                disp(['Candidate device found! Trying candidate ' num2str(x) ' of ' num2str(nCandidates)])
                try
                    CandidateDevice = PsychPortAudio('Open', CandidateDevices(x), 9, 4, SF, 4 , 32);
                    BpodSystem.SystemSettings.SoundDeviceID = CandidateDevices(x);
                    SaveBpodSystemSettings;
                    PsychPortAudio('Close', CandidateDevice);
                    disp('Success! A compatible sound card was detected and stored in Bpod settings.')
                catch
                    
                end
            end
        else
            disp('Error: no compatible sound subsystem detected. On Windows, ensure ASIO drivers are installed.')
        end
        BpodSystem.PluginObjects.SoundServer.MasterOutput = PsychPortAudio('Open', BpodSystem.SystemSettings.SoundDeviceID, 9, 4, SF, 4 , 32);
        PsychPortAudio('Start', BpodSystem.PluginObjects.SoundServer.MasterOutput, 0, 0, 1);
        for x = 1:nSlaves
            BpodSystem.PluginObjects.SoundServer.SlaveOutput(x) = PsychPortAudio('OpenSlave', BpodSystem.PluginObjects.SoundServer.MasterOutput);
        end
        Data = zeros(4,192);
        PsychPortAudio('FillBuffer', BpodSystem.PluginObjects.SoundServer.SlaveOutput(1), Data);
        PsychPortAudio('Start', BpodSystem.PluginObjects.SoundServer.SlaveOutput(1));
        disp('PsychToolbox sound server successfully initialized.')
    case 'close'
        PsychPortAudio('Close');
        disp('PsychToolbox sound server successfully closed.')
    case 'load'
        SlaveID = varargin{1};
        Data = varargin{2};
        Siz = size(Data);
        if Siz(1) > 2
            error('Sound data must be a row vector');
        end
        if Siz(1) == 1 % If mono, send the same signal on both channels
            Data(2,:) = Data;
        end
        Data(3:4,:) = zeros(2,Siz(2));
        Data(3:4,1:(SF/1000)) = ones(2,(SF/1000));
        PsychPortAudio('FillBuffer', BpodSystem.PluginObjects.SoundServer.SlaveOutput(SlaveID), Data);
    case 'play'
        SlaveID = varargin{1};
        if SlaveID < nSlaves+1
            PsychPortAudio('Start', BpodSystem.PluginObjects.SoundServer.SlaveOutput(SlaveID));
        else
            error(['The psychtoolbox sound server currently supports only ' num2str(nSlaves) ' sounds.'])
        end
    case 'stop'
        SlaveID = varargin{1};
        PsychPortAudio('Stop', BpodSystem.PluginObjects.SoundServer.SlaveOutput(SlaveID));
    case 'stopall'
        for x = 1:nSlaves
            PsychPortAudio('Stop', BpodSystem.PluginObjects.SoundServer.SlaveOutput(x));
        end
end