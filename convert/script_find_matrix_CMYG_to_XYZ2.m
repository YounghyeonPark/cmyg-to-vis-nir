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
%bayer_CMYG = imread('Objects_NIR_cut.pgm');
bayer_CMYG = imread('colorchart2_fluorescent_6500K.pgm');

%center point X, Y
color_block_size = 100;
num_of_colors = 24;
colorchart2_pos = [ 
                    1573, 1528; % dark skin 1573 1528
                    1576, 1279; % light skin 1576 1279
                    1570, 1033; % blue sky 1570 1033
                    1570, 781; % foliage 1570 781
                    1567, 538; % blue flower 1567 538
                    1558, 295; % bluish green 1558 295
                    1822, 1537; % orange 1822 1537
                    1822, 1288; % purplish blue 1822 1288
                    1825, 1030; % moderate red 1825 1030
                    1825, 775; % purple 1825 775
                    1816, 526; % yellow green 1816 526
                    1810. 280; % orange yellow 1810 280
                    2089, 1537; % blue 2089 1537
                    2080, 1282; % green 2080 1282
                    2089, 1030; % red 2089 1030
                    2077, 769; % yellow 2077 769
                    2071, 520; % magenta 2071 520
                    2059, 268; % cyan 2059 268
                    2341, 1543; % white(.05*) 2341 1543
                    2338, 1285; % neutral 8(.23*) 2338 1285
                    2338, 1027; % neutral 6.5(.44*) 2338 1027
                    2335, 775; % neutral 5(.70*) 2335 775
                    2335, 514; % neutral 3.5(.1.05*) 2335 514
                    2323, 250; % black (1.50*) 2323 250
                ];

%XYZ value of color chart
sample_colors_Lab_d50 = [
                            37.986, 13.555, 14.059;
                            65.711, 18.13, 17.81;
                            49.927, -4.88, -21.925;
                            43.139, -13.095, 21.905;
                            55.112, 8.844, -25.399;
                            70.719, -33.397, -0.199;
                            62.661, 36.067, 57.096;
                            40.02, 10.41, -45.964;
                            51.124, 48.239, 16.248;
                            30.325, 22.976, -21.587;
                            72.532, -23.709, 57.255;
                            71.941, 19.363, 67.857;
                            28.778, 14.179, -50.297;
                            55.261, -38.342, 31.37;
                            42.101, 53.378, 28.19;
                            81.733, 4.039, 79.819;
                            51.935, 49.986, -14.574;
                            51.038, -28.631, -28.638;
                            96.539, -0.425, 1.186;
                            81.257, -0.638, -0.335;
                            66.766, -0.734, -0.504;
                            50.867, -0.153, -0.27;
                            35.656, -0.421, -1.231;
                            20.461, -0.079, -0.973
                        ];
        
bradford_d50_to_d65 = [
                        0.9556, -0.0230, 0.0632;
                        -0.0283, 1.0099, 0.0210;
                        0.0123, -0.0205, 1.3299
                      ];

sample_colors_XYZ_d50 = lab2xyz(sample_colors_Lab_d50, 'WhitePoint', 'd50');
sample_colors_XYZ_d65 = bradford_d50_to_d65 * sample_colors_XYZ_d50';
                    
                    
%------------------------------%
% Step 2 : Bad pixel correction
%------------------------------%
bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');
 
%--------------------------------------------%
% Step 3 : interpolation of each CMYG channel
%--------------------------------------------%
interpolated_CMYG = interpolate_cmyg(bayer_CMYG, 'coolpix5700');

sample_colors_CMYG = zeros(4, num_of_colors);

for i=1:num_of_colors
   pos_x = colorchart2_pos(i,1);
   pos_y = colorchart2_pos(i,2);
   start_x = pos_x - (color_block_size/2);
   end_x = pos_x + (color_block_size/2);
   start_y = pos_y - (color_block_size/2);
   end_y = pos_y + (color_block_size/2);
   
   %C
   sample_colors_CMYG(1,i) = mean(mean(interpolated_CMYG(start_y:end_y,start_x:end_x,1)));
   %M
   sample_colors_CMYG(2,i) = mean(mean(interpolated_CMYG(start_y:end_y,start_x:end_x,2)));
   %Y
   sample_colors_CMYG(3,i) = mean(mean(interpolated_CMYG(start_y:end_y,start_x:end_x,3)));
   %G
   sample_colors_CMYG(4,i) = mean(mean(interpolated_CMYG(start_y:end_y,start_x:end_x,4)));
   
end

arr_CMYG = sample_colors_CMYG;
arr_CMYG1 = arr_CMYG;
arr_CMYG1(5,:) = 1;
arr_XYZ = sample_colors_XYZ_d65;
arr_XYZ1 = arr_XYZ;
arr_XYZ1(4,:) = 1;
pinv_arr_XYZ = pinv(arr_XYZ);
pinv_arr_CMYG = pinv(arr_CMYG);

pinv_arr_XYZ1 = pinv(arr_XYZ1);
pinv_arr_CMYG1 = pinv(arr_CMYG1);


CMYG_XYZ = arr_CMYG * pinv_arr_XYZ;
%cmyg_rgb = cmyg_rgb_init;

XYZ_CMYG = arr_XYZ * pinv_arr_CMYG;

CMYG_XYZ1 = arr_CMYG * pinv_arr_XYZ1;
XYZ_CMYG1 = arr_XYZ * pinv_arr_CMYG1;
