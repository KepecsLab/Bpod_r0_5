function PsychToolboxSoundServer(Function, varargin)
global BpodSystem
%SF = 192000; % Sound card sampling rate
SF = 96000;
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
                if ~isempty(strfind(AudioDevices(x).DeviceName, 'Xonar STX: Multichannel')) % Assumes ASUS Xonar STX Soundcard
                    nCandidates = nCandidates + 1;
                    CandidateDevices(nCandidates) = AudioDevices(x).DeviceIndex;
                end
            end
        end
        
        if nCandidates > 0
            for x = 1:nCandidates
                disp(['Candidate device found! Trying candidate ' num2str(x) ' of ' num2str(nCandidates)])
                try
                    CandidateDevice = PsychPortAudio('Open', CandidateDevices(x), 9, 4, SF, 3 , 32, 1, [0 1 3]);
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
        BpodSystem.PluginObjects.SoundServer.MasterOutput = PsychPortAudio('Open', BpodSystem.SystemSettings.SoundDeviceID, 9, 4, SF, 3 , 32, 1, [0 1 3]);
        PsychPortAudio('Start', BpodSystem.PluginObjects.SoundServer.MasterOutput, 0, 0, 1);
        for x = 1:nSlaves
            BpodSystem.PluginObjects.SoundServer.SlaveOutput(x) = PsychPortAudio('OpenSlave', BpodSystem.PluginObjects.SoundServer.MasterOutput);
        end
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
        Data(3,:) = ones(1,Siz(2));
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