behav_select = questdlg('What format is your behavior data?','Behavior Data', 'Excel', 'BinaryVideo', 'None', 'None');
if strcmp(behav_select, 'BinaryVideo') %Binary Eye Video Behavior
    %Parameters for loading videos
    
    pupil_video_name = '2917_pupil_seg.tif';
    
    behav_base_path = '/mnt/eng_handata/eng_research_handata2/Rebecca/Autism/2917/FearConditioning/Extinction';
    
    full_pupil_name = fullfile(behav_base_path, pupil_video_name);
    pupil_info = imfinfo(full_pupil_name);
    N_images = numel(pupil_info);
    img_height = pupil_info(1).Height;
    img_width = pupil_info(1).Width;
    full_pupil_stack = zeros(img_height, img_width, N_images, 'uint8');
    pupil_trace = zeros(N_images,1);
    TifLink = Tiff(full_pupil_name, 'r');
    max_val = 255; %Normalization of Binary Trace
    %Loop & Load Images
    sprintf('Loading Pupil Video')
    for idx = 1:N_images
        TifLink.setDirectory(idx);
        cur_frame = TifLink.read(); %imread(full_pupil_name, idx, 'Info', pupil_info);
        img_sum = double(sum(sum(cur_frame))) / max_val;
        full_pupil_stack(:,:,idx) = cur_frame;
        pupil_trace(idx) = img_sum;
    end
    TifLink.close();
    
figure
    plot(pupil_trace/max(pupil_trace))
    hold on 
    % Add tone onsets
    tones = [200:700:13500];
    for i =1:length(tones)
        line([tones(i) tones(i)],[0 1],'Color','k')
        ylim([0 1])
        xlabel('Frames')
        ylabel('Sum of the pixels')
        hold on
    end
    
    
     tones_end = [300:700:13600]
    for i =1:length(tones_end)
        line([tones_end(i) tones_end(i)],[0 1],'Color','k')
        ylim([0 1])
        xlabel('Frames')
        ylabel('Sum of the pixels')
        hold on
    end 
  
    
end