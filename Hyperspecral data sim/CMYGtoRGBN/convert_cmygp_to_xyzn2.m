function [ output_xyz, output_nir ] = convert_cmygp_to_xyzn2( interpolated_cmyg_prime )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(interpolated_cmyg_prime);
    
    output_xyz = zeros(resolution(1), resolution(2), 3);
    output_nir = zeros(resolution(1), resolution(2));
    
    %converted_xyzn = zeros(resolution(1), resolution(2), 4);
    
a = 1;
    gamma = [0.8337/a 0.9833/a 0.8296/a a];
    %cmygp_rgbn = [-0.0566 0.3293 0.2021 gamma(1); 0.1235 0.1361 0.1358 gamma(2); 0.0943 0.3851 0.0415 gamma(3); -0.0342 0.3475 0.0848 gamma(4)];
    cmygp_xyzn = [-0.3258    0.8361    0.2093 gamma(1); 0.9444   -0.2529    0.0440 gamma(2); 0.4117    0.6952   -0.1874 gamma(3); -0.3430    0.9749    0.0038 gamma(4)];
    %

    bias = [0.0450 0.0447 0.0608 0.0389]';
    bias = bias * ones(1, resolution(1) * resolution(2));

   % cmyg_rgb = normc(cmyg_rgb);
    
    xyzn_cmygp = cmygp_xyzn^-1;
    converted_xyzn_vec = xyzn_cmygp * (image_to_vector(interpolated_cmyg_prime) - bias);
    converted_xyzn = vector_to_image(converted_xyzn_vec, resolution(1), resolution(2));
    
    %for i = 1:resolution(1)
    %    for j = 1:resolution(2)
    %        converted_xyzn(i, j, :) = xyzn_cmygp * [interpolated_cmyg_prime(i, j, 1); interpolated_cmyg_prime(i, j, 2); interpolated_cmyg_prime(i, j, 3); interpolated_cmyg_prime(i, j, 4)];
    %    end
    %end
    
    
     output_xyz(:,:,:) = converted_xyzn(:,:,1:3);
     output_nir(:,:) = converted_xyzn(:,:,4);
end

