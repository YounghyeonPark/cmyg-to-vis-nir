function [ interpolated ] = interpolation_LT( org )
    img_height = size(org, 1);
    img_width = size(org, 2);
    interpolated = org;    
        
    for i = 1:2:(img_height - 1)
        for j = 2:2:(img_width - 2)
            interpolated(i,j) = (interpolated(i,j-1) + interpolated(i,j+1)) / 2;
        end
    end
    
    for i = 2:2:(img_height - 2)
        for j = 1:2:(img_width - 1)
            interpolated(i,j) = (interpolated(i-1,j) + interpolated(i+1,j)) / 2;
        end
    end

    for i = 2:2:(img_height - 2)
        for j = 2:2:(img_width - 1)
            interpolated(i,j) = (interpolated(i-1,j) + interpolated(i+1,j) + interpolated(i,j-1) + interpolated(i,j+1)) / 4;
        end
    end

    interpolated(:,img_width) = interpolated(:,img_width-1);
    interpolated(img_height,:) = interpolated(img_height-1,:);
end
