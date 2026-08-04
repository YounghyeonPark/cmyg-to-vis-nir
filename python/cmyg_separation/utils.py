"""
Utilities (Auto White Balance & End-to-End Pipeline)
"""

import numpy as np
from .demosaic import interpolate_cmyg
from .separation import convert_cmygp_to_rgbn, convert_cmyg_to_rgb
from .denoising import denoise_rgb, denoise_nir

def auto_white_balance(rgb_img, method='grayworld'):
    """Auto White Balance using Gray World algorithm"""
    awb_img = rgb_img.copy()
    if method == 'grayworld':
        mean_r = np.mean(awb_img[:, :, 0])
        mean_g = np.mean(awb_img[:, :, 1])
        mean_b = np.mean(awb_img[:, :, 2])
        
        avg_gray = (mean_r + mean_g + mean_b) / 3.0
        if mean_r > 0: awb_img[:, :, 0] *= (avg_gray / mean_r)
        if mean_g > 0: awb_img[:, :, 1] *= (avg_gray / mean_g)
        if mean_b > 0: awb_img[:, :, 2] *= (avg_gray / mean_b)
        
    return np.clip(awb_img, 0.0, 1.0)

def process_cmyg_image(bayer_raw, max_val=4095.0, denoise_method='guided'):
    """
    End-to-End CMYG Image Processing Pipeline
    Returns:
      separated_rgb: Denoised & White balanced RGB image (float64 [0,1])
      separated_nir: Denoised NIR image (float64 [0,1])
      mixed_rgb: Raw RGB+NIR mixed reference image
    """
    # Step 1: Demosaicing
    interpolated_cmyg = interpolate_cmyg(bayer_raw, max_val=max_val)
    
    # Step 2: Signal Separation
    converted_rgb, converted_nir = convert_cmygp_to_rgbn(interpolated_cmyg)
    mixed_rgb = convert_cmyg_to_rgb(interpolated_cmyg)
    
    # Step 3: Denoising
    filtered_rgb = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, interpolated_cmyg, method=denoise_method)
    filtered_nir = denoise_nir(converted_rgb, converted_nir, mixed_rgb, interpolated_cmyg, method=denoise_method)
    
    # Step 4: Auto White Balance
    rgb_awb = auto_white_balance(filtered_rgb, method='grayworld')
    
    return np.clip(rgb_awb, 0.0, 1.0), np.clip(filtered_nir, 0.0, 1.0), np.clip(mixed_rgb, 0.0, 1.0)
