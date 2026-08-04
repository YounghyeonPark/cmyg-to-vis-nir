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
%bayer_CMYG = imread('Objects_light+NIR.pgm');
bayer_CMYG = imread('Objects_NIR_cut.pgm');
RGB = imread('Objects_NIR_cut.TIF');


bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');
%RGB(:,:,1) = defective_pixel_correction(RGB(:,:,1), 'coolpix5700');
%RGB(:,:,2) = defective_pixel_correction(RGB(:,:,2), 'coolpix5700');
%RGB(:,:,3) = defective_pixel_correction(RGB(:,:,3), 'coolpix5700');


resolution_CMYG = size(bayer_CMYG);
resolution_RGB = size(RGB);
crop_col = (resolution_CMYG(2) - resolution_RGB(2)) / 2;
crop_row = (resolution_CMYG(1) - resolution_RGB(1)) / 2;

bayer_CMYG = bayer_CMYG((crop_row + 1):(resolution_CMYG(1) - crop_row), (crop_col + 1):(resolution_CMYG(2) - crop_col));
resolution_CMYG = size(bayer_CMYG);
number_of_samples = resolution_CMYG(1) * resolution_CMYG;

bayer_C = zeros(resolution_CMYG);
bayer_M = zeros(resolution_CMYG);
bayer_Y = zeros(resolution_CMYG);
bayer_G = zeros(resolution_CMYG);


interpolated_cmyg = double(zeros(resolution_CMYG(1), resolution_CMYG(2), 4));

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

interpolated_cmyg(:,:,1) = interpolated_C;
interpolated_cmyg(:,:,2) = interpolated_M;
interpolated_cmyg(:,:,3) = interpolated_Y;
interpolated_cmyg(:,:,4) = interpolated_G;
% Nomalize 0 to 1
%interpolated_cmyg = interpolated_cmyg - min(interpolated_cmyg(:));
%interpolated_cmyg = interpolated_cmyg / max(interpolated_cmyg(:));
%RGB = double(RGB);
%RGB = RGB - min(RGB(:));
%RGB = RGB / max(RGB(:));


% /4095 (12bit) : normalize (0 to 1)
 interpolated_C = interpolated_C ./ (2 ^ 12 - 1);
 interpolated_M = interpolated_M ./ (2 ^ 12 - 1);
 interpolated_Y = interpolated_Y ./ (2 ^ 12 - 1);
 interpolated_G = interpolated_G ./ (2 ^ 12 - 1);
RGB = double(RGB) ./ (2^16 - 1);


R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);

arr_CMYG = [interpolated_C(:)'; interpolated_M(:)'; interpolated_Y(:)';interpolated_G(:)'];
arr_RGB = [R(:)'; G(:)'; B(:)'];
pinv_arr_RGB = pinv(arr_RGB);
pinv_arr_CMYG = pinv(arr_CMYG);

cmyg_rgb = arr_CMYG * pinv_arr_RGB;
%cmyg_rgb = cmyg_rgb_init;

rgb_cmyg = arr_RGB * pinv_arr_CMYG;

simple_rgb_cmyg = [0 0 1 -1;0 0 0 1; 1 0 0 -1];
% 
% learning_rate = 0.000005;
% delta_w = 0;
%  for cmyg = 1:4 % functions
%  %cmyg = 1; % c channel
%     for k = 1:100 %iteration
%         for j = 1:3 %dimension
%             delta_w = 0;
%             
%             for i = 1:1536:number_of_samples % samples
%                 delta_w = delta_w + (learning_rate * arr_RGB(j,i) * (arr_CMYG(cmyg,i) - (cmyg_rgb(cmyg,:) * arr_RGB(:,i))));
%             
%             end
%             
%             cmyg_rgb(cmyg,j) = cmyg_rgb(cmyg,j) - delta_w;
%             
%     
%             
%             str = ['dimension : ', num2str(j)];
%             disp(str);
%         end
%         str = ['iteration : ', num2str(k)];
%         disp(str);
%         
%                 
%         %MSE
%         mse = 0;
%         for i = 1:1000 % samples
%             mse = mse + (arr_CMYG(:,i) - (cmyg_rgb * arr_RGB(:,i))).^2;
% 
%         end
%         mse = mse ./ 1000;
%         
%         str = ['MSE C : ', num2str(mse(1)), 'MSE M : ', num2str(mse(2)), 'MSE Y : ', num2str(mse(3)), 'MSE G : ', num2str(mse(4))];
%         disp(str);
%     end
%     str = ['CMYG index : ', num2str(cmyg)];
%      disp(str);
%      
%      
%      
%  end
 
% 
% 
% 
% 
rgb_cmyg = pinv(cmyg_rgb);
converted_rgb = zeros(resolution_CMYG(1), resolution_CMYG(2), 3);
converted_rgb_simple = zeros(resolution_CMYG(1), resolution_CMYG(2), 3);
%test
 for i = 1:resolution_CMYG(1)
   for j = 1:resolution_CMYG(2)
      converted_rgb(i, j, :) = rgb_cmyg * [interpolated_C(i,j); interpolated_M(i,j); interpolated_Y(i,j); interpolated_G(i,j)];
      converted_rgb_simple(i, j, :) = simple_rgb_cmyg * [interpolated_C(i,j); interpolated_M(i,j); interpolated_Y(i,j); interpolated_G(i,j)];
   end
 end
 
 converted_rgb_simple(:,:,2) = converted_rgb_simple(:,:,2) .* 0.25;

 figure, imshow(converted_rgb), title('Converted RGB (Custom conversion matrix)');
 figure, imshow(converted_rgb_simple*6), title('Converted RGB (Simple conversion matrix)');

 
% diff = RGB - converted_rgb;
 
 
%figure,plot(RGB(:,:,1), abs(diff(:,:,1)), 'color', 'r', 'marker', '+', 'linestyle', 'none')
%figure,plot(RGB(:,:,2), abs(diff(:,:,2)), 'color', 'g', 'marker', '+', 'linestyle', 'none')
%figure,plot(RGB(:,:,3), abs(diff(:,:,3)), 'color', 'b', 'marker', '+', 'linestyle', 'none')
