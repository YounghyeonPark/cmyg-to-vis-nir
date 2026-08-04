function psnr_val = PSNR(origImg, distImg)
% Calculates Peak Signal-to-Noise Ratio (PSNR)
    origImg = double(origImg);
    distImg = double(distImg);
    
    mse = mean((origImg(:) - distImg(:)).^2);
    if mse == 0
        psnr_val = 99.99;
    else
        max_pixel = 255.0;
        psnr_val = 10 * log10((max_pixel^2) / mse);
    end
end
