function [im2_shifted, r_out2_shifted] = roi_shifting(im1, r_out1, im2, r_out2, rois_type)
%Script to compare 2 images, determine the shift between each one, and
%apply that shift to the second one.
%Input im1 and r_out1 as image and roi map for coordinate space 1
%(Reference)
%Input im2 and r_out2 as image and roi map for coordinate space 2 (To be
%shifted)
%Input 'S' or 'K' for Simon's or Kyle's ROI naming scheme
%Output im2_shifted and r_out2_shifted as image and roi map shifted to the
%coordinate space 1

%Select Pixel Field Name
switch rois_type
    case 'S' %S for Simon
        pixel_list = 'pixel_idx';
    case 'K' %K for Kyle
        pixel_list = 'PixelIdxList';
end


%Compute Shift between images.
fft_multiply = ifftshift(ifft2(fft2(im1) .* conj(fft2(im2))));
cc = abs(fft_multiply);
[max_cc, imax] = max(abs(cc(:)));

%Shift Images
[ypeak, xpeak] = ind2sub(size(cc), imax(1));
corr_offset = [(xpeak-size(im1,2)/2), (ypeak-size(im1,1)/2)];
im2_shifted = imtranslate(im2, corr_offset);

%Shift inds in r_out2 to be in the space of r_out1
center_val = sub2ind(size(im1), size(im1,1)/2, size(im1,1)/2);
ind_shift = center_val - imax(1);
r_out2_shifted = r_out2;
maxind = size(im1,1)*size(im1,2);
for idx = 1:numel(r_out2_shifted)
    changed_pixels = r_out2(idx).(pixel_list) - ind_shift;
    changed_pixels = changed_pixels(changed_pixels>0);
    changed_pixels = changed_pixels(changed_pixels<maxind);
    r_out2_shifted(idx).(pixel_list) = changed_pixels;
end

end