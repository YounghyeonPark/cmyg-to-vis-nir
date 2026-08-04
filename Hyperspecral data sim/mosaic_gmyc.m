function mosaiced_gmyc = mosaic_gmyc(c,m,y,g)

    %c = input_cygm(:,:,1);
    %y = input_cygm(:,:,2);
    %g = input_cygm(:,:,3);
    %m = input_cygm(:,:,4);
    
    width = size(c,2);
    height = size(c,1);

    %size = width * height;

    c_col = im2col(c', [2 2], 'distinct'); 
    m_col = im2col(m', [2 2], 'distinct'); 
    y_col = im2col(y', [2 2], 'distinct'); 
    g_col = im2col(g', [2 2], 'distinct'); 

    mosaic_mask_c = double([0; 0; 0; 1]);
    mosaic_mask_m = double([0; 1; 0; 0]);
    mosaic_mask_y = double([0; 0; 1; 0]);
    mosaic_mask_g = double([1; 0; 0; 0]);

    width_col = size(c_col,2);

    for i=1:width_col
       c_col(:,i) = c_col(:,i) .* mosaic_mask_c; 
       m_col(:,i) = m_col(:,i) .* mosaic_mask_m; 
       y_col(:,i) = y_col(:,i) .* mosaic_mask_y; 
       g_col(:,i) = g_col(:,i) .* mosaic_mask_g; 
    end

    mosaiced_c = col2im(c_col, [2 2], [width height], 'distinct')';
    mosaiced_m = col2im(m_col, [2 2], [width height], 'distinct')';
    mosaiced_y = col2im(y_col, [2 2], [width height], 'distinct')';
    mosaiced_g = col2im(g_col, [2 2], [width height], 'distinct')';
    
    mosaiced_gmyc = double(mosaiced_c + mosaiced_m + mosaiced_y + mosaiced_g);

end