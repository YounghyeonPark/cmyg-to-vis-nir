function [ output_nir_filtered ] = denoise_nir( converted_rgb, converted_nir, mixed_rgb, method )
%DENOISE_RGB Summary of this function goes here
%   Detailed explanation goes here
    
    output_nir_filtered = converted_nir;

    if strcmp(method, 'wiener') == true      
         %wiener filter
        output_nir_filtered = wiener2(converted_nir, [8 8]);

    end
    
    % add new methods

end

