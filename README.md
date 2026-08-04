# An Acquisition Method for Visible and Near Infrared Images from Single CMYG Color Filter Array-Based Sensor

Official implementation (Python & MATLAB) of the paper:
**"An Acquisition Method for Visible and Near Infrared Images from Single CMYG Color Filter Array-Based Sensor"**  
*Sensors* 2020, 20(19), 5578; DOI: [10.3390/s20195578](https://doi.org/10.3390/s20195578)  
**Authors**: Younghyeon Park and Byeungwoo Jeon (*Digital Media Lab, Sungkyunkwan University*)

---

## 📌 Overview

This repository provides a method to acquire and separate **Visible (RGB)** and **Near-Infrared (NIR)** images simultaneously from a single image sensor equipped with a **CMYG (Cyan, Magenta, Yellow, Green)** Color Filter Array (CFA) without an IR cut filter (hot-mirror).

```
[CMYG RAW Sensor Data] 
       │
       ▼ (1. Demosaicing)
[Interpolated C', M', Y', G' Channels] 
       │
       ▼ (2. Matrix Inverse Transformation)
[Raw Separated RGB & NIR] 
       │
       ▼ (3. Guided Denoising)
[Denoised RGB & NIR Images] 
       │
       ▼ (4. Auto White Balance)
[Final High-Quality Visible RGB + NIR]
```

### Key Advantages
- **High Sensitivity**: Complementary CMYG filters pass more light and NIR spectrum than traditional RGB filters.
- **Fast & Lightweight**: Matrix inversion signal transformation and Joint Guided Filtering allow real-time execution.
- **High Reconstruction Quality**: Minimal color artifact and superior PSNR compared to traditional compressive sensing (SL0) methods.

---

## 📁 Repository Structure

```text
.
├── README.md                  # Project documentation & paper details
├── LICENSE                    # MIT License
├── requirements.txt           # Top-level Python dependencies
├── .gitignore                 # Output/temporary file filters
│
├── python/                    # Python Implementation
│   ├── cmyg_separation/       # Modular Python Package
│   │   ├── __init__.py
│   │   ├── demosaic.py        # 2x2 CMYG Bayer pattern demosaicing
│   │   ├── separation.py      # Matrix inverse RGB & NIR signal separation
│   │   ├── denoising.py       # Guided Filter & Wiener filter
│   │   └── utils.py           # Auto White Balance & I/O helpers
│   ├── demo.py                # Standalone Python demo script
│   └── requirements.txt       # Package requirements
│
└── matlab/                    # Complete MATLAB Implementation
    ├── main_separation.m      # Main MATLAB demo script
    ├── core/                  # Core functions (demosaic, separation, denoising, AWB)
    ├── evaluation/            # EPFL comparison benchmarks & PSNR metrics
    ├── hyperspectral_sim/     # Spectral sensitivity function (SSF) simulation
    ├── lowlight_enhancement/  # NIR-guided low-light enhancement application
    └── video_coding/          # HEVC / HM codec compression test configs
```

---

## 🚀 Quick Start

### 🐍 Python Installation & Usage

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run Python Demo**:
   ```bash
   cd python
   python demo.py
   ```

3. **Python Code Example**:
   ```python
   import cv2
   from cmyg_separation import process_cmyg_image

   # 1. Load Raw 12-bit CMYG PGM/RAW image
   raw_cmyg = cv2.imread("samples/sample_cmyg.pgm", cv2.IMREAD_UNCHANGED)

   # 2. Process through separation pipeline
   rgb_img, nir_img, mixed_img = process_cmyg_image(raw_cmyg, max_val=4095.0, denoise_method='guided')

   # 3. Save separated results
   cv2.imwrite("output_rgb.jpg", cv2.cvtColor((rgb_img * 255).astype('uint8'), cv2.COLOR_RGB2BGR))
   cv2.imwrite("output_nir.jpg", (nir_img * 255).astype('uint8'))
   ```

---

### 🔬 MATLAB Usage

1. Open MATLAB and set the working directory to `matlab/`.
2. Run the main script:
   ```matlab
   main_separation
   ```

---

## 📜 Citation

If you find this work or code useful for your research, please cite our paper:

```bibtex
@article{park2020acquisition,
  title={An Acquisition Method for Visible and Near Infrared Images from Single CMYG Color Filter Array-Based Sensor},
  author={Park, Younghyeon and Jeon, Byeungwoo},
  journal={Sensors},
  volume={20},
  number={19},
  pages={5578},
  year={2020},
  publisher={MDPI},
  doi={10.3390/s20195578}
}
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
