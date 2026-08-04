function [separated_rgb, separated_nir] = separation_rgb_nir_SKKU_nodemosaic(interpolated_CMYG)


%--------------------------------------------%
% Step 3 : interpolation of each CMYG channel
%--------------------------------------------%
%interpolated_CMYG = interpolate_cmyg(bayer_cmyg_nir, 'coolpix5700');

%--------------------------------------%
% Step 4 : convert C'M'Y'G' to RGB, NIR
%--------------------------------------%
[converted_rgb, converted_nir] = convert_cmygp_to_rgbn(interpolated_CMYG);
mixed_rgb = convert_cmyg_to_rgb(interpolated_CMYG);

%--------------------%
% Step 5 : De-noising
%--------------------%

separated_rgb = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
%separated_nir = denoise_nir(converted_rgb, converted_nir, mixed_rgb, 'wiener');
%separated_rgb = converted_rgb;
 separated_nir = denoise_nir(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
%separated_nir = converted_nir;


%-------------------------------------%
% Step 6 : Auto white balancing of RGB
%-------------------------------------%
%converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
%mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');



end