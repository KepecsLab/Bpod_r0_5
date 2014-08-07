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
        LastHardwareState
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
        PluginSerialPorts
        PluginFigureHandles
        PluginObjects
        UsesPsychToolbox
        SystemSettings
        SoftCodeHandlerFunction
    end
    
    methods
        
    end
    
end

