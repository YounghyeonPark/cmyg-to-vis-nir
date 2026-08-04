function [ output_rgb, output_nir ] = convert_cmygp_to_rgbn( interpolated_cmyg_prime )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(interpolated_cmyg_prime);
    

    
    
    output_rgb = zeros(resolution(1), resolution(2), 3);
    output_nir = zeros(resolution(1), resolution(2));
    
    converted_rgbn = zeros(resolution(1), resolution(2), 4);
    

    gamma = [0.8337 0.9833 0.8296 1.0000];
    %gamma = [0.3 0.3 0.3 0.3];
    cmygp_rgbn = [-0.0566 0.3293 0.2021 gamma(1); 0.1235 0.1361 0.1358 gamma(2); 0.0943 0.3851 0.0415 gamma(3); -0.0342 0.3475 0.0848 gamma(4)];
    %
    
   % cmyg_rgb = normc(cmyg_rgb);
    
    rgbn_cmygp = cmygp_rgbn^-1;
    for i = 1:resolution(1)
        for j = 1:resolution(2)
            converted_rgbn(i, j, :) = rgbn_cmygp * [interpolated_cmyg_prime(i, j, 1); interpolated_cmyg_prime(i, j, 2); interpolated_cmyg_prime(i, j, 3); interpolated_cmyg_prime(i, j, 4)];
        end
    end
    
    
     output_rgb(:,:,:) = converted_rgbn(:,:,1:3);
     output_nir(:,:) = converted_rgbn(:,:,4);
end

