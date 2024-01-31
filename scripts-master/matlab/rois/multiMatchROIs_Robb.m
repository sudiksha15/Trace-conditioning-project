%Script to match ROI Indexes between two sets of ROI maps between sessions
%Uses Hua-an's roi_matching.m code

%Selected Files
%File 1
base = '/mnt/eng_research_handata/eng_research_handata2/Kyle/NewTonePuff-Robb/1750/';
trace1 = '1750_d1_s2/trace_kyleFinalwDoughnut.mat';
behav1 = '1750_d1_s2/Behavior/SyncedBehavior.mat';
image1name = 'full_projection_m_f_max_min.fig';
save1 = 'trace_kyleFinalwDoughnut_matched.mat';
file1 = fullfile(base, trace1);
file1behav = fullfile(base, behav1);
image1 = fullfile(base, image1name);
file1save = fullfile(base, save1);
%File 2
trace2 = '1750_d2_s1/trace_kyleFinalwDoughnut_AllBGs.mat';
behav2 = '1750_d2_s1/Behavior/SyncedBehavior.mat';
image2name = 'full_projection_m_f_max_min_batch.fig';
save2 = 'trace_kyleFinalwDoughnut_AllBGs_matched.mat';
file2 = fullfile(base, trace2);
file2behav = fullfile(base, behav2);
image2 = fullfile(base, image2name);
file2save = fullfile(base, save2);
%File 3 Day 5
trace5 = '1750_d5_s1/trace_kyleFinalwDoughnut_AllBGs.mat';
behav5 = '1750_d5_s1/Behavior/SyncedBehavior.mat';
image5name = 'full_projection_m_f_max_min.fig';
save5 = 'trace_kyleFinalwDoughnut_AllBGs_matched.mat';
file5 = fullfile(base, trace5);
file5behav = fullfile(base, behav5);
image5 = fullfile(base, image5name);
file5save = fullfile(base, save5);
%File 4 Day 7
trace7 = '1750_d7_s1/trace_kyleFinalwDoughnut_AllBGs.mat';
behav7 = '1750_d7_s1/Behavior/SyncedBehavior.mat';
image7name = 'full_projection_m_f_max_min.fig';
save7 = 'trace_kyleFinalwDoughnut_AllBGs_matched.mat';
file7 = fullfile(base, trace7);
file7behav = fullfile(base, behav7);
image7 = fullfile(base, image7name);
file7save = fullfile(base, save7);

%Load ROI/Trace Files & Images
%Data Day 1
load(file1)
r_out1 = r_out;
clear r_out
load(file1behav)
binPuffs1=binPuffs;
binSounds1=binSounds;
binTrials1=binTrials;
%Data Day 2
load(file2)
r_out2 = r_out;
clear r_out
load(file2behav)
binPuffs2=binPuffs;
binSounds2=binSounds;
binTrials2=binTrials;
%Data Day 5
load(file5)
r_out5 = r_out;
clear r_out
load(file5behav)
binPuffs5=binPuffs;
binSounds5=binSounds;
binTrials5=binTrials;
%Data Day 7
load(file7)
r_out7 = r_out;
clear r_out
load(file7behav)
binPuffs7=binPuffs;
binSounds7=binSounds;
binTrials7=binTrials;

%Make Binary Threshold Masks
mask1 = zeros(1024,1024);
for idx=1:numel(r_out1)
    mask1(r_out1(idx).pixel_idx)=1;
end
mask2 = zeros(1024,1024);
for idx=1:numel(r_out2)
    mask2(r_out2(idx).pixel_idx)=1;
end
mask5 = zeros(1024,1024);
for idx=1:numel(r_out5)
    mask5(r_out5(idx).pixel_idx)=1;
end
mask7 = zeros(1024,1024);
for idx=1:numel(r_out7)
    mask7(r_out7(idx).pixel_idx)=1;
end

%Shift ROIs
[im2_shifted_from1, r_out2_shifted_from1] = roi_shifting(mask1, r_out1, mask2, r_out2, 'S');
[im5_shifted_from1, r_out5_shifted_from1] = roi_shifting(mask1, r_out1, mask5, r_out5, 'S');
[im7_shifted_from1, r_out7_shifted_from1] = roi_shifting(mask1, r_out1, mask7, r_out7, 'S');
[im5_shifted_from2, r_out5_shifted_from2] = roi_shifting(mask2, r_out2, mask5, r_out5, 'S');
[im7_shifted_from2, r_out7_shifted_from2] = roi_shifting(mask2, r_out2, mask7, r_out7, 'S');
[im7_shifted_from5, r_out7_shifted_from5] = roi_shifting(mask5, r_out5, mask7, r_out7, 'S');


%Line Up ROIs with Hua-an's Code
[result1_2, summary1_2] = roi_matching(r_out1, r_out2_shifted_from1, [1024, 1024], 50, 0.25);
summary1_2
[result1_5, summary1_5] = roi_matching(r_out1, r_out5_shifted_from1, [1024, 1024], 50, 0.25);
summary1_5
[result1_7, summary1_7] = roi_matching(r_out1, r_out7_shifted_from1, [1024, 1024], 50, 0.25);
summary1_7
[result2_5, summary2_5] = roi_matching(r_out2, r_out5_shifted_from2, [1024, 1024], 50, 0.25);
summary2_5
[result2_7, summary2_7] = roi_matching(r_out2, r_out7_shifted_from2, [1024, 1024], 50, 0.25);
summary2_7
[result5_7, summary5_7] = roi_matching(r_out5, r_out7_shifted_from5, [1024, 1024], 50, 0.25);
summary5_7

%Make & Plot Comparison Overlays
%Compare 1_2
match_mask1_2 = zeros(1024,1024);
for idx=1:numel(result1_2)
    if result1_2(idx).matched
        match_mask1_2(result1_2(idx).ref_pixel_idx)=1;
        match_mask1_2(result1_2(idx).test_pixel_idx)=2;
    elseif result1_2(idx).ref_only
        match_mask1_2(result1_2(idx).ref_pixel_idx)=3;
    elseif result1_2(idx).test_only
        match_mask1_2(result1_2(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask1_2); axis image; title('Overlay 1(1,3), 2(2,4)')
%Compare 1_5
match_mask1_5 = zeros(1024,1024);
for idx=1:numel(result1_5)
    if result1_5(idx).matched
        match_mask1_5(result1_5(idx).ref_pixel_idx)=1;
        match_mask1_5(result1_5(idx).test_pixel_idx)=2;
    elseif result1_5(idx).ref_only
        match_mask1_5(result1_5(idx).ref_pixel_idx)=3;
    elseif result1_5(idx).test_only
        match_mask1_5(result1_5(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask1_5); axis image; title('Overlay 1(1,3), 5(2,4)')
%Compare 1_7
match_mask1_7 = zeros(1024,1024);
for idx=1:numel(result1_7)
    if result1_7(idx).matched
        match_mask1_7(result1_7(idx).ref_pixel_idx)=1;
        match_mask1_7(result1_7(idx).test_pixel_idx)=2;
    elseif result1_7(idx).ref_only
        match_mask1_7(result1_7(idx).ref_pixel_idx)=3;
    elseif result1_7(idx).test_only
        match_mask1_7(result1_7(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask1_7); axis image; title('Overlay 1(1,3), 7(2,4)')

%Compare 2_5
match_mask2_5 = zeros(1024,1024);
for idx=1:numel(result2_5)
    if result2_5(idx).matched
        match_mask2_5(result2_5(idx).ref_pixel_idx)=1;
        match_mask2_5(result2_5(idx).test_pixel_idx)=2;
    elseif result2_5(idx).ref_only
        match_mask2_5(result2_5(idx).ref_pixel_idx)=3;
    elseif result2_5(idx).test_only
        match_mask2_5(result2_5(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask2_5); axis image; title('Overlay 2(1,3), 5(2,4)')
%Compare 2_7
match_mask2_7 = zeros(1024,1024);
for idx=1:numel(result2_7)
    if result2_7(idx).matched
        match_mask2_7(result2_7(idx).ref_pixel_idx)=1;
        match_mask2_7(result2_7(idx).test_pixel_idx)=2;
    elseif result2_7(idx).ref_only
        match_mask2_7(result2_7(idx).ref_pixel_idx)=3;
    elseif result2_7(idx).test_only
        match_mask2_7(result2_7(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask2_7); axis image; title('Overlay 2(1,3), 7(2,4)')
%Compare 5_7
match_mask5_7 = zeros(1024,1024);
for idx=1:numel(result5_7)
    if result5_7(idx).matched
        match_mask5_7(result5_7(idx).ref_pixel_idx)=1;
        match_mask5_7(result5_7(idx).test_pixel_idx)=2;
    elseif result5_7(idx).ref_only
        match_mask5_7(result5_7(idx).ref_pixel_idx)=3;
    elseif result5_7(idx).test_only
        match_mask5_7(result5_7(idx).test_pixel_idx)=4;
    end
end
figure(); imagesc(match_mask5_7); axis image; title('Overlay 5(1,3), 7(2,4)')

save('1750_d1d2d5d7_matchOverAllDays.mat', 'summary*', 'result*', 'r_out*', 'mask*', 'match_mask*', 'bin*')