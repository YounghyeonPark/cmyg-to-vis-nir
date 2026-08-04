function [ output_xyz ] = convert_cmyg_to_xyz2( input_cmyg )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(input_cmyg);
        
    cmyg_xyz = [-0.3258    0.8361    0.2093; 0.9444   -0.2529    0.0440; 0.4117    0.6952   -0.1874; -0.3430    0.9749    0.0038];
    %

    bias = [0.0450 0.0447 0.0608 0.0389]';
    bias = bias * ones(1, resolution(1) * resolution(2));
    
    %cmyg_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];
    %xyz_gmyc = [-0.5368,1.1478,0.2368,0.5537;-0.0113,0.3148,-0.4969,1.0021;0.5782,0.0778,0.9028,0.0211];
    %xyz_cmyg = [0.5537,1.1478,0.2368,-0.5368;1.0021,0.3148,-0.4969,-0.0113;0.0211,0.0778,0.9028,0.5782];
    %rgb_xyz=[ 0.412453, 0.357580, 0.180423; 0.212671, 0.715160, 0.072169;0.019334, 0.119193, 0.950227];
   % cmyg_rgb = normc(cmyg_rgb);
    
    xyz_cmyg = pinv(cmyg_xyz);
    %output_xyz = zeros(resolution(1), resolution(2), 3);
    
    output_xyz_vec = xyz_cmyg * (image_to_vector(input_cmyg) - bias);
    
    output_xyz = vector_to_image(output_xyz_vec, resolution(1), resolution(2));
    
%    rgb_cmyg = xyz_cmyg;
    %for i = 1:resolution(1)
    %    for j = 1:resolution(2)
    %        output_xyz(i, j, :) = xyz_cmyg * [input_cmyg(i,j,1); input_cmyg(i,j,2);input_cmyg(i,j,3);input_cmyg(i,j,4)];
    %    end
    %end
end

