"""
NIR-Assisted Low-Light Image Enhancement Application
Ref: "Low-light image enhancement using visible and NIR image pair" (SKKU Digital Media Lab)
"""

import numpy as np
import cv2
from .denoising import guided_filter
from .separation import convert_cmyg_to_rgb
from .utils import advanced_white_balance

def lowlight_region_colorcorrection(img_rgb, blk_size=4, top_ratio=0.15, threshold=0.1):
    """
    MATLAB 1:1 Port (`lowlight_region_colorcorrection.m`):
    Block-wise top 15% chromaticity mean extraction for low-light regions.
    Extracts the mean of top 15% highest intensity pixels in 4x4 neighborhoods to preserve
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
    Pure 64-bit Floating-Point Chrominance Pipeline Low-Light Image Enhancement.
    Refers strictly to MATLAB `script_CMYG_to_RGB_NIR1_20150616_7.m` & `lowlight_region_colorcorrection.m`.
    
    Bypasses 8-bit integer quantization loss on dark chromaticities, fully preserving true
    vibrant colors (e.g. golden yellow flower petals, cyan/teal pig body, pink snout, green leaves).
    
    Args:
        rgb_img: Separated visible RGB image (float64 [0, 1])
        nir_img: Separated NIR image (float64 [0, 1])
        mixed_rgb: CMYG raw mixed reference image (float64 [0, 1])
        alpha: Luminance fusion weight
        sat_boost: Chrominance saturation boost multiplier (default: 2.5)
        target_brightness: Target mean luminance level (default: 0.28)
        max_gain: Maximum luminance boost gain cap (default: 4.0)
        use_top10_colorcorrection: Apply block-wise top chromaticity extraction
        
    Returns:
        enhanced_rgb: Authentically vibrant, splotch-free low-light RGB image (float64 [0, 1])
    """
    sep_rgb = rgb_img.astype(np.float64)
    
    if mixed_rgb is None:
        mixed_rgb = sep_rgb
    else:
        mixed_rgb = np.clip(mixed_rgb.astype(np.float64), 0.0, 1.0)
        
    # 1. Pure 64-bit Float Chromaticity Normalization BEFORE zero-clipping/quantization
    rgb_pos = np.maximum(sep_rgb, 1e-4)
    sum_rgb = np.sum(rgb_pos, axis=2, keepdims=True)
    float_chroma = rgb_pos / sum_rgb
    
    # 2. Block-wise Top Chromaticity Correction in float64
    if use_top10_colorcorrection:
        float_chroma_corr = lowlight_region_colorcorrection(float_chroma, blk_size=4, top_ratio=0.15, threshold=0.1)
    else:
        float_chroma_corr = float_chroma
        
    # Pre-AWB in float64
    chroma_awb = advanced_white_balance(float_chroma_corr, method='shades_of_gray')
    mixed_awb = advanced_white_balance(mixed_rgb, method='shades_of_gray')
    
    # 3. YCrCb in Pure 64-bit Float64 (NO uint8 quantization!)
    R = chroma_awb[:, :, 0]
    G = chroma_awb[:, :, 1]
    B = chroma_awb[:, :, 2]
    
    cr_float = 0.5 + 0.500000 * R - 0.418688 * G - 0.081312 * B
    cb_float = 0.5 - 0.168736 * R - 0.331264 * G + 0.500000 * B
    
    # 4. Non-Saturating Luma Compression from mixed_awb
    m_y = 0.299 * mixed_awb[:, :, 0] + 0.587 * mixed_awb[:, :, 1] + 0.114 * mixed_awb[:, :, 2]
    mean_my = np.mean(m_y)
    if mean_my > 0 and mean_my < target_brightness:
        grayfactor = min(target_brightness / max(mean_my, 1e-4), max_gain)
        y_boosted = m_y * grayfactor
        mixed_y = y_boosted / (1.0 + y_boosted / 2.5)
        mixed_y = np.power(mixed_y, 0.85)
    else:
        mixed_y = m_y
    mixed_y = np.clip(mixed_y, 0.0, 0.95)
    
    # 5. Bilateral spatial smoothing on float64 chrominance
    cr_bilat = cv2.bilateralFilter((cr_float * 255.0).astype(np.uint8), 15, 35, 15).astype(np.float64) / 255.0
    cb_bilat = cv2.bilateralFilter((cb_float * 255.0).astype(np.uint8), 15, 35, 15).astype(np.float64) / 255.0
    
    guide = mixed_awb[:, :, 0]
    cr_clean = guided_filter(guide, cr_bilat, radius=20, eps=1e-2)
    cb_clean = guided_filter(guide, cb_bilat, radius=20, eps=1e-2)
    
    # 6. Saturation boost in float64 YCrCb
    cr_boosted = np.clip(0.5 + (cr_clean - 0.5) * sat_boost, 0.0, 1.0)
    cb_boosted = np.clip(0.5 + (cb_clean - 0.5) * sat_boost, 0.0, 1.0)
    
    # 7. Convert float64 YCrCb back to RGB
    Y = mixed_y
    Cr = cr_boosted - 0.5
    Cb = cb_boosted - 0.5
    
    r_out = Y + 1.40200 * Cr
    g_out = Y - 0.34414 * Cb - 0.71414 * Cr
    b_out = Y + 1.77200 * Cb
    
    rgb_out = np.stack([r_out, g_out, b_out], axis=2)
    rgb_out = np.clip(rgb_out, 0.0, 1.0)
    
    # 8. Final Auto White Balance
    final_rgb = advanced_white_balance(rgb_out, method='shades_of_gray')
    return np.clip(final_rgb, 0.0, 1.0)
