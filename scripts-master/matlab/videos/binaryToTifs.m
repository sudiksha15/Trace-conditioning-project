%Script to load .uint16 videos from one location and save them as .tif
%files in another location, for archiving motion corrected videos in a
%standard format.
%Requires readBinaryData.m of Mark's code from Mike's striatum-ca repo in 
%/striatum-ca/matlab_code/src/.
%Requires Hua-an's matrix2tiff.m.  Version in Kyle's scripts repo
%/scripts/matlab/huaan.  Need to get Hua-an to host a version

%Add folders to path
gitBase = '~/gitclones/';
addpath(fullfile(gitBase,'striatum-ca/matlab_code/src/'),fullfile(gitBase,'scripts/matlab/huaan/'));

%Input/Output info
[uint16Files,uint16Path,~] = uigetfile('.uint16', 'Select uint16 files to Convert','MultiSelect','on');
tifDir = uigetdir(uint16Path,'Select Folder to Save Tifs In');

%Handle when only 1 file chosen
if ~iscell(uint16Files)
    tempcell{1} = uint16Files;
    uint16Files = tempcell;
end

%Move to folder and loop through files to open and save
cd(uint16Path)
for idx=1:numel(uint16Files)
    curFile = uint16Files{idx};
    vid = readBinaryData(curFile);
    dotLocs = strfind(curFile,'.');
    saveFilename = ['m_',curFile(1:(dotLocs(1)-1))];
    matrix2tiff(vid, fullfile(tifDir,saveFilename), 'w');
end