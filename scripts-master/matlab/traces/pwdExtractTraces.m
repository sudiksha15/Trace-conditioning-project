%Script to run trace extraction in present working directory (pwd)

%File Inputs
%roifile = 'roi_kyleFinal.mat'; %'quickCircle_ROIs.mat'; %'ACSAT_Autorun_ROIs.mat';%'roi_4277_D1_ball.mat'; 
roifile = 'ROI_list_608451.mat';
savename = 'trace_608451.mat'; %'trace_ACSAT_Autorun.mat'; %'trace_4277_D1_ball.mat'; %'trace_kyleFinalwDoughnut_AllBGs.mat';

fprintf(['Loading ',roifile,'\n']);
load(roifile); %load ROI (Assumes CellList is name of ROI struct)

%r_out = extract_trace(CellList, 0, 1, 0, 0); %CellList for My Data %roi_list for Rebecca's Data
r_out = extract_trace(ROI_list, 0, 1, 0, 0); 
save(savename, 'r_out','-v7.3');