function bayer_cmyg_nir = mosaic_cmyg_nir(input_cmyg, input_nir)

    c = input_cmyg(:,:,1);
    m = input_cmyg(:,:,2);
    y = input_cmyg(:,:,3);
    g = input_cmyg(:,:,4);
    
    width = size(c,2);
    height = size(c,1);

    %size = width * height;


    c_col = im2col(c', [2 2], 'distinct'); 
    m_col = im2col(m', [2 2], 'distinct'); 
    y_col = im2col(y', [2 2], 'distinct'); 
    g_col = im2col(g', [2 2], 'distinct'); 

    bayer_mask_c = double([0; 0; 0; 1]);
    bayer_mask_m = double([0; 1; 0; 0]);
    bayer_mask_y = double([0; 0; 1; 0]);
    bayer_mask_g = double([1; 0; 0; 0]);

    width_col = size(c_col,2);

    for i=1:width_col
       c_col(:,i) = c_col(:,i) .* bayer_mask_c; 
       m_col(:,i) = m_col(:,i) .* bayer_mask_m; 
       y_col(:,i) = y_col(:,i) .* bayer_mask_y; 
       g_col(:,i) = g_col(:,i) .* bayer_mask_g; 
    end

    bayer_c = col2im(c_col, [2 2], [width height], 'distinct')';
    bayer_m = col2im(m_col, [2 2], [width height], 'distinct')';
    bayer_y = col2im(y_col, [2 2], [width height], 'distinct')';
    bayer_g = col2im(g_col, [2 2], [width height], 'distinct')';
    
    gamma = [1.0000 0.9833; 0.8296 0.8337];
    gamma_map = repmat(gamma, [height/2 width/2]);
    
    bayer_cmyg_nir = double(bayer_c + bayer_m + bayer_y + bayer_g + (gamma_map .* input_nir));

%gamma = [0.8337 0.9833 0.8296 1.0000];

end