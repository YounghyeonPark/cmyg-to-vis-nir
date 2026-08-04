function train_ccmat_chart(ssf)

% illumination
L = load('daylight_420-1000_10.csv');
% reflectance data of SG chart
SGdata = load('chart_420-1000_10.csv');
% color matching functions
cmf = load('ssf_xyz_420-1000_10.csv');
% target NIR function
ssfn = load('ssf_target-nir_420-1000_10.csv');

% camera RGB data
vec_cRGB = ssf(:,1:3)'* diag(L)* SGdata;
% camera NIR data
vec_cNIR = ssf(:,4)'* diag(L)* SGdata;

% normalization of camera RGB-NIR data
maxRGBN = max([vec_cRGB(:); vec_cNIR(:)]);
vec_cRGB = vec_cRGB/maxRGBN;
vec_cNIR = vec_cNIR/maxRGBN;

% camera RGB-NIR image
cRGBim = reshape(vec_cRGB',8,12,3);
cNIRim = reshape(vec_cNIR',8,12,1);
cRGBim = imresize(cRGBim,100,'nearest');
cNIRim = imresize(cNIRim,100,'nearest');

% white point
xyz = cmf'* L;
x = xyz(1)/sum(xyz);
y = xyz(2)/sum(xyz);

% rgb2xyz matrix with white point
param = [x y 0.64 0.33 0.30 0.60 0.15 0.06 1];
M = mat_rgb2xyz(param);

% sRGB data
vec_XYZ = cmf'* diag(L)* SGdata;
vec_sRGB = inv(M)* vec_XYZ;

% sNIR data
vec_sNIR = ssfn'* diag(L)* SGdata;

% normalization of sRGB and sNIR data
maxsRGBN = max([vec_sRGB(:); vec_sNIR(:)]);
vec_sRGB = vec_sRGB/maxsRGBN;
vec_sNIR = vec_sNIR/maxsRGBN;

% sRGB and sNIR images
sRGB = reshape(vec_sRGB',8,12,3);
sNIR = reshape(vec_sNIR',8,12,1);
sRGBim = imresize(sRGB,100,'nearest');
sNIRim = imresize(sNIR,100,'nearest');

% train 4x4 color correction matrix
ccmat = train_linear4x4_rgbn(vec_sRGB,vec_sNIR,vec_cRGB,vec_cNIR);
[ccRGBim,ccNIRim] = apply_linear4x4_rgbn(cRGBim,cNIRim,ccmat);

% save matrix
dir_ccmat = 'Results/ccmat';
if exist(dir_ccmat,'dir') == 0
    mkdir(dir_ccmat);
end
save(sprintf('%s/ccmat',dir_ccmat),'ccmat');

% gamma correction for visualization
gam = 2.2;
cRGBim = cRGBim.^(1/gam);
cNIRim = cNIRim.^(1/gam);
sRGBim = sRGBim.^(1/gam);
sNIRim = sNIRim.^(1/gam);
ccRGBim = ccRGBim.^(1/gam);
ccNIRim = ccNIRim.^(1/gam);

% save images
dir_chart = 'Results/chart';
if exist(dir_chart,'dir') == 0
    mkdir(dir_chart);
end
imwrite(cRGBim,sprintf('%s/chart_cRGB.png',dir_chart));
imwrite(cNIRim,sprintf('%s/chart_cNIR.png',dir_chart));
imwrite(sRGBim,sprintf('%s/chart_sRGB.png',dir_chart));
imwrite(sNIRim,sprintf('%s/chart_sNIR.png',dir_chart));
imwrite(ccRGBim,sprintf('%s/chart_ccRGB.png',dir_chart));
imwrite(ccNIRim,sprintf('%s/chart_ccNIR.png',dir_chart));

end
