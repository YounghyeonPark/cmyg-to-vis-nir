%-------------------------------------------------------------------------%
% Title : Hyperspectral simulation of CMYG vs RGB sensor sensitivity
% Authors: Younghyeon Park and Byeungwoo Jeon (SKKU Digital Media Lab)
%-------------------------------------------------------------------------%

close all;
clear all;
clc;

addpath('../core');
addpath('../evaluation');

% Camera spectral sensitivity functions
ssf_CYGM = load('MN3776_cygm_420-1000_10.csv');
ssf_RGB = load('MN3776_rgb_420-1000_10.csv');
ssf_Hotmirror = load('Hotmirror_Ideal_750_10.csv');

% Illumination (Daylight D65)
L = load('daylight_420-1000_10.csv');

fprintf('Hyperspectral simulation environment initialized successfully.\n');
