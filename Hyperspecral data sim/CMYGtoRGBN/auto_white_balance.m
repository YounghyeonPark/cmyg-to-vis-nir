function [ output_rgb ] = auto_white_balance( input_rgb, method )
%AUTO_WHITE_BALANCE 이 함수의 요약 설명 위치
%   자세한 설명 위치
    
    if strcmp(method, 'grayworld') == true
        r = input_rgb(:,:,1);
        g = input_rgb(:,:,2);
        b = input_rgb(:,:,3);
        output_rgb = input_rgb;
    
        
        avg_r = mean(r(:));
        avg_g = mean(g(:));
        avg_b = mean(b(:));
        alpha = avg_g / avg_r;
        beta = avg_g / avg_b;
        
        output_rgb(:,:,1) = alpha .* r;
        output_rgb(:,:,2) = g;
        output_rgb(:,:,3) = beta .* b;
        
        
        
    elseif strcmp(method, 'grayworld+retinex')
        resolution = size(input_rgb);
        number_of_pixels = resolution(1) * resolution(2);
        
        r = input_rgb(:,:,1);
        g = input_rgb(:,:,2);
        b = input_rgb(:,:,3);
        output_rgb = input_rgb;
    
        
        avg_r = mean(r(:));
        avg_g = mean(g(:));
        avg_b = mean(b(:));
        
        max_g = max(g(:));
        
        A_r_11 = sum(r(:).^2);
        A_r_12 = sum(r(:));
        A_r_21 = max(r(:).^2);
        A_r_22 = max(r(:));
        A_r = [A_r_11, A_r_12; A_r_21, A_r_22];
        
        A_b_11 = sum(b(:).^2);
        A_b_12 = sum(b(:));
        A_b_21 = max(b(:).^2);
        A_b_22 = max(b(:));
        A_b = [A_b_11, A_b_12; A_b_21, A_b_22];
        
        B = [number_of_pixels * avg_g; max_g];
        
        C_r = (A_r^-1) * B;
        C_b = (A_b^-1) * B;
        mu_r = C_r(1);
        nu_r = C_r(2);
        mu_b = C_b(1);
        nu_b = C_b(2);
        output_rgb(:,:,1) = mu_r .* (r.^2) + nu_r .* r;
        output_rgb(:,:,3) = mu_b .* (b.^2) + nu_b .* b;
        
    elseif strcmp(method, 'custom_fluorescent')
       output_rgb = input_rgb;
       ref_white_fluorescent = imread('White_fluorescent.pgm');
       
       
       ref_white_fluorescent = defective_pixel_correction(ref_white_fluorescent, 'coolpix5700');
       
       
       ref_white_fluorescent_interpolated = interpolate_cmyg(ref_white_fluorescent, 'coolpix5700');
       
       
       ref_white_fluorescent_rgb = convert_cmyg_to_rgb(ref_white_fluorescent_interpolated);
       
       
       r = ref_white_fluorescent_rgb(:,:,1);
       g = ref_white_fluorescent_rgb(:,:,2);
       b = ref_white_fluorescent_rgb(:,:,3);
     %  r = ref_white_sunlight_rgb(:,:,1);
     %  g = ref_white_sunlight_rgb(:,:,2);
     %  b = ref_white_sunlight_rgb(:,:,3);
       str = ['avg R : ', num2str(mean(r(:))), ', avg G : ', num2str(mean(g(:))),' , avg B : ', num2str(mean(b(:)))];
       disp(str);
       
       avg_r = mean(r(:));
       avg_g = mean(g(:));
       avg_b = mean(b(:));
       alpha = avg_g / avg_r;
       beta = avg_g / avg_b;
        
       output_rgb(:,:,1) = alpha .* input_rgb(:,:,1);
       output_rgb(:,:,2) = input_rgb(:,:,2);
       output_rgb(:,:,3) = beta .* input_rgb(:,:,3);
    elseif strcmp(method, 'custom_sunlight')
        
       output_rgb = input_rgb;
       
       ref_white_sunlight = imread('White_sunlight.pgm');
       
       
       ref_white_sunlight = defective_pixel_correction(ref_white_sunlight, 'coolpix5700');
       
       
       ref_white_sunlight_interpolated = interpolate_cmyg(ref_white_sunlight, 'coolpix5700');
       
       
       ref_white_sunlight_rgb = convert_cmyg_to_rgb(ref_white_sunlight_interpolated);
       
     
       r = ref_white_sunlight_rgb(:,:,1);
       g = ref_white_sunlight_rgb(:,:,2);
       b = ref_white_sunlight_rgb(:,:,3);
       str = ['avg R : ', num2str(mean(r(:))), ', avg G : ', num2str(mean(g(:))),' , avg B : ', num2str(mean(b(:)))];
       disp(str);
       
       avg_r = mean(r(:));
       avg_g = mean(g(:));
       avg_b = mean(b(:));
       alpha = avg_g / avg_r;
       beta = avg_g / avg_b;
        
       output_rgb(:,:,1) = alpha .* input_rgb(:,:,1);
       output_rgb(:,:,2) = input_rgb(:,:,2);
       output_rgb(:,:,3) = beta .* input_rgb(:,:,3);
    end



end

