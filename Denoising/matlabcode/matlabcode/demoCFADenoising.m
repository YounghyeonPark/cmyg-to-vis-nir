addpath('BM3D'); % add path for the BM3D
% http://www.cs.tut.fi/~foi/GCF-BM3D/

addpath('ICIP2013_RI_code'); % add path for the residual interpolation
% http://www.ok.ctrl.titech.ac.jp/res/DM/RI.html

img = double(imread('lena.png'));

noiselevel = [9.0, 10.0, 11.0];

nimg = img;
for i=1:3
 nimg(:,:,i) = img(:,:,i) + randn(size(img(:,:,i))) * noiselevel(i);
end

pattern = 'rggb';

raw = rgb2bayerraw( img, pattern );
nraw = rgb2bayerraw( nimg, pattern );

dnraw = CFAdenoise( nraw, noiselevel, pattern );

dnraw3 = repmat(dnraw,[1,1,3]);
dnimg = demosaick(dnraw3, pattern, 1);
imwrite(uint8(dnimg), 'dn_lena.png');

nraw3 = repmat(nraw,[1,1,3]);
nimg = demosaick(nraw3, pattern, 1);
imwrite(uint8(nimg), 'n_lena.png');

psnr = imcpsnr( img, nimg, 255, 8 );
fprintf( 'CPSNR of noisy image: %f\n', psnr );
psnr = imcpsnr( img, dnimg, 255, 8 );
fprintf( 'CPSNR of denoised image: %f\n', psnr );

psnr = impsnr( raw, nraw, 255, 8 );
fprintf( 'PSNR of noisy CFA data: %f\n', psnr );
psnr = impsnr( raw, dnraw, 255, 8 );
fprintf( 'PSNR of denoised CFA data: %f\n', psnr );
