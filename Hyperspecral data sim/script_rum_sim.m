%-------------------------------------------------------------------------%
% Title : Performance evalutation of CMYG' to RGB-NIR conversion method
%
% Author : SKKU Digital Media Lab.
%
% Changes:
% 2019/10/14 : First commit (Younghyeon Park, neversky@skku.edu)
%
% The structure of this script  is partially borrowed from ( )
%
%-------------------------------------------------------------------------%

%points of color chart

%295 150    355 150    410 150   470 150
%295 210    355 210    410 210   470 210
%295 265    355 265    410 265   470 265
%295 325    355 325    410 325   470 325
%295 385    355 385    410 385   470 385
%295 440    355 440    410 440   470 440

close all;

% path setting
%addpath('Functions','SpectralData');
addpath('CodeRGB-NIR/Functions');
addpath('CodeRGB-NIR/SpectralData');
addpath('CMYGtoRGBN');
addpath('MN3776SpectralData');

% camera spectral sensitivity functions
%ssf = load('ssf_rgb-nir_420-1000_10.csv');
%ssf = load('ssf_srgbn_420-1000_10.csv');
ssf_CYGM = load('MN3776_cygm_420-1000_10.csv');
ssf_RGB = load('MN3776_rgb_420-1000_10.csv');
ssf_Hotmirror = load('Hotmirror_Ideal_750_10.csv');


% mat file name
matname = dir('CodeRGB-NIR/Inputs/*.mat');

% train 4x4 color correction matrix
%train_ccmat_chart(ssf);


% illumination
L = load('daylight_420-1000_10.csv');

% color matching functions
cmf = load('ssf_xyz_420-1000_10.csv');

% white point
xyz = cmf'* L;
x = xyz(1)/sum(xyz);
y = xyz(2)/sum(xyz);

% rgb2xyz matrix with white point
param = [x y 0.64 0.33 0.30 0.60 0.15 0.06 1];
M = mat_rgb2xyz(param);

% load target NIR sensitivity function
ssfn = load('ssf_target-nir_420-1000_10.csv');

% number of images
N = 1;

% roop for N images
for i = 1:16
    % load mat file
    fileName = matname(i).name;
    load(sprintf('CodeRGB-NIR/Inputs/%s',fileName));
    
    % make camera RGB-NIR and target RGB-NIR images
    % image size
    s = size(img);
    % vectorization
    vec = reshape(img,s(1)*s(2),s(3))';
    
    % camera CYGM CFA image
    vec_cCYGM_mixed = ssf_CYGM(:,1:4)'* diag(L)* vec;
    vec_cCYGM_vis = ssf_CYGM(:,1:4)' * diag(ssf_Hotmirror) * diag(L)* vec;
    vec_cCYGM_nir = ssf_CYGM(:,1:4)'* diag(~ssf_Hotmirror) * diag(L)* vec;
    cCYGM_mixed = reshape(vec_cCYGM_mixed',s(1),s(2),4);
    cCYGM_vis =  reshape(vec_cCYGM_vis',s(1),s(2),4);
    cCYGM_nir =  reshape(vec_cCYGM_nir',s(1),s(2),4);
    
    % camera RGB CFA image
    vec_cRGB_mixed = ssf_RGB(:,1:3)'* diag(L)* vec;
    vec_cRGB_vis = ssf_RGB(:,1:3)'* diag(ssf_Hotmirror) * diag(L)* vec;
    vec_cRGB_nir = ssf_RGB(:,1:3)'* diag(~ssf_Hotmirror) * diag(L)* vec;
    cRGB_mixed = reshape(vec_cRGB_mixed',s(1),s(2),3);
    cRGB_vis = reshape(vec_cRGB_vis',s(1),s(2),3);
    cRGB_nir = reshape(vec_cRGB_nir',s(1),s(2),3);

    
    % normalization of camera RGB-NIR image
    maxCYGMRGB = max([cCYGM_mixed(:);cRGB_mixed(:)]);
    cCYGM_mixed = cCYGM_mixed/maxCYGMRGB;
    cCYGM_vis = cCYGM_vis/maxCYGMRGB;
    cCYGM_nir = cCYGM_nir/maxCYGMRGB;
    
    cRGB_mixed = cRGB_mixed/maxCYGMRGB;
    cRGB_vis = cRGB_vis/maxCYGMRGB;
    cRGB_nir = cRGB_nir/maxCYGMRGB;
    %cNIR = cNIR/maxRGBN;

    %maxRGBN = max([cRGB(:); cNIR(:)]);
    %cRGB = cRGB/maxRGBN;
    %cNIR = cNIR/maxRGBN;

    mosaicedGMYC = mosaic_gmyc(cCYGM_mixed(:,:,1), cCYGM_mixed(:,:,4), cCYGM_mixed(:,:,2), cCYGM_mixed(:,:,3));
    mosaicedGBRG = mosaic_gbrg(cRGB_mixed(:,:,1), cRGB_mixed(:,:,2), cRGB_mixed(:,:,3));
    %make_mat2gt(ssf,img,i);
   
    [separated_rgb_EPFL, separated_nir_EPFL] = separation_rgb_nir_EPFL(mosaicedGBRG);
    [separated_rgb_SKKU, separated_nir_SKKU] = separation_rgb_nir_SKKU(mosaicedGMYC);
    % apply 4x4 color correction matrix
    %apply_ccmat(i);
end
