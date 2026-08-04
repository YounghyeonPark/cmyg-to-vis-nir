"""
Performance and Quality Evaluation Metrics (PSNR, MSE, EVCC)
"""

import numpy as np

def calculate_mse(img1, img2):
    """Calculate Mean Squared Error between two images."""
    img1 = img1.astype(np.float64)
    img2 = img2.astype(np.float64)
    return np.mean((img1 - img2) ** 2)

def calculate_psnr(img1, img2, max_val=255.0):
    """Calculate Peak Signal-to-Noise Ratio (PSNR) in dB."""
    mse = calculate_mse(img1, img2)
    if mse == 0:
        return 99.99
    return 10.0 * np.log10((max_val ** 2) / mse)

def calculate_evcc(img1, img2):
    """
    Calculate EVCC (Enhanced Vector Color Correlation / Color Distance).
    Returns value in [0, 1] range (higher indicates better color correlation).
    """
    f1 = img1.astype(np.float64).flatten()
    f2 = img2.astype(np.float64).flatten()
    
    mean1, mean2 = np.mean(f1), np.mean(f2)
    std1, std2 = np.std(f1), np.std(f2)
    
    if std1 == 0 or std2 == 0:
        return 0.0
        
    correlation = np.mean((f1 - mean1) * (f2 - mean2)) / (std1 * std2)
    return float(np.clip(correlation, 0.0, 1.0))
