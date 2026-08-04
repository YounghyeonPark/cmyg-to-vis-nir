function [ output_xyz ] = convert_cmyg_to_xyz( input_cmyg, lightsource )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(input_cmyg);
    
    if strcmp(lightsource, 'fluorescent') == true
        cmyg_xyz = [-0.1871 0.7767 0.2471; 1.0820 -0.3119 0.0815; 0.5988 0.6150 -0.1364; -0.2231 0.9235 0.0365];
    
    elseif strcmp(lightsource, 'sunlight') == true
        cmyg_xyz = [0.2391 0.3952 0.3025; 2.6841 -1.3640 0.0456; 2.0932 -0.5112 -0.1288; 0.3023 0.4447 0.0986];
    
    end
    
    %cmyg_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];
    %xyz_gmyc = [-0.5368,1.1478,0.2368,0.5537;-0.0113,0.3148,-0.4969,1.0021;0.5782,0.0778,0.9028,0.0211];
    %xyz_cmyg = [0.5537,1.1478,0.2368,-0.5368;1.0021,0.3148,-0.4969,-0.0113;0.0211,0.0778,0.9028,0.5782];
    %rgb_xyz=[ 0.412453, 0.357580, 0.180423; 0.212671, 0.715160, 0.072169;0.019334, 0.119193, 0.950227];
   % cmyg_rgb = normc(cmyg_rgb);
    
    xyz_cmyg = pinv(cmyg_xyz);
    %output_xyz = zeros(resolution(1), resolution(2), 3);
    
    output_xyz_vec = xyz_cmyg * image_to_vector(input_cmyg);
    
    output_xyz = vector_to_image(output_xyz_vec, resolution(1), resolution(2));
    
%    rgb_cmyg = xyz_cmyg;
    %for i = 1:resolution(1)
    %    for j = 1:resolution(2)
    %        output_xyz(i, j, :) = xyz_cmyg * [input_cmyg(i,j,1); input_cmyg(i,j,2);input_cmyg(i,j,3);input_cmyg(i,j,4)];
    %    end
    %end
end

