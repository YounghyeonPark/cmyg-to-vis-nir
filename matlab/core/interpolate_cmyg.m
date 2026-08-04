function [ output_cmyg ] = interpolate_cmyg( input_bayer_cmyg, model )
% INTERPOLATE_CMYG Demosaic 2x2 CMYG Bayer Pattern
    resolution = size(input_bayer_cmyg);

    bayer_C = zeros(resolution);
    bayer_M = zeros(resolution);
    bayer_Y = zeros(resolution);
    bayer_G = zeros(resolution);
    
    output_cmyg = double(zeros(resolution(1), resolution(2), 4));
    
    for i = 1:resolution(1)
       for j = 1:resolution(2)
           if (mod(i,2) == 1 && mod(j,2) == 1)      % Left Top
               bayer_G(i,j) = input_bayer_cmyg(i, j);
           elseif (mod(i,2) == 1 && mod(j,2) == 0)  % Right Top
               bayer_M(i,j) = input_bayer_cmyg(i, j);    
           elseif (mod(i,2) == 0 && mod(j,2) == 1)  % Left Bottom
               bayer_Y(i,j) = input_bayer_cmyg(i, j);    
           else                                     % Right Bottom
               bayer_C(i,j) = input_bayer_cmyg(i, j);
           end
       end
    end

    interpolated_G = double(interpolation_LT(bayer_G));
    interpolated_M = double(interpolation_RT(bayer_M));
    interpolated_Y = double(interpolation_LB(bayer_Y));
    interpolated_C = double(interpolation_RB(bayer_C));

    % /4095 (12bit) normalization
    output_cmyg(:,:,1) = interpolated_C ./ (2 ^ 12 - 1);
    output_cmyg(:,:,2) = interpolated_M ./ (2 ^ 12 - 1);
    output_cmyg(:,:,3) = interpolated_Y ./ (2 ^ 12 - 1);
    output_cmyg(:,:,4) = interpolated_G ./ (2 ^ 12 - 1);
end
