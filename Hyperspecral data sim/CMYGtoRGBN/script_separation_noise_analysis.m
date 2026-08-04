%-------------------------------------------------------------------------%
% Title : Convert C'M'Y'G' to RGB, NIR (for 2014-2015 Samsung DMC project)
%         Noise Analysis
%
% Author : SKKU Digital Media Lab.
%
% Changes:
% 2015/06/06 : First commit (Younghyeon Park, neversky@skku.edu)
%
%
%-------------------------------------------------------------------------%


%CMYG-NIR to RGB, NIR conversion
close all;
%clear all;
addpath('./images');
addpath('./BM3D');
addpath('./bfilter2');
addpath('./guidedfilter');

addpath('./Images_new');

%gcp

%for cnt=1110:1133 %for multiple files

%    filename = ['DSCN', num2str(cnt), '.NEF.pgm'];
    
filename = 'DSCN1087.NEF.pgm';
%filename = 'DSCN1150.NEF.pgm';
%filename = 'DSCN1153.NEF.pgm';
%filename = 'CRW_9230.CRW.pgm';

%-------%
% Option
%-------%
%write_image_as_file = true;fig
opt.write_image_as_file = false;
opt.plot_results = true;
opt.pre_denoise = false;
opt.denoise_rgb = false;
opt.denoise_nir = false;
opt.awb = false;
opt.wg = 1;
opt.cut_start_x = 1500;
opt.cut_start_y = 650;
opt.cut_end_x = 1750;
opt.cut_end_y = 900;

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

%--------------------------------------------%
% Step 3.5 : Denoise CMYG channel
%--------------------------------------------%
if opt.pre_denoise == true
    fprintf('\nPre de-noising CMYG\n');
    tic
    interpolated_CMYG = denoise_cmyg(interpolated_CMYG, 'wiener');
    
    toc
end     %
     
%noise_CMYG = interpolated_CMYG - interpolated_CMYG_filtered;


%opt.wg_arr = 0.1:0.01:3;
opt.lightsource = 'fluorescent';
opt.wg_arr = 1;
size_wg_arr = size(opt.wg_arr');

for i = 1:size_wg_arr % wg value evaluation


%--------------------------------------%
% Step 4 : convert C'M'Y'G' to RGB, NIR
%--------------------------------------%
fprintf('\nConvert C''M''Y''G'' to RGB, NIR\n');
tic
[separated_xyz, separated_nir, inv_S] = convert_cmygp_to_xyzn(interpolated_CMYG, opt.wg_arr(i), opt.lightsource);
toc

separated_rgb = convert_xyz_to_srgb(separated_xyz);
%separated_nir = separated_nir * 1.5;
%--------------------------------------%
% Get RGB-NIR mixed image from C'M'Y'G'
%--------------------------------------%
fprintf('\nGet RGB-NIR mixed image from C''M''Y''G''\n');
tic
mixed_xyz = convert_cmyg_to_xyz(interpolated_CMYG, opt.lightsource);
toc
%mixed_rgb = xyz2rgb(mixed_xyz);
mixed_rgb = convert_xyz_to_srgb(mixed_xyz);

%--------------------%
% Step 5 : De-noising
%--------------------%
if opt.denoise_rgb == true
    fprintf('\nDe-noising RGB\n');
    tic
    separated_rgb_filtered = denoise_rgb(separated_rgb, separated_nir, mixed_xyz, interpolated_CMYG, 'guided');
    toc
end

if opt.denoise_nir == true
    fprintf('\nDe-noising NIR\n');
    tic
    separated_nir_filtered = denoise_nir(separated_rgb, separated_nir, mixed_xyz, interpolated_CMYG, 'guided');
    toc
end

%-------------------------------------%
% Step 6 : Auto white balancing of RGB
%-------------------------------------%
if opt.awb == true
    fprintf('\nAuto white balancing of RGB\n');
    tic
    if opt.denoise_rgb == true
        separated_rgb_filtered_awb = auto_white_balance(separated_rgb_filtered, 'grayworld+retinex');
    else
        separated_rgb_awb = auto_white_balance(separated_rgb, 'grayworld+retinex');
    end
    
    mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld+retinex');
    toc
end

%-------------------------%
% Step 7 : display results
%-------------------------%
if opt.plot_results == true
    if opt.denoise_rgb == true
        figure, imshow(separated_rgb_filtered), title('Separated RGB (Wiener filter)');
    end
    
    if opt.denoise_nir == true
        figure, imshow(separated_nir_filtered), title('Separated NIR (Wiener filter)');
    end
    
    figure, imshow(separated_rgb), title('Separated RGB');
    figure, imshow(separated_nir), title('Separated NIR');
    figure, imshow(mixed_rgb), title('RGB+NIR');
    
    if opt.awb == true
        if opt.denoise_rgb == true
            figure, imshow(separated_rgb_filtered_awb), title('Separated RGB (Wiener filter, AWB)');
        else
            figure, imshow(separated_rgb_awb), title('Separated RGB (AWB)');
        end
        
        figure, imshow(mixed_rgb_awb), title('RGB+NIR (AWB)');
    end
end

%-----------------------------%
% Step 8 : Save images to file
%-----------------------------%
if opt.write_image_as_file == true
    file_extension = '.jpg';
    str_filename_write_separated_RGB_wiener = [filename, '_separated_rgb(wiener)',file_extension];
    str_filename_write_separated_NIR_wiener = [filename, '_separated_nir(wiener)',file_extension];
    str_filename_write_separated_RGB = [filename, '_separated_rgb',file_extension];
    str_filename_write_separated_RGB_awb = [filename, '_separated_rgb_awb',file_extension];
    str_filename_write_separated_NIR = [filename, '_separated_nir',file_extension];
    str_filename_write_RGB_NIR = [filename, '_rgb+nir',file_extension];
    str_filename_write_separated_RGB_wiener_awb = [filename, '_separated_rgb(wiener,awb)', file_extension];
    str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)',file_extension];

    if opt.denoise_rgb == true
        imwrite(separated_rgb_filtered, str_filename_write_separated_RGB_wiener);
    end
    if opt.denoise_nir == true
        imwrite(separated_nir_filtered, str_filename_write_separated_NIR_wiener);
    end
    
    imwrite(separated_rgb, str_filename_write_separated_RGB);
    imwrite(separated_nir, str_filename_write_separated_NIR);
    imwrite(mixed_rgb, str_filename_write_RGB_NIR);
    if opt.awb == true
        imwrite(mixed_rgb_awb, str_filename_write_RGB_NIR_awb);
        if opt.denoise_rgb == true
            imwrite(separated_rgb_filtered_awb, str_filename_write_separated_RGB_wiener_awb);
        else
            imwrite(separated_rgb_awb, str_filename_write_separated_RGB_awb);
        end
    end
end


%noise analysis
separated_xyz_cut = separated_xyz(opt.cut_start_y:opt.cut_end_y, opt.cut_start_x:opt.cut_end_x,:);
separated_nir_cut = separated_nir(opt.cut_start_y:opt.cut_end_y, opt.cut_start_x:opt.cut_end_x);
interpolated_CMYG_cut = interpolated_CMYG(opt.cut_start_y:opt.cut_end_y, opt.cut_start_x:opt.cut_end_x,:);

v_c = interpolated_CMYG_cut(:,:,1);
mean_cyan = mean(v_c(:));
var_cyan = var(v_c(:));
std_cyan = std(v_c(:));
v_m = interpolated_CMYG_cut(:,:,2);
mean_magenta = mean(v_m(:));
var_magenta = var(v_m(:));
std_magenta = std(v_m(:));
v_y = interpolated_CMYG_cut(:,:,3);
mean_yellow = mean(v_y(:));
var_yellow = var(v_y(:));
std_yellow = std(v_y(:));
v_g = interpolated_CMYG_cut(:,:,4);
mean_green = mean(v_g(:));
var_green = var(v_g(:));
std_green = std(v_g(:));

cov_cm = cov(v_c(:), v_m(:));
cov_cy = cov(v_c(:), v_y(:));
cov_cg = cov(v_c(:), v_g(:));
cov_my = cov(v_m(:), v_y(:));
cov_mg = cov(v_m(:), v_g(:));
cov_yg = cov(v_y(:), v_g(:));

cov_cm = cov_cm(1,2);
cov_cy = cov_cy(1,2);
cov_cg = cov_cg(1,2);
cov_my = cov_my(1,2);
cov_mg = cov_mg(1,2);
cov_yg = cov_yg(1,2);

cov_cmyg = [cov_cm cov_cy cov_cg cov_my cov_mg cov_yg]';

v = separated_xyz_cut(:,:,1);
mean_x = mean(v(:));
var_x = var(v(:));
std_x = std(v(:));
v = separated_xyz_cut(:,:,2);
mean_y = mean(v(:));
var_y = var(v(:));
std_y = std(v(:));
v = separated_xyz_cut(:,:,3);
mean_z = mean(v(:));
var_z = var(v(:));
std_z = std(v(:));
v = separated_nir_cut;
mean_nir = mean(v(:));
var_nir = var(v(:));
std_nir = std(v(:));

%y=0:0.01:1;
y=0.4:0.001:0.6;
%nbins = 100;
range_min = 0;
range_max = 1;

if opt.plot_results == true

%range_min = mean_cyan - (var_cyan * 300);
%range_max = mean_cyan + (var_cyan * 300);

    draw_hist_n_dist(interpolated_CMYG_cut(:,:,1), mean_cyan, var_cyan, [range_min range_max], true)
    saveas(gcf, 'noise_dist_c.png');
%range_min = mean_magenta - (var_magenta * 300);
%range_max = mean_magenta + (var_magenta * 300);
    draw_hist_n_dist(interpolated_CMYG_cut(:,:,2), mean_magenta, var_magenta, [range_min range_max], false)
    saveas(gcf, 'noise_dist_m.png');
%range_min = mean_yellow - (var_yellow * 300);
%range_max = mean_yellow + (var_yellow * 300);
    draw_hist_n_dist(interpolated_CMYG_cut(:,:,3), mean_yellow, var_yellow, [range_min range_max], false)
    saveas(gcf, 'noise_dist_ye.png');
%range_min = mean_green - (var_green * 300);
%range_max = mean_green + (var_green * 300);
    draw_hist_n_dist(interpolated_CMYG_cut(:,:,4), mean_green, var_green, [range_min range_max], false)
    saveas(gcf, 'noise_dist_g.png');
end

mean_cmyg = [mean_cyan, mean_magenta, mean_yellow, mean_green]';
mean_x_est = inv_S(1,:) * mean_cmyg;
mean_y_est = inv_S(2,:) * mean_cmyg;
mean_z_est = inv_S(3,:) * mean_cmyg;
mean_nir_est = inv_S(4,:) * mean_cmyg;


w_cm = inv_S(:,1) .* inv_S(:,2);
w_cy = inv_S(:,1) .* inv_S(:,3);
w_cg = inv_S(:,1) .* inv_S(:,4);
w_my = inv_S(:,2) .* inv_S(:,3);
w_mg = inv_S(:,2) .* inv_S(:,4);
w_yg = inv_S(:,3) .* inv_S(:,4);
w_cmyg = [w_cm w_cy w_cg w_my w_mg w_yg];

var_cmyg = [var_cyan, var_magenta, var_yellow, var_green]';
var_x_est = (inv_S(1,:) .^ 2) * var_cmyg + 2 * w_cmyg(1,:) * cov_cmyg;
var_y_est = (inv_S(2,:) .^ 2) * var_cmyg + 2 * w_cmyg(2,:) * cov_cmyg;
var_z_est = (inv_S(3,:) .^ 2) * var_cmyg + 2 * w_cmyg(3,:) * cov_cmyg;
var_nir_est = (inv_S(4,:) .^ 2) * var_cmyg + 2 * w_cmyg(4,:) * cov_cmyg;

std_cmyg = [std_cyan, std_magenta, std_yellow, std_green]';
std_x_est = sqrt(var_x_est);% sqrt((inv_S(1,:) .^ 2) * (std_cmyg .^ 2));
std_y_est = sqrt(var_y_est);%sqrt((inv_S(2,:) .^ 2) * (std_cmyg .^ 2));
std_z_est = sqrt(var_z_est);%sqrt((inv_S(3,:) .^ 2) * (std_cmyg .^ 2));
std_nir_est = sqrt(var_nir_est);%sqrt((inv_S(4,:) .^ 2) * (std_cmyg .^ 2));

delta_mean_x = mean_x - mean_x_est;
delta_mean_y = mean_y - mean_y_est;
delta_mean_z = mean_z - mean_z_est;
delta_mean_nir = mean_nir - mean_nir_est;

delta_var_x = var_x - var_x_est;
delta_var_y = var_y - var_y_est;
delta_var_z = var_z - var_z_est;
delta_var_nir = var_nir - var_nir_est;

delta_std_x = std_x - std_x_est;
delta_std_y = std_y - std_y_est;
delta_std_z = std_z - std_z_est;
delta_std_nir = std_nir - std_nir_est;

err_std(i) = norm([delta_std_x delta_std_y delta_std_z delta_std_nir], 2);

%    range_min = mean_x - (var_x * 300);
%    range_max = mean_x + (var_x * 300);
    draw_hist_n_dist_n_est(separated_xyz_cut(:,:,1), mean_x, var_x, mean_x_est, var_x_est, [range_min range_max], true)
    saveas(gcf, 'noise_dist_x.png');
%    range_min = mean_y - (var_y * 300);
%    range_max = mean_y + (var_y * 300);
    draw_hist_n_dist_n_est(separated_xyz_cut(:,:,2), mean_y, var_y, mean_y_est, var_y_est, [range_min range_max], false)
saveas(gcf, 'noise_dist_y.png');
%    range_min = mean_z - (var_z * 300);
%    range_max = mean_z + (var_z * 300);
    draw_hist_n_dist_n_est(separated_xyz_cut(:,:,3), mean_z, var_z, mean_z_est, var_z_est, [range_min range_max], false)
saveas(gcf, 'noise_dist_z.png');
%    range_min = mean_nir - (var_nir * 300);
%    range_max = mean_nir + (var_nir * 300);
    draw_hist_n_dist_n_est(separated_nir_cut, mean_nir, var_nir, mean_nir_est, var_nir_est, [range_min range_max], false)
saveas(gcf, 'noise_dist_nir.png');
end %wg value evaluation

%plot(opt.wg_arr, err_std);

%[hei, wid] = size(p);
%N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

%mean_I_c = boxfilter(I(:, :, 1), r) ./ N;
%mean_I_m = boxfilter(I(:, :, 2), r) ./ N;
%mean_I_y = boxfilter(I(:, :, 3), r) ./ N;
%mean_I_g = boxfilter(I(:, :, 4), r) ./ N;

%mean_p = boxfilter(p, r) ./ N;

%mean_Ip_c = boxfilter(I(:, :, 1).*p, r) ./ N;
%mean_Ip_m = boxfilter(I(:, :, 2).*p, r) ./ N;
%mean_Ip_y = boxfilter(I(:, :, 3).*p, r) ./ N;
%mean_Ip_g = boxfilter(I(:, :, 4).*p, r) ./ N;

% covariance of (I, p) in each local patch.
%cov_Ip_c = mean_Ip_c - mean_I_c .* mean_p;
%cov_Ip_m = mean_Ip_m - mean_I_m .* mean_p;
%cov_Ip_y = mean_Ip_y - mean_I_y .* mean_p;
%cov_Ip_g = mean_Ip_g - mean_I_g .* mean_p;

% variance of I in each local patch: the matrix Sigma in Eqn (14).
% Note the variance in each local patch is a 3x3 symmetric matrix:
%           rr, rg, rb
%   Sigma = rg, gg, gb
%           rb, gb, bb
%var_I_cc = boxfilter(I(:, :, 1).*I(:, :, 1), r) ./ N - mean_I_c .*  mean_I_c; 
%var_I_cm = boxfilter(I(:, :, 1).*I(:, :, 2), r) ./ N - mean_I_c .*  mean_I_m; 
%var_I_cy = boxfilter(I(:, :, 1).*I(:, :, 3), r) ./ N - mean_I_c .*  mean_I_y; 
%var_I_cg = boxfilter(I(:, :, 1).*I(:, :, 4), r) ./ N - mean_I_c .*  mean_I_g; 
%var_I_mm = boxfilter(I(:, :, 2).*I(:, :, 2), r) ./ N - mean_I_m .*  mean_I_m; 
%var_I_my = boxfilter(I(:, :, 2).*I(:, :, 3), r) ./ N - mean_I_m .*  mean_I_y; 
%var_I_mg = boxfilter(I(:, :, 2).*I(:, :, 4), r) ./ N - mean_I_m .*  mean_I_g; 
%var_I_yy = boxfilter(I(:, :, 3).*I(:, :, 3), r) ./ N - mean_I_y .*  mean_I_y;
%var_I_yg = boxfilter(I(:, :, 3).*I(:, :, 4), r) ./ N - mean_I_y .*  mean_I_g;
%var_I_gg = boxfilter(I(:, :, 4).*I(:, :, 4), r) ./ N - mean_I_g .*  mean_I_g;

imwrite(interpolated_CMYG_cut(1:25,1:25,1), 'noise_c.png');
imwrite(interpolated_CMYG_cut(1:25,1:25,2), 'noise_m.png');
imwrite(interpolated_CMYG_cut(1:25,1:25,3), 'noise_ye.png');
imwrite(interpolated_CMYG_cut(1:25,1:25,4), 'noise_g.png');


imwrite(separated_nir_cut(1:25,1:25), 'noise_separated_nir.png');
imwrite(separated_xyz_cut(1:25,1:25,1), 'noise_separated_x.png');
imwrite(separated_xyz_cut(1:25,1:25,2), 'noise_separated_y.png');
imwrite(separated_xyz_cut(1:25,1:25,3), 'noise_separated_z.png');

%end% for loop
    
function draw_hist_n_dist(data, mean, var, range, drawlegend)
    y=linspace(range(1),range(2),200);
    %y=range(1):0.001:range(2);
    %disp(num2str(mean));
    %disp(num2str(var));
    %f = exp(-((y-mean).^2)./(2*var))./(sqrt(var)*sqrt(2*pi));
    f = normpdf(y, mean, sqrt(var));
    
    figure
    histogram(data, 'BinLimits', range, 'NumBins', 200, 'Normalization', 'pdf', 'FaceColor', 'none' , 'EdgeColor', [0.5 0.5 0.5], 'DisplayStyle' ,'stairs', 'LineWidth', 1.5)
    hold on
    plot(y,f,'LineWidth',1.5, 'LineStyle', '--', 'Color', 'black')
    set(gca, 'fontsize', 34, 'fontname', 'Times New Roman')
    xlabel('intensity')% ylabel('probability');%, title(['VIS+NIR Cyan', newline, 'mean: ',num2str(mean_cyan), newline, 'std.: ', num2str(std_cyan)]);
    if drawlegend == true
        legend('hist.','dist.');
    end
    
    
end

function draw_hist_n_dist_n_est(data, mean, var, mean_est, var_est, range, drawlegend)
    y=linspace(range(1),range(2),200);
    %y=range(1):0.001:range(2);
    %disp(num2str(mean));
    %disp(num2str(var));
    %f = exp(-((y-mean).^2)./(2*var))./(sqrt(var)*sqrt(2*pi));
    f = normpdf(y, mean, sqrt(var));
    f_est = normpdf(y, mean_est, sqrt(var_est));
    
    figure
    histogram(data, 'BinLimits', range, 'NumBins', 200,  'Normalization', 'pdf', 'FaceColor', 'none' , 'EdgeColor', [0.5 0.5 0.5], 'DisplayStyle' ,'stairs', 'LineWidth', 1.5)
    hold on
    plot(y,f,'LineWidth',1.5, 'LineStyle', '--', 'Color', 'black')
    plot(y,f_est,'LineWidth',1.5, 'LineStyle', '-', 'Color', 'red')
    set(gca, 'fontsize', 34, 'fontname', 'Times New Roman')
    xlabel('intensity')% ylabel('probability');%, title(['VIS+NIR Cyan', newline, 'mean: ',num2str(mean_cyan), newline, 'std.: ', num2str(std_cyan)]);
    if drawlegend == true
        legend('hist.','dist.', 'est.');
    end
end