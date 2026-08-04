"""
CMYG to RGB + NIR Separation Pipeline in Python
Based on the paper:
"An Acquisition Method for Visible and Near Infrared Images from Single CMYG Color Filter Array-Based Sensor"
(Sensors 2020, 20(19), 5578) - Younghyeon Park and Byeungwoo Jeon (SKKU Digital Media Lab)
"""

import numpy as np
import cv2
from scipy.signal import wiener
import os

def interpolation_LT(bayer):
    """Interpolation for Left-Top channel (Green) at (0::2, 0::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_even = np.arange(0, h, 2)
    c_odd = np.arange(1, w - 1, 2)
    if len(r_even) > 0 and len(c_odd) > 0:
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 2.0

    r_odd = np.arange(1, h - 1, 2)
    c_even = np.arange(0, w, 2)
    if len(r_odd) > 0 and len(c_even) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even]) / 2.0

    if len(r_odd) > 0 and len(c_odd) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd] +
                                 interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 4.0
    
    interp[:, -1] = interp[:, -2]
    interp[-1, :] = interp[-2, :]
    return interp

def interpolation_RT(bayer):
    """Interpolation for Right-Top channel (Magenta) at (0::2, 1::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_even = np.arange(0, h, 2)
    c_even = np.arange(2, w - 1, 2)
    if len(r_even) > 0 and len(c_even) > 0:
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 2.0

    r_odd = np.arange(1, h - 1, 2)
    c_odd = np.arange(1, w, 2)
    if len(r_odd) > 0 and len(c_odd) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd]) / 2.0

    if len(r_odd) > 0 and len(c_even) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even] +
                                  interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 4.0

    interp[:, 0] = interp[:, 1]
    interp[-1, :] = interp[-2, :]
    return interp

def interpolation_LB(bayer):
    """Interpolation for Left-Bottom channel (Yellow) at (1::2, 0::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_odd = np.arange(1, h, 2)
    c_odd = np.arange(1, w - 1, 2)
    if len(r_odd) > 0 and len(c_odd) > 0:
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 2.0

    r_even = np.arange(2, h - 1, 2)
    c_even = np.arange(0, w, 2)
    if len(r_even) > 0 and len(c_even) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even]) / 2.0

    if len(r_even) > 0 and len(c_odd) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd] +
                                  interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 4.0

    interp[:, -1] = interp[:, -2]
    interp[0, :] = interp[1, :]
    return interp

def interpolation_RB(bayer):
    """Interpolation for Right-Bottom channel (Cyan) at (1::2, 1::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_odd = np.arange(1, h, 2)
    c_even = np.arange(2, w - 1, 2)
    if len(r_odd) > 0 and len(c_even) > 0:
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 2.0

    r_even = np.arange(2, h - 1, 2)
    c_odd = np.arange(1, w, 2)
    if len(r_even) > 0 and len(c_odd) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd]) / 2.0

    if len(r_even) > 0 and len(c_even) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even] +
                                  interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 4.0

    interp[:, 0] = interp[:, 1]
    interp[0, :] = interp[1, :]
    return interp

def interpolate_cmyg(input_bayer_cmyg, max_val=4095.0):
    """
    Demosaic 2x2 CMYG Bayer Pattern
    Pattern:
      (Even row, Even col) -> Green (G)
      (Even row, Odd col)  -> Magenta (M)
      (Odd row,  Even col) -> Yellow (Y)
      (Odd row,  Odd col)  -> Cyan (C)
    """
    h, w = input_bayer_cmyg.shape
    
    bayer_G = np.zeros((h, w), dtype=np.float64)
    bayer_M = np.zeros((h, w), dtype=np.float64)
    bayer_Y = np.zeros((h, w), dtype=np.float64)
    bayer_C = np.zeros((h, w), dtype=np.float64)
    
    bayer_G[0::2, 0::2] = input_bayer_cmyg[0::2, 0::2]
    bayer_M[0::2, 1::2] = input_bayer_cmyg[0::2, 1::2]
    bayer_Y[1::2, 0::2] = input_bayer_cmyg[1::2, 0::2]
    bayer_C[1::2, 1::2] = input_bayer_cmyg[1::2, 1::2]
    
    interpolated_G = interpolation_LT(bayer_G)
    interpolated_M = interpolation_RT(bayer_M)
    interpolated_Y = interpolation_LB(bayer_Y)
    interpolated_C = interpolation_RB(bayer_C)
    
    output_cmyg = np.zeros((h, w, 4), dtype=np.float64)
    output_cmyg[:, :, 0] = interpolated_C / max_val
    output_cmyg[:, :, 1] = interpolated_M / max_val
    output_cmyg[:, :, 2] = interpolated_Y / max_val
    output_cmyg[:, :, 3] = interpolated_G / max_val
    
    return output_cmyg

def convert_cmygp_to_rgbn(interpolated_cmyg_prime, gamma=None):
    """Convert C'M'Y'G' channels to RGB + NIR (N) using matrix inverse transformation."""
    if gamma is None:
        gamma = [0.8337, 0.9833, 0.8296, 1.0000]
        
    cmygp_rgbn = np.array([
        [-0.0566, 0.3293, 0.2021, gamma[0]],
        [ 0.1235, 0.1361, 0.1358, gamma[1]],
        [ 0.0943, 0.3851, 0.0415, gamma[2]],
        [-0.0342, 0.3475, 0.0848, gamma[3]]
    ], dtype=np.float64)
    
    rgbn_cmygp = np.linalg.inv(cmygp_rgbn)
    
    converted_rgbn = np.dot(interpolated_cmyg_prime, rgbn_cmygp.T)
    
    output_rgb = converted_rgbn[:, :, :3]
    output_nir = converted_rgbn[:, :, 3]
    
    return output_rgb, output_nir

def convert_cmyg_to_rgb(interpolated_cmyg):
    """Get RGB+NIR mixed reference image from C'M'Y'G'"""
    cmyg_rgb = np.array([
        [-0.0566, 0.3293, 0.2021],
        [ 0.1235, 0.1361, 0.1358],
        [ 0.0943, 0.3851, 0.0415],
        [-0.0342, 0.3475, 0.0848]
    ], dtype=np.float64)
    
    rgb_cmyg = np.linalg.pinv(cmyg_rgb)
    mixed_rgb = np.dot(interpolated_cmyg, rgb_cmyg.T)
    return mixed_rgb

def guided_filter(guide, src, radius=8, eps=1e-4):
    """Guided Filter implementation using OpenCV boxFilter"""
    guide = guide.astype(np.float64)
    src = src.astype(np.float64)
    ksize = (2 * radius + 1, 2 * radius + 1)
    
    mean_I = cv2.boxFilter(guide, cv2.CV_64F, ksize)
    mean_p = cv2.boxFilter(src, cv2.CV_64F, ksize)
    mean_Ip = cv2.boxFilter(guide * src, cv2.CV_64F, ksize)
    cov_Ip = mean_Ip - mean_I * mean_p
    
    mean_II = cv2.boxFilter(guide * guide, cv2.CV_64F, ksize)
    var_I = mean_II - mean_I * mean_I
    
    a = cov_Ip / (var_I + eps)
    b = mean_p - a * mean_I
    
    mean_a = cv2.boxFilter(a, cv2.CV_64F, ksize)
    mean_b = cv2.boxFilter(b, cv2.CV_64F, ksize)
    
    q = mean_a * guide + mean_b
    return q

def denoise_rgb(separated_rgb, separated_nir, mixed_rgb, mixed_cmyg=None, method='guided'):
    """Denoise RGB channels"""
    filtered_rgb = separated_rgb.copy()
    
    if method == 'wiener':
        for c in range(3):
            filtered_rgb[:, :, c] = wiener(filtered_rgb[:, :, c], (8, 8))
            
    elif method == 'guided':
        guide = mixed_cmyg[:, :, 3] if mixed_cmyg is not None else cv2.cvtColor((mixed_rgb * 255).astype(np.uint8), cv2.COLOR_RGB2GRAY) / 255.0
        for c in range(3):
            filtered_rgb[:, :, c] = guided_filter(guide, filtered_rgb[:, :, c], radius=8, eps=5e-5)
            
    return filtered_rgb

def denoise_nir(separated_rgb, separated_nir, mixed_rgb, mixed_cmyg=None, method='guided'):
    """Denoise NIR channel"""
    filtered_nir = separated_nir.copy()
    
    if method == 'wiener':
        filtered_nir = wiener(filtered_nir, (8, 8))
        
    elif method == 'guided':
        guide = mixed_cmyg[:, :, 3] if mixed_cmyg is not None else cv2.cvtColor((mixed_rgb * 255).astype(np.uint8), cv2.COLOR_RGB2GRAY) / 255.0
        filtered_nir = guided_filter(guide, filtered_nir, radius=8, eps=5e-5)
        
    return filtered_nir

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
