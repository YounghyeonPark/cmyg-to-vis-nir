"""
Denoising Methods (Guided Filter & Wiener Filter)
"""

import numpy as np
import cv2
from scipy.signal import wiener

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
