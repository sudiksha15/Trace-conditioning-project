% Code to batch delete trace structures & behavior saved as HDF5 Files to
% regenerate using batchSaveHDF5.m
% Requires /scripts/matlab/utilities to be added to path

% Get Input Data
basedir = '/mnt/eng_research_handata/Kyle/AliEyeBlink/test';
hdf5_filename = 'trace_kyleFinalwDoughnut.hdf5'; %Filename in Base Directory
all_files = findNestedFiles(basedir, hdf5_filename);

for idx = 1:numel(all_files)
    delete(all_files{idx})
end