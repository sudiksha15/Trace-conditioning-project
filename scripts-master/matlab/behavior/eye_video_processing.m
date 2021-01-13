%% Mouse behavior from eyeblink videos
behav_select = questdlg('What format is your behavior data?','Behavior Data', 'Excel', 'BinaryVideo', 'None', 'None');
if strcmp(behav_select, 'BinaryVideo') %Binary Eye Video Behavior
    %Parameters for loading videos
    eye_video_name = '2712_d3_eye_seg.tif';
    %pupil_video_name = 'BinaryPupilTrace_Jan_10_2019.tif';
    %dir_parts = split(load_path, '/');
    %behav_base_path = fullfile('/', dir_parts{1:end-1});
    behav_base_path='/mnt/eng_handata/eng_research_handata2/Kyle/TonePuff_Rebecca2/2712/2712_d3s1';
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
        % why sum(sum(cur_frame))?
        img_sum = double(sum(sum(cur_frame))) / max_val;
        full_eye_stack(:,:,idx) = cur_frame;
        eye_trace(idx) = img_sum;
    end
    TifLink.close();
    figure
    plot(eye_trace/max(eye_trace))
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
    
end
