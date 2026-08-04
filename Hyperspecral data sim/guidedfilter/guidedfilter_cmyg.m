function q = guidedfilter_cmyg(I, p, r, eps)
%   GUIDEDFILTER_COLOR   O(1) time implementation of guided filter using a color image as the guidance.
%
%   - guidance image: I (should be a color (RGB) image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: eps

[hei, wid] = size(p);
N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

mean_I_c = boxfilter(I(:, :, 1), r) ./ N;
mean_I_m = boxfilter(I(:, :, 2), r) ./ N;
mean_I_y = boxfilter(I(:, :, 3), r) ./ N;
mean_I_g = boxfilter(I(:, :, 4), r) ./ N;

mean_p = boxfilter(p, r) ./ N;

mean_Ip_c = boxfilter(I(:, :, 1).*p, r) ./ N;
mean_Ip_m = boxfilter(I(:, :, 2).*p, r) ./ N;
mean_Ip_y = boxfilter(I(:, :, 3).*p, r) ./ N;
mean_Ip_g = boxfilter(I(:, :, 4).*p, r) ./ N;

% covariance of (I, p) in each local patch.
cov_Ip_c = mean_Ip_c - mean_I_c .* mean_p;
cov_Ip_m = mean_Ip_m - mean_I_m .* mean_p;
cov_Ip_y = mean_Ip_y - mean_I_y .* mean_p;
cov_Ip_g = mean_Ip_g - mean_I_g .* mean_p;

% variance of I in each local patch: the matrix Sigma in Eqn (14).
% Note the variance in each local patch is a 3x3 symmetric matrix:
%           rr, rg, rb
%   Sigma = rg, gg, gb
%           rb, gb, bb
var_I_cc = boxfilter(I(:, :, 1).*I(:, :, 1), r) ./ N - mean_I_c .*  mean_I_c; 
var_I_cm = boxfilter(I(:, :, 1).*I(:, :, 2), r) ./ N - mean_I_c .*  mean_I_m; 
var_I_cy = boxfilter(I(:, :, 1).*I(:, :, 3), r) ./ N - mean_I_c .*  mean_I_y; 
var_I_cg = boxfilter(I(:, :, 1).*I(:, :, 4), r) ./ N - mean_I_c .*  mean_I_g; 
var_I_mm = boxfilter(I(:, :, 2).*I(:, :, 2), r) ./ N - mean_I_m .*  mean_I_m; 
var_I_my = boxfilter(I(:, :, 2).*I(:, :, 3), r) ./ N - mean_I_m .*  mean_I_y; 
var_I_mg = boxfilter(I(:, :, 2).*I(:, :, 4), r) ./ N - mean_I_m .*  mean_I_g; 
var_I_yy = boxfilter(I(:, :, 3).*I(:, :, 3), r) ./ N - mean_I_y .*  mean_I_y;
var_I_yg = boxfilter(I(:, :, 3).*I(:, :, 4), r) ./ N - mean_I_y .*  mean_I_g;
var_I_gg = boxfilter(I(:, :, 4).*I(:, :, 4), r) ./ N - mean_I_g .*  mean_I_g;


a = zeros(hei, wid, 4);

for y=1:hei
    for x=1:wid        
        Sigma = [var_I_cc(y, x), var_I_cm(y, x), var_I_cy(y, x), var_I_cg(y, x);
                 var_I_cm(y, x), var_I_mm(y, x), var_I_my(y, x), var_I_mg(y, x);
                 var_I_cy(y, x), var_I_my(y, x), var_I_yy(y, x), var_I_yg(y, x);
                 var_I_cg(y, x), var_I_mg(y, x), var_I_yg(y, x), var_I_gg(y, x)
                ];
        %Sigma = Sigma + eps * eye(4);
        
        cov_Ip = [cov_Ip_c(y, x), cov_Ip_m(y, x), cov_Ip_y(y, x), cov_Ip_g(y, x)];        
        
        a(y, x, :) = cov_Ip / (Sigma + eps * eye(4)); % Eqn. (14) in the paper;
    end
end

b = mean_p - a(:, :, 1) .* mean_I_c - a(:, :, 2) .* mean_I_m - a(:, :, 3) .* mean_I_y - a(:, :, 4) .* mean_I_g; % Eqn. (15) in the paper;

q = (boxfilter(a(:, :, 1), r).* I(:, :, 1)...
+ boxfilter(a(:, :, 2), r).* I(:, :, 2)...
+ boxfilter(a(:, :, 3), r).* I(:, :, 3)...
+ boxfilter(a(:, :, 4), r).* I(:, :, 4)...
+ boxfilter(b, r)) ./ N;  % Eqn. (16) in the paper;
end