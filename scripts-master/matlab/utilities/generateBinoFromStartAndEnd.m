function binoArray = generateBinoFromStartAndEnd(origTrace, highStartPeakIndices, highEndPeakIndices)
binoArray = zeros(size(origTrace));
for id = 1:length(highStartPeakIndices)
    try
        binoArray(highStartPeakIndices(id):highEndPeakIndices(id)) = 1;
    catch
        disp('caught');
    end
end
if length(binoArray) > length(origTrace)
    binoArray = binoArray(1:length(origTrace));
end
end
