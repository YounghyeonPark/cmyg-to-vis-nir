function M=mat_rgb2xyz(param)
% mat_rgb2xyz
%
% INPUT:
%	Chromaticity coordinates for reference white point,
%	param(1:2)=[xw yw]
%	, primaries
%	param(3:8)=[xr yr xg yg xb yb]
%	, and maximum luminance
%	param(9)=Yw
% OUTPUT:
%	rgb to xyz matrix M
% EXAMPLE:
%	param=[0.3127 0.3290 0.64 0.33 0.30 0.60 0.15 0.06 1];
%	M=mat_rgb2xyz(param)

xw=param(1);
yw=param(2);
zw=1-(xw+yw);
Yw=param(9);

xr=param(3);
yr=param(4);
zr=1-(xr+yr);

xg=param(5);
yg=param(6);
zg=1-(xg+yg);

xb=param(7);
yb=param(8);
zb=1-(xb+yb);

X=[xr xg xb; yr yg yb; zr zg zb];
y=[xw*Yw/yw Yw zw*Yw/yw];

S=inv(X)*y';

M=[xr*S(1) xg*S(2) xb*S(3); yr*S(1) yg*S(2) yb*S(3); zr*S(1) zg*S(2) zb*S(3)];

end
