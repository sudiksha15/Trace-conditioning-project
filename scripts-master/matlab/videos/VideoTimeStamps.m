%Code that goes through, recursively finds files, and pulls out hardware
%time stamp values for each of the tif files.
%Requires cell2csv function

%Pre Defined Components
rangestart = 33; %Range values for selecting text from description
rangestop = 52;
framechoice = 1;
outname = '1750_d7_s1_TimeStamps.csv';

%Find all the tifs in the subdirectory
basedir = '/mnt/eng_research_handata/eng_research_handata2/Kyle/NewTonePuff-Robb/1750/1750_d7_s1/*'; %'/Volumes/Share/Data/Traumatic_Brain_Injury/Ali-TBI-9/D*'; 
[~, list] = system(sprintf('find %s -type f -name "1750*.tif"', basedir));

breaks = find(list == char(10));
filename_list = cell(1,numel(breaks));
start = 1;
for idx = 1:numel(breaks)
    if idx == 1
        filename_list{idx} = list(1:breaks(idx)-1);
    else
        filename_list{idx} = list(breaks(idx-1)+1:breaks(idx)-1);
    end
end

outcell = cell(numel(filename_list)+1,4);
for idx = 1:numel(filename_list)+1
    if idx == 1
        outcell{idx,1} = 'Filename';
        outcell{idx,2} = 'Number of Frames';
        outcell{idx,3} = 'Date Started';
        outcell{idx,4} = 'Date Finished';
    else
        step = idx-1;
        %Pull out from Metadata
        currinfo = imfinfo(filename_list{step});
        time = currinfo(framechoice).ImageDescription(rangestart:rangestop);
        
        %Create output Cell Array
        outcell{idx,1} = filename_list{step}(end-52:end);
        outcell{idx,2} = numel(currinfo);
        outcell{idx,3} = time(1:11);
        outcell{idx,4} = time(end-7:end);
    end
end

cell2csv(outname, outcell);