%% Behavior Trial Responses
%Hard coded for Ali26 Last day of Training (LT) and Extinction (EX)
LTMove = [1, 3:5, 7, 10:15, 17:19, 21:25, 27:36, 38:39];
LTNoMove = setdiff([1:40], LTMove);
EXMove = [3:13, 15:20, 23, 25];
EXNoMove = setdiff([1:40],EXMove);

%% Figure Manipulation
defaultLoc = '\\engnas.ad.bu.edu\Research\eng_research_handata\Kyle\AliEyeBlink\SFN_Figures'; 
figLoc = uigetfile(fullfile(defaultLoc,'.fig'),'Select Matlab Fig file');
typeSelection = questdlg('Last Training or Extinction Figure?', 'Select Type', 'Last Training', 'Extinction', 'Last Training');

%Pick Appropriate Indicies
if strcmp(typeSelection, 'Last Training')
    Move = LTMove;
    NoMove = LTNoMove;
    MCol = [0,0,0];
    NMCol = [1,0,0];
elseif strcmp(typeSelection, 'Extinction')
    Move = EXMove;
    NoMove = EXNoMove;
    MCol = [0,1,0];
    NMCol = [0,0,1];
end

%Open Figure and extract data
figH = openfig(fullfile(defaultLoc, figLoc));
ax = gca();
imgData = ax.Children.CData;
Ntrials = size(imgData,1);
Nsamples = size(imgData,2);

%Sort heatmap, add lines, and zoom in
sortData = [imgData(Move,:); imgData(NoMove,:)];
trialID = zeros(Ntrials,1,3); %ID Color Map
for idx = 1:Ntrials
    if idx <= numel(Move)
        trialID(idx,:,:) = MCol;
    elseif idx > Ntrials-numel(NoMove)
        trialID(idx,:,:) = NMCol;
    end
end

figure();
axID = subplot(1,2,1); %Colors for Trial Type
image(trialID);
set(axID, 'XTick', [], 'YTick', [], 'Position', [0.12, 0.1, .02, 0.82]);
axData = subplot(1,2,2); %Trial Traces
imagesc(sortData);
xlim([20,80])
set(axData, 'XTick', [20, 40, 60, 80], 'XTickLabel', [-1, 0, 1, 2], 'YTick', [], 'Position', [0.16, 0.1, 0.8, 0.82]);
colorbar; colormap(jet); caxis([-.1, 0.5]);
hold on; %Sound & Puff
plot([40,40], [0,Ntrials],':k')
plot([52,52], [0,Ntrials],'--k')

%Plot Average & Std of Trial Types
samps = [1:Nsamples]';
meanMove = mean(imgData(Move,:))';
stdMove = std(imgData(Move,:))';
meanNoMove = mean(imgData(NoMove,:))';
stdNoMove = std(imgData(NoMove,:))';

figure(); hold on;
fill([samps;flipud(samps)], [meanMove-stdMove;flipud(meanMove+stdMove)], MCol, 'linestyle','none','facealpha',0.15);
plot(samps, meanMove, 'color', MCol);
fill([samps;flipud(samps)], [meanNoMove-stdNoMove;flipud(meanNoMove+stdNoMove)], NMCol, 'linestyle','none','facealpha',0.15);
plot(samps, meanNoMove, 'color', NMCol);
plot([40,40], [-0.2,0.3],':k')
plot([52,52], [-0.2,0.3],'--k')
xlim([20, 80])
ylim([-0.1, 0.25])
set(gca(), 'XTick', [20, 40, 60, 80], 'XTickLabels', [-1, 0, 1, 2])

