function output_rgb = demosaic_rgb(bayer_rgb)
 %INTERPOLATE_CMYG Summary of this function goes here
%   Detailed explanation goes here
    


    resolution = size(bayer_rgb);

    bayer_R = zeros(resolution);
    bayer_G = zeros(resolution);
    bayer_B = zeros(resolution);
    

    output_rgb = double(zeros(resolution(1), resolution(2), 3));

    for i = 1:resolution(1)
       for j = 1:resolution(2)

           if (mod(i,2) == 1 && mod(j,2) == 1) % Left Top
               bayer_G(i,j) = bayer_rgb(i, j);

           elseif (mod(i,2) == 1 && mod(j,2) == 0) % Right Top
               bayer_B(i,j) = bayer_rgb(i, j);    

           elseif (mod(i,2) == 0 && mod(j,2) == 1) % Left Bottom
               bayer_R(i,j) = bayer_rgb(i, j);    

           else                                     % Right Bottom
               bayer_G(i,j) = bayer_rgb(i, j);

           end

       end

    end


    interpolated_G = double(interpolation_LT_RB(bayer_G));
    interpolated_B = double(interpolation_RT(bayer_B));
    interpolated_R = double(interpolation_LB(bayer_R));
    


    
    output_rgb(:,:,1) = interpolated_R;
    output_rgb(:,:,2) = interpolated_G;
    output_rgb(:,:,3) = interpolated_B;
    



end

