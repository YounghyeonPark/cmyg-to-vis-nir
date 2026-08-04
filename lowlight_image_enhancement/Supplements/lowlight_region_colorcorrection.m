function rgb_out = lowlight_region_colorcorrection(rgb_in)
    [num_rows, num_cols, num_chs] = size(rgb_in);
    blk_size = 4;
    step = 1;
    
    rgb_out = zeros(size(rgb_in));
    
    for ch_id = 1:1:num_chs
        k = 0;
        for h = 1:step:blk_size-1
            for w = 1:step:blk_size-1
                display(['(h,w) = (' num2str(h) ',' num2str(w) ')']);
                rows = h:1:max(num_rows+h-blk_size-1, num_rows);
                cols = h:1:max(num_cols+w-blk_size-1, num_cols);
                crop_img_in    = rgb_in(rows, cols, ch_id);
                croppedimg_out = CroppedChannelMedian(crop_img_in, blk_size);
                rgb_out(rows, cols, ch_id) = rgb_out(rows, cols, ch_id) + croppedimg_out;
                k = k + 1;
            end
        end
        rgb_out(:,:,ch_id) = rgb_out(:,:,ch_id) / k;        
    end

end
function Croppedimg_out = CroppedChannelMedian(img_in, blk_size)
    threshold = 0.5;
    percentkeeping = round(0.1*blk_size*blk_size);
    [num_rows, num_cols] = size(img_in);
	img_in_col = im2col(img_in, [blk_size blk_size], 'distinct');
    b = mean(img_in_col);
    img_in_col_srt = sort(img_in_col, 'descend');
    a = mean(img_in_col_srt(1:1:percentkeeping,:));   
    
    a(b > threshold) = b(b > threshold);
    a_col = repmat(a, [blk_size*blk_size, 1]);
    
    img_out_col = a_col;
    Croppedimg_out     = col2im(img_out_col, [blk_size, blk_size], [num_rows, num_cols], 'distinct');
end