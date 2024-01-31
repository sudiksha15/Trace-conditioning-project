
%% Binarize the rising time as 1's to plot heatmap and visualize

% Need to have event_data loaded and in workspace or else use above to run
% event_detection and then binarize to visualize 

%a=h5read('traces_ali24.h5','/traces');
%roi_list = struct();
%for n = 1:size(a,1)
 %    roi_list(n).trace =  a(n,:);
%end
%event_data=runEventDetection(roi_list);

% Can also use below to make event onsets 1 
binTraces =event_detection_heatmap(event_data);
figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])
% Looking at first 10000 frames
imagesc(binTraces(:,1:10000))

function[binTraces] = event_detection_heatmap(event_data)
binTraces = zeros(numel(event_data),size(event_data(1).trace,2));
for roi_idx=1:numel(event_data)
    event_idx = event_data(roi_idx).event_idx;
    for event = 1:size(event_idx,1)
        binTraces(roi_idx,[event_idx(event,1):event_idx(event,2)]) = 1;
    end
end

end

