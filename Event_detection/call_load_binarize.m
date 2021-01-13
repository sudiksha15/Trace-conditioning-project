%% Option 1 - 2 functions 
%event_data=load_h5_events('traces_ali24.h5');
%r_out=binarize_trace(event_data);
%struct2hdf5_event(r_out,'binary_trace_ali25.h5')

%% Option 2 - 1 concise function 
r_out=load_h5_events_binarize('first_traces_8089.h5');
% Save r_out in  hdf5 file
% Make naming easier automated 
struct2hdf5_event(r_out,'first_binary_trace_8089.h5')

