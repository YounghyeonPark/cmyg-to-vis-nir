"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair"
"""

import numpy as np
import cv2
from .denoising import guided_filter

def enhance_lowlight_image(rgb_img, nir_img, alpha=0.4, beta=0.6):
    """
    Enhance a low-light visible RGB image using the detail and luminance from a NIR image.
    
    Args:
        rgb_img: Low-light visible RGB image (float64 [0, 1])
        nir_img: Corresponding NIR image (float64 [0, 1])
        alpha: Weight for RGB luminance base
        beta: Weight for NIR detail boost
    
    Returns:
        enhanced_rgb: High-contrast, detail-enhanced RGB image (float64 [0, 1])
    """
    # 1. Convert RGB to YUV/HSV color space
    hsv = cv2.cvtColor((rgb_img * 255).astype(np.uint8), cv2.COLOR_RGB2HSV).astype(np.float64) / 255.0
    v_channel = hsv[:, :, 2]
    
    # 2. Extract high-frequency detail layer from NIR using Guided Filter
    nir_base = guided_filter(v_channel, nir_img, radius=8, eps=1e-3)
    nir_detail = nir_img - nir_base
    
    # 3. Enhance luminance V channel using NIR base & detail layer
    v_enhanced = alpha * v_channel + beta * nir_base + 1.2 * nir_detail
    v_enhanced = np.clip(v_enhanced, 0.0, 1.0)
    
    # 4. Reconstruct HSV and convert back to RGB
    hsv[:, :, 2] = v_enhanced
    hsv_uint8 = (hsv * 255).astype(np.uint8)
    enhanced_rgb = cv2.cvtColor(hsv_uint8, cv2.COLOR_HSV2RGB).astype(np.float64) / 255.0
    
    return enhanced_rgb
