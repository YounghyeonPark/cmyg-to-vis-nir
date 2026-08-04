function [ccRGB,ccNIR] = apply_linear4x4_rgbn(cRGB,cNIR,ccmat)

s = size(cRGB);

vec_cRGB = reshape(cRGB,s(1)*s(2),3)';
vec_cNIR = reshape(cNIR,s(1)*s(2),1)';

vec_ccRGBN = ccmat * [vec_cRGB;vec_cNIR];
ccRGBN = reshape(vec_ccRGBN',s(1),s(2),4);

ccRGB = ccRGBN(:,:,1:3);
ccNIR = ccRGBN(:,:,4);

end
