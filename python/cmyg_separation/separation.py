"""
Signal Separation via Matrix Inversion (C'M'Y'G' -> RGB + NIR)
"""

import numpy as np

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
