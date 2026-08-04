%-------------------------------------------------------------------------%
% Title : Performance comparison simulation (SKKU vs EPFL)
% Authors: Younghyeon Park and Byeungwoo Jeon (SKKU Digital Media Lab)
% Paper : "An Acquisition Method for Visible and Near Infrared Images 
%          from Single CMYG Color Filter Array-Based Sensor" (Sensors 2020)
%-------------------------------------------------------------------------%

close all;
clear all;
clc;

addpath('../core');
addpath('../../samples');
addpath('../denoising_modules/guidedfilter');
addpath('../denoising_modules/toolbox_v1.3');

number_of_images = 54;

psnr_rgb_EPFL = zeros(number_of_images,1);
psnr_nir_EPFL = zeros(number_of_images,1);
psnr_rgb_SKKU = zeros(number_of_images,1);
psnr_nir_SKKU = zeros(number_of_images,1);

for i = 1:number_of_images
    filename = sprintf('%04d_', i-1);
    
    if ~exist([filename 'rgb.tiff'], 'file')
        continue;
    end

    input_rgb = double(imread([filename 'rgb.tiff']));
    input_nir = double(imread([filename 'nir.tiff']));

    re_img_width = (floor(size(input_rgb,2)/128) * 128) - 16;
    re_img_height = (floor(size(input_rgb,1)/128) * 128) - 16;
    
    input_rgb = input_rgb(9:(re_img_height + 8), 9:(re_img_width + 8),:);
    original_nir = input_nir(9:(re_img_height + 8), 9:(re_img_width + 8),:); 
 
    [optimizer, metric] = imregconfig('multimodal');
    original_nir = imregister(original_nir, input_rgb(:,:,2), 'affine', optimizer, metric);
    
    bayer_rgb = mosaic_rgb(input_rgb);
    original_rgb = demosaic_rgb(bayer_rgb);
    bayer_rgb_nir = mosaic_rgb_nir(original_rgb, original_nir);

    cmyg = convert_rgb_to_cmyg(original_rgb);
    cmyg_nir = convert_rgbn_to_cmygp(original_rgb, original_nir);
    bayer_cmyg_nir = mosaic_cmyg_nir(cmyg, original_nir);

    [separated_rgb_EPFL, separated_nir_EPFL] = separation_rgb_nir_EPFL(bayer_rgb_nir);
    [separated_rgb_SKKU, separated_nir_SKKU] = separation_rgb_nir_SKKU(bayer_cmyg_nir);

    separated_rgb_EPFL = uint8(separated_rgb_EPFL);
    separated_rgb_SKKU = uint8(separated_rgb_SKKU);
    separated_nir_EPFL = uint8(separated_nir_EPFL);
    separated_nir_SKKU = uint8(separated_nir_SKKU);
    original_rgb = uint8(original_rgb);
    original_nir = uint8(original_nir);

    psnr_rgb_EPFL(i) = PSNR(original_rgb, separated_rgb_EPFL);
    psnr_nir_EPFL(i) = PSNR(original_nir, separated_nir_EPFL);

    psnr_rgb_SKKU(i) = PSNR(original_rgb, separated_rgb_SKKU);
    psnr_nir_SKKU(i) = PSNR(original_nir, separated_nir_SKKU);

    fprintf('Processed image %04d | SKKU RGB PSNR: %.2f dB, EPFL RGB PSNR: %.2f dB\n', ...
            i-1, psnr_rgb_SKKU(i), psnr_rgb_EPFL(i));
end
