"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair" (SKKU Digital Media Lab)
"""

import numpy as np
import cv2
from .denoising import guided_filter
from .separation import convert_cmyg_to_rgb
from .utils import advanced_white_balance

def lowlight_region_colorcorrection(img_rgb, blk_size=4, top_ratio=0.1, threshold=0.5):
    """
    MATLAB 1:1 Port (`lowlight_region_colorcorrection.m`):
    Block-wise top 10% chromaticity mean extraction for low-light regions.
    Extracts the mean of top 10% highest intensity pixels in 4x4 neighborhoods to preserve
    valid chromaticity in dark regions avoiding zero-clipping destruction.
    """
    h, w, c = img_rgb.shape
    pad_h = (blk_size - h % blk_size) % blk_size
    pad_w = (blk_size - w % blk_size) % blk_size
    
    padded = np.pad(img_rgb, ((0, pad_h), (0, pad_w), (0, 0)), mode='reflect')
    ph, pw, _ = padded.shape
    
    keep_count = max(1, int(round(top_ratio * blk_size * blk_size)))
    img_out = np.zeros_like(padded)
    count_map = np.zeros((ph, pw, 1), dtype=np.float64)
    
    shifts = [(0, 0), (1, 1), (2, 2), (3, 3)]
    for sy, sx in shifts:
        sub = padded[sy:ph - (ph - sy) % blk_size, sx:pw - (pw - sx) % blk_size, :]
        sh, sw, _ = sub.shape
        if sh == 0 or sw == 0:
            continue
            
        blocks = sub.reshape(sh // blk_size, blk_size, sw // blk_size, blk_size, c)
        blocks = blocks.transpose(1, 3, 0, 2, 4).reshape(blk_size * blk_size, -1, c)
        
        means = np.mean(blocks, axis=0)
        sorted_blocks = np.sort(blocks, axis=0)[::-1, :, :]
        top_means = np.mean(sorted_blocks[:keep_count, :, :], axis=0)
        
        res = np.where(means > threshold, means, top_means)
        
        res_blocks = np.tile(res[None, :, :], (blk_size * blk_size, 1, 1))
        res_img = res_blocks.reshape(blk_size, blk_size, sh // blk_size, sw // blk_size, c).transpose(2, 0, 3, 1, 4).reshape(sh, sw, c)
        
        img_out[sy:sy + sh, sx:sx + sw, :] += res_img
        count_map[sy:sy + sh, sx:sx + sw, :] += 1.0
        
    img_out /= np.maximum(count_map, 1.0)
    return np.clip(img_out[:h, :w, :], 0.0, 1.0)


def enhance_lowlight_image(rgb_img, nir_img, mixed_rgb=None, alpha=0.5, sat_boost=2.5, target_brightness=0.28, max_gain=4.0, use_top10_colorcorrection=True):
    """
    Splotch-Free Joint Bilateral & Guided Chrominance Low-Light Image Enhancement.
    
    Args:
        rgb_img: Separated visible RGB image (float64 [0, 1])
        nir_img: Separated NIR image (float64 [0, 1])
        mixed_rgb: CMYG raw mixed reference image (float64 [0, 1])
        alpha: Luminance fusion weight
        sat_boost: Chrominance saturation boost multiplier (default: 2.5)
        target_brightness: Target mean luminance level (default: 0.28)
        max_gain: Maximum luminance boost gain cap (default: 4.0)
        use_top10_colorcorrection: Apply block-wise top 10% chromaticity extraction
        
    Returns:
        enhanced_rgb: High-contrast, splotch-free, vividly color-enhanced low-light RGB image (float64 [0, 1])
    """
    sep_rgb = rgb_img.astype(np.float64)
    
    if mixed_rgb is None:
        mixed_rgb = sep_rgb
    else:
        mixed_rgb = np.clip(mixed_rgb.astype(np.float64), 0.0, 1.0)
        
    # 1. 64-bit Floating-Point Chromaticity Normalization BEFORE 8-bit clipping
    rgb_pos = np.maximum(sep_rgb, 0.0)
    sum_rgb = np.maximum(np.sum(rgb_pos, axis=2, keepdims=True), 1e-6)
    float_chroma_rgb = rgb_pos / sum_rgb
    
    # 2. Block-wise Top 10% Chromaticity Extraction in Dark Neighborhoods
    if use_top10_colorcorrection:
        float_chroma_corr = lowlight_region_colorcorrection(float_chroma_rgb)
    else:
        float_chroma_corr = float_chroma_rgb
        
    # 3. Pre-Auto White Balance
    sep_rgb_awb = advanced_white_balance(float_chroma_corr, method='shades_of_gray')
    mixed_rgb_awb = advanced_white_balance(mixed_rgb, method='shades_of_gray')
    
    # 4. YCrCb Conversion
    c_yuv = cv2.cvtColor((sep_rgb_awb * 255.0).astype(np.uint8), cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    m_yuv = cv2.cvtColor((mixed_rgb_awb * 255.0).astype(np.uint8), cv2.COLOR_RGB2YCrCb).astype(np.float64) / 255.0
    
    # 5. Soft-Knee Non-Saturating Luma Compression (Reinhard Tone-Mapping)
    raw_y = m_yuv[:, :, 0]
    mean_my = np.mean(raw_y)
    if mean_my > 0 and mean_my < target_brightness:
        grayfactor = min(target_brightness / max(mean_my, 1e-4), max_gain)
        y_boosted = raw_y * grayfactor
        mixed_y = y_boosted / (1.0 + y_boosted / 2.5)
        mixed_y = np.power(mixed_y, 0.85)
    else:
        mixed_y = raw_y
        
    mixed_y = np.clip(mixed_y, 0.0, 0.95)
    
    # 6. Splotch-Free Bilateral + Guided Denoising on Chrominance Channels (Cr, Cb)
    cr_raw = c_yuv[:, :, 1]
    cb_raw = c_yuv[:, :, 2]
    
    cr_u8 = (cr_raw * 255.0).astype(np.uint8)
    cb_u8 = (cb_raw * 255.0).astype(np.uint8)
    
    # Bilateral spatial smoothing to eliminate splotch blobs
    cr_bilat = cv2.bilateralFilter(cr_u8, 15, 45, 15).astype(np.float64) / 255.0
    cb_bilat = cv2.bilateralFilter(cb_u8, 15, 45, 15).astype(np.float64) / 255.0
    
    # Structural Guided Filter
    guide = mixed_rgb[:, :, 0]
    cr_clean = guided_filter(guide, cr_bilat, radius=25, eps=2e-2)
    cb_clean = guided_filter(guide, cb_bilat, radius=25, eps=2e-2)
    
    # 7. SNR-Adaptive Luminance-Weighted Saturation Boosting
    luma_weight = np.clip((mixed_y - 0.02) / 0.15, 0.0, 1.0)
    adaptive_sat = 1.0 + (sat_boost - 1.0) * luma_weight
    
    cr_boosted = np.clip(0.5 + (cr_clean - 0.5) * adaptive_sat, 0.0, 1.0)
    cb_boosted = np.clip(0.5 + (cb_clean - 0.5) * adaptive_sat, 0.0, 1.0)
    
    # 8. Reconstruct YCrCb -> RGB
    comb_yuv = np.zeros_like(m_yuv)
    comb_yuv[:, :, 0] = mixed_y
    comb_yuv[:, :, 1] = cr_boosted
    comb_yuv[:, :, 2] = cb_boosted
    
    comb_rgb = cv2.cvtColor((comb_yuv * 255.0).astype(np.uint8), cv2.COLOR_YCrCb2RGB).astype(np.float64) / 255.0
    
    # 9. HSV Saturation Boost with Bilateral Smoothing
    hsv = cv2.cvtColor((comb_rgb * 255.0).astype(np.uint8), cv2.COLOR_RGB2HSV).astype(np.float64) / 255.0
    sat_channel = cv2.bilateralFilter((hsv[:, :, 1] * 255.0).astype(np.uint8), 9, 50, 9).astype(np.float64) / 255.0
    hsv[:, :, 1] = np.clip(sat_channel * (1.0 + 0.45 * luma_weight), 0.0, 1.0)
    
    comb_vibrant = cv2.cvtColor((hsv * 255.0).astype(np.uint8), cv2.COLOR_HSV2RGB).astype(np.float64) / 255.0
    
    # 10. Final Auto White Balance
    final_rgb = advanced_white_balance(comb_vibrant, method='shades_of_gray')
    return np.clip(final_rgb, 0.0, 1.0)
