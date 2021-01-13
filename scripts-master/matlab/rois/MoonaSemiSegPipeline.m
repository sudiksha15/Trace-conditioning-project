%Pipeline file to aid Moona in selecting ROIs and Labelling them

%Select matlab figure of Motion Corrected, Homomorphic Filtered Frame
[figName, figPath, ~] = uigetfile('.fig','Select Matlab .fig for ROI Selection');
cd(figPath)
h = open(figName);

%Extract Image Data from Figure
roiIm = get(get(gca(),'Children'),'CData');
close(h)

%Select ROIs with SemiSeg
CellList = SemiSeg(roiIm, []);

%Save Selected ROIs
save('circleROIsMoona.mat','CellList')

%Load Labelling Image
greenImStack = loadTifArray_Multifile(1);
greenIm = max(greenImStack,[],3);

%Run Labelling Code
[CellList_Label, allLabels] = SemiSeg_Label(greenIm, CellList);

%Save Labelled Output
save('circleROIsMoonaLabelled.mat','CellList_Label','allLabels')
