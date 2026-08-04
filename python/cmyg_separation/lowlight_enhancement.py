"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair"
"""

import numpy as np
import cv2
from .denoising import guided_filter

def enhance_lowlight_image(rgb_img, nir_img, alpha=0.4, beta=0.6, gamma=0.7):
    """
    Enhance a low-light visible RGB image using high-SNR NIR detail & luminance guidance.
    Uses HSV color space luminance fusion for smooth, artifact-free low-light enhancement.
    
    Args:
        rgb_img: Low-light visible RGB image (float64 [0, 1])
        nir_img: Corresponding NIR image (float64 [0, 1])
        alpha: Base visible intensity weight
        beta: NIR luminance boost weight
        gamma: Dark region gamma factor
    
    Returns:
        enhanced_rgb: High-contrast, detail-enhanced RGB image (float64 [0, 1])
    """
    rgb_float = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    nir_float = np.clip(nir_img.astype(np.float64), 0.0, 1.0)
    
    # 1. Base intensity and guided NIR detail extraction
    intensity = np.mean(rgb_float, axis=2)
    nir_base = guided_filter(intensity, nir_float, radius=8, eps=1e-3)
    nir_detail = nir_float - nir_base
    
    # 2. Enhanced Luminance V
    v_fused = np.power(intensity, gamma) + beta * nir_base + 0.5 * nir_detail
    v_fused = np.clip(v_fused, 0.0, 1.0)
    
    # 3. CLAHE Contrast Equalization
    v_uint8 = (v_fused * 255.0).astype(np.uint8)
    clahe = cv2.createCLAHE(clipLimit=1.8, tileGridSize=(8, 8))
    v_clahe = clahe.apply(v_uint8).astype(np.float64) / 255.0
    
    # 4. Color space HSV reconstruction
    rgb_uint8 = (rgb_float * 255.0).astype(np.uint8)
    hsv = cv2.cvtColor(rgb_uint8, cv2.COLOR_RGB2HSV).astype(np.float64) / 255.0
    
    # Preserve original saturation S and hue H, boost V
    hsv[:, :, 2] = v_clahe
    hsv[:, :, 1] = np.clip(hsv[:, :, 1] * 1.2, 0.0, 1.0) # Subtle saturation boost
    
    enhanced_rgb = cv2.cvtColor((hsv * 255.0).astype(np.uint8), cv2.COLOR_HSV2RGB).astype(np.float64) / 255.0
    return np.clip(enhanced_rgb, 0.0, 1.0)
