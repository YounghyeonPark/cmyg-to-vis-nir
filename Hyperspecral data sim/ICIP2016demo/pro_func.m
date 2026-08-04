%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  PROPOSED METHOD:
%     [output] = pro_func(X,M,nl,k,div_size)
%
%  INPUT ARGUMENTS:
%     1) X ( H x W x 3 )   : noisy input image
%     2) M ( 3 x 3 )       : color correction matrix for noise-free case
%     3) nl ( 3 x1 )       : noise level (std. dev.) of input image
%     4) k                 : block size of SVCC (k must be odd)
%     5) div_size          : interval width of assumed noise levels
%
%  OUTPUTS:
%     1) out               : output image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = pro_func(X,M,nl,k,div_size)

%% spatially varying color correction
disp('spatially varying color correction...')
[Y,nl_map] = svcc(X,M,nl,k);

%% parameters for denoising
disp('parameter setting for denoising...')
% noise level distribution maps
nlR = nl_map(:,:,1);
nlG = nl_map(:,:,2);
nlB = nl_map(:,:,3);
% minimum noise levels
nlR_min = min(nlR(:));
nlG_min = min(nlG(:));
nlB_min = min(nlB(:));
% maximum noise levels
nlR_max = max(nlR(:));
nlG_max = max(nlG(:));
nlB_max = max(nlB(:));

% start and end points of denoising
% R channel
start_nlR = floor(nlR_min/div_size);
end_nlR = ceil(nlR_max/div_size);
div_r = end_nlR - start_nlR + 1;
% G channel
start_nlG = floor(nlG_min/div_size);
end_nlG = ceil(nlG_max/div_size);
div_g = end_nlG - start_nlG + 1;
% B channel
start_nlB = floor(nlB_min/div_size);
end_nlB = ceil(nlB_max/div_size);
div_b = end_nlB - start_nlB + 1;

% noise level setting for denoising
den_nlR = zeros(1,div_r);
den_nlG = zeros(1,div_g);
den_nlB = zeros(1,div_b);
% R channel
for i=0:div_r-1
    den_nlR(i+1) = div_size*(start_nlR+i);
end
% G channel
for i=0:div_g-1
    den_nlG(i+1) = div_size*(start_nlG+i);
end
% B channel
for i=0:div_b-1
    den_nlB(i+1) = div_size*(start_nlB+i);
end

%% denoising of the color corrected RGB image
% R channel
disp('denoising color corrected R image...')
if den_nlR(1)==0
    Zr(:,:,1) = Y(:,:,1);
    parfor i=2:div_r
        [~, Zr(:,:,i)] = BM3D(1,Y(:,:,1),255*den_nlR(i),'np',0);
    end
else
    parfor i=1:div_r
        [~, Zr(:,:,i)] = BM3D(1,Y(:,:,1),255*den_nlR(i),'np',0);
    end
end

% G channel
disp('denoising color corrected G image...')
if den_nlG(1)==0
    Zg(:,:,1) = Y(:,:,2);
    parfor i=2:div_g
        [~, Zg(:,:,i)] = BM3D(1,Y(:,:,2),255*den_nlG(i),'np',0);
    end
else
    parfor i=1:div_g
        [~, Zg(:,:,i)] = BM3D(1,Y(:,:,2),255*den_nlG(i),'np',0);
    end
end

% B channel
disp('denoising color corrected B image...')
if den_nlB(1)==0
    Zb(:,:,1) = Y(:,:,3);
    parfor i=2:div_b
        [~, Zb(:,:,i)] = BM3D(1,Y(:,:,3),255*den_nlB(i),'np',0);
    end
else
    parfor i=1:div_b
        [~, Zb(:,:,i)] = BM3D(1,Y(:,:,3),255*den_nlB(i),'np',0);
    end
end

%% composing denoised images
disp('composing denoised images...')
out = zeros(512,512,3);
% R channel
for i =1:div_r-1
    out(:,:,1) = out(:,:,1)+(Zr(:,:,i).*(den_nlR(i+1)-nlR)+Zr(:,:,i+1).*(nlR-den_nlR(i)))...
        .*((den_nlR(i)<=nlR) & (nlR<den_nlR(i+1)))/(den_nlR(i+1)-den_nlR(i));
end
% G channel
for i =1:div_g-1
    out(:,:,2) = out(:,:,2)+(Zg(:,:,i).*(den_nlG(i+1)-nlG)+Zg(:,:,i+1).*(nlG-den_nlG(i)))...
        .*((den_nlG(i)<=nlG) & (nlG<den_nlG(i+1)))/(den_nlG(i+1)-den_nlG(i));
end
% B channel
for i =1:div_b-1
    out(:,:,3) = out(:,:,3)+(Zb(:,:,i).*(den_nlB(i+1)-nlB)+Zb(:,:,i+1).*(nlB-den_nlB(i)))...
        .*((den_nlB(i)<=nlB) & (nlB<den_nlB(i+1)))/(den_nlB(i+1)-den_nlB(i));
end
out(:,:,1) = out(:,:,1) + Zr(:,:,div_r).*(den_nlR(div_r)==nlR);
out(:,:,2) = out(:,:,2) + Zg(:,:,div_g).*(den_nlG(div_g)==nlG);
out(:,:,3) = out(:,:,3) + Zb(:,:,div_b).*(den_nlB(div_b)==nlB);

end