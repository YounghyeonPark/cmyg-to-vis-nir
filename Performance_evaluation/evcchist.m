

function  t=evcchist(A,B)
% A,B color or grayscale 
A=double(A);
B=double(B);

% evc for grayscale

    t=mean(sqrt((A-B).^2));
end

    

