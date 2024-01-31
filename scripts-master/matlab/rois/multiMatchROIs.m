function multiMatchROIs(files, images, saves)
% Function to match the ROIs between multiple files, with corresponding 
% behavior data, ROI selection images, and save file names.
% files - cell array of filenames/paths for trace values
% images - cell array of filenames/paths for ROI selection images for
% corresponding traces in "files"
% saves - cell array of filenames/paths for saved outputs for corresponding
% traces in "files"

%Overlapping Parameters
imageSize = [1024, 1024]; %Need to change if using different size images
distanceThreshold = 50; %Number of Pixels cells need to be within to keep
overlapThreshold = 0.5; %Percent Overlap between cells to keep

% Load in all data
[allTraces, allImgs] = loadAll(files, images);
sprintf('Loading done')
% Make Binary Thresholded Masks
[allMasks] = makeBinaryMasks(allTraces, allImgs);
sprintf('Binary masks made')
%Shift ROI Masks to match one another
[shiftedMasks, shiftedTraces, shiftedIDs] = allShifting(allTraces, allMasks, 'S'); %'S' for Simon's ROI Type
sprintf('ROI masks shifted')
%Line Up ROIs with Hua-an's Code
[results, summary, matchedIDs] = allMatching(shiftedTraces, imageSize, distanceThreshold, overlapThreshold);

sprintf('Results')

end

function [allTraces, allImages] = loadAll(files, images)
% Function to load multiple trace files, corresponding ROI selection
% images, and file savenames, and put them all into cell arrays to output.
% files - cell array of filenames/paths for trace values
% images - cell array of filenames/paths for ROI selection images for
% corresponding traces in "files"

%Initialize Outputs
N_traces = numel(files);
allTraces = cell(N_traces, 1);
allImages = cell(N_traces, 1);

%Load Data
for idx = 1:N_traces
    sprintf('Loading %s',files{idx})
    load(files{idx})
    allTraces{idx} = r_out;
    clear r_out
    open(images{idx})
    ax=gca();
    allImages{idx} = ax.Children.CData;
    close(figure(1))
end
end


function [allMasks] = makeBinaryMasks(allTraces, allImages)
% Function to take a cell array of trace structures, and make a cell array
% of corresponding Binary Masks corresponding to each set of traces
% allTraces - cell array of ROI structures to make binary masks for

%Initialize Outputs
N_traces = numel(allTraces);
allMasks = cell(N_traces, 1);

%Loop through traces and make binary masks
for idx = 1:N_traces
    img_size = size(allImages{idx});
    allMasks{idx} = zeros(img_size);
    cell_struct = allTraces{idx};
    for cellIdx = 1:numel(cell_struct)
        allMasks{idx}(cell_struct(cellIdx).pixel_idx)=1;
    end
end
end


function [shiftedMasks, shiftedTraces, shiftedIDs] = allShifting(allTraces, allMasks, roiType)
% Function to take a cell array of trace structures and Binary Masks and 
% make cell arrays of shifted images, trace structures, and IDs for those
% comparisons
% allTraces - cell array of ROI structures to make binary masks for
% allMasks - cell array of Binary Masks for corresponding Traces
% roiType - 'S' if field is pixel_idx or 'K' if field is PixelIdxList

%Initialize Outputs
N_traces = numel(allTraces);
shiftedMasks = cell(N_traces, 1);
shiftedTraces = cell(N_traces, 1);
shiftedIDs = cell(N_traces, 1);

shiftedMasks{1} = allMasks{1};
shiftedTraces{1} = allTraces{1};
shiftedIDs{1} = [1,1];
for idx = 2:N_traces
    [shiftedMasks{idx}, shiftedTraces{idx}] = roi_shifting(allMasks{1}, allTraces{1}, allMasks{idx}, allTraces{idx}, roiType);
    shiftedIDs{idx} = [1,idx];
end

end


function [results, summary, matchedIDs] = allMatching(shiftedTraces, imageSize, distanceThreshold, overlapThreshold)
% Function to loop through traces and match up ROIs using roi_matching
% function
% allTraces - Cell Array of Non-shifted trace structures
% shiftedTraces - Cell Array of shifted trace structures to 

%Initialize Outputs
N_traces = numel(shiftedTraces);
N_combinations = factorial(N_traces)/(factorial(N_traces-2)*factorial(2)); %N-choose-2
results = cell(N_combinations, 1);
summary = cell(N_combinations, 1);
matchedIDs = cell(N_combinations, 1);

comb_idx = 1;
for idx = 1:(N_traces-1)
    for ind = (idx+1):N_traces
        [results{comb_idx}, summary{comb_idx}] = roi_matching(shiftedTraces{idx}, shiftedTraces{ind}, imageSize, distanceThreshold, overlapThreshold);
        matchedIDs{comb_idx} = [idx, ind];
        comb_idx = comb_idx + 1;
    end
end

end
