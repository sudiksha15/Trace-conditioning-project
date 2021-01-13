%Code to plot matched cells.  Assumes that the output of Hua-ans code
%"result" and the r_out from session 1 and r_out_shifted from session 2 are
%loaded in the namespace, as well as their appropriate behavior codes with "shifted" appeneded to session 2.

%% Behavior
figure(1000); plot(binTrials);
xlim([0, numel(binTrials)])
set(gca(), 'XTick', [220, 6150, 12820, 19480, 25890], 'YTick', [-1, 1])
set(gca(), 'XTickLabel', {1, 10, 20, 30, 40}, 'YTickLabel', {'No', 'Yes'})
xlabel('Trial Number'), ylabel('Movement')
title('Ali26 Last Training')

figure(1001); plot(binTrials_shifted);
xlim([0, numel(binTrials_shifted)])
set(gca(), 'XTick', [220, 6150, 12820, 19480, 25890], 'YTick', [-1, 1])
set(gca(), 'XTickLabel', {1, 10, 20, 30, 40}, 'YTickLabel', {'No', 'Yes'})
xlabel('Trial Number'), ylabel('Movement')
title('Ali26 Extinction')

%% Line up everything to be done in loop
outs = struct();
for sess = 1:2
    if sess == 1
        r = r_out;
        bPuffs = binPuffs(1:end-1);
        bSounds = binSounds(1:end-1);
        bTrials = binTrials(1:end-1);
    elseif sess == 2
        r = r_out_shifted;
        bPuffs = binPuffs_shifted(1:end-1);
        bSounds = binSounds_shifted(1:end-1);
        bTrials = binTrials_shifted(1:end-1);
    end
    %Get traces into matrix
    outs(sess).traces = zeros(numel(bPuffs),numel(r_out));
    outs(sess).BGtraces = zeros(numel(bPuffs),numel(r_out));
    outs(sess).diffTraces = zeros(numel(bPuffs),numel(r_out));
    outs(sess).dFdiffTraces = zeros(numel(bPuffs),numel(r_out));
    %labels = zeros(1,numel(r_out));
    for idx = 1:numel(r)
        tr = r(idx).trace;
        BGtr = r(idx).BGtrace;
        outs(sess).traces(:,idx) = (tr-mean(tr))/mean(tr);
        outs(sess).BGtraces(:,idx) = (BGtr-mean(BGtr))/mean(BGtr);
        outs(sess).diffTraces(:,idx) = tr - BGtr;
        outs(sess).dFdiffTraces(:,idx) = (outs(sess).diffTraces(:,idx) - mean(outs(sess).diffTraces(:,idx)))/mean(outs(sess).diffTraces(:,idx));
        %labels(idx) = r_out(idx).isLabel;
    end
    
    %Find Sound Onsets
    indSounds = find(findPulses(bSounds) == 1);
    
    %Loop through each trial
    outs(sess).raw = zeros(numel(indSounds),201, size(outs(sess).traces,2));
    outs(sess).BGraw = zeros(numel(indSounds),201, size(outs(sess).BGtraces,2));
    outs(sess).diffRaw = zeros(numel(indSounds),201, size(outs(sess).BGtraces,2));
    outs(sess).dFdiffRaw = zeros(numel(indSounds),201, size(outs(sess).BGtraces,2));
    outs(sess).correct = false(numel(indSounds),1);
    outs(sess).incorrect = false(numel(indSounds), 1);
    for idx = 1:numel(indSounds)
        spot = indSounds(idx);
        if bTrials(spot+1) == 1
            outs(sess).correct(idx) = true;
        elseif bTrials(spot+1) == -1
            outs(sess).incorrect(idx) = true;
        end
        outs(sess).raw(idx,:,:) = outs(sess).traces(spot-40:spot+160,:);
        outs(sess).BGraw(idx,:,:) = outs(sess).BGtraces(spot-40:spot+160,:);
        outs(sess).diffRaw(idx,:,:) = outs(sess).diffTraces(spot-40:spot+160,:);
        outs(sess).dFdiffRaw(idx,:,:) = outs(sess).dFdiffTraces(spot-40:spot+160,:);
    end
    %Project across all traces
    outs(sess).fullmax = squeeze(mean(outs(sess).raw,1));
    outs(sess).BGmax = squeeze(mean(outs(sess).BGraw,1));
    outs(sess).diffMax = squeeze(mean(outs(sess).diffRaw,1));
    outs(sess).dFdiffMax = squeeze(mean(outs(sess).dFdiffRaw,1));
    outs(sess).mean2s = zeros(size(outs(sess).fullmax,2),1);
    for idx = 1:size(outs(sess).fullmax,2)
        outs(sess).mean2s(idx) = mean(outs(sess).fullmax(41:81,idx));
    end
    [~, outs(sess).inds] = sort(outs(sess).mean2s);
end

%Plot all cells for each session
figure(1); imagesc(outs(1).fullmax(:,outs(1).inds)'-outs(1).BGmax(:,outs(1).inds)')
colorbar; colormap(jet); caxis([-.01, .05])
title('Ali 26 D5 S1')

figure(2); imagesc(outs(2).fullmax(:,outs(2).inds)'-outs(2).BGmax(:,outs(2).inds)')
colorbar; colormap(jet); caxis([-.01, .05])
title('Ali 26 D5 S2')

%% Pulled out match inds and do Matching Only
Nmatched = sum([result(:).matched]);
outs(1).IDs = [result(1:Nmatched).ref_id];
outs(2).IDs = [result(1:Nmatched).test_id];

for sess = 1:2
    outs(sess).raw_matched = outs(sess).raw(:,:,outs(sess).IDs);
    outs(sess).BGraw_matched = outs(sess).BGraw(:,:,outs(sess).IDs);
    outs(sess).fullmax_matched = squeeze(mean(outs(sess).raw_matched,1));
    outs(sess).BGmax_matched = squeeze(mean(outs(sess).BGraw_matched,1));
    outs(sess).mean2s_matched = zeros(size(outs(sess).fullmax_matched,2),1);
    for idx = 1:size(outs(sess).fullmax_matched,2)
        outs(sess).mean2s_matched(idx) = mean(outs(sess).fullmax_matched(41:81,idx));
    end
    [~, outs(sess).inds_matched] = sort(outs(sess).mean2s_matched);
end

%Plot matched cells
figure(3); imagesc(outs(1).fullmax_matched(:,outs(1).inds_matched)'-outs(1).BGmax_matched(:,outs(1).inds_matched)')
colorbar; colormap(jet); caxis([-.05, .05])
xlim([0,201])
set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
hold on; plot([40,40],[0,Nmatched],':k')
plot([52,52],[0,Nmatched],'--k')
ylabel('Cell Number'); xlabel('Time (sec)')
title('Ali 26 D5 S1 Matched')

figure(4); imagesc(outs(2).fullmax_matched(:,outs(1).inds_matched)'-outs(2).BGmax_matched(:,outs(1).inds_matched)')
colorbar; colormap(jet); caxis([-.05, .05])
xlim([0,201])
set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
hold on; plot([40,40],[0,Nmatched],':k')
plot([52,52],[0,Nmatched],'--k')
ylabel('Cell Number'); xlabel('Time (sec)')
title('Ali 26 D5 S2 Matched S1 Sorted')

figure(5); imagesc(outs(1).fullmax_matched(:,outs(2).inds_matched)'-outs(1).BGmax_matched(:,outs(2).inds_matched)')
colorbar; colormap(jet); caxis([-.05, .05])
xlim([0,201])
set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
hold on; plot([40,40],[0,Nmatched],':k')
plot([52,52],[0,Nmatched],'--k')
ylabel('Cell Number'); xlabel('Time (sec)')
title('Ali 26 D5 S1 Matched S2 Sorted')

figure(6); imagesc(outs(2).fullmax_matched(:,outs(2).inds_matched)'-outs(2).BGmax_matched(:,outs(2).inds_matched)')
colorbar; colormap(jet); caxis([-.05, .05])
xlim([0,201])
set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
hold on; plot([40,40],[0,Nmatched],':k')
plot([52,52],[0,Nmatched],'--k')
ylabel('Cell Number'); xlabel('Time (sec)')
title('Ali 26 D5 S2 Matched')

%% Look at bottom 10 cells in both cases
fignum = 101;
%Individual Cells by own session sorting
for sess = 1:2
    outs(sess).bot10inds = outs(sess).inds_matched(end-9:end);
    for idx = 1:numel(outs(sess).bot10inds)
        figure(fignum); hold on;
        cellind = outs(sess).bot10inds(idx);
        for trial = 1:10
            subplot(1,4,1); hold on;
            plot(outs(sess).raw_matched(trial,:,cellind)-outs(sess).BGraw_matched(trial,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,2); hold on;
            plot(outs(sess).raw_matched(trial+10,:,cellind)-outs(sess).BGraw_matched(trial+10,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,3); hold on;
            plot(outs(sess).raw_matched(trial+20,:,cellind)-outs(sess).BGraw_matched(trial+20,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,4); hold on;
            plot(outs(sess).raw_matched(trial+30,:,cellind)-outs(sess).BGraw_matched(trial+30,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
        end
        subplot(1,4,1);
        plot(mean(outs(sess).raw_matched(1:10,:,cellind)-outs(sess).BGraw_matched(1:10,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,2); hold on;
        plot(mean(outs(sess).raw_matched(11:20,:,cellind)-outs(sess).BGraw_matched(11:20,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,3); hold on;
        plot(mean(outs(sess).raw_matched(21:30,:,cellind)-outs(sess).BGraw_matched(21:30,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,4); hold on;
        plot(mean(outs(sess).raw_matched(31:40,:,cellind)-outs(sess).BGraw_matched(31:40,:,cellind),1),'color',[1,0,0]);
        suptitle(sprintf('Session S%d Cell %d Own Sorting', sess, idx)); %Suptitle exists in Bioinformatics toolbox
        set(gcf(), 'Position', [1545, 1000, 2500, 650])
        pause(.5)
        fignum = fignum+1;
    end
end
%Individual Cells by other session sorting
for sess = 1:2
    for idx = 1:numel(outs(sess).bot10inds)
        figure(fignum); hold on;
        if sess == 1
            cellind = outs(2).bot10inds(idx);
        elseif sess == 2
            cellind = outs(1).bot10inds(idx);
        end
        for trial = 1:10
            subplot(1,4,1); hold on;
            plot(outs(sess).raw_matched(trial,:,cellind)-outs(sess).BGraw_matched(trial,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,2); hold on;
            plot(outs(sess).raw_matched(trial+10,:,cellind)-outs(sess).BGraw_matched(trial+10,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,3); hold on;
            plot(outs(sess).raw_matched(trial+20,:,cellind)-outs(sess).BGraw_matched(trial+20,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,4); hold on;
            plot(outs(sess).raw_matched(trial+30,:,cellind)-outs(sess).BGraw_matched(trial+30,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
        end
        subplot(1,4,1);
        plot(mean(outs(sess).raw_matched(1:10,:,cellind)-outs(sess).BGraw_matched(1:10,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,2); hold on;
        plot(mean(outs(sess).raw_matched(11:20,:,cellind)-outs(sess).BGraw_matched(11:20,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,3); hold on;
        plot(mean(outs(sess).raw_matched(21:30,:,cellind)-outs(sess).BGraw_matched(21:30,:,cellind),1),'color',[1,0,0]);
        subplot(1,4,4); hold on;
        plot(mean(outs(sess).raw_matched(31:40,:,cellind)-outs(sess).BGraw_matched(31:40,:,cellind),1),'color',[1,0,0]);
        suptitle(sprintf('Session S%d Cell %d Other Sorting', sess, idx)); %Suptitle exists in Bioinformatics toolbox
        set(gcf(), 'Position', [1545, 350, 2500, 650])
        pause(.5)
        fignum = fignum+1;
    end
end

%Average across 10 cells & 10 trials per session
height = [1000, 350];
for sess = 1:2 %Sorting based on High Performance Learning Day
    bot10inds = outs(1).bot10inds;
    figure(6+sess); hold on;
    subplot(1,4,1); hold on;
    plot(mean(mean(outs(sess).raw_matched(1:10,:,bot10inds)-outs(sess).BGraw_matched(1:10,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,2); hold on;
    plot(mean(mean(outs(sess).raw_matched(11:20,:,bot10inds)-outs(sess).BGraw_matched(11:20,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,3); hold on;
    plot(mean(mean(outs(sess).raw_matched(21:30,:,bot10inds)-outs(sess).BGraw_matched(21:30,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,4); hold on;
    plot(mean(mean(outs(sess).raw_matched(31:40,:,bot10inds)-outs(sess).BGraw_matched(31:40,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    suptitle(sprintf('Session S%d High Performance Sorting', sess)); %Suptitle exists in Bioinformatics toolbox
    set(gcf(), 'Position', [1545, height(sess), 2500, 650])
end
for sess = 1:2 %Sorting based on Extinction Day
    bot10inds = outs(2).bot10inds;
    figure(8+sess); hold on;
    subplot(1,4,1); hold on;
    plot(mean(mean(outs(sess).raw_matched(1:10,:,bot10inds)-outs(sess).BGraw_matched(1:10,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,2); hold on;
    plot(mean(mean(outs(sess).raw_matched(11:20,:,bot10inds)-outs(sess).BGraw_matched(11:20,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,3); hold on;
    plot(mean(mean(outs(sess).raw_matched(21:30,:,bot10inds)-outs(sess).BGraw_matched(21:30,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    subplot(1,4,4); hold on;
    plot(mean(mean(outs(sess).raw_matched(31:40,:,bot10inds)-outs(sess).BGraw_matched(31:40,:,bot10inds),3),1),'color',[1,0,0]);
    ylim([-.02, .15])
    suptitle(sprintf('Session S%d Extinction Sorting', sess)); %Suptitle exists in Bioinformatics toolbox
    set(gcf(), 'Position', [1545, height(sess), 2500, 650])
end

%3 Example Cells
HPex = [outs(1).bot10inds(1), outs(1).bot10inds(5), outs(1).bot10inds(9)];
EXex = [outs(2).bot10inds(4), outs(2).bot10inds(8), outs(2).bot10inds(10)];
%Plot individual traces per trial
fignum = 11;
for sess = 1:2 %High Performance Learning Day
    for idx = 1:numel(HPex)
        cellind = HPex(idx);
        figure(fignum); hold on;
        for trial = 1:10
            subplot(1,4,1); hold on;
            plot(outs(sess).raw_matched(trial,:,cellind)-outs(sess).BGraw_matched(trial,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,2); hold on;
            plot(outs(sess).raw_matched(trial+10,:,cellind)-outs(sess).BGraw_matched(trial+10,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,3); hold on;
            plot(outs(sess).raw_matched(trial+20,:,cellind)-outs(sess).BGraw_matched(trial+20,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,4); hold on;
            plot(outs(sess).raw_matched(trial+30,:,cellind)-outs(sess).BGraw_matched(trial+30,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
        end
        subplot(1,4,1);
        plot(mean(outs(sess).raw_matched(1:10,:,cellind)-outs(sess).BGraw_matched(1:10,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,2); hold on;
        plot(mean(outs(sess).raw_matched(11:20,:,cellind)-outs(sess).BGraw_matched(11:20,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,3); hold on;
        plot(mean(outs(sess).raw_matched(21:30,:,cellind)-outs(sess).BGraw_matched(21:30,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,4); hold on;
        plot(mean(outs(sess).raw_matched(31:40,:,cellind)-outs(sess).BGraw_matched(31:40,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        suptitle(sprintf('Session %d Cell %d High Performance', sess, idx)); %Suptitle exists in Bioinformatics toolbox
        set(gcf(), 'Position', [1545, height(sess), 2500, 650])
        fignum=fignum+1;
    end
end
for sess = 1:2 %High Performance Learning Day
    for idx = 1:numel(EXex)
        cellind = EXex(idx);
        figure(fignum); hold on;
        for trial = 1:10
            subplot(1,4,1); hold on;
            plot(outs(sess).raw_matched(trial,:,cellind)-outs(sess).BGraw_matched(trial,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,2); hold on;
            plot(outs(sess).raw_matched(trial+10,:,cellind)-outs(sess).BGraw_matched(trial+10,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,3); hold on;
            plot(outs(sess).raw_matched(trial+20,:,cellind)-outs(sess).BGraw_matched(trial+20,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
            subplot(1,4,4); hold on;
            plot(outs(sess).raw_matched(trial+30,:,cellind)-outs(sess).BGraw_matched(trial+30,:,cellind),'color',[.5,.5,.5,.4]); %Last Value is Alpha
        end
        subplot(1,4,1);
        plot(mean(outs(sess).raw_matched(1:10,:,cellind)-outs(sess).BGraw_matched(1:10,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,2); hold on;
        plot(mean(outs(sess).raw_matched(11:20,:,cellind)-outs(sess).BGraw_matched(11:20,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,3); hold on;
        plot(mean(outs(sess).raw_matched(21:30,:,cellind)-outs(sess).BGraw_matched(21:30,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        subplot(1,4,4); hold on;
        plot(mean(outs(sess).raw_matched(31:40,:,cellind)-outs(sess).BGraw_matched(31:40,:,cellind),1),'color',[1,0,0]);
        ylim([-.1, .5])
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Calcium dF/F'); xlabel('Time (sec)')
        if sess == 1
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
            patch([53,54,54,53],[-.1, -.1, .5, .5],[1,.65,0],'FaceAlpha',0.2,'EdgeColor','none')
        elseif sess == 2
            patch([41,47,47,41],[-.1, -.1, .5, .5],[1,0,1],'FaceAlpha',0.1,'EdgeColor','none')
        end
        suptitle(sprintf('Session %d Cell %d Extinction', sess, idx)); %Suptitle exists in Bioinformatics toolbox
        set(gcf(), 'Position', [1545, height(sess), 2500, 650])
        fignum=fignum+1;
    end
end

%Example Cells Plot Heatmaps of all trials in time.
fignum = 23;
for sess = 1:2 %High Performance Learning Day
    for idx = 1:numel(HPex)
        cellind = HPex(idx);
        figure(fignum);
        imagesc(outs(sess).raw_matched(:,:,cellind)-outs(sess).BGraw_matched(:,:,cellind))
        colorbar; colormap(jet); caxis([-.1, .5])
        title(sprintf('Session %d Cell %d High Performance', sess, idx));
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Trial Number'); xlabel('Time (sec)')
        fignum=fignum+1;
    end
end
for sess = 1:2 %High Performance Learning Day
    for idx = 1:numel(EXex)
        cellind = EXex(idx);
        figure(fignum);
        imagesc(outs(sess).raw_matched(:,:,cellind)-outs(sess).BGraw_matched(:,:,cellind))
        colorbar; colormap(jet); caxis([-.1, .5])
        title(sprintf('Session %d Cell %d High Extinction', sess, idx));
        xlim([0,201])
        set(gca(), 'XTick', [1, 41, 81, 121, 161, 201])
        set(gca(), 'XTickLabel', {'-2','0','2','4','6','8'})
        ylabel('Trial Number'); xlabel('Time (sec)')
        fignum=fignum+1;
    end
end

%% Saving Code
filenames = {'Ali26HPLastTrainingCell1', 'Ali26HPLastTrainingCell2', 'Ali26HPLastTrainingCell3', ...
    'Ali26HPExtinctionCell1', 'Ali26HPExtinctionCell2', 'Ali26HPExtinctionCell3', ...
    'Ali26EXLastTrainingCell1', 'Ali26EXLastTrainingCell2', 'Ali26EXLastTrainingCell3', ...
    'Ali26EXExtinctionCell1', 'Ali26EXExtinctionCell2', 'Ali26EXExtinctionCell3', ...
    'Ali26HPLastTrainingAllTrialsCell1', 'Ali26HPLastTrainingAllTrialsCell2', 'Ali26HPLastTrainingAllTrialsCell3', ...
    'Ali26HPExtinctionAllTrialsCell1', 'Ali26HPExtinctionAllTrialsCell2', 'Ali26HPExtinctionAllTrialsCell3', ...
    'Ali26EXLastTrainingAllTrialsCell1', 'Ali26EXLastTrainingAllTrialsCell2', 'Ali26EXLastTrainingAllTrialsCell3', ...
    'Ali26EXExtinctionAllTrialsCell1', 'Ali26EXExtinctionAllTrialsCell2', 'Ali26EXExtinctionAllTrialsCell3'};
for idx = 11:22
    set(figure(idx), 'PaperOrientation', 'Landscape', 'PaperUnits', 'inches', 'PaperSize', [30, 10])
    saveas(figure(idx), filenames{idx-10}, 'fig')
    print(figure(idx), filenames{idx-10}, '-dpdf')
end
for idx = 23:34
    saveas(figure(idx), filenames{idx-10}, 'fig')
    print(figure(idx), filenames{idx-10}, '-dpdf','-bestfit')
end

behav_filenames = {'Ali26LastTrainingBehavior', 'Ali26ExtinctionBehavior'};
for idx = 1000:1001
    saveas(figure(idx), behav_filenames{idx-999}, 'fig')
    print(figure(idx), behav_filenames{idx-999}, '-dpdf','-bestfit')
end

match_filenames = {'Ali26LastTrainingCells_LTSort', 'Ali26ExtinctionCells_LTSort',...
    'Ali26LastTrainingCells_EXSort', 'Ali26ExtinctionCells_EXSort'};
for idx = 3:6
    saveas(figure(idx), match_filenames{idx-2}, 'fig')
    print(figure(idx), match_filenames{idx-2}, '-dpdf','-bestfit')
end
