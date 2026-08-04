function make_mat2gt_cygm(ssf,img,i)

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

% image size
s = size(img);
% vectorization
vec = reshape(img,s(1)*s(2),s(3))';

% camera RGB image
vec_cRGB = ssf(:,1:3)'* diag(L)* vec;
cRGB = reshape(vec_cRGB',s(1),s(2),3);

% camera NIR image
vec_cNIR = ssf(:,4)'* diag(L)* vec;
cNIR = reshape(vec_cNIR',s(1),s(2),1);

% normalization of camera RGB-NIR image
maxRGBN = max([cRGB(:); cNIR(:)]);
cRGB = cRGB/maxRGBN;
cNIR = cNIR/maxRGBN;

% sRGB image
vec_XYZ = cmf'* diag(L)* vec;
vec_sRGB = inv(M)* vec_XYZ;
sRGB = reshape(vec_sRGB',s(1),s(2),3);

% target NIR image
vec_sNIR = ssfn'* diag(L)* vec;
sNIR = reshape(vec_sNIR',s(1),s(2),1);

% normalization of sRGB and sNIR images
maxsRGBN = max([sRGB(:); sNIR(:)]);
sRGB = sRGB/maxsRGBN;
sNIR = sNIR/maxsRGBN;

% save mat files
dir_mat = 'Results/mat';
if exist(dir_mat,'dir') == 0
    mkdir(dir_mat);
end
save(sprintf('%s/%03d_cRGB.mat',dir_mat,i),'cRGB');
save(sprintf('%s/%03d_cNIR.mat',dir_mat,i),'cNIR');
save(sprintf('%s/%03d_sRGB.mat',dir_mat,i),'sRGB');
save(sprintf('%s/%03d_sNIR.mat',dir_mat,i),'sNIR');

% gamma correction for visualization
gam = 2.2;
cRGB = cRGB.^(1/gam);
cNIR = cNIR.^(1/gam);
sRGB = sRGB.^(1/gam);
sNIR = sNIR.^(1/gam);

% save images
dir_png = 'Results/png';
if exist(dir_png,'dir') == 0
    mkdir(dir_png);
end
imwrite(real(cRGB), sprintf('%s/%03d_cRGB.png', dir_png, i));
imwrite(real(cNIR), sprintf('%s/%03d_cNIR.png', dir_png, i));
imwrite(real(sRGB), sprintf('%s/%03d_sRGB.png', dir_png, i));
imwrite(real(sNIR), sprintf('%s/%03d_sNIR.png', dir_png, i));

end
