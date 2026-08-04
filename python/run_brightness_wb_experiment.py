"""
Experiment: Visible RGB Brightness and Advanced White Balance Correction
"""

import sys, os
import cv2
import numpy as np

sys.path.append(os.path.dirname(__file__))

from cmyg_separation import (
    interpolate_cmyg,
    convert_cmygp_to_rgbn,
    convert_cmyg_to_rgb,
    denoise_rgb,
    denoise_nir,
    advanced_white_balance,
    correct_brightness_and_contrast
)

def run_experiment():
    print("=== Visible RGB Brightness & Advanced White Balance Correction Experiment ===")
    
    test_file = os.path.join("..", "convert", "Images", "piggybank2_lowlight+NIR_wb.pgm")
    if not os.path.exists(test_file):
        test_file = os.path.join("..", "convert", "Images", "Objects_light+NIR.pgm")
        
    print(f"Loading raw CMYG sample image: {os.path.abspath(test_file)}")
    raw_cmyg = cv2.imread(test_file, cv2.IMREAD_UNCHANGED)
    if raw_cmyg is None:
        print("Creating synthetic raw array...")
        raw_cmyg = np.random.randint(0, 4095, (512, 512), dtype=np.uint16)
        
    # Step 1: Demosaic & Separate
    interpolated_cmyg = interpolate_cmyg(raw_cmyg, max_val=4095.0)
    converted_rgb, converted_nir = convert_cmygp_to_rgbn(interpolated_cmyg)
    mixed_rgb = convert_cmyg_to_rgb(interpolated_cmyg)
    
    # Step 2: Denoise
    filtered_rgb = denoise_rgb(converted_rgb, converted_nir, mixed_rgb, interpolated_cmyg, method='guided')
    filtered_nir = denoise_nir(converted_rgb, converted_nir, mixed_rgb, interpolated_cmyg, method='guided')
    
    # Stage 1: Raw Separated (No Correction)
    stage1_rgb = np.clip(filtered_rgb, 0.0, 1.0)
    
    # Stage 2: Advanced White Balance (Shades of Gray)
    stage2_rgb = advanced_white_balance(filtered_rgb, method='shades_of_gray', p=6)
    
    # Stage 3: NIR-Guided Adaptive Brightness + AWB
    stage3_rgb = correct_brightness_and_contrast(stage2_rgb, nir_img=filtered_nir, gamma=0.75, lambda_nir=0.45)
    
    print("\nQuantitative Illumination Statistics:")
    print(f" - Stage 1 (Raw Separated RGB)    : Mean Luminance = {np.mean(stage1_rgb):.4f}")
    print(f" - Stage 2 (+ Shades-of-Gray AWB) : Mean Luminance = {np.mean(stage2_rgb):.4f}")
    print(f" - Stage 3 (+ Adaptive Brightness): Mean Luminance = {np.mean(stage3_rgb):.4f}")
    
    # Prepare Visual Comparison Grid
    target_w = 400
    def prep(im, title):
        bgr = cv2.cvtColor((im * 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
        h, w = bgr.shape[:2]
        nh = int(h * (target_w / float(w)))
        resized = cv2.resize(bgr, (target_w, nh))
        
        banner = np.zeros((40, resized.shape[1], 3), dtype=np.uint8) + 30
        cv2.putText(banner, title, (15, 27), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 2)
        return np.vstack([banner, resized])
        
    p1 = prep(stage1_rgb, "1. Raw Separated RGB")
    p2 = prep(stage2_rgb, "2. + Advanced AWB (Shades of Gray)")
    p3 = prep(stage3_rgb, "3. + NIR-Guided Brightness Corrected")
    
    min_h = min(p1.shape[0], p2.shape[0], p3.shape[0])
    grid = np.hstack([p1[:min_h], p2[:min_h], p3[:min_h]])
    
    out_path = os.path.join("..", "docs", "brightness_wb_experiment.jpg")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    cv2.imwrite(out_path, grid)
    print(f"\nExperiment finished successfully! Saved comparison diagram: {os.path.abspath(out_path)}")

if __name__ == "__main__":
    run_experiment()
