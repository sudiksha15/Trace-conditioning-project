%Code to Generate Plots from Ali's Paper
%Takes traces_*.mat and SyncedBehavior.mat as inputs.

%Input Info
% % ----- Ali24 d5 s1
% baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s1/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% % ----- Ali24 d5 s2
% baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s2/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% % ----- Ali25 d5 s1
% baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali25_d5_s1/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% % ----- Ali25 d5 s2
% baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali25_d5_s2/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% % ----- Ali26 d2 s1
% baseDir =   '/home/kyleh/ProcessedVideos/Ali26_d2_s1/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% % -----Ali26 d5 s1
% baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s1/';
% traceFn = 'trace_kyleFinalwDoughnut.mat';
% -----Ali26 d5 s2
baseDir =   '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s2/';
traceFn = 'trace_kyleFinalwDoughnut.mat';
% % ----- Moona Mouse
% baseDir =   '/mnt/eng_research_handata/Kyle/MoonaPVLabel/Mouse4254/02182017s1_Day3/ProcessedData/'; 
% traceFn = 'Images/MotionCorrected/trace_MoonaLabelledwDoughnut.mat'; 
% ----- Behavior
behavDir = 'Behavior';
behavFn = 'SyncedBehavior.mat';

%Load data
load(fullfile(baseDir,traceFn));
load(fullfile(baseDir,behavDir,behavFn));
saveOut = 0;  %If 1, save output

%Remove last puff/sound
binPuffs = binPuffs(1:end);%-1);
binSounds = binSounds(1:end);%-1);

%Get traces into matrix
traces = zeros(numel(binPuffs),numel(r_out));
BGtraces = zeros(numel(binPuffs),numel(r_out));
diffTraces = zeros(numel(binPuffs),numel(r_out));
dFdiffTraces = zeros(numel(binPuffs),numel(r_out));
labels = zeros(1,numel(r_out));
for idx = 1:numel(r_out)
    tr = r_out(idx).trace(1:end-1);
    BGtr = r_out(idx).BGtrace(1:end-1);
    traces(:,idx) = (tr-mean(tr))/mean(tr);
    BGtraces(:,idx) = (BGtr-mean(BGtr))/mean(BGtr);
    diffTraces(:,idx) = tr - BGtr;
    dFdiffTraces(:,idx) = (diffTraces(:,idx) - mean(diffTraces(:,idx)))/mean(diffTraces(:,idx));
    %labels(idx) = r_out(idx).isLabel;
end

%Find Sound Onsets
indSounds = find(findPulses(binSounds) == 1);

%Loop through each trial
raw = zeros(numel(indSounds),201, size(traces,2));
BGraw = zeros(numel(indSounds),201, size(BGtraces,2));
diffRaw = zeros(numel(indSounds),201, size(BGtraces,2));
dFdiffRaw = zeros(numel(indSounds),201, size(BGtraces,2));
%correct = false(numel(indSounds),1);
%incorrect = false(numel(indSounds), 1);
for idx = 1:numel(indSounds)
    spot = indSounds(idx);
%    if binTrials(spot+1) == 1
%        correct(idx) = true;
%    elseif binTrials(spot+1) == -1
%        incorrect(idx) = true;
%    end
    raw(idx,:,:) = traces(spot-40:spot+160,:);
    BGraw(idx,:,:) = BGtraces(spot-40:spot+160,:);
    diffRaw(idx,:,:) = diffTraces(spot-40:spot+160,:);
    dFdiffRaw(idx,:,:) = dFdiffTraces(spot-40:spot+160,:);
end
%Project across all traces
fullmax = squeeze(mean(raw,1));
BGmax = squeeze(mean(BGraw,1));
diffMax = squeeze(mean(diffRaw,1));
dFdiffMax = squeeze(mean(dFdiffRaw,1));
mean2s = zeros(size(fullmax,2),1);
for idx = 1:size(fullmax,2)
    mean2s(idx) = mean(fullmax(41:81,idx));
end
[~, inds] = sort(mean2s);
figure(); imagesc(fullmax(:,inds)');
colorbar; colormap(jet); caxis([-.03, .03])
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
figure(); imagesc(BGmax(:,inds)');
colorbar; colormap(jet); caxis([-.03, .03])
figure(); imagesc(diffMax(:,inds)');
colorbar; colormap(jet); %caxis([-.03, .03])
figure(); imagesc(dFdiffMax(:,inds)');
colorbar; colormap(jet); %caxis([-.03, .03])
figure(); imagesc(fullmax(:,inds)'-BGmax(:,inds)')
colorbar; colormap(jet); caxis([-.03, .03])
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
ylabel('Sorted Cell Number'); xlabel('Time (Sec)');
title('Third Learning Day');

%Break down to correct and incorrect traces
ctraces = raw(correct,:,:);
itraces = raw(incorrect,:,:);
cmax = squeeze(mean(ctraces,1));
imax = squeeze(mean(itraces,1));
cmean2s = zeros(size(cmax,2),1);
imean2s = zeros(size(imax,2),1);
for idx = 1:size(cmax,2)
    cmean2s(idx) = mean(cmax(41:81,idx));
end
for idx = 1:size(imax,2)
    imean2s(idx) = mean(imax(41:81,idx));
end
%Find Order
[~, cinds] = sort(cmean2s);
[~, iinds] = sort(imean2s);

figure(6); imagesc(cmax(:,cinds)')
colorbar; colormap(jet); caxis([-.1,.25])
title('Correct n=31')
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
figure(7); imagesc(imax(:,iinds)')
colorbar; colormap(jet); caxis([-.1,.25])
title('Incorrect n=9')
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')


%% Make Output for Bobak's Project
% if saveOut
%     outLoc = '/home/kyleh/Documents/Networks/ProjectData/';
%     doughnutTraces = raw-BGraw;
%     for idx = 1:size(doughnutTraces,1)
%         fn = sprintf('fluorescence_%d_ali26d5s2.txt',idx);
%         dlmwrite(fullfile(outLoc,fn), squeeze(doughnutTraces(idx,:,:)));
%     end
% end
