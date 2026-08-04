

function  t=evcchist3(A1,A2,A3,B1,B2,B3)
% A,B color or grayscale 
A1=double(A1);
A2=double(A2);
A3=double(A3);
B1=double(B1);
B2=double(B2);
B3=double(B3);

% evc for grayscale

    t=mean(sqrt(((A1-B1).^2) + ((A2-B2).^2) + ((A3-B3).^2)));
end

    

