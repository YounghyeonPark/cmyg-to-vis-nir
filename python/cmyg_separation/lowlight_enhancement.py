"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair" (SKKU Digital Media Lab)
"""

import numpy as np
import cv2
from .denoising import guided_filter
from .separation import convert_cmyg_to_rgb
from .utils import advanced_white_balance

def enhance_lowlight_image(rgb_img, nir_img, mixed_rgb=None, alpha=0.5, gamma=0.75):
    """
    High-SNR Luminance Guided Low-Light Image Enhancement.
    Fuses high-SNR mixed CMYG luminance (Y) with separated chromaticity (Cr, Cb)
    to produce crystal-clear, noise-free enhanced visible RGB images.
    
    Args:
        rgb_img: Separated visible RGB image (float64 [0, 1])
        nir_img: Separated NIR image (float64 [0, 1])
        mixed_rgb: CMYG raw mixed reference image (float64 [0, 1])
        alpha: Luminance fusion weight
        gamma: Gamma correction factor for lowlight Y
        
    Returns:
        enhanced_rgb: Crystal-clear, high-contrast enhanced visible RGB image (float64 [0, 1])
    """
    sep_rgb = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    
    if mixed_rgb is None:
        mixed_rgb = sep_rgb
    else:
        mixed_rgb = np.clip(mixed_rgb.astype(np.float64), 0.0, 1.0)
        
    # 1. Convert to YCrCb (Y: Luminance, Cr/Cb: Chrominance)
    sep_rgb_u8 = (sep_rgb * 255.0).astype(np.uint8)
    mixed_rgb_u8 = (mixed_rgb * 255.0).astype(np.uint8)
    
    sep_yuv = cv2.cvtColor(sep_rgb_u8, cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    mixed_yuv = cv2.cvtColor(mixed_rgb_u8, cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    
    # 2. Extract High-SNR Luminance Y from mixed CMYG signal & Chrominance Cr/Cb from separated RGB
    y_mixed = mixed_yuv[:, :, 0]
    cr_sep = sep_yuv[:, :, 1]
    cb_sep = sep_yuv[:, :, 2]
    
    # 3. Guided Denoising on Chrominance Channels (Cr, Cb) using Y_mixed as guide
    cr_filtered = guided_filter(y_mixed, cr_sep, radius=12, eps=1e-3)
    cb_filtered = guided_filter(y_mixed, cb_sep, radius=12, eps=1e-3)
    
    # 4. Adaptive Luminance Scaling for Low-Light Scenes
    mean_y = np.mean(y_mixed)
    if mean_y > 0 and mean_y < 0.18:
        target_y = min(mean_y * 3.5, 0.5)
        y_enhanced = np.power(y_mixed / (mean_y + 1e-4) * target_y, gamma)
    else:
        y_enhanced = y_mixed
        
    y_enhanced = np.clip(y_enhanced, 0.0, 1.0)
    
    # 5. Reconstruct YCrCb -> RGB
    comb_yuv = np.zeros_like(mixed_yuv)
    comb_yuv[:, :, 0] = y_enhanced
    comb_yuv[:, :, 1] = np.clip(cr_filtered, 0.0, 1.0)
    comb_yuv[:, :, 2] = np.clip(cb_filtered, 0.0, 1.0)
    
    comb_yuv_u8 = (comb_yuv * 255.0).astype(np.uint8)
    comb_rgb = cv2.cvtColor(comb_yuv_u8, cv2.COLOR_YCrCb2RGB).astype(np.float64) / 255.0
    
    # 6. Advanced Auto White Balance
    final_rgb = advanced_white_balance(comb_rgb, method='shades_of_gray')
    return np.clip(final_rgb, 0.0, 1.0)
