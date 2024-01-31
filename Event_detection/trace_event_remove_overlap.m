function roi_list=trace_event_remove_overlap(roi_list, save_keyword)

    whole_tic = tic;
    
    if nargin<2 || isempty(save_keyword) 
        save_keyword = datestr(now,'yyyymmdd');
    end

    for roi_idx=1:numel(roi_list)
        whole_trace = roi_list(roi_idx).trace;
        current_event_trace = zeros(size(whole_trace));
        x_axis = [1:numel(current_event_trace )]/20;
        
        original_event_count = size(roi_list(roi_idx).event_time,1);
        for event_idx=1:original_event_count           
            current_event_trace(roi_list(roi_idx).event_idx(event_idx,1):roi_list(roi_idx).event_idx(event_idx,2)) = 1;
        end
        
        d_current_event_trace = diff(current_event_trace);
        
        start_idx_list = find(d_current_event_trace==1)+1;
        end_idx_list = find(d_current_event_trace==-1)+1;
        start_idx_list = start_idx_list(1:min(numel(start_idx_list),numel(end_idx_list)));
        end_idx_list = end_idx_list(1:min(numel(start_idx_list),numel(end_idx_list)));
        
        event_idx = cat(2,reshape(start_idx_list,[],1),reshape(end_idx_list,[],1));
        event_time = cat(2,reshape(x_axis(start_idx_list),[],1),reshape(x_axis(end_idx_list),[],1));
        
        new_event_count = size(event_idx,1);
        
        event_amp = nan(size(event_idx,1),1);
        
        for current_event_idx=1:size(event_idx,1)
            ref_idx = event_idx(current_event_idx,1)-1;
            current_trace = whole_trace(event_idx(current_event_idx,1):event_idx(current_event_idx,2));
            
            [max_amp,max_idx] = max(current_trace);
            event_idx(current_event_idx,2) = ref_idx+max_idx(1);
            [min_amp,min_idx] = min(current_trace(1:max_idx));
            event_idx(current_event_idx,1) = ref_idx+min_idx(1);
            
            event_amp(current_event_idx) = max_amp-min_amp;
            
        end
        
        roi_list(roi_idx).event_time = event_time;
        roi_list(roi_idx).event_idx = event_idx;
        roi_list(roi_idx).event_amp = event_amp;
        
        fprintf(['ROI ',num2str(roi_idx),': ',num2str(original_event_count),'->',num2str(new_event_count),'\n']);
        
    end
    
%     save(['refined_trace_event_',save_keyword],'roi_list');
    fprintf(['Total loading time: ',num2str(round(toc(whole_tic),2)),' seconds.\n']);
    

end