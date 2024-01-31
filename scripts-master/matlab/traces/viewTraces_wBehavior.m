%Script to simultaneously look at traces and behavior

%% Load Data
%Input Info
baseDir = '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali26_d5_s1/';
behavDir = 'Behavior';
traceFn = 'trace_kyleFinal.mat';
behavFn = 'SyncedBehavior.mat';

%Load data
load(fullfile(baseDir,traceFn));
load(fullfile(baseDir,behavDir,behavFn));

%% Massage Data
%Assume structure of traces is r_out
allTraces_dFoF = zeros(numel(r_out(1).trace),numel(r_out)); %rows=time cols=#Cells
for idx = 1:numel(r_out)
    [allTraces_dFoF(:,idx),~] = calcdFoF(r_out(idx).trace, 20, [0.25, 0.75, 60]);
end

%Time Window for Images
beforeSound = 40; %2 seconds before
afterSound = 160; %8 seconds after

%Pull out data
correctInds = find(findPulses(binTrials == 1) == 1) + 1; %Sound onset Inds for Correct
incorrectInds = find(findPulses(binTrials == -1) == 1) + 1; %Sound onset Inds for Incorrect

%% Create Plots
%Correct
for idx = 1:numel(correctInds)
    curInd = correctInds(idx);
    correctTraces = allTraces_dFoF((curInd-beforeSound):(curInd+afterSound),:);
    figure(); %Heatmap
    imagesc(correctTraces')
    colormap('jet')
    colorbar
    caxis([-.15, .40])
    title(sprintf('Correct %d',idx));
%     figure(); %Stacked
%     hold on;
%     baseline = 0;
%     for ind = 1:size(allTraces_dFoF,2)
%         plot(correctTraces(:,ind)+baseline);
%         baseline = baseline + 1;
%     end
end

%Incorrect
for idx = 1:numel(incorrectInds)
    curInd = incorrectInds(idx);
    if curInd < beforeSound
        incorrectTraces = allTraces_dFoF(1:(curInd+afterSound),:);
    elseif curInd+afterSound > size(allTraces_dFoF,1)
        incorrectTraces = allTraces_dFoF((curInd-beforeSound):end,:);
    else
        incorrectTraces = allTraces_dFoF((curInd-beforeSound):(curInd+afterSound),:);
    end
    figure(); %Heatmap
    imagesc(incorrectTraces')
    colormap('jet')
    colorbar
    caxis([-.15, .40])
    title(sprintf('Incorrect %d',idx));
end