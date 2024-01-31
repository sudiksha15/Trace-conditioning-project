%Code to Generate Plots from Ali's Paper
%Takes traces_*.mat and SyncedBehavior.mat as inputs.
%Assumes it's all within the present working directory

%Files to load in
baseDir =  pwd;
traceFn = 'trace_ACSAT_Autorun.mat'; %'trace_quickCircle.mat'; %'trace_KyleFinalwDoughnut.mat'; %'trace_ACSATwDoughnut.mat';
% ----- Behavior
behavDir = 'Behavior';
behavFn = 'SyncedBehavior_NoXLS.mat';

%Load data
load(fullfile(baseDir,traceFn));
load(fullfile(baseDir,behavDir,behavFn));

%Match Puff/Fluorescence length
Nf = numel(r_out(1).trace);

%Remove last puff/sound
tr_size_adjust = 0;
if numel(binSounds) > Nf
    binPuffs = binPuffs(1:Nf);
    binSounds = binSounds(1:Nf);
elseif Nf == (numel(binSounds)+1)
    tr_size_adjust=1;
end
binSounds(end) = 0;

%Get traces into matrix
raw_traces = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
raw_BG = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
traces = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
BGtraces = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
diffTraces = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
dFdiffTraces = zeros(numel(binPuffs)+tr_size_adjust,numel(r_out));
labels = zeros(1,numel(r_out));
for idx = 1:numel(r_out)
    tr = r_out(idx).trace;
    BGtr = r_out(idx).BG10trace;
    raw_traces(:,idx) = tr;
    raw_BG(:,idx) = BGtr;
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
for idx = 1:numel(indSounds)
    spot = indSounds(idx);
    if spot+160 > Nf
        sprintf('Empty Last Position')
    else
        raw(idx,:,:) = traces(spot-40:spot+160,:);
        BGraw(idx,:,:) = BGtraces(spot-40:spot+160,:);
        diffRaw(idx,:,:) = diffTraces(spot-40:spot+160,:);
        dFdiffRaw(idx,:,:) = dFdiffTraces(spot-40:spot+160,:);
    end
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
figure(1); imagesc(fullmax(:,inds)');
colorbar; colormap(jet); caxis([-.03, .03])
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
ylabel('Sorted Cell Number'); xlabel('Time (Sec)');
title('Raw without Background Adjusting');
figure(2); imagesc(BGmax(:,inds)');
colorbar; colormap(jet); caxis([-.03, .03])
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
ylabel('Sorted Cell Number'); xlabel('Time (Sec)');
title('Background');
figure(3); imagesc(fullmax(:,inds)'-BGmax(:,inds)')
colorbar; colormap(jet); caxis([-.03, .03])
set(gca(),'XTick',[1, 40, 80, 120, 160, 200])
set(gca(),'XTickLabel',[-2, 0, 2, 4, 6, 8])
hold on; plot([40,40],[0,size(fullmax,2)],':k')
plot([52,52],[0,size(fullmax,2)],'--k')
ylabel('Sorted Cell Number'); xlabel('Time (Sec)');
title('Background Adjusted');
figure(4); hold on; step=0;
for idx=1:size(traces,2)
    sel_cell = inds(idx);
    plot(traces(:,sel_cell)+step);
    text(0,mean(traces(:,sel_cell)+step),sprintf('%d',sel_cell));
    step=step+0.1;
end
plot(step*binSounds,'--k')
title('Each Cell dF/F for all Trials w/Sound Onset/Offset')

figure(1); savefig('RawFluorescence.fig');
pause(2)
figure(2); savefig('Background Traces.fig');
pause(2)
figure(3); savefig('Adjusted Background.fig');
pause(2)
figure(4); savefig('Every Cell Trace.fig');