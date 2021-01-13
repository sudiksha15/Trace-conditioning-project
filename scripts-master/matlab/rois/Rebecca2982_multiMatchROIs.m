%Script to take names of session to combine, and put all them together with
%the multiMatchROIs.m script.

%Input Values
baseNames = {'/mnt/eng_research_handata/eng_research_handata2/Kyle/TonePuff-Rebecca/2982/2982_d2_s1',
    '/mnt/eng_research_handata/eng_research_handata2/Kyle/TonePuff-Rebecca/2982/2982_d9_s1'};
traceName = 'trace_quickCircle.mat';
imageName = 'full_projection_m_f_max_min_batch.fig';
saveName = 'trace_quickCircle_allMatched.mat';

%Initialize Cell Arrays
files = cell(numel(baseNames),1);
images = cell(numel(baseNames),1);
saves = cell(numel(baseNames),1);

%Loop Through and Create Full Paths
for idx=1:numel(baseNames)
    files{idx} = fullfile(baseNames{idx}, traceName);
    images{idx} = fullfile(baseNames{idx}, imageName);
    saves{idx} = fullfile(baseNames{idx}, saveName);
end

multiMatchROIs(files, images, saves);