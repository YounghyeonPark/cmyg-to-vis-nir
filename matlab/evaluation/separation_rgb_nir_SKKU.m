function [separated_rgb, separated_nir] = separation_rgb_nir_SKKU(bayer_cmyg_nir)
% Proposed SKKU Separation Pipeline
    addpath('../core');
    interpolated_CMYG = interpolate_cmyg(bayer_cmyg_nir, 'coolpix5700');

    [converted_rgb, converted_nir] = convert_cmygp_to_rgbn(interpolated_CMYG);
    mixed_rgb = convert_cmyg_to_rgb(interpolated_CMYG);

    separated_rgb = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
    separated_nir = denoise_nir(converted_rgb, converted_nir, mixed_rgb, interpolated_CMYG, 'guided');
end
