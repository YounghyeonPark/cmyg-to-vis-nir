function [ interpolated ] = interpolation_RT( bayer )
%INTERPOLATION Summary of this function goes here
%   Detailed explanation goes here
img_height = size(bayer, 1);
img_width = size(bayer, 2);


    interpolated = bayer;    

        
    for i = 1:2:(img_height - 1)
        for j = 3:2:(img_width - 1)
            interpolated(i,j) = (interpolated(i,j-1) + interpolated(i,j+1)) / 2;
            
        end
    end
    
    
    
    for i = 2:2:(img_height - 2)
        for j = 2:2:(img_width)
            interpolated(i,j) = (interpolated(i-1,j) + interpolated(i+1,j)) / 2;
            
        end
    end
    
    for i = 2:2:(img_height - 2)
        for j = 3:2:(img_width)
            interpolated(i,j) = (interpolated(i-1,j) + interpolated(i+1,j) + interpolated(i,j-1) + interpolated(i,j+1)) / 4;
            
        end
    end
%     
     interpolated(:,1) = interpolated(:,2);
     interpolated(img_height,:) = interpolated(img_height-1,:);

end

