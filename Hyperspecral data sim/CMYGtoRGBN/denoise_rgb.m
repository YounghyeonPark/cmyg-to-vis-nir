function [ output_rgb_filtered ] = denoise_rgb( separated_rgb, separated_nir, mixed_xyz, mixed_cmyg, method )
%DENOISE_RGB Summary of this function goes here
%   Detailed explanation goes here
    output_rgb_filtered = separated_rgb;
 %   output_nir_filtered = converted_nir;

    if strcmp(method, 'wiener') == true
         % Trick 
         %output_rgb_filtered(:,:,1) = separated_rgb(:,:,1) + 0.3 * separated_nir;
         %output_rgb_filtered(:,:,2) = separated_rgb(:,:,2) + 0.3 * separated_nir;
         %output_rgb_filtered(:,:,3) = separated_rgb(:,:,3) + 0.3 * separated_nir;

         %wiener filter
        output_rgb_filtered(:,:,1) = wiener2(output_rgb_filtered(:,:,1), [8 8]);
        output_rgb_filtered(:,:,2) = wiener2(output_rgb_filtered(:,:,2), [8 8]);
        output_rgb_filtered(:,:,3) = wiener2(output_rgb_filtered(:,:,3), [8 8]);
        %output_nir_filtered = wiener2(output_nir_filtered, [8 8]);


    elseif strcmp(method, 'guided') == true
            
        %output_rgb_filtered(:,:,1) = imguidedfilter(separated_rgb(:,:,1),mixed_cmyg(:,:,4), 'NeighborhoodSize', [8 8]);
        %output_rgb_filtered(:,:,2) = imguidedfilter(separated_rgb(:,:,2),mixed_cmyg(:,:,4), 'NeighborhoodSize', [8 8]);
        %output_rgb_filtered(:,:,3) = imguidedfilter(separated_rgb(:,:,3),mixed_cmyg(:,:,4), 'NeighborhoodSize', [8 8]);
        %Guided
        output_rgb_filtered(:,:,1) = guidedfilter_cmyg(mixed_cmyg, separated_rgb(:,:,1), 16, 0.00005);
        output_rgb_filtered(:,:,2) = guidedfilter_cmyg(mixed_cmyg, separated_rgb(:,:,2), 16, 0.00005);
        output_rgb_filtered(:,:,3) = guidedfilter_cmyg(mixed_cmyg, separated_rgb(:,:,3), 16, 0.00005);
               
        %Edge preserved
        %output_rgb_filtered = imguidedfilter(separated_rgb,separated_rgb, 'NeighborhoodSize', [5 5]);
    elseif strcmp(method, 'BM3D') == true
        [NA, output_rgb_filtered(:,:,1)] = BM3D(1, separated_rgb(:,:,1), 32); 
        [NA, output_rgb_filtered(:,:,2)] = BM3D(1, separated_rgb(:,:,2), 32); 
        [NA, output_rgb_filtered(:,:,3)] = BM3D(1, separated_rgb(:,:,3), 32); 
    
      
    
    elseif strcmp(method, 'agf') == true
        % RGB denoising
        %G           = mean(mixed_cmyg, 4);
        G            = mixed_cmyg(:,:,4);
        sigma       = 20;
        filtSize    = 12;
        num_channels=  3;
        separated_yuv = zeros(size(separated_rgb));
        separated_yuv(:,:,1) = mean(separated_rgb(:)) * G / mean(G(:));
        separated_yuv(:,:,2) = -0.25*separated_rgb(:,:,1) + 0.50*separated_rgb(:,:,2) - 0.25*separated_rgb(:,:,3);
        separated_yuv(:,:,3) =  0.50*separated_rgb(:,:,1)                             - 0.50*separated_rgb(:,:,3);
        for ch_id = 2:num_channels
            A       = separated_yuv(:,:,ch_id);
            separated_yuv(:,:,ch_id) ...
                    = AdaptiveGuidedFilter(A,G,filtSize,sigma);
        end
        output_rgb_filtered          = zeros(size(separated_rgb));
        tmp                          = separated_yuv(:,:,1)   - separated_yuv(:,:,2);
        output_rgb_filtered(:,:,1)   = tmp                    + separated_yuv(:,:,3);
        output_rgb_filtered(:,:,2)   = separated_yuv(:,:,1)   + separated_yuv(:,:,2);
        output_rgb_filtered(:,:,3)   = tmp                    - separated_yuv(:,:,3);    
        figure,imshow(output_rgb_filtered/max(output_rgb_filtered(:)));
        
        % NIR denoising
        %G           = mean(mixed_cmyg, 4);
        G            = mixed_cmyg(:,:,4);
        sigma       = 10;
        filtSize    = 6;
        output_nir_filtered = AdaptiveGuidedFilter(separated_nir,G,filtSize,sigma);
        figure,imshow(output_nir_filtered,[]);
    end
    % add new methods

end

