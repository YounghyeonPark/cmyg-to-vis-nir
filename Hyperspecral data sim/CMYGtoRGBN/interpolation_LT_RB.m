function [ interpolated ] = interpolation_LT_RB( bayer )
%INTERPOLATION_LT Summary of this function goes here
%   Detailed explanation goes here
%   Detailed explanation goes here
img_height = size(bayer, 1);
img_width = size(bayer, 2);


interpolated = bayer;    

   
avail_top = true;
avail_bottom = true;
avail_left = true;
avail_right = true;
acc_value = 0;
acc_count = 0;

for i=1:img_height
    for j=1:img_width
        if (mod(i,2) == 0 && mod(j,2) == 1) || (mod(i,2) == 1 && mod(j,2) == 0)% (even row & odd col) or (odd row & even col)

            if i == 1
                avail_top = false;

            end

            if j == 1
                avail_left = false;
            end

            if i == img_height
                avail_bottom = false;
            end

            if j == img_width
                avail_right = false;
            end

            if avail_top == true
                acc_value = acc_value + interpolated(i-1,j);
                acc_count = acc_count + 1;
            end

            if avail_bottom == true
                acc_value = acc_value + interpolated(i+1,j);
                acc_count = acc_count + 1;
            end


            if avail_left == true
                acc_value = acc_value + interpolated(i,j-1);
                acc_count = acc_count + 1;
            end


            if avail_right == true
                acc_value = acc_value + interpolated(i,j+1);
                acc_count = acc_count + 1;
            end

            interpolated(i,j) = double(acc_value / acc_count);

            
        end
        
        avail_top = true;
        avail_bottom = true;
        avail_left = true;
        avail_right = true;
        acc_value = 0;
        acc_count = 0;

        
    end
end


end

