"""
NIR-Assisted Low-Light Image Enhancement Demo Script
"""

import os
import cv2
import numpy as np
from cmyg_separation import enhance_lowlight_image

def run_lowlight_demo():
    print("=== NIR-Assisted Low-Light Image Enhancement Demo ===")
    
    # Generate synthetic low-light RGB and NIR pair
    h, w = 512, 512
    lowlight_rgb = (np.random.randint(5, 60, (h, w, 3), dtype=np.uint8).astype(np.float64)) / 255.0
    nir_img = (np.random.randint(50, 220, (h, w), dtype=np.uint8).astype(np.float64)) / 255.0
    
    print("Enhancing low-light RGB image using NIR detail and luminance guidance...")
    enhanced_rgb = enhance_lowlight_image(lowlight_rgb, nir_img, alpha=0.3, beta=0.7)
    
    out_dir = "output"
    os.makedirs(out_dir, exist_ok=True)
    
    cv2.imwrite(os.path.join(out_dir, "lowlight_input_rgb.jpg"), (lowlight_rgb * 255).astype(np.uint8))
    cv2.imwrite(os.path.join(out_dir, "lowlight_nir_guide.jpg"), (nir_img * 255).astype(np.uint8))
    cv2.imwrite(os.path.join(out_dir, "lowlight_enhanced_rgb.jpg"), cv2.cvtColor((enhanced_rgb * 255).astype(np.uint8), cv2.COLOR_RGB2BGR))
    
    print(f"Enhancement complete! Saved results to: {os.path.abspath(out_dir)}")

if __name__ == "__main__":
    run_lowlight_demo()
