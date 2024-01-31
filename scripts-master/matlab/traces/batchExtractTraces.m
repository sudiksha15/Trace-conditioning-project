%Script to run batch trace extraction for a lot of files

%Add extract_trace.m to path
addpath('/home/sudi/scripts-master/matlab/traces')

%File inputs
basedir = '/mnt/eng_handata/eng_research_handata2/Sudi/608450/11182019/608450_25uA_10Hz00001/motion_corrected'; %AliEyeBlink/ali26_d5_s1'; %'/mnt/eng_research_handata/Kyle/MoonaPVLabel/Mouse4254/02182017s1_Day3/ProcessedData/Images/MotionCorrected'; '/mnt/eng_research_handata/eng_research_handata2/Rebecca/Autism/2085/Day_5/TonePuff/motion_corrected/';
roifile = 'ROI_list.mat'; %'circleROIsMoonaLabelled.mat'; 'roi_2085_D5_tonepuff.mat';
savename = 'trace_608450.mat'; %'trace_MoonaLabelledwDoughnut.mat'; '/mnt/eng_research_handata/eng_research_handata2/Rebecca/Autism/2085/ROIandTraces/trace_2085_D5_tonepuff.mat'; 
file_list = findNestedFiles(basedir, roifile);

%Loop through files
for idx = 1:numel(file_list) %Connection shut down.
    %Navigate to folder
    filename = file_list{idx};
    [pathstr, name, ext] = fileparts(filename);
    cd(pathstr);
    
    fprintf(['Loading ',filename,'\n']);
    load(filename); %load ROI (Assumes CellList is name of ROI struct)
    
    r_out = extract_trace(Roi_list, 0, 1, 0, 0); %CellList_Label, roi_2085_D5_tonepuff
    
    save(savename, 'r_out','-v7.3');
end