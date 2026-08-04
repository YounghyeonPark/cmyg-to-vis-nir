%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  SPATIALLY VARYING COLOR CORRECTION
%     [Y,nl_map] = svcc(X,M,nl,k)
%
%  INPUT ARGUMENTS:
%     1) X ( H x W x 3 )   : noisy input image
%     2) M ( 3 x 3 )       : color correction matrix for noise-free case
%     3) nl ( 3 x 1 )      : noise level (std. dev.) of input image
%     4) k                 : block size of SVCC (k must be odd)
%
%  OUTPUTS:
%     1) Y                 : color corrected image
%     2) nl_map            : noise level distribution map
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Y,nl_map] = svcc(X,M,nl,k)

% block size
if ~rem(k,2)
    error('block size should be odd');
end
n = floor(k/2);
mid = ceil(k*k/2);

% correlation matrix of noise
Cn = diag(nl.^2);

% spatially varying color correction
fun = @(block_struct) BlockImCal(block_struct.data,M,Cn,nl,k,mid);
temp = blockproc(padarray(X,[n,n],'symmetric'),[1,1],fun,'BorderSize',[n,n],...
    'TrimBorder',false,'PadPartialBlocks',true,'UseParallel',true);

% output
Y = temp(n+1:end-n,n+1:end-n,1:3);
nl_map = temp(n+1:end-n,n+1:end-n,4:6);

end

% block-wise process
function [out] = BlockImCal(X,M,Cn,nl,k,mid)

% correlation matrix of noisy data
a = reshape(X,k*k,[])';
C = a*a'/(k*k);

% optimal color correction matrix
optM = M*(C\(C-Cn))';

% color corrected values
y = reshape(optM*a(:,mid),1,1,3);
% noise levels after SVCC
nl_new = reshape(sqrt(optM.^2*nl.^2),1,1,3);

% output form
out = cat(3,y,nl_new);

end
