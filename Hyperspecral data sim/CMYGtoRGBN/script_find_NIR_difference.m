%Find NIR difference of each CMYG channel

close all;
clear all;
addpath('./images');

%bayer_CMYG = imread('RGB.NEF.pgm');
bayer_CMYG = imread('Box_White_NIR_only.pgm');
%bayer_CMYG = imread('Box_White_NIR_only_940.pgm');
%bayer_CMYG = imread('Box_White_NIR_only_940_dot.pgm');
%bayer_CMYG = imread('piggybank_wo_IRFlash.NEF.pgm');
%bayer_CMYG = imread('Box_Object_NIR_only.pgm');
resolution = size(bayer_CMYG);

bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');


bayer_C = zeros(resolution);
bayer_M = zeros(resolution);
bayer_Y = zeros(resolution);
bayer_G = zeros(resolution);

for i = 1:resolution(1)
   for j = 1:resolution(2)
     
       if (mod(i,2) == 1 && mod(j,2) == 1) % Left Top
           bayer_G(i,j) = bayer_CMYG(i, j);
           
       elseif (mod(i,2) == 1 && mod(j,2) == 0) % Right Top
           bayer_M(i,j) = bayer_CMYG(i, j);    
            
       elseif (mod(i,2) == 0 && mod(j,2) == 1) % Left Bottom
           bayer_Y(i,j) = bayer_CMYG(i, j);    
           
       else                                     % Right Bottom
           bayer_C(i,j) = bayer_CMYG(i, j);
       
       end
         
   end
    
end

%interpolated_C = double(interpolation_LT(bayer_C));
%interpolated_M = double(interpolation_RT(bayer_M));
%interpolated_Y = double(interpolation_LB(bayer_Y));
%interpolated_G = double(interpolation_RB(bayer_G));

interpolated_G = double(interpolation_LT(bayer_G));
interpolated_M = double(interpolation_RT(bayer_M));
interpolated_Y = double(interpolation_LB(bayer_Y));
interpolated_C = double(interpolation_RB(bayer_C));


MbyC = interpolated_M ./ interpolated_C;
YbyC = interpolated_Y ./ interpolated_C;
GbyC = interpolated_G ./ interpolated_C;

CbyM = interpolated_C ./ interpolated_M;
YbyM = interpolated_Y ./ interpolated_M;
GbyM = interpolated_G ./ interpolated_M;

CbyY = interpolated_C ./ interpolated_Y;
MbyY = interpolated_M ./ interpolated_Y;
GbyY = interpolated_G ./ interpolated_Y;

CbyG = interpolated_C ./ interpolated_G;
MbyG = interpolated_M ./ interpolated_G;
YbyG = interpolated_Y ./ interpolated_G;
mu_CG = mean(CbyG(:));
mu_MG = mean(MbyG(:));
mu_YG = mean(YbyG(:));
var_CG = var(CbyG(:));
var_MG = var(MbyG(:));
var_YG = var(YbyG(:));
gamma_C = [1 mean(MbyC(:)) mean(YbyC(:)) mean(GbyC(:))];
gamma_M = [mean(CbyM(:)) 1 mean(YbyM(:)) mean(GbyM(:))];
gamma_Y = [mean(CbyY(:)) mean(MbyY(:)) 1 mean(GbyY(:))];
gamma_G = [mu_CG mu_MG mu_YG 1];



figure, imshow(double(bayer_CMYG)./(2^12-1)*3), title('bayer pattern(NIR only)');

figure, title('NIR intensity in color channels (x : G y : C)'), xlabel('G intensity'), ylabel('C intensity'), hold on;
plot(interpolated_G, interpolated_C, 'color', 'c', 'marker', '+', 'linestyle', 'none')...
, plot(0:600, 0:600,'r--'), plot(0:600, mu_CG.*[0:600], 'b')

figure, title('NIR intensity in color channels (x : G y : M)'), xlabel('G intensity'), ylabel('M intensity'), hold on;
plot(interpolated_G, interpolated_M, 'color', 'm', 'marker', '+', 'linestyle', 'none')...
, plot(0:600, 0:600,'r--'), plot(0:600, mu_MG.*[0:600], 'b')

figure, title('NIR intensity in color channels (x : G y : Y)'), xlabel('G intensity'), ylabel('Y intensity'), hold on;
plot(interpolated_G, interpolated_Y, 'color', 'y', 'marker', '+', 'linestyle', 'none')...
, plot(0:600, 0:600,'r--'), plot(0:600, mu_YG.*[0:600], 'b')
