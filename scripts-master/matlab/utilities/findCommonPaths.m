function [ outPaths ] = findCommonPaths(inPaths1, inPaths2)
%findCommonPaths Find paths in common between 2 cell arrays of paths
%   Find the file paths in common between two cell arrays of file paths,
%   where it is assumed that inPaths2 may contain additional folders nested
%   within the root of inPaths1.
%   inPaths1 - Cell Array of File Paths of File Type 1
%   inPaths2 - Cell Array of File Paths of File Type 2 
%
%   outPaths - Cell Array of File Paths Common between both inPaths
%
%   For example if inPaths1 = /home/test/file1.txt and 
%   inPaths2 = /home/test/nest1/nest2/file2.jpg, then n_Nested would be 2
%   and outPaths would be on the level of /home/test/

if numel(inPaths1) > 1
    sz_idx = 2;
else
    sz_idx = 1;
end

%Determine number of characters to drop at the end of inPaths2
strings1 = split(inPaths1, '/');
strings2 = split(inPaths2, '/');
n_Nested1 = size(strings1,sz_idx);
n_Nested2 = size(strings2,sz_idx);
n_Nested_diff = n_Nested2-n_Nested1;
n_Nested_change = n_Nested_diff - 1; %Shift for the change by 1, to account for filenames
n_drop = 0;
if n_Nested_change >= 0
    for idx = (n_Nested2-1-n_Nested_change):(n_Nested2-1)
        if numel(inPaths1) > 1
            n_drop = n_drop + numel(strings2{1,idx});
        else
            n_drop = n_drop + numel(strings2{idx});
        end
    end
    n_drop = n_drop + n_Nested_diff; %Include '/' in drop total
end

%Loop through and create lists
dropFiles1 = cell(numel(inPaths1),1);
for idx = 1:numel(inPaths1)
    dropFiles1{idx} = fileparts(inPaths1{idx});
end
dropFiles2 = cell(numel(inPaths2),1);
for idx = 1:numel(inPaths2)
    temp = fileparts(inPaths2{idx});
    dropFiles2{idx} = temp(1:end-n_drop);
end

outPaths = intersect(dropFiles1, dropFiles2);


end

