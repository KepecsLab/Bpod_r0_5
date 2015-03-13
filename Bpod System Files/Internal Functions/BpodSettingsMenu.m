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
function BpodSettingsMenu

global BpodSystem
BpodSystem.GUIHandles.SettingsMenuFig = figure('Position', [650 480 326 126],'name','Settings Menu','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
ha = axes('units','normalized', 'position',[0 0 1 1]);
uistack(ha,'bottom');
BG = imread('SettingsMenuBG.bmp');
image(BG); axis off; drawnow;
LiquidCalButtonGFX = imread('WaterCalBW.bmp');
BpodSystem.GUIHandles.LiquidCalLaunchButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [45 30 40 40], 'Callback', @CalibrateValves, 'CData', LiquidCalButtonGFX, 'TooltipString', 'Calibrate valves for precise liquid delivery');
SpeakerCalButtonGFX = imread('SpeakerCalButton.bmp');
BpodSystem.GUIHandles.SoundCalLaunchButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [145 30 40 40], 'Callback', @CalibrateSound, 'CData', SpeakerCalButtonGFX, 'TooltipString', 'Test and calibrate sound delivery');
PortCalButtonGFX = imread('PortConfigButton.bmp');
BpodSystem.GUIHandles.PortCalLaunchButton = uicontrol('Style', 'pushbutton', 'String', '', 'Position', [245 30 40 40], 'Callback', @ConfigurePorts, 'CData', PortCalButtonGFX, 'TooltipString', 'Configure low impedence inputs (ports and wire terminals)');

function CalibrateValves(trash, othertrash)
global BpodSystem
close(BpodSystem.GUIHandles.SettingsMenuFig)
LiquidCalibrationManager;

function CalibrateSound(trash, othertrash)
global BpodSystem
close(BpodSystem.GUIHandles.SettingsMenuFig)
SoundTestAndCalApp;

function ConfigurePorts(trash, othertrash)
global BpodSystem
close(BpodSystem.GUIHandles.SettingsMenuFig)
BpodPortConfig;