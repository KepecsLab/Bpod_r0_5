function ValveTimes = GetValveTimes(LiquidAmount, TargetValves)
loadBpodPath
CalibrationFilePath = fullfile(BpodPath, 'Calibration Files', 'LiquidCalibration.mat');
load(CalibrationFilePath);
nValves = length(TargetValves);
ValveTimes = nan(1,nValves);
for x = 1:nValves
    ValidTable = 1;
    CurrentTable = LiquidCal(TargetValves(x)).Table;
    if ~isempty(CurrentTable)
        ValveDurations = CurrentTable(:,1)';
        nMeasurements = length(ValveDurations);
        if nMeasurements < 2
            ValidTable = 0;
            error(['Not enough liquid calibration measurements exist for valve ' num2str(TargetValves(x)) '. Bpod needs at least 3 measurements.'])
        end
    else
        ValidTable = 0;
        error(['Not enough liquid calibration measurements exist for valve ' num2str(TargetValves(x)) '. Bpod needs at least 3 measurements.'])
    end
    if ValidTable == 1
        ValveTimes(x) = polyval(LiquidCal(TargetValves(x)).TrinomialCoeffs, LiquidAmount);
        if isnan(ValveTimes(x))
            ValveTimes(x) = 0;
        end
    end
end
