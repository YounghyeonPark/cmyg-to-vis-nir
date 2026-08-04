"""
EPFL Baseline RGB-NIR Separation Method using SL0 (Smoothed L0 Norm)
Based on: "Compressive Sensing based RGB and NIR separation"
"""

import numpy as np

def sl0_decode(theta, y, sigma_min=1e-5, sigma_factor=0.5, L=3):
    """
    Smoothed L0 (SL0) sparse decoding algorithm
    """
    m, n = theta.shape
    x = np.dot(np.linalg.pinv(theta), y)
    sigma = 2.0 * np.max(np.abs(x))
    
    while sigma > sigma_min:
        for _ in range(L):
            # Gradient ascent of Gaussian smoothed L0 norm
            delta = x * np.exp(-(x ** 2) / (2 * (sigma ** 2)))
            x = x - delta
            # Projection back onto solution space: theta * x = y
            x = x - np.dot(np.linalg.pinv(theta), np.dot(theta, x) - y)
        sigma *= sigma_factor
        
    return x

def separate_rgb_nir_epfl(bayer_rgb_nir, alpha=(0.5523, 0.4475)):
    """
    Separate RGB and NIR from RGB+NIR bayer matrix using SL0 compressive sensing.
    """
    h, w = bayer_rgb_nir.shape
    h_crop = (h // 2) * 2
    w_crop = (w // 2) * 2
    img = bayer_rgb_nir[:h_crop, :w_crop].astype(np.float64)
    
    alpha1, alpha2 = alpha
    beta1, beta2 = 1.0 - alpha1, 1.0 - alpha2
    
    # 2x2 Block decoding
    phi_alpha = np.diag([alpha1, alpha2])
    phi_beta = np.diag([beta1, beta2])
    phi = np.hstack([phi_alpha, phi_beta])
    
    idct_kernel = np.eye(2)
    idct_matrix = np.zeros((4, 4))
    idct_matrix[:2, :2] = idct_kernel
    idct_matrix[2:, 2:] = idct_kernel
    
    theta = np.dot(phi, idct_matrix)
    
    recon_g = np.zeros((h_crop, w_crop), dtype=np.float64)
    recon_nir = np.zeros((h_crop, w_crop), dtype=np.float64)
    
    for r in range(0, h_crop, 2):
        for c in range(0, w_crop, 2):
            y_g = np.array([img[r, c], img[r+1, c+1]])
            x_g = sl0_decode(theta, y_g)
            x_g = np.dot(idct_matrix, x_g)
            
            recon_g[r, c] = x_g[0]
            recon_g[r+1, c+1] = x_g[1]
            recon_nir[r, c] = x_g[2]
            recon_nir[r+1, c+1] = x_g[3]
            
    # Interpolation for full image
    separated_g = (recon_g + np.roll(recon_g, -1, axis=0) + np.roll(recon_g, -1, axis=1)) / 3.0
    separated_nir = (recon_nir + np.roll(recon_nir, -1, axis=0) + np.roll(recon_nir, -1, axis=1)) / 3.0
    
    separated_r = img - beta2 * separated_nir
    separated_b = img - beta1 * separated_nir
    
    separated_rgb = np.zeros((h_crop, w_crop, 3), dtype=np.float64)
    separated_rgb[:, :, 0] = separated_r * (1.0 / alpha2)
    separated_rgb[:, :, 1] = separated_g
    separated_rgb[:, :, 3-1] = separated_b * (1.0 / alpha1)
    
    return np.clip(separated_rgb, 0.0, 255.0), np.clip(separated_nir, 0.0, 255.0)
