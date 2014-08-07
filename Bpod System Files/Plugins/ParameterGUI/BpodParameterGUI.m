function varargout = BpodParameterGUI(varargin)
% BpodParameterGUI('init', ParamStruct) - initializes a GUI with edit boxes for every field in subfield ParamStruct.GUI
% BpodParameterGUI('sync', ParamStruct) - updates the GUI with fields of
%       ParamStruct.GUI, if they have not been changed by the user. 
%       Returns a param struct. Fields in the GUI sub-struct are read from the UI.
global BpodSystem
Op = varargin{1};
Params = varargin{2};
switch Op
    case 'init'
        Params = Params.GUI;
        ParamNames = fieldnames(Params);
        nValues = length(ParamNames);
        ParamValues = zeros(1,nValues);
        for x = 1:nValues
            ParamValues(x) = getfield(Params, ParamNames{x});
        end
        Vsize = 25+(30*nValues);
        BpodSystem.GUIHandles.Figures.BpodParameterGUI = figure('Position', [100 250 320 Vsize],'name','Live Params','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        uicontrol('Style', 'text', 'String', 'Parameter', 'Position', [10 Vsize-20 200 20], 'FontWeight', 'bold', 'FontSize', 14, 'FontName', 'Arial');
        uicontrol('Style', 'text', 'String', 'Value', 'Position', [235 Vsize-20 70 20], 'FontWeight', 'bold', 'FontSize', 14, 'FontName', 'Arial');
        BpodSystem.GUIHandles.ParameterGUI = struct;
        BpodSystem.GUIHandles.ParameterGUI.ParamNames = ParamNames;
        BpodSystem.GUIHandles.ParameterGUI.LastParamValues = ParamValues;
        BpodSystem.GUIHandles.ParameterGUI.Labels = zeros(1,nValues);
        Pos = Vsize-50;
        for x = 1:nValues
            eval(['BpodSystem.GUIHandles.ParameterGUI.Labels(x) = uicontrol(''Style'', ''text'', ''String'', ''' ParamNames{x} ''', ''Position'', [10 ' num2str(Pos) ' 200 20], ''FontWeight'', ''normal'', ''FontSize'', 14, ''FontName'', ''Arial'');']);
            eval(['BpodSystem.GUIHandles.ParameterGUI.ParamValues(x) = uicontrol(''Style'', ''edit'', ''String'', ''' num2str(ParamValues(x)) ''', ''Position'', [235 ' num2str(Pos) ' 70 20], ''FontWeight'', ''normal'', ''FontSize'', 14, ''FontName'', ''Arial'');']);
            Pos = Pos - 30;
        end
        
    case 'sync'
        ParamNames = fieldnames(Params.GUI);
        nValues = length(BpodSystem.GUIHandles.ParameterGUI.LastParamValues);
        for x = 1:nValues
            thisParamGUIValue = str2double(get(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'String'));
            thisParamLastValue = BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x);
            thisParamInputValue = eval(['Params.GUI.' ParamNames{x}]);
            if thisParamGUIValue == thisParamLastValue % If the user didn't change the GUI, the GUI can be changed from the input.
                set(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'String', num2str(thisParamInputValue));
                thisParamGUIValue = thisParamInputValue;
            end
            eval(['Params.GUI.' BpodSystem.GUIHandles.ParameterGUI.ParamNames{x} ' = ' num2str(thisParamGUIValue) ';'])
            BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x) = thisParamGUIValue;
        end
    varargout{1} = Params;
end