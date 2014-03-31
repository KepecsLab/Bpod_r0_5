classdef BpodObject < handle
    %STATEMACHINEOBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StateMatrix
        Birthdate
        LastTimestamp
        CurrentStateCode
        CurrentStateName
        LastEvent
        LastTrialData
        SessionData
        HardwareState
        BNCOverrideState
        GUIHandles
        GUIData
        Graphics
        EventNames
        OutputActionNames
        BeingUsed
        InStateMatrix
        Live
        CurrentProtocolName
        SerialPort
        Stimuli
        FirmwareBuild
        SplashData
        ProtocolSettings
        Data
        BpodPath
        SettingsPath
        DataPath
        ProtocolPath
        InputConfigPath
        InputsEnabled
    end
    
    methods
        
    end
    
end

