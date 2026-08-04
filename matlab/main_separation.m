%-------------------------------------------------------------------------%
% Title : Convert C'M'Y'G' to RGB, NIR
% Authors: Younghyeon Park and Byeungwoo Jeon (SKKU Digital Media Lab)
% Paper : "An Acquisition Method for Visible and Near Infrared Images 
%          from Single CMYG Color Filter Array-Based Sensor" (Sensors 2020)
%-------------------------------------------------------------------------%

close all;
clear all;
clc;

% Add paths
addpath('core');
addpath('../samples');

% Options
filename = 'sample_cmyg.pgm'; % Change to your input CMYG raw PGM file
write_image_as_file = true;
plot_results = true;

if ~exist(filename, 'file')
    % Check in convert images if sample not in current path
    filename = '../convert/images/colorchart2_fluorescent_6500K.pgm';
end

%----------------------------------%
% Step 1 : Read CMYG Bayer Pattern
%----------------------------------%
fprintf('Reading bayer image: %s\n', filename);
bayer_CMYG = imread(filename);

%--------------------------------------------%
% Step 2 : Interpolation of each CMYG channel
%--------------------------------------------%
fprintf('Demosaicing 2x2 CMYG pattern...\n');
interpolated_CMYG = interpolate_cmyg(bayer_CMYG, 'coolpix5700');

%--------------------------------------%
% Step 3 : Convert C'M'Y'G' to RGB & NIR
%--------------------------------------%
fprintf('Converting C''M''Y''G'' to RGB and NIR...\n');
tic
[converted_rgb, converted_nir] = convert_cmygp_to_rgbn(interpolated_CMYG);
mixed_rgb = convert_cmyg_to_rgb(interpolated_CMYG);
toc

%--------------------%
% Step 4 : De-noising
%--------------------%
fprintf('Denoising RGB & NIR channels...\n');
tic
converted_rgb_filtered = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
converted_nir_filtered = denoise_nir(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
toc

%-------------------------------------%
% Step 5 : Auto white balancing of RGB
%-------------------------------------%
fprintf('Auto white balancing...\n');
tic
converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');
toc

%-------------------------%
% Step 6 : Display Results
%-------------------------%
if plot_results == true
    figure, imshow(converted_rgb_filtered_awb), title('Separated Visible RGB (Guided Filter, AWB)');
    figure, imshow(converted_nir_filtered), title('Separated NIR (Guided Filter)');
    figure, imshow(mixed_rgb_awb), title('Mixed RGB+NIR (AWB)');
end

%-----------------------------%
% Step 7 : Save images to file
%-----------------------------%
if write_image_as_file == true
    output_dir = 'output';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    imwrite(converted_rgb_filtered_awb, fullfile(output_dir, 'separated_rgb_awb.jpg'));
    imwrite(converted_nir_filtered, fullfile(output_dir, 'separated_nir.jpg'));
    imwrite(mixed_rgb_awb, fullfile(output_dir, 'mixed_rgb_nir_awb.jpg'));
    fprintf('Results saved to directory: %s\n', output_dir);
end
