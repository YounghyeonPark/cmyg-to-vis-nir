function [ output_rgb_filtered ] = denoise_rgb( converted_rgb, converted_nir, mixed_rgb, method )
%DENOISE_RGB Summary of this function goes here
%   Detailed explanation goes here
    output_rgb_filtered = converted_rgb;
 %   output_nir_filtered = converted_nir;

    if strcmp(method, 'wiener') == true
         % Trick 
         output_rgb_filtered(:,:,1) = converted_rgb(:,:,1) + 0.3 * converted_nir;
         output_rgb_filtered(:,:,2) = converted_rgb(:,:,2) + 0.3 * converted_nir;
         output_rgb_filtered(:,:,3) = converted_rgb(:,:,3) + 0.3 * converted_nir;

         %wiener filter
        output_rgb_filtered(:,:,1) = wiener2(output_rgb_filtered(:,:,1), [8 8]);
        output_rgb_filtered(:,:,2) = wiener2(output_rgb_filtered(:,:,2), [8 8]);
        output_rgb_filtered(:,:,3) = wiener2(output_rgb_filtered(:,:,3), [8 8]);     
    end
    
    if strcmp(method, 'nirAdaptive') == true
        
        Y_id = 1; Cb_id = 2; Cr_id = 3;
        converted_yuv = rgb2ycbcr(converted_rgb);
        output_ycbcr_filtered(:,:,Y_id)  = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,Y_id), converted_nir, converted_yuv(:,:,Y_id), Y_id);     plotFlag = 1; figure, imshow(output_ycbcr_filtered(:,:,Y_id), [0 1]), title('Denoised R'); 
        output_ycbcr_filtered(:,:,Cb_id) = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,Cb_id), converted_nir, converted_yuv(:,:,Cb_id), Cb_id);  plotFlag = 1; figure, imshow(output_ycbcr_filtered(:,:,Cb_id), [0 1]), title('Denoised G'); 
        output_ycbcr_filtered(:,:,Cr_id) = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,Cr_id), converted_nir, converted_yuv(:,:,Cr_id), Cr_id);  plotFlag = 1; figure, imshow(output_ycbcr_filtered(:,:,Cr_id), [0 1]), title('Denoised B'); 
        output_rgb_filtered = ycbcr2rgb(output_ycbcr_filtered);
        figure, imshow(converted_rgb), title('converted rgb');
        figure, imshow(output_rgb_filtered), title('output rgb filtered in ycbcr');
        
        R_id = 1; G_id = 2; B_id = 3; 
        output_rgb_filtered(:,:,R_id) = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,R_id), converted_nir, converted_rgb(:,:,R_id), R_id);  plotFlag = 1; figure, imshow(output_rgb_filtered(:,:,R_id), [0 1]), title('Denoised R'); 
        output_rgb_filtered(:,:,G_id) = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,G_id), converted_nir, converted_rgb(:,:,G_id), G_id);  plotFlag = 1; figure, imshow(output_rgb_filtered(:,:,G_id), [0 1]), title('Denoised G'); 
        output_rgb_filtered(:,:,B_id) = AdaptiveDenoising4RGBNIR_20150615(mixed_rgb(:,:,B_id), converted_nir, converted_rgb(:,:,B_id), B_id);  plotFlag = 1; figure, imshow(output_rgb_filtered(:,:,B_id), [0 1]), title('Denoised B'); 
        figure, imshow(converted_rgb), title('converted rgb');
        figure, imshow(output_rgb_filtered), title('output rgb filtered in rgb');
    end
end

