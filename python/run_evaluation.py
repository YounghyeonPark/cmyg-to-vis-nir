"""
Python Evaluation & Benchmark Script (SKKU Method vs EPFL Baseline)
"""

import os
import cv2
import numpy as np
from cmyg_separation import (
    process_cmyg_image,
    separate_rgb_nir_epfl,
    calculate_psnr,
    calculate_evcc
)

def run_evaluation():
    print("=== CMYG RGB-NIR Separation Performance Benchmark ===")
    
    # Generate synthetic benchmark pair or load dataset if present
    h, w = 512, 512
    gt_rgb = np.random.randint(20, 230, (h, w, 3), dtype=np.uint8)
    gt_nir = np.random.randint(10, 200, (h, w), dtype=np.uint8)
    
    # Synthesize CMYG bayer raw signal
    cmyg_bayer = (gt_rgb[:, :, 0].astype(np.float64) * 0.4 +
                  gt_rgb[:, :, 1].astype(np.float64) * 0.4 +
                  gt_nir.astype(np.float64) * 0.2) * (4095.0 / 255.0)
                  
    # 1. Proposed SKKU Method
    skku_rgb, skku_nir, _ = process_cmyg_image(cmyg_bayer, max_val=4095.0)
    skku_rgb_uint8 = (skku_rgb * 255).astype(np.uint8)
    skku_nir_uint8 = (skku_nir * 255).astype(np.uint8)
    
    # 2. EPFL Baseline Method
    epfl_rgb, epfl_nir = separate_rgb_nir_epfl(cmyg_bayer * (255.0 / 4095.0))
    epfl_rgb_uint8 = epfl_rgb.astype(np.uint8)
    epfl_nir_uint8 = epfl_nir.astype(np.uint8)
    
    # Evaluate PSNR & EVCC
    skku_rgb_psnr = calculate_psnr(gt_rgb, skku_rgb_uint8)
    skku_nir_psnr = calculate_psnr(gt_nir, skku_nir_uint8)
    skku_evcc = calculate_evcc(gt_rgb, skku_rgb_uint8)
    
    epfl_rgb_psnr = calculate_psnr(gt_rgb, epfl_rgb_uint8)
    epfl_nir_psnr = calculate_psnr(gt_nir, epfl_nir_uint8)
    epfl_evcc = calculate_evcc(gt_rgb, epfl_rgb_uint8)
    
    print("\nBenchmark Results:")
    print(f"[SKKU Proposed]  RGB PSNR: {skku_rgb_psnr:.2f} dB | NIR PSNR: {skku_nir_psnr:.2f} dB | EVCC: {skku_evcc:.4f}")
    print(f"[EPFL Baseline]  RGB PSNR: {epfl_rgb_psnr:.2f} dB | NIR PSNR: {epfl_nir_psnr:.2f} dB | EVCC: {epfl_evcc:.4f}")
    print("\nBenchmark completed successfully!")

if __name__ == "__main__":
    run_evaluation()
