%Script to pull out behavioral timing data, specifically for eyeblink experiments

%Determine which filetype to use
raw_behavior_type = questdlg('What is the data type for your Behavioral Data?','Select Data Type', 'TDT', 'ABF', 'TDT');
addpath('../utilities') %Add utilities folder to path for "FindPulses." Assumes starting in /scripts/matlab/behavior directory
if strcmp(raw_behavior_type, 'TDT')
    addpath('TDTbin2mat') %Add TDT SDK to Path.  Assumes starting in /scripts/matlab/behavior directory
    [frames, puffs, sounds, load_path] = tdtload(pwd);
elseif strcmp(raw_behavior_type, 'ABF')
    %Find and extract behavior data from ABF files
    [abf_file, load_path] = uigetfile('.abf', 'Select .abf File to Open');
    [d, si, h] = abfload(fullfile(load_path,abf_file));
    frames = d(:,1);  sounds = d(:,2);  puffs = d(:,3);
end

%Force fixed difference between tone-puff based on puff (Mainly For
%Ali24_d2_s1 & Ali25_d2_s1)
fixed_tp_window = 'No';
%fixed_tp_window = questdlg('Fixed Tone Window Offset from Puff?','Enforce Fixed Tone-Puff Window?', 'Yes', 'No', 'No');

%Tone Only to Address if no Puffs
tone_only = 'No';
%tone_only = questdlg('Only Tone in Experiment?', 'Tone Only?', 'Yes', 'No', 'No');
%tone_only_trial_length = 14;

%Drop artifact for 1750_d10_s1 from unplugging Sound for 5 Trials
drop_artifact = 'No';
%drop_artifact = questdlg('Drop 19554 Artifact?', 'Drop Artifact?', 'Yes', 'No', 'No');

%Find ttl pulse locations for frames using findPulses utility function
locFrames = findPulses(frames);

%Find pulse onsets & offsets
onFrames = locFrames == 1;
offFrames = locFrames == -1;

%Get indexes of frames to adjust everything by
indFrames = find(onFrames==1);
off_indFrames = find(offFrames==1);

%Determine how many behavior samples occur between frames on average
%(assume in ms) If this is equal to 50, then the file sampling rate=1000 Hz
samplingDiff = mean(diff(indFrames));

%Shift all values for traces to be equal to the video lengths
vidExtentFrames = frames(indFrames(1):off_indFrames(end));  
vidExtentPuffs = puffs(indFrames(1):off_indFrames(end));

%Find Video Frame Locations
locVidFrames = findPulses(vidExtentFrames) == -1; %Pick end of frame as index in case sound comes on during frame.

%Make Puff Vector
vidFrames = vidExtentFrames(locVidFrames);
vidPuffs = vidExtentPuffs(locVidFrames);

%Create Binary Puff Vector
binPuffs = squareWaveAnalog(vidPuffs, 10, 0.05);

%Find Puff locations 
indPuffs = find(findPulses(binPuffs) == 1);

%Do the Same for Sounds from Video if Sounds were Recorded, if not make
%fixed Binary Vector
if ~isempty(sounds) && strcmp(fixed_tp_window, 'No')
    vidExtentSounds = sounds(indFrames(1):off_indFrames(end)); %Equal Video Length
    vidSounds = vidExtentSounds(locVidFrames); %Make Sound vector from frames
    %Make Square for Binarization
    if strcmp(raw_behavior_type, 'ABF')
        windSize = 200;
        frac = 0.02;
    else
        windSize = 10;
        frac = 0.2; %0.05; %Can use 0.05 if session doesn't have tone-puff switch during session
    end
    squareSounds = squareWaveAnalog(sounds, windSize, frac); %Square wave of Analog Signal
    squareExtentSounds = squareSounds(indFrames(1):off_indFrames(end)); %Equal Video Length
    squareVidSounds = squareExtentSounds(locVidFrames); %Make Sound vector from frames
    binSounds = (squareVidSounds - max(squareVidSounds)/2) > 0;
    indSounds = find(findPulses(binSounds) == 1);
elseif strcmp(fixed_tp_window, 'Yes')
    indSounds = indPuffs - 12; %600ms (12 data points at 20 Hz) between begin of sound and begin of puff
    binSounds = zeros(size(binPuffs));
    for idx = 1:numel(indSounds)
        binSounds(indSounds(idx):indSounds(idx)+6) = 1; %Sound is 350ms long (7 data points at 20 Hz)
    end
    binSounds = logical(binSounds);
end

%Find number of trials
numSounds = sum(findPulses(binSounds) == -1); %Determine Sound Off as Counting a Trial
numPuffs = sum(findPulses(binPuffs) == -1); %Determine Puff Off as Counting a Tria
soundWindow = ceil(sum(binSounds)/numSounds); %Window for Moving Sum of Sounds
puffWindow = ceil(sum(binPuffs)/numPuffs); %Window for Moving Sum of Puffs

%% Mouse behavior from eyeblink videos
behav_select = questdlg('What format is your behavior data?','Behavior Data', 'Excel', 'BinaryVideo', 'None', 'None');
if strcmp(behav_select, 'BinaryVideo') %Binary Eye Video Behavior
    %Parameters for loading videos
    eye_video_name = '2712_d7_f.tif';
    %pupil_video_name = 'binary_pupil_trace_sudi.tif';
    dir_parts = split(load_path, '/');
    %behav_base_path = fullfile('/', dir_parts{1:end-1});
    behav_base_path = fullfile('/', dir_parts{1:end-2});
    %Eye Videos
    %Load metadata
    full_eye_name = fullfile(behav_base_path, eye_video_name);
    eye_info = imfinfo(full_eye_name);
    N_images = numel(eye_info);
    img_height = eye_info(1).Height;
    img_width = eye_info(1).Width;
    full_eye_stack = zeros(img_height, img_width, N_images, 'uint8');
    eye_trace = zeros(N_images,1);
    TifLink = Tiff(full_eye_name, 'r');
    max_val = 255; %Normalization of Binary Trace
    %Loop & Load Images
    sprintf('Loading Eye Video')
    for idx = 1:N_images
        TifLink.setDirectory(idx);
        cur_frame = TifLink.read(); %imread(full_eye_name, idx, 'Info', eye_info);
        img_sum = double(sum(sum(cur_frame))) / max_val;
        full_eye_stack(:,:,idx) = cur_frame;
        eye_trace(idx) = img_sum;
    end
    TifLink.close();
    %Pupil Videos
    %Load metadata
%     full_pupil_name = fullfile(behav_base_path, pupil_video_name);
%     pupil_info = imfinfo(full_pupil_name);
%     N_images = numel(pupil_info);
%     img_height = pupil_info(1).Height;
%     img_width = pupil_info(1).Width;
%     full_pupil_stack = zeros(img_height, img_width, N_images, 'uint8');
%     pupil_trace = zeros(N_images,1);
%     TifLink = Tiff(full_pupil_name, 'r');
%     max_val = 255; %Normalization of Binary Trace
%     %Loop & Load Images
%     sprintf('Loading Pupil Video')
%     for idx = 1:N_images
%         TifLink.setDirectory(idx);
%         cur_frame = TifLink.read(); %imread(full_pupil_name, idx, 'Info', pupil_info);
%         img_sum = double(sum(sum(cur_frame))) / max_val;
%         full_pupil_stack(:,:,idx) = cur_frame;
%         pupil_trace(idx) = img_sum;
%     end
%     TifLink.close();
    
    %Find and label each trial
    indSoundOn = find(findPulses(binSounds) == 1);
    if strcmp(drop_artifact, 'Yes')
        indSoundOn = indSoundOn(indSoundOn ~= 19554);
    end
    if strcmp(tone_only, 'Yes')
        indPuffOff = indSoundOn + tone_only_trial_length;
    else
        indPuffOff = find(findPulses(binPuffs) == -1);
    end
    binTrials = zeros(size(binSounds));
    [minDiff, matchIdx] = min(abs(indPuffOff(1)-indSoundOn)); 
    trialSize = minDiff - 1; %Subtract 1 to have equal indexing sizes
    if indSoundOn(end) == numel(binSounds) %If Last part is a tone with no puff
        soundSelect = indSoundOn(1:end-1); %Select all but last one
    else
        soundSelect = indSoundOn;
    end
    %Deal with Trials with Sound turned on/off mid-trial
    max_diff_vals = 40; %2 seconds as max between tone-puff
    sound_idx = 1;
    puff_idx = 1;
    for idx = 1:numel(soundSelect)
        behav = 2; %Use to demark Trials, but different from other scaling
        if abs(indPuffOff(puff_idx)-indSoundOn(sound_idx)) > max_diff_vals
            binTrials(indSoundOn(sound_idx):(indSoundOn(sound_idx)+trialSize)) = behav;
            sound_idx = sound_idx + 1;
        else
            binTrials(indSoundOn(sound_idx):(indPuffOff(puff_idx)-1)) = behav; %Subtract one because find indPuffOff gives index that the puff is now 0.  Don't want that to have a value in trials.
            sound_idx = sound_idx+1;
            puff_idx = puff_idx+1;
        end
        if puff_idx > numel(indPuffOff)
            puff_idx=1;
        end
    end
    numTrials = sum(findPulses(abs(binTrials)) == -1); %Count trial off in abs value of all trials
    trialWindow = ceil(sum(abs(binTrials))/numTrials); %Window for Moving Sum of Trials, Abs Value because of -1 behaviors

elseif strcmp(behav_select, 'Excel') %Excel Behavior
    %Find and extract file
    [xlsx_file, xlsx_path] = uigetfile(fullfile(load_path,'*.xlsx'), 'Select .xlsx with behavior scores');
    [num, txt, raw] = xlsread(fullfile(xlsx_path, xlsx_file));
    
    %Get column of data of interest
    colName = 'Movement';
    colSelect = find(strcmp(txt(1,:), colName));
    behavCol = num(:,colSelect);
    behavSelect = behavCol(~isnan(behavCol));
    
    %Find and label each trial
    indSoundOn = find(findPulses(binSounds) == 1);
    if strcmp(drop_artifact, 'Yes')
        indSoundOn = indSoundOn(indSoundOn ~= 19554);
    end
    if strcmp(tone_only, 'Yes')
        indPuffOff = indSoundOn + tone_only_trial_length;
    else
        indPuffOff = find(findPulses(binPuffs) == -1);
    end
    binTrials = zeros(size(binSounds));
    trialSize = indPuffOff(1)-indSoundOn(1)-1; %Subtract 1 to have equal indexing sizes
    for idx = 1:numel(behavSelect)
        if behavSelect(idx) > 0 %Assume can have more than 0s and 1s as input (ie. Robb's Scaling)
            behav = 1; %Correct trial
        else
            behav = -1; %Incorrect trials
        end
        if idx > numel(indPuffOff)
            binTrials(indSoundOn(idx):(indSoundOn(idx)+trialSize)) = behav;
        else
            binTrials(indSoundOn(idx):(indPuffOff(idx)-1)) = behav; %Subtract one because find indPuffOff gives index that the puff is now 0.  Don't want that to have a value in trials.
        end
    end
    numTrials = sum(findPulses(abs(binTrials)) == -1); %Count trial off in abs value of all trials
    trialWindow = ceil(sum(abs(binTrials))/numTrials); %Window for Moving Sum of Trials, Abs Value because of -1 behaviors
end

% Need to add a loop and calculate bin trials for when none 
%% Sanity Check
%Sanity Check to compare binary traces to raw data values
figure(); plot_names = plot(vidFrames,'-b'); line_names={'vidFrames'}; hold on; 
plot_names(end+1)=plot(vidPuffs,'-g'); line_names{end+1} = 'vidPuffs';
if exist('vidSounds')
    plot_names(end+1)=plot(vidSounds,'-m'); line_names{end+1} = 'vidSounds';
end
plot_names(end+1)=plot(binSounds,'-k'); line_names{end+1} = 'binSounds';
plot_names(end+1)=plot(binPuffs,'-r'); line_names{end+1} = 'binPuffs';
if exist('binTrials')
    plot_names(end+1)=plot(binTrials,'-c'); line_names{end+1} = 'binTrials';
end
if exist('eye_trace')
    plot_names(end+1)=plot(eye_trace / max(eye_trace),'-y'); line_names{end+1} = 'Eye_Trace';
end
title('Sanity Check for Line Ups')
legend(plot_names, line_names, 'Location', 'eastoutside')

%Sound Widths
figure(); plot(movsum(binSounds, soundWindow))
title('Width of Each Sound Pulse')
ylabel('Width of Pulse')%% Mouse behavior from eyeblink videos
behav_select = questdlg('What format is your behavior data?','Behavior Data', 'Excel', 'BinaryVideo', 'None', 'None');
if strcmp(behav_select, 'BinaryVideo') %Binary Eye Video Behavior
    %Parameters for loading videos
    eye_video_name = '2712_d7_f.tif';
    
    %pupil_video_name = 'binary_pupil_trace_sudi.tif';
    dir_parts = split(load_path, '/');
    %behav_base_path = fullfile('/', dir_parts{1:end-1});
    behav_base_path = fullfile('/', dir_parts{1:end-2});
    %Eye Videos
    %Load metadata
    full_eye_name = fullfile(behav_base_path, eye_video_name);
    eye_info = imfinfo(full_eye_name);
    N_images = numel(eye_info);
    img_height = eye_info(1).Height;
    img_width = eye_info(1).Width;
    full_eye_stack = zeros(img_height, img_width, N_images, 'uint8');
    eye_trace = zeros(N_images,1);
    TifLink = Tiff(full_eye_name, 'r');
    max_val = 255; %Normalization of Binary Trace
    %Loop & Load Images
    sprintf('Loading Eye Video')
    for idx = 1:N_images
        TifLink.setDirectory(idx);
        cur_frame = TifLink.read(); %imread(full_eye_name, idx, 'Info', eye_info);
        img_sum = double(sum(sum(cur_frame))) / max_val;
        full_eye_stack(:,:,idx) = cur_frame;
        eye_trace(idx) = img_sum;
    end
    TifLink.close();
    %Pupil Videos
    %Load metadata
%     full_pupil_name = fullfile(behav_base_path, pupil_video_name);
%     pupil_info = imfinfo(full_pupil_name);
%     N_images = numel(pupil_info);
%     img_height = pupil_info(1).Height;
%     img_width = pupil_info(1).Width;
%     full_pupil_stack = zeros(img_height, img_width, N_images, 'uint8');
%     pupil_trace = zeros(N_images,1);
%     TifLink = Tiff(full_pupil_name, 'r');
%     max_val = 255; %Normalization of Binary Trace
%     %Loop & Load Images
%     sprintf('Loading Pupil Video')
%     for idx = 1:N_images
%         TifLink.setDirectory(idx);
%         cur_frame = TifLink.read(); %imread(full_pupil_name, idx, 'Info', pupil_info);
%         img_sum = double(sum(sum(cur_frame))) / max_val;
%         full_pupil_stack(:,:,idx) = cur_frame;
%         pupil_trace(idx) = img_sum;
%     end
%     TifLink.close();
    
    %Find and label each trial
    indSoundOn = find(findPulses(binSounds) == 1);
    if strcmp(drop_artifact, 'Yes')
        indSoundOn = indSoundOn(indSoundOn ~= 19554);
    end
    if strcmp(tone_only, 'Yes')
        indPuffOff = indSoundOn + tone_only_trial_length;
    else
        indPuffOff = find(findPulses(binPuffs) == -1);
    end
    binTrials = zeros(size(binSounds));
    [minDiff, matchIdx] = min(abs(indPuffOff(1)-indSoundOn)); 
    trialSize = minDiff - 1; %Subtract 1 to have equal indexing sizes
    if indSoundOn(end) == numel(binSounds) %If Last part is a tone with no puff
        soundSelect = indSoundOn(1:end-1); %Select all but last one
    else
        soundSelect = indSoundOn;
    end
    %Deal with Trials with Sound turned on/off mid-trial
    max_diff_vals = 40; %2 seconds as max between tone-puff
    sound_idx = 1;
    puff_idx = 1;
    for idx = 1:numel(soundSelect)
        behav = 2; %Use to demark Trials, but different from other scaling
        if abs(indPuffOff(puff_idx)-indSoundOn(sound_idx)) > max_diff_vals
            binTrials(indSoundOn(sound_idx):(indSoundOn(sound_idx)+trialSize)) = behav;
            sound_idx = sound_idx + 1;
        else
            binTrials(indSoundOn(sound_idx):(indPuffOff(puff_idx)-1)) = behav; %Subtract one because find indPuffOff gives index that the puff is now 0.  Don't want that to have a value in trials.
            sound_idx = sound_idx+1;
            puff_idx = puff_idx+1;
        end
        if puff_idx > numel(indPuffOff)
            puff_idx=1;
        end
    end
    numTrials = sum(findPulses(abs(binTrials)) == -1); %Count trial off in abs value of all trials
    trialWindow = ceil(sum(abs(binTrials))/numTrials); %Window for Moving Sum of Trials, Abs Value because of -1 behaviors

elseif strcmp(behav_select, 'Excel') %Excel Behavior
    %Find and extract file
    [xlsx_file, xlsx_path] = uigetfile(fullfile(load_path,'*.xlsx'), 'Select .xlsx with behavior scores');
    [num, txt, raw] = xlsread(fullfile(xlsx_path, xlsx_file));
    
    %Get column of data of interest
    colName = 'Movement';
    colSelect = find(strcmp(txt(1,:), colName));
    behavCol = num(:,colSelect);
    behavSelect = behavCol(~isnan(behavCol));
    
    %Find and label each trial
    indSoundOn = find(findPulses(binSounds) == 1);
    if strcmp(drop_artifact, 'Yes')
        indSoundOn = indSoundOn(indSoundOn ~= 19554);
    end
    if strcmp(tone_only, 'Yes')
        indPuffOff = indSoundOn + tone_only_trial_length;
    else
        indPuffOff = find(findPulses(binPuffs) == -1);
    end
    binTrials = zeros(size(binSounds));
    trialSize = indPuffOff(1)-indSoundOn(1)-1; %Subtract 1 to have equal indexing sizes
    for idx = 1:numel(behavSelect)
        if behavSelect(idx) > 0 %Assume can have more than 0s and 1s as input (ie. Robb's Scaling)
            behav = 1; %Correct trial
        else
            behav = -1; %Incorrect trials
        end
        if idx > numel(indPuffOff)
            binTrials(indSoundOn(idx):(indSoundOn(idx)+trialSize)) = behav;
        else
            binTrials(indSoundOn(idx):(indPuffOff(idx)-1)) = behav; %Subtract one because find indPuffOff gives index that the puff is now 0.  Don't want that to have a value in trials.
        end
    end
    numTrials = sum(findPulses(abs(binTrials)) == -1); %Count trial off in abs value of all trials
    trialWindow = ceil(sum(abs(binTrials))/numTrials); %Window for Moving Sum of Trials, Abs Value because of -1 behaviors
end

%% Sanity Check
%Sanity Check to compare binary traces to raw data values
figure(); plot_names = plot(vidFrames,'-b'); line_names={'vidFrames'}; hold on; 
plot_names(end+1)=plot(vidPuffs,'-g'); line_names{end+1} = 'vidPuffs';
if exist('vidSounds')
    plot_names(end+1)=plot(vidSounds,'-m'); line_names{end+1} = 'vidSounds';
end
plot_names(end+1)=plot(binSounds,'-k'); line_names{end+1} = 'binSounds';
plot_names(end+1)=plot(binPuffs,'-r'); line_names{end+1} = 'binPuffs';
if exist('binTrials')
    plot_names(end+1)=plot(binTrials,'-c'); line_names{end+1} = 'binTrials';
end
if exist('eye_trace')
    plot_names(end+1)=plot(eye_trace / max(eye_trace),'-y'); line_names{end+1} = 'Eye_Trace';
end
title('Sanity Check for Line Ups')
legend(plot_names, line_names, 'Location', 'eastoutside')

%Sound Widths
figure(); plot(movsum(binSounds, soundWindow))
title('Width of Each Sound Pulse')
ylabel('Width of Pulse')
figure(); plot(movsum(binPuffs, puffWindow))
title('Width of Each Puff Pulse')
ylabel('Width of Pulse')
if strcmp(behav_select, 'Excel') || strcmp(behav_select, 'BinaryVideo') %Trial Plots if There
    figure(); plot(movsum(abs(binTrials), trialWindow))
    title('Width of Each Trial Pulse')
    ylabel('Width of Trial')
end

figure(); plot(movsum(binPuffs, puffWindow))
title('Width of Each Puff Pulse')
ylabel('Width of Pulse')
if strcmp(behav_select, 'Excel') || strcmp(behav_select, 'BinaryVideo') %Trial Plots if There
    figure(); plot(movsum(abs(binTrials), trialWindow))
    title('Width of Each Trial Pulse')
    ylabel('Width of Trial')
end

%% Saving the Output
if strcmp(behav_select, 'BinaryVideo')
    saveDir = behav_base_path;
    cd(saveDir)
    %save('SyncedBehavior_BinaryVideo_sudi.mat','bin*', 'eye_trace', 'pupil_trace')
    save('SyncedBehavior_BinaryVideo_sudi.mat','bin*', 'eye_trace')
elseif strcmp(behav_select, 'Excel')
    saveDir = xlsx_path; %Assume xlsx is in a Behavior Output Folder
    cd(saveDir)
    % cd(xlsx_path)
    save('SyncedBehavior.mat','bin*')
elseif strcmp(behav_select, 'None')
    saveDir = load_path; %Assume xlsx is in a Behavior Output Folder
    cd(saveDir)
    % cd(xlsx_path)
    save('SyncedBehavior.mat','bin*') %Requires xlwrite in /scripts/matlab/utilities/downloadedFunctions to work on Linux w/out Excel
    %[saveloc, savename] = fileparts(load_path);
   %colnames = {'Sound Frame', 'Puff Frame', 'Blink', 'Blink Score', 'Movement', 'Movement Strength Score', 'Movement Duration', 'Pupil Size', 'Notes'};
    %xlwrite(fullfile(saveloc,[savename,'_Behavior.xlsx']), colnames, 'Sheet 1', 'A1');
    %xlwrite(fullfile(saveloc,[savename,'_Behavior.xlsx']), indSounds, 'Sheet 1', 'A2');
    %xlwrite(fullfile(saveloc,[savename,'_Behavior.xlsx']), indPuffs, 'Sheet 1', 'B2');
end

