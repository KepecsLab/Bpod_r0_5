% BpodPath
% AGV Feb 14, 2012
% This script 
% a) returns the value of BpodPath 
% b) doublechecks that BpodPath/Data and BpodPath/CalibrationFiles exist, and makes them if not.


%% Set BpodPath

FullBpodPath = which('Bpod');
BpodPath = FullBpodPath(1:strfind(FullBpodPath, 'Bpod System Files')-1);

%% Check that /Data and /CalibrationFiles exist, and make them if not.

%Check for Data
dir_data = dir( fullfile(BpodPath,'Data') );
if length(dir_data) == 0, %then Data didn't exist.
    mkdir([BpodPath,'/' 'Data']);
end

%Check for CalibrationFiles
dir_calfiles = dir( fullfile(BpodPath,'Calibration Files') );
if length(dir_calfiles) == 0, %then Data didn't exist.
    mkdir([BpodPath,'/' 'Calibration Files']);
end
clear dir_data dir_calfiles FullBpodPath

