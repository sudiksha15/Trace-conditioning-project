
% Script to run trace extraction in present working directory (pwd)


% File inputs To be found in the directory
% roi_file.mat - should be in the form roi_list<WHATEVER>.mat
% motion corrected tiff or hdf5 files

roi_file = dir(['*roi_list*.mat']); 

if isempty(roi_file)
    error('roi mat file with a name containing "roi_list" is missing')
end

fprintf(['Loading ',roi_file(1).name,'\n']);

loaded_roi = load(roi_file(1).name);
fieldnames_roi = fieldnames(loaded_roi);

if isempty(fieldnames_roi)
    error('roi_list mat file is empty')
end

roi_list = loaded_roi.(fieldnames_roi{1});


fieldnames_inside_roi = fieldnames(roi_list);
pixel_idx_idx = find(strcmp(fieldnames_inside_roi,'pixel_idx'));

if isempty(pixel_idx_idx)
    error('roi_list should have a field named pixel_idx')
end

% if field names inside roi_list are not named pixel_idx , rename them
% existing_name = fieldnames_inside_roi{pixel_idx_idx};
% if ~strcmp(existing_name,'pixel_idx')
% 
% [roi_list.pixel_idx] = roi_list.(existing_name);
% roi_list = rmfield(roi_list,existing_name);
% end

savename = sprintf('trace%s',roi_file(1).name(9:end));

r_out = extract_trace(roi_list, 1, 0, 0); 
save(savename, 'r_out','-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[r_out] = extract_trace(roi_list, rmfilt, rmgreen, isLabel)

%roi_list is the roi list. It contains a field named pixel_idx
%
%rmfilt is a logical (0 or 1).  Select 1 if you want to remove all .tif
%files that have the text "f_" in their name.
%
%rmgreen is a logical (0 or 1).  Select 1 if you want to remove all
%.tif files that have the name "green" in them.
%
%isLabel is a logical (0 or 1).  Select 1 if your input ROI structure
%has the field name "isLabel" for labelling cells in a particular way.

selected_dir = pwd;

if rmfilt
    filt_struct = [dir('f_*.tif'),dir('f_*.hdf5')]; %Remove Filtered Videos from extraction
    all_struct = [dir('m_*.tif'),dir('m_*.hdf5')];
    selected_struct = all_struct;
    for idx = 1:numel(filt_struct)
        match = strcmp({selected_struct.name}, filt_struct(idx).name)==1;
        selected_struct(match) = [];
    end
else
    selected_struct = [dir('m_*.tif'),dir('m_*.hdf5')];
end


if rmgreen
    green_struct = [dir('*green*.tif'),dir('*green*.hdf5')]; %Remove green channels from extraction
    for idx = 1:numel(green_struct)
        match = strcmp({selected_struct.name}, green_struct(idx).name)==1;
        selected_struct(match) = [];
    end
end


temp_cell = struct2cell(selected_struct);
selected_files = temp_cell(1,:);

% check if files are tiff or hdf5
if sum(contains(selected_files,'hdf5')) == numel(selected_files)
    isTiff = 0;
elseif sum(contains(selected_files,'tif')) == numel(selected_files)
    isTiff = 1;
else
    error('Motion corrected videos should be in in either .tif or .hdf5 format')
end

whole_tic = tic;

if class(selected_files)=='char'
    file_list(1).name = fullfile(selected_dir,selected_files);
else
    file_list = cell2struct(fullfile(selected_dir,selected_files),'name',1);
end


for file_idx=1:length(file_list)
    
    filename = file_list(file_idx).name;
    fprintf(['Processing ',num2str(file_idx),' ....\n'])
    
    if isTiff
        InfoImage = imfinfo(filename);   % for tiff
        NumberImages=length(InfoImage);
        h = InfoImage(1).Height;
        w = InfoImage(1).Width;
        f_matrix = zeros(h,w,NumberImages,'uint16');
        
        for i=1:NumberImages
            f_matrix(:,:,i) = imread(filename,'Index',i,'Info',InfoImage);
        end
        
        f_matrix = double(reshape(f_matrix,h*w,NumberImages));
        
    else
        InfoImage = h5info(filename);
        f_matrix = h5read(filename,['/',InfoImage.Datasets.Name]);
        [h,w,~] = size(f_matrix);
        f_matrix = double(reshape(f_matrix,h*w,size(f_matrix,3)));
        
    end
    for roi_idx=1:numel(roi_list)
        current_mask = zeros(1,h*w);
        try
            current_mask(roi_list(roi_idx).pixel_idx) = 1;
            r_out(roi_idx).pixel_idx = roi_list(roi_idx).pixel_idx;
        catch
            current_mask(roi_list(roi_idx).PixelIdxList) = 1;
            r_out(roi_idx).pixel_idx = roi_list(roi_idx).PixelIdxList;
        end
        image_mask = reshape(current_mask,h,w);
        %Find Centroid code from
        %(https://www.mathworks.com/matlabcentral/answers/322369-find-centroid-of-binary-image)
        [y, x] = ndgrid(1:h, 1:w);
        centroid = mean([x(logical(image_mask)), y(logical(image_mask))]);
        xcent = centroid(1);
        ycent = centroid(2);
        BG_radius = 50; %BG 5 , Number of Pixels for Local Background Radius.  Assume 1 neuron about 10 pixels in diameter
        BG_mask = (y - ycent).^2 + (x-xcent).^2 <= BG_radius.^2;
        onlyBG_mask = BG_mask - image_mask;
        BG_vect = reshape(onlyBG_mask, 1,h*w);
        r_out(roi_idx).BG_idx = find(BG_vect == 1);
        %Take Out Trace Values & Update r_out
        current_trace = (current_mask*f_matrix)/sum(current_mask);
        current_BG = (BG_vect*f_matrix)/sum(BG_vect);
        r_out(roi_idx).file(file_idx).filename = filename;
        r_out(roi_idx).file(file_idx).trace = current_trace;
        r_out(roi_idx).file(file_idx).BGtrace = current_BG;
        
        
        if file_idx==1
            r_out(roi_idx).trace = current_trace;
            r_out(roi_idx).BGtrace = current_BG;
        else
            r_out(roi_idx).trace = cat(2,r_out(roi_idx).trace,current_trace);
            r_out(roi_idx).BGtrace = cat(2,r_out(roi_idx).BGtrace,current_BG);
        end
        
        %Include Label
        if isLabel
            r_out(roi_idx).isLabel = roi_list(roi_idx).isLabel;
        end
    end
    
end

for roi_idx=1:numel(roi_list)
    r_out(roi_idx).color = rand(1,3);
end

fprintf(['Total loading time: ',num2str(round(toc(whole_tic),2)),' seconds.\n']);

end

