"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair"
"""

import numpy as np
import cv2
from .denoising import guided_filter

def enhance_lowlight_image(rgb_img, nir_img, alpha=0.5, gamma=0.45, eps=0.04):
    """
    Artifact-Free NIR-Assisted Low-Light Visible RGB Enhancement.
    Operates in pure floating-point color space with smooth scale ratioing to prevent noise specks.
    
    Args:
        rgb_img: Low-light visible RGB image (float64 [0, 1])
        nir_img: High-SNR NIR image (float64 [0, 1])
        alpha: Weight for NIR luminance fusion [0.3 - 0.7]
        gamma: Gamma correction factor for low-light visible luminance
        eps: Epsilon parameter to prevent zero-division & dark noise specks
    
    Returns:
        enhanced_rgb: Smooth, high-contrast, detail-enhanced RGB image (float64 [0, 1])
    """
    rgb = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    nir = np.clip(nir_img.astype(np.float64), 0.0, 1.0)
    
    # 1. Calculate Visible Luminance (Rec. 601 / Rec. 709 weights)
    v_vis = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
    
    # 2. Stretch low-light visible luminance using 99th percentile normalization
    p99 = np.percentile(v_vis, 99)
    if p99 > 0:
        v_norm = np.clip(v_vis / p99, 0.0, 1.0)
    else:
        v_norm = v_vis
        
    v_gamma = np.power(v_norm, gamma)
    
    # 3. High-frequency NIR Detail extraction using Guided Filter
    nir_base = guided_filter(v_vis, nir, radius=8, eps=1e-3)
    nir_detail = nir - nir_base
    
    # 4. Target Luminance Fusion (Combine Gamma-boosted Visible + High-SNR NIR Base & Detail)
    v_target = (1.0 - alpha) * v_gamma + alpha * nir + 0.5 * nir_detail
    v_target = np.clip(v_target, 0.0, 1.0)
    
    # 5. Smooth Chromaticity Scale Ratio (eps prevents dark noise specks & color clipping)
    scale = (v_target + eps) / (v_vis + eps)
    
    # 6. Apply Scale Ratio to RGB channels
    enhanced = np.zeros_like(rgb)
    for c in range(3):
        enhanced[:, :, c] = np.clip(rgb[:, :, c] * scale, 0.0, 1.0)
        
    return enhanced
