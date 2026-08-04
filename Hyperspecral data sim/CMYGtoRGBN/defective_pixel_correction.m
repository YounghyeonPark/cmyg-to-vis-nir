function [ output_bayer ] = defective_pixel_correction( input_bayer, model )
%DEFECTIVE_PIXEL_CORRECTION 이 함수의 요약 설명 위치
%   자세한 설명 위치
    resolution = size(input_bayer);
    output_bayer = input_bayer;
    avail_top = true;
    avail_bottom = true;
    avail_left = true;
    avail_right = true;

    if strcmp(model, 'coolpix5700') == true
        defective_map_black = imread('Defective_Black_map_Coolpix5700.pgm');
        defective_map_white = imread('Defective_White_map_Coolpix5700.pgm');
        %defective_thd_black = 2^12-1;
        defective_thd_black = 50;
        defective_thd_white = 100;
        
        [row_blk, col_blk] = find(defective_map_black > defective_thd_black);
        [row_wht, col_wht] = find(defective_map_white < defective_thd_white);
        row = [row_blk',row_wht']';
        col = [col_blk',col_wht']';
        
        for k = 1:size(row)
            acc_value = 0;
            acc_count = 0;
            if row(k) <= 2
                avail_top = false;

            end

            if col(k) <= 2
                avail_left = false;
            end

            if row(k) >= resolution(1) - 1
                avail_bottom = false;
            end

            if col(k) >= resolution(2) - 1
                avail_right = false;
            end

            if avail_top == true
                acc_value = acc_value + input_bayer(row(k) - 2,col(k));
                acc_count = acc_count + 1;
            end

            if avail_bottom == true
                acc_value = acc_value + input_bayer(row(k) + 2,col(k));
                acc_count = acc_count + 1;
            end


            if avail_left == true
                acc_value = acc_value + input_bayer(row(k),col(k) - 2);
                acc_count = acc_count + 1;
            end


            if avail_right == true
                acc_value = acc_value + input_bayer(row(k),col(k) + 2);
                acc_count = acc_count + 1;
            end

            output_bayer(row(k),col(k)) = uint16(acc_value / acc_count);

        
        
        
        end
        
        
        
        
        
    end
end

