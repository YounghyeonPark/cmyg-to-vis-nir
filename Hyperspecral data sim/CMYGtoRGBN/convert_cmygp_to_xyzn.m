function [ output_xyz, output_nir, xyzn_cmygp ] = convert_cmygp_to_xyzn( interpolated_cmyg_prime, alpha, lightsource)
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(interpolated_cmyg_prime);
    
    output_xyz = zeros(resolution(1), resolution(2), 3);
    output_nir = zeros(resolution(1), resolution(2));
    
    %converted_xyzn = zeros(resolution(1), resolution(2), 4);
    

   % gamma = [0.8337/alpha 0.9833/alpha 0.8296/alpha alpha];
    %gamma = [0.8053/alpha 0.9730/alpha 0.8035/alpha 1];
    %gamma = [0.8053 0.9730 0.8035 1];
    gamma = [0.8053*alpha 0.9730*alpha 0.8035*alpha alpha];
    %cmygp_rgbn = [-0.0566 0.3293 0.2021 gamma(1); 0.1235 0.1361 0.1358 gamma(2); 0.0943 0.3851 0.0415 gamma(3); -0.0342 0.3475 0.0848 gamma(4)];
    
    if strcmp(lightsource, 'fluorescent') == true
        cmygp_xyzn = [-0.1871 0.7767 0.2471 gamma(1); 1.0820 -0.3119 0.0815 gamma(2); 0.5988 0.6150 -0.1364 gamma(3); -0.2231 0.9235 0.0365 gamma(4)];
        
    elseif strcmp(lightsource, 'sunlight') == true
        cmygp_xyzn = [0.2391 0.3952 0.3025 gamma(1); 2.6841 -1.3640 0.0456 gamma(2); 2.0932 -0.5112 -0.1288 gamma(3); 0.3023 0.4447 0.0986 gamma(4)];
        
    end
    
    
   % cmyg_rgb = normc(cmyg_rgb);
    
    xyzn_cmygp = cmygp_xyzn^-1;
    converted_xyzn_vec = xyzn_cmygp * image_to_vector(interpolated_cmyg_prime);
    converted_xyzn = vector_to_image(converted_xyzn_vec, resolution(1), resolution(2));
    
    %for i = 1:resolution(1)
    %    for j = 1:resolution(2)
    %        converted_xyzn(i, j, :) = xyzn_cmygp * [interpolated_cmyg_prime(i, j, 1); interpolated_cmyg_prime(i, j, 2); interpolated_cmyg_prime(i, j, 3); interpolated_cmyg_prime(i, j, 4)];
    %    end
    %end
    
    
     output_xyz(:,:,:) = converted_xyzn(:,:,1:3);
     output_nir(:,:) = converted_xyzn(:,:,4);
     
     %saturated region
%     for i=1:4
%      [row, col] = find(interpolated_cmyg_prime(:,:,i) == 1);
%      
%     
%     output_xyz(sub2ind(size(output_xyz), row, col)) = 1;
%     end
    %output_xyz(row,col,:) = 1;
    
end

