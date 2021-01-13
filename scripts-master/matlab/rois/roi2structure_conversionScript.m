%Script created to convert an ROI Object (from Mark's code) to a built in
%Matlab structure so that the dependency on the ROI Class is no longer
%required for those data.

%Outputted file name
outname = 'circleROIs.mat';

%Switch to ROI Directory w/Nested Files Code on Kyle's Git
file_list = findNestedFiles('/mnt/eng_research_handata/Kyle/MoonaPVLabel', '*green-rois*.mat');

for idx = 1:numel(file_list)
    [pathstr, name, ext] = fileparts(file_list{idx});
    cd(pathstr)
    load(strcat(name,ext)); %Need to have code in path to load Mark's roi class.  Named roi for TBI, and R for Mike's Code
    
    CellList = struct([]);
    for step = 1:numel(R) %Take Values from roi class and add to new structure
        CellList(step).PixelIdxList = R(step).PixelIdxList;
        CellList(step).perimeter = R(step).Perimeter;
        CellList(step).isPV = R(step).isChI; %If has labels from Mike's code
    end
    save(outname, 'CellList')
    clear CellList R
end
