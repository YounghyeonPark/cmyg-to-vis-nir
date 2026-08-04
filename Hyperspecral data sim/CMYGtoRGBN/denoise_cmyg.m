function [ output_cmyg_filtered ] = denoise_cmyg(interpolated_cmyg, method )
%DENOISE_RGB Summary of this function goes here
%   Detailed explanation goes here
    output_cmyg_filtered = interpolated_cmyg;
 %   output_nir_filtered = converted_nir;

    if strcmp(method, 'wiener') == true
         % Trick 
         %output_rgb_filtered(:,:,1) = converted_rgb(:,:,1) + 0.3 * converted_nir;
         %output_rgb_filtered(:,:,2) = converted_rgb(:,:,2) + 0.3 * converted_nir;
         %output_rgb_filtered(:,:,3) = converted_rgb(:,:,3) + 0.3 * converted_nir;
        window_size = [64 64];
         %wiener filter
        output_cmyg_filtered(:,:,1) = wiener2(output_cmyg_filtered(:,:,1), window_size);
        output_cmyg_filtered(:,:,2) = wiener2(output_cmyg_filtered(:,:,2), window_size);
        output_cmyg_filtered(:,:,3) = wiener2(output_cmyg_filtered(:,:,3), window_size);
        output_cmyg_filtered(:,:,4) = wiener2(output_cmyg_filtered(:,:,4), window_size);
     %   output_nir_filtered = wiener2(output_nir_filtered, [8 8]);


    elseif strcmp(method, 'BM3D') == true
        [NA, output_cmyg_filtered(:,:,1)] = BM3D(1, output_cmyg_filtered(:,:,1), 32); 
        [NA, output_cmyg_filtered(:,:,2)] = BM3D(1, output_cmyg_filtered(:,:,2), 32); 
        [NA, output_cmyg_filtered(:,:,3)] = BM3D(1, output_cmyg_filtered(:,:,3), 32); 
        [NA, output_cmyg_filtered(:,:,4)] = BM3D(1, output_cmyg_filtered(:,:,4), 32); 
    elseif strcmp(method, 'bilateral') == true
        % Set bilateral filter parameters.
        w     = 5;       % bilateral filter half-width
        sigma = [3 0.1]; % bilateral filter standard deviations

        % Apply bilateral filter to each image.
        output_cmyg_filtered(:,:,1) = bfilter2(output_cmyg_filtered(:,:,1),w,sigma);
        output_cmyg_filtered(:,:,2) = bfilter2(output_cmyg_filtered(:,:,2),w,sigma);
        output_cmyg_filtered(:,:,3) = bfilter2(output_cmyg_filtered(:,:,3),w,sigma);
        output_cmyg_filtered(:,:,4) = bfilter2(output_cmyg_filtered(:,:,4),w,sigma);
    end
    % add new methods

end

