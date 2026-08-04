function x_filtered = BasicFilter(x, img_guiding, fsize, filType)
	hsize = [fsize fsize];
	switch filType
		case 'AvergingFilter'			
			h = fspecial('average', hsize);
			x_filtered = imfilter(x, h);
		case 'WienerFilter'
			x_filtered = wiener2(x, hsize);
        case 'GuidedFitler'
            x_filtered = imguidedfilter(x, img_guiding, 'NeighborhoodSize', hsize);
	end
end


% Input Arguments
% collapse all
% A — Image to be filtered
% binary image | grayscale image | RGB image
% Image to be filtered, specified as a nonsparse, binary, grayscale, or RGB image.
% 
% Data Types: single | double | int8 | int16 | int32 | uint8 | uint16 | uint32 | logical
% 
% G — Image to use as a guide during filtering
% binary image | grayscale image | RGB image
% Image to use as a guide during filtering, specified as a nonsparse, binary, grayscale, or RGB image.
% 
% Data Types: single | double | int8 | int16 | int32 | uint8 | uint16 | uint32 | logical
% 
% Name-Value Pair Arguments
% Specify optional comma-separated pairs of Name,Value arguments. Name is the argument name and Value is the corresponding value. Name must appear inside single quotes (' '). You can specify several name and value pair arguments in any order as Name1,Value1,...,NameN,ValueN.
% 
% Example: Ismooth = imguidedfilter(A,'NeighborhoodSize',[4 4]);
% 'NeighborhoodSize' — Size of the rectangular neighborhood around each pixel used in guided filtering
% [5 5] (default) | scalar or two-element vector of positive integers
% Size of the rectangular neighborhood around each pixel used in guided filtering, specified as a scalar or a two-element vector, [M N], of positive integers. If you specify a scalar value, such as Q, the neighborhood is a square of size [Q Q].
% 
% Example: Ismooth = imguidedfilter(A,'NeighborhoodSize',[4 4]);
% 
% Data Types: single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64
% 
% 'DegreeOfSmoothing' — Amount of smoothing in the output image
% 0.01*diff(getrangefromclass(G)).^2 (default) | positive scalar
% Amount of smoothing in the output image, specified as a positive scalar. If you specify a small value, only neighborhoods with small variance (uniform areas) will get smoothed and neighborhoods with larger variance (such as around edges) will not be smoothed. If you specify a larger value, high variance neighborhoods, such as stronger edges, will get smoothed in addition to the relatively uniform neighborhoods. Start with the default value, check the results, and adjust the default up or down to achieve the effect you desire.
% 
% Data Types: single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64