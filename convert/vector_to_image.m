function [ output_img ] = vector_to_image( input_vec, height, width )
%VECTOR_TO_IMAGE 이 함수의 요약 설명 위치
%   자세한 설명 위치

    channels = size(input_vec,1);
    
    output_img = zeros(height, width, channels);
    
    for i = 1:channels
       output_img(:,:,i) =  reshape(input_vec(i, :), height, width);
    end
end

