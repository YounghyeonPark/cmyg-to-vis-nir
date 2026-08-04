%CMYG-NIR to RGB, NIR conversion
close all;
clear all;
addpath('./images');

%filename = 'RGB.NEF.pgm';
%filename = 'piggybank_w_IRFlash.NEF.pgm';
%filename = 'piggybank_wo_IRFlash.NEF.pgm';
%filename = 'Box_Black_NIR_only.pgm';
%filename = 'Box_White_NIR_only.pgm';
%filename = 'Box_Object_NIR_only.pgm';
%filename = 'CMYG_light+NIR.pgm';
%filename = 'CMYG_NIR_cut.pgm';
%filename = 'CMYG_NIR_only.pgm';
%filename = 'RGB_NIR_only.pgm';
%filename = 'Outside1_RGB_NIR.pgm';
%filename = 'Outside2_RGB_NIR.pgm';
%filename = 'Objects_light+NIR.pgm';
%filename = 'Objects_NIR_cut.pgm';
%filename = 'Objects2_light+NIR.pgm';
%filename = 'hand_light+NIR.pgm';
%filename = 'hand2_light+NIR.pgm';
%filename = 'orange1_light+NIR.pgm';
%filename = 'orange2_light+NIR.pgm';
% filename = 'orange3_light+NIR.pgm';
%filename = 'orange4_light+NIR.pgm';
%filename = 'plants1_light+NIR.pgm';
%filename = 'plants2_light+NIR.pgm';
%filename = 'lowlight_light+NIR.pgm';
%filename = 'badpixel_Coolpix5700.pgm';
%filename = 'natural_NIR+CMYG.pgm';
%filename = 'outside_wrist_sunlight.pgm';
%filename = 'Object3_light+NIR_wb.pgm';%
%filename = 'piggybank_lowlight_wb.pgm';
%filename = 'piggybank_lowlight+NIR_wb.pgm';
%filename = 'piggybank2_lowlight+NIR_wb.pgm';
%filename = 'Plants3_sunlight_wb.pgm';
%filename = 'Outside5_sunlight_wb.pgm';
filename = 'demo3.pgm'
bayer_CMYG = imread(filename);
resolution = size(bayer_CMYG);

bayer_C = zeros(resolution);
bayer_M = zeros(resolution);
bayer_Y = zeros(resolution);
bayer_G = zeros(resolution);

bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');


for i = 1:resolution(1)
   for j = 1:resolution(2)
     
       if (mod(i,2) == 1 && mod(j,2) == 1) % Left Top
           bayer_G(i,j) = bayer_CMYG(i, j);
           
       elseif (mod(i,2) == 1 && mod(j,2) == 0) % Right Top
           bayer_M(i,j) = bayer_CMYG(i, j);    
            
       elseif (mod(i,2) == 0 && mod(j,2) == 1) % Left Bottom
           bayer_Y(i,j) = bayer_CMYG(i, j);    
           
       else                                     % Right Bottom
           bayer_C(i,j) = bayer_CMYG(i, j);
       
       end
         
   end
    
end


interpolated_G = double(interpolation_LT(bayer_G));
interpolated_M = double(interpolation_RT(bayer_M));
interpolated_Y = double(interpolation_LB(bayer_Y));
interpolated_C = double(interpolation_RB(bayer_C));


% /4095 (12bit) : normalize (0 to 1)
interpolated_C = interpolated_C ./ (2 ^ 12 - 1);
interpolated_M = interpolated_M ./ (2 ^ 12 - 1);
interpolated_Y = interpolated_Y ./ (2 ^ 12 - 1);
interpolated_G = interpolated_G ./ (2 ^ 12 - 1);

              

%subplot(2,2,1), imshow(interpolated_C)
%subplot(2,2,2), imshow(interpolated_M)
%subplot(2,2,3), imshow(interpolated_Y)
%subplot(2,2,4), imshow(interpolated_G)


alpha = 1; %birghtness control factor;
beta = 1; % red control factor;
%gamma = [1 1 1 1];
%gamma = [0.974 0.810 0.805 1];

gamma_C = [1.0000 1.1882 1.0035 1.2188];
gamma_M = [0.8545 1.0000 0.8503 1.0338];
gamma_Y = [1.0127 1.1932 1.0000 1.2239];
gamma_G = [0.8337 0.9833 0.8296 1.0000];

gamma = gamma_G;
CMYG_cmygn = [1 0 0 0 gamma(1); 0 1 0 0 gamma(2); 0 0 1 0 gamma(3); 0 0 0 1 gamma(4)];
%cmygn_rgbn = [0 1 1 0; 1 0 1 0; 1 1 0 0; 0 1 0 0; 0 0 0 1];
%cmygn_rgbn = [-0.0566 0.3293 0.2021 0; 0.1235 0.1361 0.1358 0; 0.0943 0.3851 0.0415 0; -0.0342 0.3475 0.0848 0; 0 0 0 1];
%cmygp_rgbn = CMYG_cmygn * cmygn_rgbn;
%rgbn_cmygp = pinv(cmygp_rgbn);
%cmygp_rgbn = [0 1 1 gamma(1); 1 0 1 gamma(2); 1 1 0 gamma(3); 0 1 0 gamma(4)];
cmygp_rgbn = [-0.0566 0.3293 0.2021 gamma(1); 0.1235 0.1361 0.1358 gamma(2); 0.0943 0.3851 0.0415 gamma(3); -0.0342 0.3475 0.0848 gamma(4)];
cmygp_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];



%normalize
%cmygp_rgbn = normc(cmygp_rgbn);
%cmygp_rgb = normc(cmygp_rgb);

%alternative
%rgbn_cmygp = inv(cmygp_rgbn);
rgbn_cmygp = cmygp_rgbn^-1;
rgb_cmygp = pinv(cmygp_rgb);


converted_rgb = zeros(resolution(1), resolution(2), 3);
converted_nir = zeros(resolution(1), resolution(2));
converted_rgbn = zeros(resolution(1), resolution(2), 4);
converted_rgb_filtered = zeros(resolution(1), resolution(2), 3);
converted_nir_filtered = zeros(resolution(1), resolution(2));
mixed_rgb = zeros(resolution(1), resolution(2), 3);

 for i = 1:resolution(1)
   for j = 1:resolution(2)
      converted_rgbn(i, j, :) = rgbn_cmygp * [interpolated_C(i,j); interpolated_M(i,j); interpolated_Y(i,j); interpolated_G(i,j)];
      mixed_rgb(i, j, :) = rgb_cmygp * [interpolated_C(i,j); interpolated_M(i,j); interpolated_Y(i,j); interpolated_G(i,j)];
   end
 end
 
 converted_rgb(:,:,:) = converted_rgbn(:,:,1:3);
 converted_nir(:,:) = converted_rgbn(:,:,4);
 
 
 % 
 converted_rgb(:,:,1) = converted_rgb(:,:,1) + 0.3 * converted_nir;
 converted_rgb(:,:,2) = converted_rgb(:,:,2) + 0.3 * converted_nir;
 converted_rgb(:,:,3) = converted_rgb(:,:,3) + 0.3 * converted_nir;

 % Clipping 0 to 1
 %converted_rgb = converted_rgb;
 %converted_rgb(converted_rgb<0)=0;
 %converted_rgb(converted_rgb>1)=1;
 
 converted_nir = converted_nir.*2;
 %converted_nir(converted_nir<0)=0;
 %converted_nir(converted_nir>1)=1;
 
 addpath('./BM3D');
 sigma = 5;
% [NA, converted_rgb_filtered] = CBM3D(1, converted_rgb, sigma); 
 %[NA, converted_nir_filtered] = CBM3D(1, converted_nir, sigma); 

 
 %wiener filter
converted_rgb_filtered(:,:,1) = wiener2(converted_rgb(:,:,1), [8 8]);
converted_rgb_filtered(:,:,2) = wiener2(converted_rgb(:,:,2), [8 8]);
converted_rgb_filtered(:,:,3) = wiener2(converted_rgb(:,:,3), [8 8]);
converted_nir_filtered = wiener2(converted_nir, [8 8]);
 

 
%r=converted_rgb_filtered(:,:,1);
%g=converted_rgb_filtered(:,:,2);
%b=converted_rgb_filtered(:,:,3);

%cmap = [r(:) g(:) b(:)];

%figure, rgbplot(cmap), title('RGB plot');

%converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
%converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld+retinex');
converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');
%mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld+retinex');
%r=converted_rgb_filtered_awb(:,:,1);
%g=converted_rgb_filtered_awb(:,:,2);
%b=converted_rgb_filtered_awb(:,:,3);

%cmap = [r(:) g(:) b(:)];

%figure, rgbplot(cmap), title('RGB plot AWB');

%figure, imshow(converted_rgb_filtered), title('Separated RGB (Wiener filter)');
%figure, imshow(converted_nir_filtered), title('Separated NIR (Wiener filter)');
figure, imshow(converted_rgb), title('Separated RGB');
figure, imshow(converted_nir), title('Separated NIR');
figure, imshow(mixed_rgb), title('RGB+NIR');
figure, imshow(converted_rgb_filtered_awb), title('Separated RGB (Wiener filter, AWB)');
%figure, imshow(mixed_rgb_awb), title('RGB+NIR (AWB)');

str_filename_write_separated_RGB_wiener = [filename, '_separated_rgb(wiener)','.jpg'];
str_filename_write_separated_NIR_wiener = [filename, '_separated_nir(wiener)','.jpg'];
str_filename_write_separated_RGB = [filename, '_separated_rgb','.jpg'];
str_filename_write_separated_NIR = [filename, '_separated_nir','.jpg'];
str_filename_write_RGB_NIR = [filename, '_rgb+nir','.jpg'];
str_filename_write_separated_RGB_wiener_awb = [filename, '_separated_rgb(wiener,awb)','.jpg'];
str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)','.jpg'];

imwrite(converted_rgb_filtered, str_filename_write_separated_RGB_wiener);
imwrite(converted_nir_filtered, str_filename_write_separated_NIR_wiener);
imwrite(converted_rgb, str_filename_write_separated_RGB);
imwrite(converted_nir, str_filename_write_separated_NIR);
imwrite(mixed_rgb, str_filename_write_RGB_NIR);
imwrite(mixed_rgb_awb, str_filename_write_RGB_NIR_awb);
imwrite(converted_rgb_filtered_awb, str_filename_write_separated_RGB_wiener_awb);


% Gradient x,y
% [grad_x_r grad_y_r] = imgradientxy(converted_rgb(:,:,1));
% [grad_x_g grad_y_g] = imgradientxy(converted_rgb(:,:,2));
% [grad_x_b grad_y_b] = imgradientxy(converted_rgb(:,:,3));
% [grad_x_nir grad_y_nir] = imgradientxy(converted_nir);
% [grad_x_r_nir grad_y_r_nir] = imgradientxy(mixed_rgb(:,:,1));
% [grad_x_g_nir grad_y_g_nir] = imgradientxy(mixed_rgb(:,:,2));
% [grad_x_b_nir grad_y_b_nir] = imgradientxy(mixed_rgb(:,:,3));
% 
% % Total Variation(Isotropic)
% tv_r = sum(sqrt(grad_x_r(:) .^ 2 + grad_y_r(:) .^ 2));
% tv_g = sum(sqrt(grad_x_g(:) .^ 2 + grad_y_g(:) .^ 2));
% tv_b = sum(sqrt(grad_x_b(:) .^ 2 + grad_y_b(:) .^ 2));
% tv_nir = sum(sqrt(grad_x_nir(:) .^ 2 + grad_y_nir(:) .^ 2));
% tv_r_nir = sum(sqrt(grad_x_r_nir(:) .^ 2 + grad_y_r_nir(:) .^ 2));
% tv_g_nir = sum(sqrt(grad_x_g_nir(:) .^ 2 + grad_y_g_nir(:) .^ 2));
% tv_b_nir = sum(sqrt(grad_x_b_nir(:) .^ 2 + grad_y_b_nir(:) .^ 2));
% 
% disp(['TV(Red Ch) : ' num2str(tv_r) ' TV(NIR Ch) : ' num2str(tv_nir) ' TV(Red+NIR Ch) : ' num2str(tv_r_nir)]);

%converted_ycbcr_filtered = rgb2ycbcr(converted_rgb_filtered);
%converted_ycbcr_filtered(:,:,1) = converted_ycbcr_filtered(:,:,1) + converted_nir_filtered;
%converted_ycbcr_filtered(:,:,2) = converted_ycbcr_filtered(:,:,2);
%converted_ycbcr_filtered(:,:,3) = converted_ycbcr_filtered(:,:,3);
%enhanced_rgb = ycbcr2rgb(converted_ycbcr_filtered);


converted_hsv_filtered = rgb2hsv(converted_rgb_filtered_awb);
converted_hsv_filtered(:,:,1) = converted_hsv_filtered(:,:,1); %Hue
%converted_hsv_filtered(:,:,2) = converted_hsv_filtered(:,:,2) + converted_nir_filtered; %Saturation
converted_hsv_filtered(:,:,3) = (converted_hsv_filtered(:,:,3) + converted_nir_filtered*3)/2; % Value(Intensity)
enhanced_rgb = hsv2rgb(converted_hsv_filtered);


%figure, imshow(enhanced_rgb), title('Enhanced RGB using NIR');
