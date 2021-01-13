%Script to take names of session to combine, and put all them together with
%the multiMatchROIs.m script.

%Input Values
baseNames = {'/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d2_s1/',
    '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s1/',
    '/mnt/eng_research_handata/Kyle/AliEyeBlink/ali24_d5_s2/'};
traceName = 'trace_kyleFinalwDoughnut_AllBGs.mat';
imageName = 'full_projection_m_f_max_min_batch.fig';
saveName = 'trace_kyleFinalwDoughnut_AllBGs_allMatched.mat';

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