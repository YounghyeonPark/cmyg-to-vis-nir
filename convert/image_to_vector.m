function [ output_vec ] = image_to_vector( input_img )
%IMAGE_TO_VECTOR 이 함수의 요약 설명 위치
%   자세한 설명 위치
    channels = size(input_img,3);
    height = size(input_img,1);
    width = size(input_img,2);
    output_vec = zeros(channels, height * width);
    
    for i = 1:channels
       output_vec(i,:) =  reshape(input_img(:,:,i), 1, []);
    end
    
end

