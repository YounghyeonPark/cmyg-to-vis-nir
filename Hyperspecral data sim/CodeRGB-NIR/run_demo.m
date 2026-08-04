clear;

% path setting
addpath('Functions','SpectralData');

% camera spectral sensitivity functions
%ssf = load('ssf_rgb-nir_420-1000_10.csv');
ssf = load('ssf_srgbn_420-1000_10.csv');
%ssf = load('ssf_cygm_nir_420-1000_10.csv');

% mat file name
matname = dir('Inputs/*.mat');

% train 4x4 color correction matrix
train_ccmat_chart(ssf);

% number of images
N = 1;

% roop for N images
for i = 1:16
    % load mat file
    fileName = matname(i).name;
    load(sprintf('Inputs/%s',fileName));
    
    % make camera RGB-NIR and target RGB-NIR images
    make_mat2gt(ssf,img,i);
    
    % apply 4x4 color correction matrix
    apply_ccmat(i);
end
