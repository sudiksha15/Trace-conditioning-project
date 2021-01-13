function struct2hdf5(inputStruct, filename, labelType, imSize, chunkSize)
    %Code to take a matlab structure as input and save it's output as an hdf5
    %file.  Assumes every field is a Vector except one special case where 
    %it is a field of known structure.  Can be altered to take 2D inputs, 
    %but has not yet had that added.
    
    %inputStruct - Structure inputted to save as hdf5 file.  Assumes that
    %initial dimensions (inputStruct(idx)) are cells, while additional
    %nested dimensions (inputStruct.field(idx)) are files where data came
    %from with stored individual traces.
    %filename - String as filename to save hdf5 as.  The extensions .hdf5
    %should be included
    %labelType - String to of name of cell type labelled in dataset
    %imSize - Image Size as [Height, Width] for pixel indexing purposes.  
    %Assumes 1024x1024 image if input is empty
    %chunkSize - 3D array of dimensions to chunk the data for saving
    %compression.  [Height, Width, Number of Cells].  Assumes [imSize/2^3,
    %lfactor] if empty, where lfactor is the largest prime factor of the
    %number of cells in inputStruct.
    
    %Hidden output - hdf5 file saved as filename
    
    if isempty(imSize)
        imSize = [1024,1024];
    end
    if isempty(chunkSize)
        imChunk = imSize / 2^3;
        cellChunk = factor(numel(inputStruct));
        chunkSize = [imChunk, cellChunk(end)];
    end
    
    %Get structure info
    groups = fieldnames(inputStruct); %Base groups as names of fields in structure
    for field = 1:numel(groups) %Loop through each group
        if strcmp(groups{field}, 'file') %Loop through files if saved as own structure
            nFiles = numel(inputStruct(1).(groups{field}));
            for selFile = 1:nFiles %Loop through files
                %Hard Coded Field Names & # values based on Assumptions
                nTime = numel(inputStruct(1).(groups{field})(selFile).trace); %Time for specific File
                dataset = nan(nTime, numel(inputStruct)); %Initialize Dataset
                for idx = 1:numel(inputStruct) %Loop through each cell
                    dataset(:, idx) = inputStruct(idx).(groups{field})(selFile).trace;
                end
                fName = inputStruct(1).(groups{field})(selFile).filename;
                %Add to hdf5 file
                h5create(filename, ['/' groups{field} '/trace' num2str(selFile,'%02d')], size(dataset));
                h5write(filename, ['/' groups{field} '/trace' num2str(selFile,'%02d')], dataset);
                h5writeatt(filename, ['/' groups{field} '/trace' num2str(selFile,'%02d')], 'Filename', fName);
                h5writeatt(filename, ['/' groups{field} '/trace' num2str(selFile,'%02d')], 'Description', 'Traces for all ROIs for only associated Filename. Organized as N-time rows x N-cells columns'); %Description of Dataset
            end
        elseif strcmp(groups{field}, 'pixel_idx')
            roiArray = zeros([prod(imSize), numel(inputStruct)]);
            for idx = 1:numel(inputStruct)
                roiArray(inputStruct(idx).pixel_idx,idx) = 1;
            end
            roiMasks = reshape(roiArray, [imSize, numel(inputStruct)]);
            h5create(filename, ['/rois/ROImasks'], size(roiMasks), 'ChunkSize', chunkSize, 'Deflate', 9);
            h5write(filename, ['/rois/ROImasks'], roiMasks);
            h5writeatt(filename, ['/rois/ROImasks'], 'Image Size', imSize);
            h5writeatt(filename, ['/rois/ROImasks'], 'Number of Cells', numel(inputStruct));
            h5writeatt(filename, ['/rois/ROImasks'], 'Description', 'Selected ROI Masks');
        elseif strcmp(groups{field}, 'BG_idx')
            BGArray = zeros([prod(imSize), numel(inputStruct)]);
            for idx = 1:numel(inputStruct)
                BGArray(inputStruct(idx).BG_idx,idx) = 1;
            end
            BGMasks = reshape(BGArray, [imSize, numel(inputStruct)]);
            h5create(filename, ['/rois/BGmasks'], size(BGMasks), 'ChunkSize', chunkSize, 'Deflate', 9);
            h5write(filename, ['/rois/BGmasks'], BGMasks);
            h5writeatt(filename, ['/rois/BGmasks'], 'Image Size', imSize);
            h5writeatt(filename, ['/rois/BGmasks'], 'Number of Cells', numel(inputStruct));
            h5writeatt(filename, ['/rois/BGmasks'], 'Description', 'Selected ROI Background Masks');
        elseif strcmp(groups{field}, 'BG5_idx')
            BG5Array = zeros([prod(imSize), numel(inputStruct)]);
            for idx = 1:numel(inputStruct)
                BG5Array(inputStruct(idx).BG5_idx,idx) = 1;
            end
            BG5Masks = reshape(BG5Array, [imSize, numel(inputStruct)]);
            h5create(filename, ['/rois/BG5masks'], size(BG5Masks), 'ChunkSize', chunkSize, 'Deflate', 9);
            h5write(filename, ['/rois/BG5masks'], BG5Masks);
            h5writeatt(filename, ['/rois/BG5masks'], 'Image Size', imSize);
            h5writeatt(filename, ['/rois/BG5masks'], 'Number of Cells', numel(inputStruct));
            h5writeatt(filename, ['/rois/BG5masks'], 'Description', 'Selected ROI Background Masks of Radius of ~5 Cells');
        elseif strcmp(groups{field}, 'BG10_idx')
            BG10Array = zeros([prod(imSize), numel(inputStruct)]);
            for idx = 1:numel(inputStruct)
                BG10Array(inputStruct(idx).BG10_idx,idx) = 1;
            end
            BG10Masks = reshape(BG10Array, [imSize, numel(inputStruct)]);
            h5create(filename, ['/rois/BG10masks'], size(BG10Masks), 'ChunkSize', chunkSize, 'Deflate', 9);
            h5write(filename, ['/rois/BG10masks'], BG10Masks);
            h5writeatt(filename, ['/rois/BG10masks'], 'Image Size', imSize);
            h5writeatt(filename, ['/rois/BG10masks'], 'Number of Cells', numel(inputStruct));
            h5writeatt(filename, ['/rois/BG10masks'], 'Description', 'Selected ROI Background Masks of Radius of ~10 Cells');
        else %Use if base field is only numeric data vectors all the same size
            fieldSize = numel([inputStruct.(groups{field})])/numel(inputStruct); %Determine size of field vectors
            dataset = nan(fieldSize, numel(inputStruct)); %Initialize Dataset
            for idx = 1:numel(inputStruct) %Populate Dataset
                dataset(:,idx) = inputStruct(idx).(groups{field});
            end
            h5create(filename, ['/' groups{field}], size(dataset));
            h5write(filename, ['/' groups{field}], dataset);
            if strcmp(groups{field}, 'trace') %Select Description of Dataset
                descString = 'Full trace concatenated across all files.';
            elseif strcmp(groups{field}, 'BGtrace')
                descString = 'Full trace for Background ROI concatenated across all files.';
            elseif strcmp(groups{field}, 'BG5trace')
                descString = 'Full trace for Background ROI of Radius ~5 Cells concatenated across all files.';
            elseif strcmp(groups{field}, 'BG10trace')
                descString = 'Full trace for Background ROI of Radius ~10 Cells concatenated across all files.';
            elseif strcmp(groups{field}, 'NPtrace')
                descString = 'Full trace for Background Neuropil (complement of all ROIs) concatenated across all files.';
            elseif strcmp(groups{field}, 'color')
                descString = 'Randomly selected color for ROI identification.';
            elseif strcmp(groups{field}, 'isLabel')
                descString = sprintf('Array of Logicals if Cell was labelled as %s.', labelType);
            elseif strcmp(groups{field}, 'lastTraning_d5_s1_index')
                descString = 'Cell Index for Last Day of Training (d5_s1 for Ali Mice)';
            elseif strcmp(groups{field}, 'firstExtinction_d5_s2_index')
                descString = 'Cell Index for First Day of Extinction (d5_s2 for Ali Mice)';
            end
            h5writeatt(filename, ['/' groups{field}], 'Description', descString);
        end
    end
    
end
