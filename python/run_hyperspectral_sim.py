"""
Hyperspectral Spectral Sensitivity Function (SSF) Simulation in Python
"""

import numpy as np

def run_hyperspectral_simulation():
    print("=== Hyperspectral Spectral Sensitivity Function (SSF) Simulation ===")
    
    # Wavelength band: 420nm to 1000nm (10nm interval -> 59 bands)
    wavelengths = np.arange(420, 1010, 10)
    num_bands = len(wavelengths)
    print(f"Spectral wavelength range: 420 nm to 1000 nm ({num_bands} bands)")
    
    # Simulated D65 daylight illuminant spectrum
    d65_spectrum = np.exp(-((wavelengths - 550) ** 2) / (2 * (150 ** 2)))
    
    # Sensor spectral response functions for Cyan, Magenta, Yellow, Green
    ssf_C = np.exp(-((wavelengths - 500) ** 2) / (2 * (60 ** 2))) + 0.3 * np.exp(-((wavelengths - 850) ** 2) / (2 * (80 ** 2)))
    ssf_M = np.exp(-((wavelengths - 620) ** 2) / (2 * (50 ** 2))) + 0.35 * np.exp(-((wavelengths - 850) ** 2) / (2 * (80 ** 2)))
    ssf_Y = np.exp(-((wavelengths - 580) ** 2) / (2 * (70 ** 2))) + 0.3 * np.exp(-((wavelengths - 850) ** 2) / (2 * (80 ** 2)))
    ssf_G = np.exp(-((wavelengths - 530) ** 2) / (2 * (40 ** 2))) + 0.25 * np.exp(-((wavelengths - 850) ** 2) / (2 * (80 ** 2)))
    
    ssf_matrix = np.vstack([ssf_C, ssf_M, ssf_Y, ssf_G]) # (4, 59)
    
    # Integrated response calculation
    integrated_response = np.dot(ssf_matrix, d65_spectrum)
    
    print("\nIntegrated CMYG Sensor Responses under D65 Daylight:")
    print(f" - Cyan  (C) Response: {integrated_response[0]:.4f}")
    print(f" - Magenta(M) Response: {integrated_response[1]:.4f}")
    print(f" - Yellow (Y) Response: {integrated_response[2]:.4f}")
    print(f" - Green  (G) Response: {integrated_response[3]:.4f}")
    
    print("\nHyperspectral simulation finished successfully!")

if __name__ == "__main__":
    run_hyperspectral_simulation()
