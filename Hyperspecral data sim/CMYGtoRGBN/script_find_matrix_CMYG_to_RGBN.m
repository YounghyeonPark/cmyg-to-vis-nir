%Find CMYG to RGB conversion matrix

close all;
clear all;
addpath('./images');

%bayer_CMYG = imread('RGB.NEF.pgm');
%bayer_CMYG = imread('piggybank_w_IRFlash.NEF.pgm');
%bayer_CMYG = imread('piggybank_wo_IRFlash.NEF.pgm');
%bayer_CMYG = imread('Box_Black_NIR_only.pgm');
%bayer_CMYG = imread('Box_White_NIR_only.pgm');
%bayer_CMYG = imread('Box_Object_NIR_only.pgm');
%bayer_CMYG = imread('CMYG_NIR_cut.pgm');
%bayer_CMYG = imread('CMYG_NIR_cut.pgm');
%bayer_CMYG = imread('CMYG_NIR_only.pgm');
%bayer_CMYG = imread('RGB_NIR_only.pgm');
%bayer_CMYG = imread('Outside1_RGB_NIR.pgm');
%bayer_CMYG = imread('Outside2_RGB_NIR.pgm');
bayer_CMYG = imread('Objects_light+NIR.pgm');
%bayer_CMYG = imread('Objects_NIR_cut.pgm');
%bayer_CMYG = imread('Objects2_light+NIR.pgm');
%RGB = imread('Objects2_light_hotmirror.TIF');
%NIR = imread('Objects2_NIR_only.TIF');
RGB = imread('Objects_NIR_cut.TIF');
NIR = imread('Objects_NIR_only.TIF');

resolution_CMYG = size(bayer_CMYG);
resolution_RGB = size(RGB);
crop_col = (resolution_CMYG(2) - resolution_RGB(2)) / 2;
crop_row = (resolution_CMYG(1) - resolution_RGB(1)) / 2;

bayer_CMYG = bayer_CMYG((crop_row + 1):(resolution_CMYG(1) - crop_row), (crop_col + 1):(resolution_CMYG(2) - crop_col));
resolution_CMYG = size(bayer_CMYG);


bayer_C = zeros(resolution_CMYG);
bayer_M = zeros(resolution_CMYG);
bayer_Y = zeros(resolution_CMYG);
bayer_G = zeros(resolution_CMYG);

for i = 1:resolution_CMYG(1)
   for j = 1:resolution_CMYG(2)
     
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

%interpolated_C = double(interpolation_LT(bayer_C));
%interpolated_M = double(interpolation_RT(bayer_M));
%interpolated_Y = double(interpolation_LB(bayer_Y));
%interpolated_G = double(interpolation_RB(bayer_G));

interpolated_G = double(interpolation_LT(bayer_G));
interpolated_M = double(interpolation_RT(bayer_M));
interpolated_Y = double(interpolation_LB(bayer_Y));
interpolated_C = double(interpolation_RB(bayer_C));


% /4095 (12bit) : normalize (0 to 1)
interpolated_C = interpolated_C ./ (2 ^ 12 - 1);
interpolated_M = interpolated_M ./ (2 ^ 12 - 1);
interpolated_Y = interpolated_Y ./ (2 ^ 12 - 1);
interpolated_G = interpolated_G ./ (2 ^ 12 - 1);


RGB = double(RGB) ./ (2^16 - 1);
R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);

NIR = double(NIR) ./ (2^16 - 1);

%NIR = NIR * 0.25; % Scaling due to different exposure time

NIR = rgb2gray(NIR);

arr_CMYG = [interpolated_C(:)'; interpolated_M(:)'; interpolated_Y(:)';interpolated_G(:)'];
arr_RGBN = [R(:)'; G(:)'; B(:)';NIR(:)'];
pinv_arr_RGBN = pinv(arr_RGBN);
pinv_arr_CMYG = pinv(arr_CMYG);

cmygp_rgbn = arr_CMYG * pinv_arr_RGBN;
%cmyg_rgb = cmyg_rgb_init;
rgbn_cmygp = arr_RGBN * pinv_arr_CMYG;
% learning_rate = 0.1;
% w = zeros(1, 3);
% for k = 1:10
%     for i = 1:4
%         for j = 1:3
%              w(j) = cmyg_rgb(i,j) - learning_rate * dot(arr_RGB(j,:), (cmyg_rgb(i,:) * arr_RGB) - arr_CMYG(i,:));
%         end
%         cmyg_rgb(i,:) = w;
%     end
%     
% end
% 
% 
% 
% 
