function [ output_rgb ] = convert_cmyg_to_rgb( input_cmyg )
%CONVERT_CMYG_TO_RGB Summary of this function goes here
%   Detailed explanation goes here
    resolution = size(input_cmyg);
    cmyg_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];
    
   % cmyg_rgb = normc(cmyg_rgb);
    
    rgb_cmyg = pinv(cmyg_rgb);
    for i = 1:resolution(1)
        for j = 1:resolution(2)
            output_rgb(i, j, :) = rgb_cmyg * [input_cmyg(i,j,1); input_cmyg(i,j,2);input_cmyg(i,j,3);input_cmyg(i,j,4)];
        end
    end
end

