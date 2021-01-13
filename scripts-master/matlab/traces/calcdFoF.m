function [dFoF, params] = calcdFoF(F, sampfreq, staus)
%Calculate Delta F over F from the process in 
%http://www.nature.com/nprot/journal/v6/n1/box/nprot.2010.169_BX1.html
%Assuming Step 1 is all ready done, that F = average of all pixels
%in ROI, which is assumed to be a column vector input
%F = input trace
%sampfreq = Sampling frequency in Hz
%staus = vector of tau values as [tau0, tau1, tau2] from paper

%Check input format to make sure is column vector
if isrow(F)
    F = F';
end
Ts = 1/sampfreq;
[Npts, Ntraces] = size(F);

%Need to convert seconds to datapoint values
if isempty(staus)
    staus = [0.2, 0.75, 3]; %All in seconds.  Defaults recommended for 30 Hz filtering in paper
    taus = sampfreq * staus; %Multiply 30 samples/sec by number of seconds for tau values
else
    %For our data, decide on staus = [0.25, 0.75, 60];  
    taus = sampfreq * staus;
end

%Calc baseline F0 from smoothed trace avgF (Step 2)
avgF = nan(Npts,Ntraces); %Smoothed F(t) (**Change window size to be average)
for t = 1:Npts
    if (t-taus(2)) < 1
        x1 = 1;
        x2 = floor(t+(taus(2)/2));
    elseif (t+taus(2)) > Npts
        x1 = floor(t-(taus(2)/2));
        x2 = numel(F);
    else
        x1 = floor(t-(taus(2)/2));
        x2 = floor(t+(taus(2)/2));
    end
    avgF(t,:) = mean(F(x1:x2,:)); %1/taus(2) * sum(F(x1:x2)); %Just taking the average
end

F0 = nan(Npts,Ntraces); %Minimum value of smoothed F(t)
for t = 1:Npts
    if (t-taus(3)) < 1
        x3 = 1;
    else
        x3 = t-taus(3);
    end
    F0(t,:) = min(avgF(x3:t,:));
end

%Calc relative change R (Step 3)
R = (F - F0) ./ F0;

%Filtering (Step 4) **Still need to update to work with matrix of traces
%Create a w(t) function
ivals = [(-floor(Npts/2)+1):ceil(Npts/2)];
wtvals = ivals*Ts;
w = exp(-(abs(ivals)*Ts)/staus(1));
%Convolve shift with w(t)
y = conv(R,w,'same');
z = sum(w);
dFoF = y/z;

params = [avgF, F0, R, wtvals', w', y, z*ones(numel(avgF),1)];

end