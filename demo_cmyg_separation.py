"""
Demo script for running CMYG to RGB+NIR separation in Python.
"""

import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
from cmyg_to_rgb_nir import process_cmyg_image

def run_demo():
    # Search for an example image in convert/images or convert/
    sample_paths = [
        os.path.join("convert", "images", "colorchart2_fluorescent_6500K.pgm"),
        os.path.join("convert", "Objects_light+NIR.pgm"),
        os.path.join("convert", "images", "piggybank_lowlight+NIR_wb.pgm")
    ]
    
    img_path = None
    for p in sample_paths:
        if os.path.exists(p):
            img_path = p
            break
            
    if img_path is None:
        print("Sample PGM image not found. Creating a synthetic 256x256 CMYG pattern for demo...")
        bayer_raw = np.random.randint(0, 4095, (256, 256), dtype=np.uint16)
    else:
        print(f"Loading sample CMYG raw image: {img_path}")
        bayer_raw = cv2.imread(img_path, cv2.IMREAD_UNCHANGED)
        if bayer_raw is None:
            print("Failed to read image via cv2, generating synthetic array.")
            bayer_raw = np.random.randint(0, 4095, (256, 256), dtype=np.uint16)

    print("Running CMYG to RGB+NIR separation pipeline...")
    rgb, nir, mixed = process_cmyg_image(bayer_raw, max_val=4095.0, denoise_method='guided')
    
    print("Separation finished successfully!")
    print(f"RGB output shape: {rgb.shape}, range: [{rgb.min():.3f}, {rgb.max():.3f}]")
    print(f"NIR output shape: {nir.shape}, range: [{nir.min():.3f}, {nir.max():.3f}]")
    
    # Save output images
    output_dir = "python_output"
    os.makedirs(output_dir, exist_ok=True)
    
    rgb_bgr = cv2.cvtColor((rgb * 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
    nir_uint8 = (nir * 255).astype(np.uint8)
    mixed_bgr = cv2.cvtColor((mixed * 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
    
    cv2.imwrite(os.path.join(output_dir, "separated_rgb.jpg"), rgb_bgr)
    cv2.imwrite(os.path.join(output_dir, "separated_nir.jpg"), nir_uint8)
    cv2.imwrite(os.path.join(output_dir, "mixed_rgb_nir.jpg"), mixed_bgr)
    
    print(f"Saved result images to folder: {os.path.abspath(output_dir)}")

if __name__ == "__main__":
    run_demo()
