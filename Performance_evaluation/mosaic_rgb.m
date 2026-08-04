function bayer_rgb = mosaic_rgb(input_rgb)


    r = input_rgb(:,:,1);
    g = input_rgb(:,:,2);
    b = input_rgb(:,:,3);

    width = size(r,2);
    height = size(r,1);

    %size = width * height;


    r_col = im2col(r', [2 2], 'distinct'); 
    g_col = im2col(g', [2 2], 'distinct'); 
    b_col = im2col(b', [2 2], 'distinct'); 

    bayer_mask_r = double([0; 0; 1; 0]);
    bayer_mask_g = double([1; 0; 0; 1]);
    bayer_mask_b = double([0; 1; 0; 0]);

    width_col = size(r_col,2);

    for i=1:width_col
       r_col(:,i) = r_col(:,i) .* bayer_mask_r; 
       g_col(:,i) = g_col(:,i) .* bayer_mask_g; 
       b_col(:,i) = b_col(:,i) .* bayer_mask_b; 
    end

    bayer_r = col2im(r_col, [2 2], [width height], 'distinct')';
    bayer_g = col2im(g_col, [2 2], [width height], 'distinct')';
    bayer_b = col2im(b_col, [2 2], [width height], 'distinct')';

    bayer_rgb = double(bayer_r + bayer_g + bayer_b);



end