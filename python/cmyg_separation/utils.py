"""
Utilities (Auto White Balance, Brightness Correction & End-to-End Pipeline)
"""

import numpy as np
import cv2
from .demosaic import interpolate_cmyg
from .separation import convert_cmygp_to_rgbn, convert_cmyg_to_rgb
from .denoising import denoise_rgb, denoise_nir

def advanced_white_balance(rgb_img, method='shades_of_gray', p=6):
    """
    Advanced Auto White Balance Supporting:
      - 'shades_of_gray': Minkowski p-norm based white balance (default p=6)
      - 'whitepatch': Max-RGB color constancy algorithm
      - 'grayworld': Standard Gray-World algorithm
    """
    img_float = rgb_img.astype(np.float64)
    awb_img = img_float.copy()
    
    if method == 'shades_of_gray':
        # Minkowski p-norm illumination estimation
        norm_r = (np.mean(img_float[:, :, 0] ** p)) ** (1.0 / p)
        norm_g = (np.mean(img_float[:, :, 1] ** p)) ** (1.0 / p)
        norm_b = (np.mean(img_float[:, :, 2] ** p)) ** (1.0 / p)
        
        avg_norm = (norm_r + norm_g + norm_b) / 3.0
        if norm_r > 0: awb_img[:, :, 0] *= (avg_norm / norm_r)
        if norm_g > 0: awb_img[:, :, 1] *= (avg_norm / norm_g)
        if norm_b > 0: awb_img[:, :, 2] *= (avg_norm / norm_b)
        
    elif method == 'whitepatch':
        max_r = np.max(img_float[:, :, 0])
        max_g = np.max(img_float[:, :, 1])
        max_b = np.max(img_float[:, :, 2])
        
        target_max = (max_r + max_g + max_b) / 3.0
        if max_r > 0: awb_img[:, :, 0] *= (target_max / max_r)
        if max_g > 0: awb_img[:, :, 1] *= (target_max / max_g)
        if max_b > 0: awb_img[:, :, 2] *= (target_max / max_b)
        
    elif method == 'grayworld':
        mean_r = np.mean(img_float[:, :, 0])
        mean_g = np.mean(img_float[:, :, 1])
        mean_b = np.mean(img_float[:, :, 2])
        
        avg_gray = (mean_r + mean_g + mean_b) / 3.0
        if mean_r > 0: awb_img[:, :, 0] *= (avg_gray / mean_r)
        if mean_g > 0: awb_img[:, :, 1] *= (avg_gray / mean_g)
        if mean_b > 0: awb_img[:, :, 2] *= (avg_gray / mean_b)
        
    return np.clip(awb_img, 0.0, 1.0)

def auto_white_balance(rgb_img, method='grayworld'):
    """Backward compatible wrapper for Gray World AWB"""
    return advanced_white_balance(rgb_img, method=method)

def correct_brightness_and_contrast(rgb_img, nir_img=None, gamma=0.8, lambda_nir=0.4, clip_limit=2.0):
    """
    NIR-Guided Adaptive Brightness and Contrast Correction.
    
    Args:
        rgb_img: Visible RGB image (float64 [0, 1])
        nir_img: Corresponding NIR image (float64 [0, 1]) for luminance guidance
        gamma: Gamma correction factor for base luminance
        lambda_nir: Gain weight for NIR-guided dark region enhancement
        clip_limit: CLAHE clip limit parameter for contrast enhancement
        
    Returns:
        corrected_rgb: Brightness & contrast corrected RGB image (float64 [0, 1])
    """
    rgb_uint8 = (np.clip(rgb_img, 0.0, 1.0) * 255.0).astype(np.uint8)
    hsv = cv2.cvtColor(rgb_uint8, cv2.COLOR_RGB2HSV).astype(np.float64) / 255.0
    v = hsv[:, :, 2]
    
    # 1. Gamma correction on luminance V
    v_gamma = np.power(v, gamma)
    
    # 2. Adaptive NIR-guided gain boost for under-exposed regions
    if nir_img is not None:
        nir_norm = np.clip(nir_img, 0.0, 1.0)
        gain_map = 1.0 + lambda_nir * np.maximum(0.0, nir_norm - v)
        v_boost = v_gamma * gain_map
    else:
        v_boost = v_gamma
        
    v_boost = np.clip(v_boost, 0.0, 1.0)
    
    # 3. CLAHE Contrast enhancement
    v_uint8 = (v_boost * 255.0).astype(np.uint8)
    clahe = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=(8, 8))
    v_clahe = clahe.apply(v_uint8).astype(np.float64) / 255.0
    
    # 4. Reconstruct HSV and convert back to RGB
    hsv[:, :, 2] = v_clahe
    hsv_uint8 = (hsv * 255.0).astype(np.uint8)
    corrected_rgb = cv2.cvtColor(hsv_uint8, cv2.COLOR_HSV2RGB).astype(np.float64) / 255.0
    
    return np.clip(corrected_rgb, 0.0, 1.0)

def process_cmyg_image(bayer_raw, max_val=4095.0, denoise_method='guided', awb_method='shades_of_gray', enhance_brightness=True):
    """
    End-to-End CMYG Image Processing Pipeline with Brightness & White Balance Correction
    
    Returns:
      separated_rgb: Denoised, White Balanced & Brightness Corrected RGB image (float64 [0,1])
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
    
    # Step 4: Advanced Auto White Balance
    rgb_awb = advanced_white_balance(filtered_rgb, method=awb_method)
    
    # Step 5: NIR-Guided Adaptive Brightness Correction
    if enhance_brightness:
        final_rgb = correct_brightness_and_contrast(rgb_awb, nir_img=filtered_nir)
    else:
        final_rgb = rgb_awb
        
    return np.clip(final_rgb, 0.0, 1.0), np.clip(filtered_nir, 0.0, 1.0), np.clip(mixed_rgb, 0.0, 1.0)
