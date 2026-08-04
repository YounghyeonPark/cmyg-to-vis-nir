"""
Utilities (Auto White Balance, Brightness Correction & End-to-End Pipeline)
"""

import numpy as np
import cv2
from .demosaic import interpolate_cmyg
from .separation import convert_cmygp_to_rgbn, convert_cmyg_to_rgb
from .denoising import denoise_rgb, denoise_nir

def advanced_white_balance(rgb_img, method='grayworld', p=6):
    """
    Auto White Balance supporting percentile-constrained Gray World & Shades of Gray.
    Prevents unnatural green/color cast by clipping channel scale gains within safe bounds [0.75, 1.4].
    """
    img_float = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    awb_img = img_float.copy()
    
    if method == 'shades_of_gray':
        norm_r = (np.mean(img_float[:, :, 0] ** p)) ** (1.0 / p)
        norm_g = (np.mean(img_float[:, :, 1] ** p)) ** (1.0 / p)
        norm_b = (np.mean(img_float[:, :, 2] ** p)) ** (1.0 / p)
        
        avg_norm = (norm_r + norm_g + norm_b) / 3.0
        scale_r = np.clip(avg_norm / max(norm_r, 1e-5), 0.75, 1.4)
        scale_g = np.clip(avg_norm / max(norm_g, 1e-5), 0.75, 1.4)
        scale_b = np.clip(avg_norm / max(norm_b, 1e-5), 0.75, 1.4)
        
        awb_img[:, :, 0] *= scale_r
        awb_img[:, :, 1] *= scale_g
        awb_img[:, :, 2] *= scale_b
        
    elif method == 'whitepatch':
        # Brightest 1% percentile white patch estimation
        p_r = np.percentile(img_float[:, :, 0], 99)
        p_g = np.percentile(img_float[:, :, 1], 99)
        p_b = np.percentile(img_float[:, :, 2], 99)
        
        avg_p = (p_r + p_g + p_b) / 3.0
        if p_r > 0: awb_img[:, :, 0] *= np.clip(avg_p / p_r, 0.75, 1.4)
        if p_g > 0: awb_img[:, :, 1] *= np.clip(avg_p / p_g, 0.75, 1.4)
        if p_b > 0: awb_img[:, :, 2] *= np.clip(avg_p / p_b, 0.75, 1.4)
        
    else: # grayworld
        mean_r = np.mean(img_float[:, :, 0])
        mean_g = np.mean(img_float[:, :, 1])
        mean_b = np.mean(img_float[:, :, 2])
        
        avg_gray = (mean_r + mean_g + mean_b) / 3.0
        if mean_r > 0: awb_img[:, :, 0] *= np.clip(avg_gray / mean_r, 0.75, 1.4)
        if mean_g > 0: awb_img[:, :, 1] *= np.clip(avg_gray / mean_g, 0.75, 1.4)
        if mean_b > 0: awb_img[:, :, 2] *= np.clip(avg_gray / mean_b, 0.75, 1.4)
        
    return np.clip(awb_img, 0.0, 1.0)

def auto_white_balance(rgb_img, method='grayworld'):
    """Backward compatible wrapper for Gray World AWB"""
    return advanced_white_balance(rgb_img, method=method)

def correct_brightness_and_contrast(rgb_img, nir_img=None, gamma=0.7, lambda_nir=0.35, clip_limit=1.8):
    """
    Chromaticity-Preserving NIR-Guided Adaptive Brightness and Contrast Correction.
    Preserves RGB chromaticity ratios (R/I, G/I, B/I) to guarantee zero color cast distortion.
    """
    img_float = np.clip(rgb_img.astype(np.float64), 0.0, 1.0)
    
    # 1. Compute Intensity I = (R + G + B) / 3
    intensity = np.mean(img_float, axis=2)
    safe_intensity = np.maximum(intensity, 1e-5)
    
    # 2. Chromaticity Ratios (R/I, G/I, B/I)
    chroma_r = img_float[:, :, 0] / safe_intensity
    chroma_g = img_float[:, :, 1] / safe_intensity
    chroma_b = img_float[:, :, 2] / safe_intensity
    
    # 3. Gamma enhancement on intensity
    i_gamma = np.power(intensity, gamma)
    
    # 4. NIR-guided adaptive gain boost for under-exposed dark areas
    if nir_img is not None:
        nir_norm = np.clip(nir_img.astype(np.float64), 0.0, 1.0)
        gain_map = 1.0 + lambda_nir * np.maximum(0.0, nir_norm - intensity)
        i_boost = i_gamma * gain_map
    else:
        i_boost = i_gamma
        
    i_boost = np.clip(i_boost, 0.0, 1.0)
    
    # 5. Contrast Limited Adaptive Histogram Equalization (CLAHE)
    i_uint8 = (i_boost * 255.0).astype(np.uint8)
    clahe = cv2.createCLAHE(clipLimit=clip_limit, tileGridSize=(8, 8))
    i_clahe = clahe.apply(i_uint8).astype(np.float64) / 255.0
    
    # 6. Multiply enhanced intensity back by original chromaticity
    corrected_rgb = np.zeros_like(img_float)
    corrected_rgb[:, :, 0] = i_clahe * chroma_r
    corrected_rgb[:, :, 1] = i_clahe * chroma_g
    corrected_rgb[:, :, 2] = i_clahe * chroma_b
    
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
    
    # Step 5: Chromaticity-Preserving NIR-Guided Adaptive Brightness Correction
    if enhance_brightness:
        final_rgb = correct_brightness_and_contrast(rgb_awb, nir_img=filtered_nir)
    else:
        final_rgb = rgb_awb
        
    return np.clip(final_rgb, 0.0, 1.0), np.clip(filtered_nir, 0.0, 1.0), np.clip(mixed_rgb, 0.0, 1.0)
