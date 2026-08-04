function [ output_nir_filtered ] = denoise_nir( separated_rgb, separated_nir, mixed_rgb, mixed_cmyg, method )
%DENOISE_RGB Summary of this function goes here
%   Detailed explanation goes here
    
    output_nir_filtered = separated_nir;

    if strcmp(method, 'wiener') == true      
         %wiener filter
        output_nir_filtered = wiener2(separated_nir, [8 8]);

    elseif strcmp(method, 'guided') == true
        %output_nir_filtered = imguidedfilter(converted_nir, interpolated_cmyg(:,:,4), 'NeighborhoodSize', [8 8]);
        output_nir_filtered = guidedfilter_cmyg(mixed_cmyg, separated_nir, 16, 0.00005);
    
    elseif strcmp(method, 'BM3D') == true
        [NA, output_nir_filtered] = BM3D(1, separated_nir, 32); 
        
      
    
    end
    
    % add new methods

end

