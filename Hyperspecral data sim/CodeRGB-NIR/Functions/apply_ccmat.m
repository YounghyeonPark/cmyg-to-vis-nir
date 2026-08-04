function apply_ccmat(i)

% path setting
addpath('Results/mat');

% load images
load(sprintf('%03d_cRGB',i));
load(sprintf('%03d_cNIR',i));

% clipping
cRGB(cRGB<0) = 0;
cNIR(cNIR<0) = 0;

% apply 4x4 color correction matrix
load('Results/ccmat/ccmat.mat');
[ccRGB,ccNIR] = apply_linear4x4_rgbn(cRGB,cNIR,ccmat);

% save mat files
dir_mat = sprintf('Results/mat');
if exist(dir_mat,'dir') == 0
    mkdir(dir_mat);
end
save(sprintf('%s/%03d_ccRGB.mat',dir_mat,i),'ccRGB');
save(sprintf('%s/%03d_ccNIR.mat',dir_mat,i),'ccNIR');

% gamma correction for visualization
gam = 2.2;
ccRGB = ccRGB.^(1/gam);
ccNIR = ccNIR.^(1/gam);

% save images
dir_png = sprintf('Results/png');
if exist(dir_png,'dir') == 0
    mkdir(dir_png);
end
imwrite(real(ccRGB),sprintf('%s/%03d_ccRGB.png',dir_png,i));
imwrite(real(ccNIR),sprintf('%s/%03d_ccNIR.png',dir_png,i));

% remove path
rmpath('Results/mat');

end
