function r_out = load_h5_events_binarize(filename)
%% Loading h5 file and convert traces to struct 
a=h5read(filename,'/traces');
roi_list = struct();
for n = 1:size(a,1)
    roi_list(n).trace =  a(n,:);
end

%% Run Event detection 
event_data=runEventDetection(roi_list);

%% Initialize struct with traces as 0's 
r_out = struct();
s=size(event_data(1).trace);
for n = 1:numel(event_data)
     r_out(n).binary_trace =  zeros(s);
end


%% Store binary traces - 1's at event_starts and 0 everywhere else 

for ii= 1:numel(event_data)
    n = numel(event_data(ii).event_idx)/2;
    for i=1:n
        j= event_data(ii).event_idx(i);
        r_out(ii).binary_trace(j)=1;
    end
end
end