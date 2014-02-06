classdef BpodObject < handle
    %STATEMACHINEOBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StateMatrix
        CurrentStateCode
        CurrentStateName
        LastEvent
        LastTrialData
        SessionData
        HardwareState
        BNCOverrideState
        GUIHandles
        Graphics
        EventNames
        OutputActionNames
        Birthdate
        BeingUsed
        InStateMatrix
        Live
        CurrentProtocolName
        SettingsPath
        DataPath
        LastTimestamp
        SerialPort
        Stimuli
        FirmwareBuild
        SplashData
    end
    
    methods
        
    end
    
end

