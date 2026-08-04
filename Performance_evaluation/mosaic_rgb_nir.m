function bayer_rgb_nir = mosaic_rgb_nir(input_rgb, input_nir)

    bayer_rgb = mosaic_rgb(input_rgb);
         
    %G(LT)
    alpha1 = 0.5523;
    beta1 = 1 - alpha1;
    %G(RB)
    alpha2 = 0.4475;
    beta2 = 1 - alpha2;
    %B(RT)
    alpha3 = 0.5;
    beta3 = 1 - alpha3;
    %R(LB)
    alpha4 = 0.5;
    beta4 = 1 - alpha4;
    
    
    alpha = [alpha1 alpha3; alpha4 alpha2];
    beta = [beta1 beta3; beta4 beta2];
    
    alpha_map = repmat(alpha, size(input_rgb,1)/2, size(input_rgb,2)/2);
    beta_map = repmat(beta, size(input_nir,1)/2, size(input_nir,2)/2);
    
    
    bayer_rgb_nir = (alpha_map .* bayer_rgb) + (beta_map .* input_nir);



end