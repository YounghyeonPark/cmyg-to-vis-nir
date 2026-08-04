%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Demo code of
%       'Effective Color Correction Pipeline for a Noisy Image'
%
%   Please see the readme.txt file for usage.
%
%   This code is available only for reserch purpose.
%   If you use this code for future publications,
%   please cite the following paper.
%
%   Kenta Takahashi, Yusuke Monno, Masayuki Tanaka and Masatoshi Okutomi,
%   'Effective Color Correction Pipeline for a Noisy Image',
%   IEEE International Conference on Image Processing 2016.
%
%   Copyright (C) 2016 Kenta Takahashi. All rights reserved.
%
%   If you have any questions, please e-mail to Yusuke Monno.
%   e-mail : ymonno@ok.ctrl.titech.ac.jp
%   website: http://www.ok.ctrl.titech.ac.jp/~ymonno/
%
%   August 25, 2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

% path setting
% please download BM3D package from http://www.cs.tut.fi/~foi/GCF-BM3D/
addpath(genpath('BM3D'));

% load color correction matrix for the noise-fre case (linear_3x3)
load('linear_3x3.mat');

% load noise-free camera RGB image (cRGB)
cRGB = im2double(imread('cameraRGB_noisefree.png'));
% degamma correction
cRGB = cRGB.^2.2;

% image size
h = size(cRGB,1);
w = size(cRGB,2);

% noise level
nl_r = 20/255; % R
nl_g = 20/255; % G
nl_b = 20/255; % B
nl = [nl_r;nl_g;nl_b];

% add noise
cRGBn(:,:,1) = cRGB(:,:,1) + nl_r*randn(h,w);
cRGBn(:,:,2) = cRGB(:,:,2) + nl_g*randn(h,w);
cRGBn(:,:,3) = cRGB(:,:,3) + nl_b*randn(h,w);

% proposed method
k = 21; % block size
div_size = 2.5/255; % interval width of assumed noise levels
sRGBpro = pro_func(cRGBn,linear_3x3,nl,k,div_size);

% gamma correction for displaying images
cRGB = cRGB.^(1/2.2);
cRGBn = cRGBn.^(1/2.2);
sRGBpro = sRGBpro.^(1/2.2);

% save images
imwrite(cRGB,'cameraRGB_noisefree.png');
imwrite(cRGBn,'cameraRGB_noisy.png');
imwrite(sRGBpro,'sRGB_proposed.png');

