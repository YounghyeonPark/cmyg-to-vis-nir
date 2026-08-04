

function  t=evcc(A,B)
% A,B color or grayscale 
A=double(A);
B=double(B);

% evc for grayscale
if (size(A,3)==1) && (size(B,3)==1)
         t=mean(mean(sqrt((A-B).^2)));
% evc for color
elseif  (size(A,3)==3) && (size(B,3)==3)
for k=1:3
    a=A(:,:,k);
    b=B(:,:,k);
    e(:,k)= (a(:)-b(:)).^2;
end
t=mean(sqrt(e(:,1)+e(:,2)+e(:,3))); %evc of color A and B
% if A=B, t=0
end


    

