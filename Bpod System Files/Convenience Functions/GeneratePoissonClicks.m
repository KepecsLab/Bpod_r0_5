function ClickTimes = GeneratePoissonClicks(ClickRate, Duration)

% ClickTimes = times in us
% ClickRate = click rate in Hz
% Duration = click train duration in seconds
SamplingRate = 1000000;
nSamples = Duration*SamplingRate;
ExponentialMean = round((1/ClickRate)*SamplingRate); % Calculates mean of exponential distribution to draw intervals from, in samples
InvertedMean = ExponentialMean*-1;
PreallocateSize = ClickRate*Duration*2;
ClickTimes = zeros(1,PreallocateSize);
Pos = 0;
Time = 0;
Building = 1;
while Building == 1
    Pos = Pos + 1;
    Interval = InvertedMean*log(rand);
    Time = Time + Interval;
    if Time > nSamples
        Building = 0;
    else
        ClickTimes(Pos) = Time;
    end
end
ClickTimes = ClickTimes(1:Pos-1);