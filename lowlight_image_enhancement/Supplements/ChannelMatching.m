%  20-15 06 14
% Input:
%       Img_in: separated RGB
%       Img_ref: mixed RGB+NIR
% Ouput:
%       Img_out: corrected color channel

% 20-15 06 13
function img_out = ChannelMatching(img_in, img_ref, blk_size, channel_id)
	step = 2;
    [num_rows, num_cols] = size(img_in);
    
    img_out = zeros(size(img_in));
    k = 0;
    for h = 1:step:blk_size-1
        for w = 1:step:blk_size-1
            rows = h:1:max(num_rows+h-blk_size-1, num_rows);
            cols = h:1:max(num_cols+w-blk_size-1, num_cols);
            crop_img_in    = img_in(rows, cols);
            crop_img_ref   = img_ref(rows, cols);
            croppedimg_out = CroppedChannelMatching(crop_img_in, crop_img_ref, blk_size, channel_id);
            img_out(rows, cols) = img_out(rows, cols) + croppedimg_out;
            k = k + 1;
        end
    end
    img_out = img_out / k;
end
function Croppedimg_out = CroppedChannelMatching(img_in, img_ref, blk_size, channel_id)
    [num_rows, num_cols] = size(img_in);
	img_in_col = im2col(img_in, [blk_size blk_size], 'distinct');
    img_ref_col = im2col(img_ref, [blk_size blk_size], 'distinct');
    
    a = sum(img_in_col) ./ sum(img_ref_col);    
    if channel_id == 1
        a = max(a, 1);
    end
    a_col = repmat(a, [blk_size*blk_size, 1]);
    
    img_out_col = img_ref_col .* a_col;
    Croppedimg_out     = col2im(img_out_col, [blk_size, blk_size], [num_rows, num_cols], 'distinct');
end

% % 2015 06 14
% function img_out = ChannelMatching(img_in, img_ref, blk_size)
% 
% 	% blk_size = 32;
% 	step = 1;
%     [num_rows, num_cols] = size(img_in);
%     
%     img_out = zeros(size(img_in));
%     k = 0;
%     
%     num_blk_h = floor(num_rows / blk_size) - 1;     
%     num_blk_w = floor(num_cols / blk_size) - 1;
%     h_set = 1:step:blk_size-1;  h_set_l = length(h_set); h_a = num_blk_h * h_set_l;
%     w_set = 1:step:blk_size-1;  w_set_l = length(w_set); w_a = num_blk_w * w_set_l;
%     img_a = zeros(h_a, w_a);
%     
%     a_r = 0;
%     for h = h_set
%         a_r = a_r + 1;
%         a_c = 0;
%         for w = w_set
%             a_c = a_c + 1;
%             
%             rows = h:1:(num_blk_h*blk_size+h-1);    num_rows_crop    = length(rows);
%             cols = w:1:(num_blk_w*blk_size+w-1);    num_cols_crop    = length(cols);
%                                                     % display(['(' num2str(num_rows_crop) ',' num2str(num_cols_crop) ')']);
%             
%             crop_img_in    = img_in(rows, cols);                crop_img_in_col  = im2col(crop_img_in, [blk_size blk_size], 'distinct');
%             crop_img_ref   = img_ref(rows, cols);               crop_img_ref_col = im2col(crop_img_ref, [blk_size blk_size], 'distinct');
%             
%             a = sum(crop_img_in_col) ./ sum(crop_img_ref_col);  
%             h_a_r = a_r:h_set_l:h_a; h_a_c = a_c:w_set_l:w_a;   
% %             img_a(h_a_r, h_a_c) = reshape(a, [num_blk_h, num_blk_w]);   % figure, imshow(img_a(h_a_r, h_a_c), []);
% %             img_a_fil = wiener2(img_a(h_a_r, h_a_c), [3, 3]);           % figure, imshow(img_a_fil, []);
% %             a = img_a_fil(:)';
%             a_col = repmat(a, [blk_size*blk_size, 1]);
%             crop_img_out_col = crop_img_ref_col .* a_col;       crop_img_out     = col2im(crop_img_out_col, [blk_size, blk_size], [num_rows_crop, num_cols_crop], 'distinct');
%             
%             img_out(rows, cols) = img_out(rows, cols) + crop_img_out;
%             k = k + 1;
%         end
%     end
%     % imshow(img_a, []);
%     img_out = img_out / k;
% end
% function [Croppedimg_out, a] = CroppedChannelMatching(img_in, img_ref, blk_size)
%     [num_rows, num_cols] = size(img_in);
% 	img_in_col = im2col(img_in, [blk_size blk_size], 'distinct');
%     img_ref_col = im2col(img_ref, [blk_size blk_size], 'distinct');
%     
%     a = sum(img_in_col) ./ sum(img_ref_col);    
%     a_col = repmat(a, [blk_size*blk_size, 1]);
%     
%     img_out_col = img_ref_col .* a_col;
%     Croppedimg_out     = col2im(img_out_col, [blk_size, blk_size], [num_rows, num_cols], 'distinct');
% end