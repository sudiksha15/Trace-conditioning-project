function roi_list=runEventDetection(roi_list)%, save_keyword)
% run the four event detection scripts together

roi_list = trace_event_detection(roi_list);
roi_list = trace_event_remove_overlap(roi_list);
roi_list = trace_waveform(roi_list);
%roi_list = trace_waveform_remove_empty(roi_list);

end


