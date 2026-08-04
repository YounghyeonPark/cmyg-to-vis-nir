%-------------------------------------------------------------------------%
% Title : Convert C'M'Y'G' to RGB, NIR (for 2014-2015 Samsung DMC project)
%
% Author : SKKU Digital Media Lab.
%
% Changes:
% 2015/06/06 : First commit (Younghyeon Park, neversky@skku.edu)
%
%
%-------------------------------------------------------------------------%


%CMYG-NIR to RGB, NIR conversion
close all;
clear all;
addpath('Images');
addpath(genpath('Supplements'));

%filename = 'RGB.NEF.pgm';
%filename = 'piggybank_w_IRFlash.NEF.pgm';
%filename = 'piggybank_wo_IRFlash.NEF.pgm';
%filename = 'Box_Black_NIR_only.pgm';
%filename = 'Box_White_NIR_only.pgm';
%filename = 'Box_Object_NIR_only.pgm';
%filename = 'CMYG_light+NIR.pgm';
%filename = 'CMYG_NIR_cut.pgm';
%filename = 'CMYG_NIR_only.pgm';
%filename = 'RGB_NIR_only.pgm';
%filename = 'Outside1_RGB_NIR.pgm';
%filename = 'Outside2_RGB_NIR.pgm';
%filename = 'Objects_light+NIR.pgm';
%filename = 'Objects_NIR_cut.pgm';
%filename = 'Objects2_light+NIR.pgm';
%filename = 'hand_light+NIR.pgm';
%filename = 'hand2_light+NIR.pgm';
%filename = 'orange1_light+NIR.pgm';
%filename = 'orange2_light+NIR.pgm';
% filename = 'orange3_light+NIR.pgm';
%filename = 'orange4_light+NIR.pgm';
%filename = 'plants1_light+NIR.pgm';
%filename = 'plants2_light+NIR.pgm';
%filename = 'lowlight_light+NIR.pgm';
%filename = 'badpixel_Coolpix5700.pgm';
%filename = 'natural_NIR+CMYG.pgm';
%filename = 'outside_wrist_sunlight.pgm';
%filename = 'Object3_light+NIR_wb.pgm';%
%filename = 'piggybank_lowlight_wb.pgm';
%filename = 'piggybank2_lowlight+NIR_wb.pgm';
%filename = 'Plants3_sunlight_wb.pgm';
%filename = 'Outside5_sunlight_wb.pgm';


%%filename = 'flower_lowlight+NIR.pgm';
filename = 'miniature_lowlight+NIR.pgm';
%filename = 'treename_lowlight+NIR.pgm';
%filename = 'nohohon_lowlight+NIR.pgm';
%filename = 'Things_lowlight+NIR.pgm';
%filename = 'minifan_lowlight+NIR.pgm';

%filename = 'minifan2_lowlight+NIR.pgm';
%filename = 'piggybank_lowlight+NIR_wb.pgm';
%filename = 'Things2_lowlight+NIR.pgm';

%-------%
% Option
%-------%
write_to_image_file = false;
plot_results = true;

%----------------------------------%
% Step 1 : Read bayer pattern(CMYG)
%----------------------------------%
bayer_CMYG = imread(filename);

%------------------------------%
% Step 2 : Bad pixel correction
%------------------------------%
bayer_CMYG = defective_pixel_correction(bayer_CMYG, 'coolpix5700');

%--------------------------------------------%
% Step 3 : interpolation of each CMYG channel
%--------------------------------------------%
interpolated_CMYG = interpolate_cmyg(bayer_CMYG, 'coolpix5700');

%--------------------------------------%
% Step 4 : convert C'M'Y'G' to RGB, NIR
%--------------------------------------%
fprintf('\nConvert C''M''Y''G'' to RGB, NIR\n');
tic
[converted_rgb, converted_nir] = convert_cmygp_to_rgbn(interpolated_CMYG);
toc


%--------------------------------------%
% Get RGB-NIR mixed image from C'M'Y'G'
%--------------------------------------%
fprintf('\nGet RGB-NIR mixed image from C''M''Y''G''\n');
tic
mixed_rgb = convert_cmyg_to_rgb(interpolated_CMYG);
toc


% =====================================================================================================================
% LOW LIGHT IMAGE PROCESSING
    % Initial
        filename2write = ['' filename(1:1:9)];
        plotfigureFlag = false;
        if plotfigureFlag, titlestr = [filename(1:1:6) ' bayer CMYG'];     	 figure, set(gca, 'Fontsize', 14); imshow(bayer_CMYG, []), title(titlestr);        imwrite(bayer_CMYG/max(bayer_CMYG(:)), [titlestr '.tif']);   end
        if plotfigureFlag, titlestr = [filename2write ' converted rgb'];     figure, set(gca, 'Fontsize', 14); imshow(converted_rgb), title(titlestr);         imwrite(converted_rgb, [titlestr '.tif']);      end
        if plotfigureFlag, titlestr = [filename2write ' mixed rgb'];         figure, set(gca, 'Fontsize', 14); imshow(mixed_rgb), title(titlestr);             imwrite(mixed_rgb, [titlestr '.tif']);          end
        if plotfigureFlag, titlestr = [filename2write ' nir'];               figure, set(gca, 'Fontsize', 14); imshow(converted_nir), title(titlestr);         imwrite(converted_nir, [titlestr '.tif']);      end
        
    % Brightness correction - first step
        firstbrightnesscorrectionFlag = true;
        if firstbrightnesscorrectionFlag
            converted_yuv = rgb2ycbcr(converted_rgb);     
            mixed_yuv     = rgb2ycbcr(mixed_rgb);      
            brightness = 0.2; grayfactor_mixedrgb = brightness / mean(mean(mixed_yuv(:,:,1)));          mixed_rgb_brighten     = mixed_rgb * grayfactor_mixedrgb;               grayfactor_mixedrgb
            brightness = 0.5; grayfactor_convertedrgb = brightness / mean(mean(converted_yuv(:,:,1)));  converted_rgb_brighten = converted_rgb * grayfactor_convertedrgb;       grayfactor_convertedrgb                                                                                                   % BrightnessGammacorrection(converted_rgb_clip, brightness, gamma);
        else
            mixed_rgb_brighten     = mixed_rgb;
            converted_rgb_brighten = converted_rgb;
        end
        if plotfigureFlag, titlestr = [filename2write ' brighten converted rgb'];             figure, set(gca, 'Fontsize', 14); imshow(converted_rgb_brighten), title(titlestr);   imwrite(converted_rgb_brighten, [titlestr '.tif']);      end
        if plotfigureFlag, titlestr = [filename2write ' brighten mixed rgb'];                 figure, set(gca, 'Fontsize', 14); imshow(mixed_rgb_brighten), title(titlestr);       imwrite(mixed_rgb_brighten, [titlestr '.tif']);      end
        
    % Color enhancement
        colorenhancementFlag = true; 
        if colorenhancementFlag
            % converted_rgb_brighten_filterred = BasicFilter(converted_rgb_brighten, mixed_rgb, 5, 'GuidedFitler');
            converted_rgb_brighten_filterred = converted_rgb_brighten;
            converted_rgb_brighten_filterred_colorcorrected = lowlight_region_colorcorrection(converted_rgb_brighten_filterred);
        else
            converted_rgb_brighten_filterred_colorcorrected = converted_rgb_brighten;
        end
        if plotfigureFlag, titlestr = [filename2write ' converted rgb brighten filtered color corrected'];     figure, set(gca, 'Fontsize', 14); imshow(converted_rgb_brighten_filterred_colorcorrected), title(titlestr);     imwrite(converted_rgb_brighten_filterred_colorcorrected, [titlestr '.tif']);      end
                 
    % Color correction
        converted_yuv = rgb2ycbcr(converted_rgb_brighten_filterred_colorcorrected);     
        mixed_yuv     = rgb2ycbcr(mixed_rgb_brighten);     
        
        combined_yuv        = converted_yuv;                                                                                                                                    % combined_yuv(:,:,2) = converted_yuv(:,:,2); combined_yuv(:,:,3) = converted_yuv(:,:,3);      
        combine_factor      = 1;                combined_yuv(:,:,1) = combine_factor * mixed_yuv(:,:,1) + (1-combine_factor) * converted_yuv(:,:,1);

        verylowlightFlag = false; % true false
        if verylowlightFlag
            slidingwindowsize = 0;
            filteringwindowsize = 8;
            channel_ref = mixed_rgb(:,:,1);    filterType  = 'GuidedFitler';             
            combined_yuv = imguidedfilter(combined_yuv, mixed_yuv, 'NeighborhoodSize', [filteringwindowsize filteringwindowsize], 'DegreeOfSmoothing', 1);             
        else
            filteringwindowsize_set = [25 50 75 100 125 150];
            slidingwindowsize_set   = [4 8 16];
            for slidingwindowsize_id = 1                                                                                                                                            % :1:length(slidingwindowsize_set)
                slidingwindowsize = slidingwindowsize_set(slidingwindowsize_id);
                for filteringwindowsize_id = 2                                                                                                                                      % :1:4 % length(filteringwindowsize_set)
                    filteringwindowsize = filteringwindowsize_set(filteringwindowsize_id);

                    colorfilterFlag = 1;
                    if colorfilterFlag == 1            
                        channel_ref = mixed_rgb(:,:,1);    filterType  = 'GuidedFitler';                                                                                            % GuidedFitler (best 50/4) WienerFilter (best 75/4) AvergingFilter
						if plotfigureFlag, channel_id = 2; titlestr = [filename2write ' channel ' num2str(channel_id)];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end
                        if plotfigureFlag, channel_id = 3; titlestr = [filename2write ' channel ' num2str(channel_id)];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end                       
                        channel_id = 2; combined_yuv(:,:,channel_id) = BasicFilter(combined_yuv(:,:,channel_id), channel_ref, filteringwindowsize, filterType);
                        channel_id = 3; combined_yuv(:,:,channel_id) = BasicFilter(combined_yuv(:,:,channel_id), channel_ref, filteringwindowsize, filterType);
                        if plotfigureFlag, channel_id = 2; titlestr = [filename2write ' channel ' num2str(channel_id) ' filterred'];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end
                        if plotfigureFlag, channel_id = 3; titlestr = [filename2write ' channel ' num2str(channel_id) ' filterred'];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end                       
                    end    
                    % channel_id = 2; combined_yuv(:,:,channel_id) = ChannelMatching(combined_yuv(:,:,channel_id), mixed_yuv(:,:,channel_id), slidingwindowsize, channel_id);
                    % channel_id = 3; combined_yuv(:,:,channel_id) = ChannelMatching(combined_yuv(:,:,channel_id), mixed_yuv(:,:,channel_id), slidingwindowsize, channel_id); 
                    channel_id = 2; combined_yuv(:,:,channel_id) = BasicFilter(combined_yuv(:,:,channel_id), mixed_yuv(:,:,channel_id), filteringwindowsize, filterType);
                    channel_id = 3; combined_yuv(:,:,channel_id) = BasicFilter(combined_yuv(:,:,channel_id), mixed_yuv(:,:,channel_id), filteringwindowsize, filterType);                        
                        
                    if plotfigureFlag, channel_id = 2; titlestr = [filename2write ' channel ' num2str(channel_id) ' mixed'];  figure, set(gca, 'Fontsize', 14); imshow(mixed_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(mixed_yuv(:,:,channel_id), [titlestr '.tif']);      end
                    if plotfigureFlag, channel_id = 3; titlestr = [filename2write ' channel ' num2str(channel_id) ' mixed'];  figure, set(gca, 'Fontsize', 14); imshow(mixed_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(mixed_yuv(:,:,channel_id), [titlestr '.tif']);      end
                    if plotfigureFlag, channel_id = 2; titlestr = [filename2write ' channel ' num2str(channel_id) ' filterred matching'];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end
                    if plotfigureFlag, channel_id = 3; titlestr = [filename2write ' channel ' num2str(channel_id) ' filterred matching'];  figure, set(gca, 'Fontsize', 14); imshow(combined_yuv(:,:,channel_id), [0 1]), title(titlestr);   imwrite(combined_yuv(:,:,channel_id), [titlestr '.tif']);      end                       
				end
            end
        end   
        if plotfigureFlag
            combined_rgb        = ycbcr2rgb(combined_yuv);
            combined_rgb_awb    = AWB(combined_rgb);
            titlestr = [filename2write ' combined rgb awb ' filterType ' ' num2str(filteringwindowsize) ' wWindowsize ' num2str(slidingwindowsize)];
            figure, set(gca, 'Fontsize', 14); imshow(combined_rgb_awb), title(titlestr);   imwrite(combined_rgb_awb, [titlestr '.tif']);                             
        end
        % Brightness correction - second step converted_nir
            secondbrightnesscorrectionFlag = true;
            if secondbrightnesscorrectionFlag
                combined_yuv_brighten = combined_yuv;
                
                a    = (converted_yuv(:,:,1) + 1) ./ (combined_yuv(:,:,1) + 1); lowb = 1; upb = 10; a(a<lowb) = lowb; a(a>upb) = upb;                                                 % 1. Brightness ratio is chosen as the brighter ones, either mixedRGB or brightenRGB - a>= 1
                a    = BasicFilter(a, mixed_rgb(:,:,1), 30, 'GuidedFitler');
                combined_yuv_brighten(:,:,1) = (combined_yuv(:,:,1) .* a).^(1/1.3);
            else
                c    = ones(size(combined_yuv(:,:,1)));
            end         
            combined_rgb        = ycbcr2rgb(combined_yuv_brighten);% .^(1/1.3);
            
        combined_rgb_awb    = AWB(combined_rgb);
        titlestr = [filename2write ' combined rgb awb brighten' filterType ' ' num2str(filteringwindowsize) ' wWindowsize ' num2str(slidingwindowsize)];
        figure, set(gca, 'Fontsize', 14); imshow(combined_rgb_awb), title(titlestr);  
        imwrite(combined_rgb_awb, [titlestr '.tif']);        
        close all;


% =====================================================================================================================

%{
figure, imshow(converted_yuv(:,:,1), []);
figure, imshow(converted_yuv(:,:,2), []);
figure, imshow(converted_yuv(:,:,3), []);
figure, imshow(combined_yuv(:,:,1), []);
figure, imshow(combined_yuv(:,:,2), []);
figure, imshow(combined_yuv(:,:,3), []);
figure, imshow(mixed_yuv(:,:,1), []);
figure, imshow(mixed_yuv(:,:,2), []);
figure, imshow(mixed_yuv(:,:,3), []);

converted_hsv = rgb2hsv(converted_rgb);     figure, imshow(converted_hsv), title('converted hsv');
mixed_hsv     = rgb2hsv(mixed_rgb);         figure, imshow(mixed_hsv),     title('mixed hsv');
combined_hsv = zeros(size(mixed_hsv));
factor = 10;
combined_hsv(:,:,3) = mixed_hsv(:,:,3);
combined_hsv(:,:,1) = factor*converted_hsv(:,:,1);
combined_hsv(:,:,2) = factor*converted_hsv(:,:,2);
combined_rgb = hsv2rgb(combined_hsv);
figure, imshow(combined_rgb), title('combined RGB');

%--------------------%
% Step 5 : De-noising
%--------------------%
fprintf('\nDe-noising RGB\n');
tic
denoisingMode = 'wiener'; % 'wiener';nirAdaptive
converted_rgb_filtered = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, denoisingMode);
toc

fprintf('\nDe-noising NIR\n');
tic
converted_nir_filtered = denoise_nir(converted_rgb, converted_nir, mixed_rgb, 'wiener');
toc


%-------------------------------------%
% Step 6 : Auto white balancing of RGB
%-------------------------------------%
fprintf('\nAuto white balancing of RGB\n');
tic
converted_rgb_filtered_awb = auto_white_balance(converted_rgb_filtered, 'grayworld');
mixed_rgb_awb = auto_white_balance(mixed_rgb, 'grayworld');
toc



%-------------------------%
% Step 7 : display results
%-------------------------%
plot_results = true;
if plot_results == true
    figure, imshow(converted_rgb_filtered), title('Separated RGB (Wiener filter)');
    figure, imshow(converted_nir_filtered), title('Separated NIR (Wiener filter)');
    figure, imshow(converted_rgb*10), title('Separated RGB');
    figure, imshow(converted_nir), title('Separated NIR');
    figure, imshow(mixed_rgb), title('RGB+NIR');
    figure, imshow(converted_rgb_filtered_awb), title('Separated RGB (Wiener filter, AWB)');
    figure, imshow(mixed_rgb_awb), title('RGB+NIR (AWB)');
end

%-----------------------------%
% Step 8 : Save images to file
%-----------------------------%
if write_to_image_file == true
    file_extension = '.jpg';
    str_filename_write_separated_RGB_wiener = [filename, '_separated_rgb(wiener)',file_extension];
    str_filename_write_separated_NIR_wiener = [filename, '_separated_nir(wiener)',file_extension];
    str_filename_write_separated_RGB = [filename, '_separated_rgb',file_extension];
    str_filename_write_separated_NIR = [filename, '_separated_nir',file_extension];
    str_filename_write_RGB_NIR = [filename, '_rgb+nir',file_extension];
    str_filename_write_separated_RGB_wiener_awb = [filename, '_separated_rgb(wiener,awb)', file_extension];
    str_filename_write_RGB_NIR_awb = [filename, '_rgb+nir(awb)',file_extension];

    imwrite(converted_rgb_filtered, str_filename_write_separated_RGB_wiener);
    imwrite(converted_nir_filtered, str_filename_write_separated_NIR_wiener);
    imwrite(converted_rgb, str_filename_write_separated_RGB);
    imwrite(converted_nir, str_filename_write_separated_NIR);
    imwrite(mixed_rgb, str_filename_write_RGB_NIR);
    imwrite(mixed_rgb_awb, str_filename_write_RGB_NIR_awb);
    imwrite(converted_rgb_filtered_awb, str_filename_write_separated_RGB_wiener_awb);
end
%}
