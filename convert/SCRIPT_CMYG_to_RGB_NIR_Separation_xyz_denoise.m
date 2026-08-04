%-------------------------------------------------------------------------%
% Title : Convert C'M'Y'G' to RGB, NIR (for 2014-2015 Samsung DMC project)
%
% Author : SKKU Digital Media Lab.
%
% Changes:
% 2015/06/06 : First commit (Younghyeon Park, neversky@skku.edu)
%
%
%-------------------------------------------------------------------------%


%CMYG-NIR to RGB, NIR conversion
close all;
clear all;
addpath('./images');
addpath('./BM3D');
addpath('./bfilter2');
addpath('./guidedfilter');

addpath('./Images_new');

%gcp


% multiple files
%for cnt=1023:1254 %for multiple files

%    filename = ['DSCN', num2str(cnt), '.NEF.pgm'];
    
    
%    if ~exist(filename, 'file')
%        continue;
%    end


filename = 'DSCN1251.NEF.pgm';
%filename = 'DSCN1326.NEF.pgm';
%filename = 'CRW_9230.CRW.pgm';
%


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
%filename = 'orange3_light+NIR.pgm';
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
%filename = 'flower_lowlight+NIR.pgm';
%filename = 'colorchart2_fluorescent_6500K.pgm';
%filename = 'Things2_lowlight+LED.pgm';
%filename = 'Things_lowlight+NIR.pgm';
%filename = 'miniature_lowlight+NIR.NEF.pgm';
%filename = 'miniature_lowlight+NIR.pgm';
%filename = 'miniature_lowlight_nohotmirror.pgm';
%filename = 'book_fluorescent+NIR.pgm';
%filename = 'treename_lowlight+NIR.pgm';
%-------%
% Option
%-------%

opt.write_image_as_file = true;
opt.plot_results = true;
opt.pre_denoise = false;
opt.denoise_rgb = true;
opt.denoise_nir = true;
opt.denoise_filter = 'wiener';
opt.cut_result = true;
opt.cut_pos_start_x = 550;
opt.cut_pos_start_y = 250;
opt.cut_pos_end_x = 1050;
opt.cut_pos_end_y = 850;
opt.awb = false;
opt.alpha = 1;
opt.lightsource = 'sunlight';
%opt.alpha = 1.21;
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

%--------------------------------------------%
% Step 3.5 : Denoise CMYG channel
%--------------------------------------------%
if opt.pre_denoise == true
    fprintf('\nPre de-noising CMYG\n');
    tic
    interpolated_CMYG = denoise_cmyg(interpolated_CMYG, 'wiener');
    
    toc
end     %
     
%noise_CMYG = interpolated_CMYG - interpolated_CMYG_filtered;

%--------------------------------------%
% Step 4 : convert C'M'Y'G' to RGB, NIR
%--------------------------------------%
fprintf('\nConvert C''M''Y''G'' to RGB, NIR\n');
tic
[separated_xyz, separated_nir] = convert_cmygp_to_xyzn(interpolated_CMYG, opt.alpha, opt.lightsource);
toc

separated_rgb = convert_xyz_to_srgb(separated_xyz);
%separated_nir = separated_nir ./ opt.alpha;
%--------------------------------------%
% Get RGB-NIR mixed image from C'M'Y'G'
%--------------------------------------%
fprintf('\nGet RGB-NIR mixed image from C''M''Y''G''\n');
tic
mixed_xyz = convert_cmyg_to_xyz(interpolated_CMYG, opt.lightsource);
toc
%mixed_rgb = xyz2rgb(mixed_xyz);
mixed_rgb = convert_xyz_to_srgb(mixed_xyz);

%--------------------%
% Step 5 : De-noising
%--------------------%
if opt.denoise_rgb == true
    fprintf('\nDe-noising RGB\n');
    tic
    separated_rgb_filtered = denoise_rgb(separated_rgb, separated_nir, mixed_xyz, interpolated_CMYG, opt.denoise_filter);
    toc
end

if opt.denoise_nir == true
    fprintf('\nDe-noising NIR\n');
    tic
    separated_nir_filtered = denoise_nir(separated_rgb, separated_nir, mixed_xyz, interpolated_CMYG, opt.denoise_filter);
    toc
end

%-------------------------------------%
% Step 6 : Auto white balancing of RGB
%-------------------------------------%
if opt.awb == true
    fprintf('\nAuto white balancing of RGB\n');
    tic
    if opt.denoise_rgb == true
        separated_rgb_filtered_awb = auto_white_balance(separated_rgb_filtered, 'grayworld');
    else
        separated_rgb_awb = auto_white_balance(separated_rgb, 'grayworld');
    end
    
    mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');
    toc
end

%-------------------------%
% Step 7 : display results
%-------------------------%
if opt.plot_results == true
    if opt.denoise_rgb == true
        figure, imshow(separated_rgb_filtered), title(['Separated RGB (', opt.denoise_filter, ')']);
    end
    
    if opt.denoise_nir == true
        figure, imshow(separated_nir_filtered), title(['Separated NIR (', opt.denoise_filter, ')']);
    end
    
    figure, imshow(separated_rgb), title('Separated RGB');
    figure, imshow(separated_nir), title('Separated NIR');
    figure, imshow(mixed_rgb), title('RGB+NIR');
    
    if opt.awb == true
        if opt.denoise_rgb == true
            figure, imshow(separated_rgb_filtered_awb), title('Separated RGB (', opt.denoise_filter, ', AWB)');
        else
            figure, imshow(separated_rgb_awb), title('Separated RGB (AWB)');
        end
        
        figure, imshow(mixed_rgb_awb), title('RGB+NIR (AWB)');
    end
end

%-----------------------------%
% Step 8 : Save images to file
%-----------------------------%
if opt.write_image_as_file == true
    file_extension = '.jpg';
    str_filename_write_separated_RGB_filter = [filename, '_separated_rgb(', opt.denoise_filter, ')',file_extension];
    str_filename_write_separated_NIR_filter = [filename, '_separated_nir(', opt.denoise_filter, ')',file_extension];
    str_filename_write_separated_RGB = [filename, '_separated_rgb',file_extension];
    str_filename_write_separated_RGB_awb = [filename, '_separated_rgb_awb',file_extension];
    str_filename_write_separated_NIR = [filename, '_separated_nir',file_extension];
    str_filename_write_RGB_NIR = [filename, '_rgb+nir',file_extension];
    str_filename_write_separated_RGB_filter_awb = [filename, '_separated_rgb(', opt.denoise_filter, ',awb)', file_extension];
    str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)',file_extension];

    if opt.denoise_rgb == true
        imwrite(separated_rgb_filtered, str_filename_write_separated_RGB_filter);
    end
    if opt.denoise_nir == true
        imwrite(separated_nir_filtered, str_filename_write_separated_NIR_filter);
    end
    
    imwrite(separated_rgb, str_filename_write_separated_RGB);
    imwrite(separated_nir, str_filename_write_separated_NIR);
    imwrite(mixed_rgb, str_filename_write_RGB_NIR);
    if opt.awb == true
        imwrite(mixed_rgb_awb, str_filename_write_RGB_NIR_awb);
        if opt.denoise_rgb == true
            imwrite(separated_rgb_filtered_awb, str_filename_write_separated_RGB_filter_awb);
        else
            imwrite(separated_rgb_awb, str_filename_write_separated_RGB_awb);
        end
    end
end


%-------------------------------------%
% Step 9 : Save cutted images to file
%-------------------------------------%
if opt.cut_result == true
    file_extension = '_cut.jpg';
    str_filename_write_separated_RGB_filter = [filename, '_separated_rgb(', opt.denoise_filter, ')',file_extension];
    str_filename_write_separated_NIR_filter = [filename, '_separated_nir(', opt.denoise_filter, ')',file_extension];
    str_filename_write_separated_RGB = [filename, '_separated_rgb',file_extension];
    str_filename_write_separated_RGB_awb = [filename, '_separated_rgb_awb',file_extension];
    str_filename_write_separated_NIR = [filename, '_separated_nir',file_extension];
    str_filename_write_RGB_NIR = [filename, '_rgb+nir',file_extension];
    str_filename_write_separated_RGB_filter_awb = [filename, '_separated_rgb(', opt.denoise_filter, ',awb)', file_extension];
    str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)',file_extension];

    if opt.denoise_rgb == true
        imwrite(separated_rgb_filtered(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_separated_RGB_filter);
    end
    if opt.denoise_nir == true
        imwrite(separated_nir_filtered(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x), str_filename_write_separated_NIR_filter);
    end
    
    imwrite(separated_rgb(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_separated_RGB);
    imwrite(separated_nir(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x), str_filename_write_separated_NIR);
    imwrite(mixed_rgb(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_RGB_NIR);
    if opt.awb == true
        imwrite(mixed_rgb_awb(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_RGB_NIR_awb);
        if opt.denoise_rgb == true
            imwrite(separated_rgb_filtered_awb(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_separated_RGB_filter_awb);
        else
            imwrite(separated_rgb_awb(opt.cut_pos_start_y:opt.cut_pos_end_y, opt.cut_pos_start_x:opt.cut_pos_end_x,:), str_filename_write_separated_RGB_awb);
        end
    end
end

%end% for loop
