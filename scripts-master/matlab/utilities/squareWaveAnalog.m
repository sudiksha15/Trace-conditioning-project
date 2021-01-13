function [bin_trace] = squareWaveAnalog(in_trace, windSize, frac)
%SQUAREWAVEANALOG Take signal with analog alternating waves (Sounds) and
%return a square trace representing on-off
%   in_trace: Signal with assumed periodic sound pulses (Sound Trace for
%   tone-puff)
%   square_trace: Processed in_trace with square waves in place of
%   tones/localized analog signals

if isempty(windSize) %If sliding window is not inputted for filling gaps, set to 10
    windSize=10;
end
if isempty(frac)
    frac=0.5; %Half-max as default threshold
end

abs_center_trace = abs(in_trace - mean(in_trace)); %Center & Absolute Value Trace
max_point = max(abs_center_trace);
threshold = max_point * frac; %Pick Threshold for envelope trace
bin_trace = abs_center_trace>threshold;
for idx = (1+windSize):(numel(bin_trace)-windSize) %Loop through each point and close gaps
    if bin_trace(idx) == 0
        if (sum(bin_trace(idx-windSize:idx-1)) >= 1) && (sum(bin_trace(idx+1:idx+windSize)) >= 1)
            bin_trace(idx) = 1;
        end
    end
end

end

