"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair" (SKKU Digital Media Lab)
"""

import numpy as np
import cv2
from .denoising import guided_filter
from .separation import convert_cmyg_to_rgb
from .utils import advanced_white_balance

def enhance_lowlight_image(rgb_img, nir_img, mixed_rgb=None, alpha=0.5, sat_boost=1.75):
    """
    High-SNR YCrCb Luminance Fusion & Guided Chrominance Low-Light Image Enhancement.
    Fuses high-SNR mixed CMYG luminance (Y) with pre-white balanced chrominance (Cr, Cb)
    to produce clean, high-contrast, naturally color-enhanced low-light visible RGB images.
    
    Args:
        rgb_img: Separated visible RGB image (float64 [0, 1])
        nir_img: Separated NIR image (float64 [0, 1])
        mixed_rgb: CMYG raw mixed reference image (float64 [0, 1])
        alpha: Luminance fusion weight
        sat_boost: Chrominance saturation boost multiplier
        
    Returns:
        enhanced_rgb: High-contrast, naturally color-enhanced visible RGB image (float64 [0, 1])
    """
    sep_rgb = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    
    if mixed_rgb is None:
        mixed_rgb = sep_rgb
    else:
        mixed_rgb = np.clip(mixed_rgb.astype(np.float64), 0.0, 1.0)
        
    # 1. Pre-Auto White Balance to eliminate sensor color cast
    sep_rgb_awb = advanced_white_balance(sep_rgb, method='shades_of_gray')
    mixed_rgb_awb = advanced_white_balance(mixed_rgb, method='shades_of_gray')
    
    # 2. YCrCb Conversion
    c_yuv = cv2.cvtColor((sep_rgb_awb * 255.0).astype(np.uint8), cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    m_yuv = cv2.cvtColor((mixed_rgb_awb * 255.0).astype(np.uint8), cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    
    # 3. High-SNR Luminance Adaptive Scaling
    mean_my = np.mean(m_yuv[:, :, 0])
    if mean_my > 0 and mean_my < 0.2:
        grayfactor = min(0.38 / max(mean_my, 1e-4), 4.5)
        mixed_y = np.power(np.clip(m_yuv[:, :, 0] * grayfactor, 0.0, 1.0), 0.78)
    else:
        mixed_y = m_yuv[:, :, 0]
        
    # 4. Guided Filtering on Chrominance Channels (Cr, Cb) using mixed_rgb R channel
    guide = mixed_rgb[:, :, 0]
    cr_clean = guided_filter(guide, c_yuv[:, :, 1], radius=20, eps=1e-2)
    cb_clean = guided_filter(guide, c_yuv[:, :, 2], radius=20, eps=1e-2)
    
    # 5. Chrominance Saturation Boost
    cr_boosted = np.clip(0.5 + (cr_clean - 0.5) * sat_boost, 0.0, 1.0)
    cb_boosted = np.clip(0.5 + (cb_clean - 0.5) * sat_boost, 0.0, 1.0)
    
    # 6. Reconstruct YCrCb -> RGB
    comb_yuv = np.zeros_like(m_yuv)
    comb_yuv[:, :, 0] = np.clip(mixed_y, 0.0, 1.0)
    comb_yuv[:, :, 1] = cr_boosted
    comb_yuv[:, :, 2] = cb_boosted
    
    comb_rgb = cv2.cvtColor((comb_yuv * 255.0).astype(np.uint8), cv2.COLOR_YCrCb2RGB).astype(np.float64) / 255.0
    
    # 7. Final Auto White Balance
    final_rgb = advanced_white_balance(comb_rgb, method='shades_of_gray')
    return np.clip(final_rgb, 0.0, 1.0)
