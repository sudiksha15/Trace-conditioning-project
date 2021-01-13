function file_list = findNestedFiles(startdir, filename)
    %Function to recursively find all files of specific name nested within 
    %a certain directory.
    %Inputs
    %startdir(String) - Directory to start searching in
    %filename(String) - Filename to search for recursively. Wildcard values
    %must contain quotes, at least on Linux
    %Outputs
    %file_list(Cell Array) - Cell array where each cell is the full path to
    %each file that was found
    
    if ispc == 1 %If on PC
        curdir = pwd; %Get current directory to switch back to at the end
        cd(startdir);
        %Find the files
        [~, list] = system(sprintf('dir /B /S %s', filename));
        temp_result = textscan(list, '%s', 'delimiter', '\n');
        file_list = temp_result{1};
        cd(curdir)
    elseif isunix == 1 %If on Unix
        [~, sel_file, sel_ext] = fileparts(fullfile(startdir, filename)); %Needed to handle if filename includes additional nested paths
        [~, list] = system(sprintf('find %s -iname %s -type f', startdir, strcat(sel_file,sel_ext)));
        temp_result = textscan(list, '%s', 'delimiter', '\n');
        file_list = temp_result{1};
    end
    
end