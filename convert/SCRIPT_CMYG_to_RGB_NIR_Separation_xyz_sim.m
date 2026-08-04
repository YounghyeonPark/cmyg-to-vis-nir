%-------------------------------------------------------------------------%
% Title : Convert C'M'Y'G' to RGB, NIR (for 2014-2015 Samsung DMC project)
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
clear all;
addpath('./images');
addpath('./BM3D');
addpath('./bfilter2');
addpath('./guidedfilter');

addpath('./Images_new');




intensity_C = 0.1;
intensity_M = 0.2;
intensity_Y = 0.6;
intensity_G = 0.27;
intensity_NIR = 5;


%i = 1;
wg=0.5:0.1:1.5;
length=size(wg);

for i=1:length(2)
    
    gamma = [0.8053*wg(i) 0.9730*wg(i) 0.8035*wg(i) wg(i)];
    cmygp_xyzn = [-0.1871 0.7767 0.2471 gamma(1); 1.0820 -0.3119 0.0815 gamma(2); 0.5988 0.6150 -0.1364 gamma(3); -0.2231 0.9235 0.0365 gamma(4)];
    
    xyzn_cmygp = cmygp_xyzn^-1;
    
    
    C_NIR = intensity_C + (0.8053 * wg(i) * intensity_NIR);
    M_NIR = intensity_M + (0.9730 * wg(i) * intensity_NIR);
    Y_NIR = intensity_Y + (0.8035 * wg(i) * intensity_NIR);
    G_NIR = intensity_G + (1 * intensity_NIR);

    Dk = [C_NIR; M_NIR; Y_NIR; G_NIR];

    output_xyzn_vec = xyzn_cmygp * Dk;
    
    separated_nir = output_xyzn_vec(4);

    out_nir(i) = separated_nir;
    out_x(i) = output_xyzn_vec(1);
    out_y(i) = output_xyzn_vec(2);
    out_z(i) = output_xyzn_vec(3);
    
end
cmyg_xyz = [-0.1871 0.7767 0.2471; 1.0820 -0.3119 0.0815; 0.5988 0.6150 -0.1364; -0.2231 0.9235 0.0365];
xyz_cmyg = pinv(cmyg_xyz);
CMYG = [intensity_C;intensity_M;intensity_Y;intensity_G];
XYZ = xyz_cmyg * CMYG;




figure, hold on, plot(wg, out_nir), plot(wg, intensity_NIR * ones(size(wg)));
%figure, plot(wg, out_x);
%figure, plot(wg, out_y);
%figure, plot(wg, out_z);