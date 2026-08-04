function [ output_rgb ] = convert_xyz_to_srgb( input_xyz )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(input_xyz);
    rgblinear_xyz = [3.2406 -1.5372 -0.4986;-0.9689 1.8758 0.0415;0.0557 -0.2040 1.0570];
    
    xyz_vec = image_to_vector(input_xyz);
    
    rgblinear_vec = rgblinear_xyz * xyz_vec;
    
    % crop below 0 or over 1 values
    
    rgblinear_vec(rgblinear_vec<0) = 0;
    rgblinear_vec(rgblinear_vec>1) = 1;
    
    size_vec = size(rgblinear_vec);
    
    % gamma correction...How to make it faster?
    alpha = 0.055;
    
    for i = 1:size_vec(2)
        for j = 1:size_vec(1) %channels
            
            if rgblinear_vec(j,i) <= 0.0031308
                rgblinear_vec(j,i) = 12.92 * rgblinear_vec(j,i);
            else
                rgblinear_vec(j,i) = ((1 + alpha) * (rgblinear_vec(j,i) .^ (1/2.4))) - alpha;
            end
        end
    end
    
    output_rgb = vector_to_image(rgblinear_vec, resolution(1),resolution(2));
  
end

