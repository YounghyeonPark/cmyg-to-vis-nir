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
filename = 'Objects_light+NIR.pgm';
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

%-------%
% Option
%-------%
write_to_image_file = false;
plot_results = true;

%----------------------------------%
% Step 1 : Read bayer pattern(CMYG)
%----------------------------------%
bayer_CMYG = imread(filename);

%------------------------------%
% Step 2 : Bad pixel correction
%------------------------------%
bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');
 
%--------------------------------------------%
% Step 3 : interpolation of each CMYG channel
%--------------------------------------------%
interpolated_CMYG = interpolate_cmyg(bayer_CMYG, 'coolpix5700');

%--------------------------------------%
% Step 4 : convert C'M'Y'G' to RGB, NIR
%--------------------------------------%
fprintf('\nConvert C''M''Y''G'' to RGB, NIR\n');
tic
[converted_rgb, converted_nir] = convert_cmygp_to_rgbn(interpolated_CMYG);
toc


%--------------------------------------%
% Get RGB-NIR mixed image from C'M'Y'G'
%--------------------------------------%
fprintf('\nGet RGB-NIR mixed image from C''M''Y''G''\n');
tic
mixed_rgb = convert_cmyg_to_rgb(interpolated_CMYG);
toc


%--------------------%
% Step 5 : De-noising
%--------------------%
fprintf('\nDe-noising RGB\n');
tic
converted_rgb_filtered = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, 'wiener');
toc

fprintf('\nDe-noising NIR\n');
tic
converted_nir_filtered = denoise_nir(converted_rgb, converted_nir, mixed_rgb, 'wiener');
toc


%-------------------------------------%
% Step 6 : Auto white balancing of RGB
%-------------------------------------%
fprintf('\nAuto white balancing of RGB\n');
tic
converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');
toc


%-------------------------%
% Step 7 : display results
%-------------------------%
if plot_results == true
    figure, imshow(converted_rgb_filtered), title('Separated RGB (Wiener filter)');
    figure, imshow(converted_nir_filtered), title('Separated NIR (Wiener filter)');
    figure, imshow(converted_rgb), title('Separated RGB');
    figure, imshow(converted_nir), title('Separated NIR');
    figure, imshow(mixed_rgb), title('RGB+NIR');
    figure, imshow(converted_rgb_filtered_awb), title('Separated RGB (Wiener filter, AWB)');
    figure, imshow(mixed_rgb_awb), title('RGB+NIR (AWB)');
end

%-----------------------------%
% Step 8 : Save images to file
%-----------------------------%
if write_to_image_file == true
    file_extension = '.jpg';
    str_filename_write_separated_RGB_wiener = [filename, '_separated_rgb(wiener)',file_extension];
    str_filename_write_separated_NIR_wiener = [filename, '_separated_nir(wiener)',file_extension];
    str_filename_write_separated_RGB = [filename, '_separated_rgb',file_extension];
    str_filename_write_separated_NIR = [filename, '_separated_nir',file_extension];
    str_filename_write_RGB_NIR = [filename, '_rgb+nir',file_extension];
    str_filename_write_separated_RGB_wiener_awb = [filename, '_separated_rgb(wiener,awb)', file_extension];
    str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)',file_extension];

    imwrite(converted_rgb_filtered, str_filename_write_separated_RGB_wiener);
    imwrite(converted_nir_filtered, str_filename_write_separated_NIR_wiener);
    imwrite(converted_rgb, str_filename_write_separated_RGB);
    imwrite(converted_nir, str_filename_write_separated_NIR);
    imwrite(mixed_rgb, str_filename_write_RGB_NIR);
    imwrite(mixed_rgb_awb, str_filename_write_RGB_NIR_awb);
    imwrite(converted_rgb_filtered_awb, str_filename_write_separated_RGB_wiener_awb);
end
