%Script to match ROI Indexes between two sets of ROI maps between sessions
%Uses Hua-an's roi_matching.m code

%Selected Files
%File 1
base1 = '/mnt/eng_handata/Kyle_Hansen/AliEyeBlink/ali24_d4_s1/';
trace1 = 'trace_kyleFinal.mat';
image1name = 'full_projection_m_f_max_min_batch.fig';
save1 = 'trace_kyleFinal_matched.mat';
file1 = fullfile(base1, trace1);
image1 = fullfile(base1, image1name);
file1save = fullfile(base1, save1);
%File 
base2 = '/mnt/eng_handata/Kyle_Hansen/AliEyeBlink/ali24_d4_s2';
trace2 = 'trace_kyleFinal.mat';
image2name = 'full_projection_m_f_max_min_batch.fig';
save2 = 'trace_kyleFinal_matched.mat';
file2 = fullfile(base2, trace2);
image2 = fullfile(base2, image2name);
file2save = fullfile(base2, save2);
%Fields Out
field1name = 'first30_d4_s1_index'; %'baseline_d2_s1_index';
field2name = 'last30_d4_s2_index'; %'firstExtinction_d5_s2_index';

%Load ROI/Trace Files & Images
%Data 1
load(file1)
r_out1 = r_out;
clear r_out
open(image1);
ax=gca();
img1 = ax.Children.CData;
close(figure(1))
%Data 2
load(file2)
r_out2 = r_out;
clear r_out
open(image2);
ax=gca();
img2 = ax.Children.CData;
close(figure(1))

%Make Binary Threshold Masks
mask1 = zeros(1024,1024);
for idx=1:numel(r_out1)
    mask1(r_out1(idx).pixel_idx)=1;
end
mask2 = zeros(1024,1024);
for idx=1:numel(r_out2)
    mask2(r_out2(idx).pixel_idx)=1;
end

%Shift ROIs
%[im2_shifted, r_out2_shifted] = roi_shifting(img1, r_out1, img2, r_out2, 'S');
[im2_shifted, r_out2_shifted] = roi_shifting(mask1, r_out1, mask2, r_out2, 'S');

%Line Up ROIs with Hua-an's Code
[result, summary] = roi_matching(r_out1, r_out2_shifted, [1024, 1024], 50, 0.5);
summary

%Add Output to Structures
for idx = 1:numel(result)
    id1 = result(idx).ref_id;
    id2 = result(idx).test_id;
    if result(idx).matched
        r_out1(id1).(field1name) = id1;
        r_out1(id1).(field2name) = id2;
        r_out2(id2).(field1name) = id1;
        r_out2(id2).(field2name) = id2;
    elseif result(idx).ref_only
        r_out1(id1).(field1name) = id1;
        r_out1(id1).(field2name) = id2;
    elseif result(idx).test_only
        r_out2(id2).(field1name) = id1;
        r_out2(id2).(field2name) = id2;
    end
end

%Save Output
r_out = r_out1;
save(file1save, 'r_out');
clear r_out
r_out = r_out2;
save(file2save, 'r_out');
clear r_out