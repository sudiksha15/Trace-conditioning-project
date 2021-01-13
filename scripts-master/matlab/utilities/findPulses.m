function [ locationTrace ] = findPulses(inputTrace)
%findPulses Function to find locations of onset and offset of pulses
%   inputTrace = 1-D Trace of values assumed to be similar to a train of ttl
%   pulses, where there is a clear onset and offset for each pulse.
%
%   locationTrace = Pseudo-logical 1-D trace, with 1s at pulse onset, -1s at
%   pulse offset, and 0s everywhere else.

shiftedInput = inputTrace - mean(inputTrace); %Shift to have mean 0 and baseline below 0.
changes = sign(shiftedInput); %Find where the sign changes
locationTrace = zeros(size(inputTrace)); %Initialize Output
locationTrace(logical([0;diff(changes)==2])) = 1; %Set onsets to 1.  Prepend 0 to account for shift from diff
locationTrace(logical([0;diff(changes)==-2])) = -1; %Set offsets to -1  Prepend 0 to account for shift from diff

end

