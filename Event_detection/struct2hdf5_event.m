function struct2hdf5_event(inputStruct, filename)

groups = fieldnames(inputStruct); %Base groups as names of fields in structure
for field = 1:numel(groups) %Loop through each group
    fieldSize = numel([inputStruct.(groups{field})])/numel(inputStruct); %Determine size of field vectors
    dataset = nan(fieldSize, numel(inputStruct)); %Initialize Dataset
    for idx = 1:numel(inputStruct) %Populate Dataset
        dataset(:,idx) = inputStruct(idx).(groups{field});
    end
    h5create(filename, ['/' groups{field}], size(dataset));
    h5write(filename, ['/' groups{field}], dataset);
            
    descString = 'Binary trace with 1 at event onset';
            
    h5writeatt(filename, ['/' groups{field}], 'Description', descString);
end
end
   
