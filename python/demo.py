"""
Python Standalone Demo for CMYG to RGB+NIR Separation
"""

import os
import cv2
import numpy as np
from cmyg_separation import process_cmyg_image

def run_demo():
    sample_paths = [
        os.path.join("..", "samples", "sample_cmyg.pgm"),
        os.path.join("..", "convert", "images", "colorchart2_fluorescent_6500K.pgm"),
        os.path.join("..", "convert", "Objects_light+NIR.pgm")
    ]
    
    img_path = None
    for p in sample_paths:
        if os.path.exists(p):
            img_path = p
            break
            
    if img_path is None:
        print("Sample image not found. Generating a 256x256 synthetic CMYG raw image...")
        bayer_raw = np.random.randint(0, 4095, (256, 256), dtype=np.uint16)
    else:
        print(f"Loading sample CMYG raw image: {os.path.abspath(img_path)}")
        bayer_raw = cv2.imread(img_path, cv2.IMREAD_UNCHANGED)
        if bayer_raw is None:
            print("Failed to load image file. Using synthetic image...")
            bayer_raw = np.random.randint(0, 4095, (256, 256), dtype=np.uint16)

    print("Executing CMYG -> RGB + NIR separation pipeline...")
    rgb, nir, mixed = process_cmyg_image(bayer_raw, max_val=4095.0, denoise_method='guided')
    
    print("Separation finished successfully!")
    print(f" - Visible RGB Output shape: {rgb.shape}, range: [{rgb.min():.3f}, {rgb.max():.3f}]")
    print(f" - NIR Output shape:        {nir.shape}, range: [{nir.min():.3f}, {nir.max():.3f}]")
    
    # Save outputs
    out_dir = "output"
    os.makedirs(out_dir, exist_ok=True)
    
    cv2.imwrite(os.path.join(out_dir, "separated_rgb.jpg"), cv2.cvtColor((rgb * 255).astype(np.uint8), cv2.COLOR_RGB2BGR))
    cv2.imwrite(os.path.join(out_dir, "separated_nir.jpg"), (nir * 255).astype(np.uint8))
    cv2.imwrite(os.path.join(out_dir, "mixed_rgb_nir.jpg"), cv2.cvtColor((mixed * 255).astype(np.uint8), cv2.COLOR_RGB2BGR))
    
    print(f"Results saved to: {os.path.abspath(out_dir)}")

if __name__ == "__main__":
    run_demo()
