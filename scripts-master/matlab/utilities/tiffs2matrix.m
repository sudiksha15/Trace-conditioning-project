function [f_matrix] = tiffs2matrix(keyword, method)

    if isempty(keyword)
        file_list = uigetfile('*.tif','MultiSelect','on');
        file_list = cell2struct(file_list,'name',1);
    else
        file_list = dir([keyword,'*.*']);
    end

    frame_number = zeros((length(file_list)+1),1);

    for f=1:length(file_list)
        filename = file_list(f).name;
        InfoImage = imfinfo(filename);
        frame_number(f+1) = length(InfoImage);
    end

    total_frame = sum(frame_number);

    f_matrix = zeros(InfoImage(1).Height,InfoImage(1).Width,total_frame,'uint16');


    switch method
        case 1
            for f=1:length(file_list)
                filename = file_list(f).name;
                fprintf(['Loading ',filename,'\n']);
                InfoImage = imfinfo(filename);
                NumberImages=length(InfoImage);
                frame_zero = sum(frame_number(1:f));
                for i=1:NumberImages
                    f_matrix(:,:,i+frame_zero) = imread(filename,'Index',i,'Info',InfoImage);
                end
            end
        case 2
            warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
            for f=1:length(file_list)
                filename = file_list(f).name;
                InfoImage = imfinfo(filename);
                NumberImages=length(InfoImage);
                frame_zero = sum(frame_number(1:f));
                TifLink = Tiff(filename, 'r');
                for i = 1:NumberImages
                    TifLink.setDirectory(i);
                    f_matrix(:,:,i+frame_zero) = TifLink.read();
                end
            end
            warning('on','all');

    end
    
end
