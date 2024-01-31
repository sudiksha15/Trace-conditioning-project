function [pkstarts, pkends] = findPeakStartsEnds(trace, bintrace)
%Get peak start indices and peak maximums from a derivative trace
difftrace = diff(trace); %Derivatives
pktrace = zeros(1,numel(trace));
pktrace(bintrace) = trace(bintrace);
[~, pklocs] = findpeaks(pktrace);
if isempty(pklocs) %If no peaks
    pkstarts=NaN;
    pkends=NaN;
else
    pkstarts = nan(numel(pklocs),1);
    pkends = nan(numel(pklocs),1);
    for idx = 1:numel(pklocs) %Loop through found peaks and find where derivative goes negative for both
        start = pklocs(idx)-1; %Minus 1 for shifting indicies by 1 with diff
        before = find(difftrace(1:start)<0);
        after = find(difftrace(start:end)<0);
        if isempty(before) %Handle Endpoints
            before = NaN;
            after = NaN;
        elseif isempty(after)
            after=numel(difftrace);
        end
        pkstarts(idx) = before(end);
        pkends(idx) = start+after(1);
    end
end
end
