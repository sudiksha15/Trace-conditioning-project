function [result,summary] = roi_matching(r_ref, r_test, image_size, distance_threshold, overlap_threshold)
    %Code written by Hua-an to match up and determine if ROIs in one
    %structure are matched or similar to ROIs in another structure.
    
    whole_tic = tic;
    
    if isempty(image_size)
        image_size = [1024 1024];
    end
    
    if isempty(distance_threshold)
        distance_threshold = 50;
    end
    
    if isempty(overlap_threshold)
        overlap_threshold = 0.5;
    end
    
    if isfield(r_ref,'pixel_idx')
        pixel_idx_field_ref = 'pixel_idx';
    else
        pixel_idx_field_ref = 'PixelIdxList';
    end
    
    if isfield(r_test,'pixel_idx')
        pixel_idx_field_test = 'pixel_idx';
    else
        pixel_idx_field_test = 'PixelIdxList';
    end
    
    
    
    for ref_idx=1:numel(r_ref)
        mask_ref = zeros(image_size);
        mask_ref(r_ref(ref_idx).(pixel_idx_field_ref)) = 1;
        temp_centroid = regionprops(mask_ref,'centroid');
        r_ref(ref_idx).centroid = temp_centroid.Centroid;
    end
    
    for test_idx=1:numel(r_test)
        mask_test = zeros(image_size);
        mask_test(r_test(test_idx).(pixel_idx_field_test)) = 1;
        temp_centroid = regionprops(mask_test,'centroid');
        r_test(test_idx).centroid = temp_centroid.Centroid;
    end
    
    [centroid_pair_ref, centroid_pair_test] = find(pdist2(cat(1,r_ref.centroid),cat(1,r_test.centroid))<distance_threshold);
    overlap_matrix = zeros(numel(r_ref),numel(r_test));
    for centroid_pair_idx=1:numel(centroid_pair_ref)
        overlap_matrix(centroid_pair_ref(centroid_pair_idx),centroid_pair_test(centroid_pair_idx)) = calculate_mutual_overlap(r_ref(centroid_pair_ref(centroid_pair_idx)).(pixel_idx_field_ref),r_test(centroid_pair_test(centroid_pair_idx)).(pixel_idx_field_test));

%         mutual_overlap = calculate_mutual_overlap(r_ref(centroid_pair_ref(centroid_pair_idx)).(pixel_idx_field_ref),r_test(centroid_pair_test(centroid_pair_idx)).(pixel_idx_field_test));
%         
%         if mutual_overlap>overlap_threshold
%             overlap_matrix(centroid_pair_ref(centroid_pair_idx),centroid_pair_test(centroid_pair_idx)) = mutual_overlap;
%         end
        
    end
    
    overlap_matrix(overlap_matrix<=overlap_threshold) = 0;

    
    fprintf('Start matching ROIs....\n');
    result = [];
    max_overlap = max(overlap_matrix(:));
    result_mask = zeros(image_size);
    
    while ~isnan(max_overlap) && max_overlap~=0
        [roi_idx_ref,roi_idx_test] = find(overlap_matrix==max_overlap);
        
        for pair_idx = 1:numel(roi_idx_ref)
            
            current_ref_idx = roi_idx_ref(pair_idx);
            current_test_idx = roi_idx_test(pair_idx);
            
            current_idx = numel(result)+1;
            
            result(current_idx).ref_id = current_ref_idx;
            result(current_idx).ref_pixel_idx = r_ref(current_ref_idx).(pixel_idx_field_ref);
            result(current_idx).test_id = current_test_idx;
            result(current_idx).test_pixel_idx = r_test(current_test_idx).(pixel_idx_field_test);
            result(current_idx).mutual_overlap = max_overlap;
            result(current_idx).matched = 1;
            result(current_idx).ref_only = 0;
            result(current_idx).test_only = 0;
            overlap_matrix(current_ref_idx,:) = nan;
            overlap_matrix(:,current_test_idx) = nan;
            fprintf(['Ref ',num2str(current_ref_idx),' <-> Test ',num2str(current_test_idx),' (',num2str(max_overlap),')\n']);
        end
        max_overlap = max(overlap_matrix(:));
    end
    
    unmatched_ref_idx = find(~isnan(nanmean(overlap_matrix,2)));
    if ~isempty(unmatched_ref_idx)
        for unmatched_idx=1:numel(unmatched_ref_idx)
            
            current_ref_idx = unmatched_ref_idx(unmatched_idx);
            current_idx = numel(result)+1;
            
            result(current_idx).ref_id = current_ref_idx;
            result(current_idx).ref_pixel_idx = r_ref(current_ref_idx).(pixel_idx_field_ref);
            result(current_idx).test_id = -1;
            result(current_idx).matched = 0;
            result(current_idx).ref_only = 1;
            result(current_idx).test_only = 0;
            
        end
    end
    
    unmatched_test_idx = find(~isnan(nanmean(overlap_matrix,1)));
    if ~isempty(unmatched_test_idx)
        for unmatched_idx=1:numel(unmatched_test_idx)
            
            current_test_idx = unmatched_test_idx(unmatched_idx);
            current_idx = numel(result)+1;
            
            result(current_idx).ref_id = -1; 
            result(current_idx).test_id = current_test_idx;
            result(current_idx).test_pixel_idx = r_test(current_test_idx).(pixel_idx_field_test);
            result(current_idx).matched = 0;
            result(current_idx).ref_only = 0;
            result(current_idx).test_only = 1;
            
        end
    end
    
    total_match = sum(cat(1,result.matched));
    ref_only = sum(cat(1,result.ref_only));
    test_only = sum(cat(1,result.test_only));
    
    summary = [total_match ref_only test_only];
    
    fprintf(['Total time: ',num2str(toc(whole_tic)),' seconds.\n']);

end

function mutual_overlap = calculate_mutual_overlap(pixel_idx_ref,pixel_idx_test)
    mutual_pixel = intersect(pixel_idx_ref,pixel_idx_test);
    
    mutual_overlap = (numel(mutual_pixel)/numel(pixel_idx_ref)+numel(mutual_pixel)/numel(pixel_idx_test))/2;
    
end
