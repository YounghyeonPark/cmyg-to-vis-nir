%Find NIR difference of each CMYG channel

close all;
%clear all;
addpath('./Images_NIR');


pos_center_x = 1288;
pos_center_y = 962;
box_size = 100;

pos_start_x = pos_center_x - box_size;
pos_end_x = pos_center_x + box_size;
pos_start_y = pos_center_y - box_size;
pos_end_y = pos_center_y + box_size;

img_start_idx = 1258;
%img_end_idx = 1227;
img_end_idx = 1291;
num_of_img = img_end_idx - img_start_idx + 1;

mean_C = zeros(num_of_img, 1);
mean_M = zeros(num_of_img, 1);
mean_Y = zeros(num_of_img, 1);
mean_G = zeros(num_of_img, 1);

var_C = zeros(num_of_img, 1);
var_M = zeros(num_of_img, 1);
var_Y = zeros(num_of_img, 1);
var_G = zeros(num_of_img, 1);


for i = 1:num_of_img %for multiple files
    
    filename = ['DSCN', num2str(i + img_start_idx - 1), '.NEF.pgm'];

    
    %----------------------------------%
    % Step 1 : Read bayer pattern(CMYG)
    %----------------------------------%
    bayer_CMYG = imread(filename);

    %------------------------------%
    % Step 2 : Bad pixel correction
    %------------------------------%
    bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');

    %--------------------------------------------%
    % Step 3 : interpolation of each CMYG channel
    %--------------------------------------------%
    interpolated_CMYG = interpolate_cmyg(bayer_CMYG, 'coolpix5700');

    
    
    interpolated_C = interpolated_CMYG(pos_start_y:pos_end_y, pos_start_x:pos_end_x, 1);
    interpolated_M = interpolated_CMYG(pos_start_y:pos_end_y, pos_start_x:pos_end_x, 2);
    interpolated_Y = interpolated_CMYG(pos_start_y:pos_end_y, pos_start_x:pos_end_x, 3);
    interpolated_G = interpolated_CMYG(pos_start_y:pos_end_y, pos_start_x:pos_end_x, 4);
    
    mean_C(i) = mean(interpolated_C(:));
    mean_M(i) = mean(interpolated_M(:));
    mean_Y(i) = mean(interpolated_Y(:));
    mean_G(i) = mean(interpolated_G(:));
    
    var_C(i) = var(interpolated_C(:));
    var_M(i) = var(interpolated_M(:));
    var_Y(i) = var(interpolated_Y(:));
    var_G(i) = var(interpolated_G(:));
end

mean_CG = mean(mean_C ./ mean_G);
mean_MG = mean(mean_M ./ mean_G);
mean_YG = mean(mean_Y ./ mean_G);


%MbyC = interpolated_M ./ interpolated_C;
%YbyC = interpolated_Y ./ interpolated_C;
%GbyC = interpolated_G ./ interpolated_C;

%CbyM = interpolated_C ./ interpolated_M;
%YbyM = interpolated_Y ./ interpolated_M;
%GbyM = interpolated_G ./ interpolated_M;

%CbyY = interpolated_C ./ interpolated_Y;
%MbyY = interpolated_M ./ interpolated_Y;
%GbyY = interpolated_G ./ interpolated_Y;

%CbyG = interpolated_C ./ interpolated_G;
%MbyG = interpolated_M ./ interpolated_G;
%YbyG = interpolated_Y ./ interpolated_G;
%mu_CG = mean(CbyG(:));
%mu_MG = mean(MbyG(:));
%mu_YG = mean(YbyG(:));
%var_CG = var(CbyG(:));
%var_MG = var(MbyG(:));
%var_YG = var(YbyG(:));
%gamma_C = [1 mean(MbyC(:)) mean(YbyC(:)) mean(GbyC(:))];
%gamma_M = [mean(CbyM(:)) 1 mean(YbyM(:)) mean(GbyM(:))];
%gamma_Y = [mean(CbyY(:)) mean(MbyY(:)) 1 mean(GbyY(:))];
%gamma_G = [mu_CG mu_MG mu_YG 1];



%figure, imshow(double(bayer_CMYG)./(2^12-1)*3), title('bayer pattern(NIR only)');

% figure, title('NIR intensity in color channels (x : G y : C)'), xlabel('G intensity'), ylabel('C intensity'), hold on;
% plot(interpolated_G, interpolated_C, 'color', 'c', 'marker', '+', 'linestyle', 'none')...
% , plot(0:600, 0:600,'r--'), plot(0:600, mu_CG.*[0:600], 'b')
% 
% figure, title('NIR intensity in color channels (x : G y : M)'), xlabel('G intensity'), ylabel('M intensity'), hold on;
% plot(interpolated_G, interpolated_M, 'color', 'm', 'marker', '+', 'linestyle', 'none')...
% , plot(0:600, 0:600,'r--'), plot(0:600, mu_MG.*[0:600], 'b')
% 
% figure, title('NIR intensity in color channels (x : G y : Y)'), xlabel('G intensity'), ylabel('Y intensity'), hold on;
% plot(interpolated_G, interpolated_Y, 'color', 'y', 'marker', '+', 'linestyle', 'none')...
% , plot(0:600, 0:600,'r--'), plot(0:600, mu_YG.*[0:600], 'b')
