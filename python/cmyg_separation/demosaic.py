"""
2x2 CMYG Bayer Pattern Demosaicing (Interpolation)
"""

import numpy as np

def interpolation_LT(bayer):
    """Interpolation for Left-Top channel (Green) at (0::2, 0::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_even = np.arange(0, h, 2)
    c_odd = np.arange(1, w - 1, 2)
    if len(r_even) > 0 and len(c_odd) > 0:
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 2.0

    r_odd = np.arange(1, h - 1, 2)
    c_even = np.arange(0, w, 2)
    if len(r_odd) > 0 and len(c_even) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even]) / 2.0

    if len(r_odd) > 0 and len(c_odd) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd] +
                                 interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 4.0
    
    interp[:, -1] = interp[:, -2]
    interp[-1, :] = interp[-2, :]
    return interp

def interpolation_RT(bayer):
    """Interpolation for Right-Top channel (Magenta) at (0::2, 1::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_even = np.arange(0, h, 2)
    c_even = np.arange(2, w - 1, 2)
    if len(r_even) > 0 and len(c_even) > 0:
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 2.0

    r_odd = np.arange(1, h - 1, 2)
    c_odd = np.arange(1, w, 2)
    if len(r_odd) > 0 and len(c_odd) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd]) / 2.0

    if len(r_odd) > 0 and len(c_even) > 0:
        r_prev = (r_odd - 1)[:, None]
        r_next = (r_odd + 1)[:, None]
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even] +
                                  interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 4.0

    interp[:, 0] = interp[:, 1]
    interp[-1, :] = interp[-2, :]
    return interp

def interpolation_LB(bayer):
    """Interpolation for Left-Bottom channel (Yellow) at (1::2, 0::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_odd = np.arange(1, h, 2)
    c_odd = np.arange(1, w - 1, 2)
    if len(r_odd) > 0 and len(c_odd) > 0:
        r_grid = r_odd[:, None]
        interp[r_grid, c_odd] = (interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 2.0

    r_even = np.arange(2, h - 1, 2)
    c_even = np.arange(0, w, 2)
    if len(r_even) > 0 and len(c_even) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even]) / 2.0

    if len(r_even) > 0 and len(c_odd) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd] +
                                  interp[r_grid, c_odd - 1] + interp[r_grid, c_odd + 1]) / 4.0

    interp[:, -1] = interp[:, -2]
    interp[0, :] = interp[1, :]
    return interp

def interpolation_RB(bayer):
    """Interpolation for Right-Bottom channel (Cyan) at (1::2, 1::2)"""
    h, w = bayer.shape
    interp = bayer.copy().astype(np.float64)
    
    r_odd = np.arange(1, h, 2)
    c_even = np.arange(2, w - 1, 2)
    if len(r_odd) > 0 and len(c_even) > 0:
        r_grid = r_odd[:, None]
        interp[r_grid, c_even] = (interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 2.0

    r_even = np.arange(2, h - 1, 2)
    c_odd = np.arange(1, w, 2)
    if len(r_even) > 0 and len(c_odd) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_odd] = (interp[r_prev, c_odd] + interp[r_next, c_odd]) / 2.0

    if len(r_even) > 0 and len(c_even) > 0:
        r_prev = (r_even - 1)[:, None]
        r_next = (r_even + 1)[:, None]
        r_grid = r_even[:, None]
        interp[r_grid, c_even] = (interp[r_prev, c_even] + interp[r_next, c_even] +
                                  interp[r_grid, c_even - 1] + interp[r_grid, c_even + 1]) / 4.0

    interp[:, 0] = interp[:, 1]
    interp[0, :] = interp[1, :]
    return interp

def interpolate_cmyg(input_bayer_cmyg, max_val=4095.0):
    """
    Demosaic 2x2 CMYG Bayer Pattern
    Pattern:
      (Even row, Even col) -> Green (G)
      (Even row, Odd col)  -> Magenta (M)
      (Odd row,  Even col) -> Yellow (Y)
      (Odd row,  Odd col)  -> Cyan (C)
    """
    h, w = input_bayer_cmyg.shape
    
    bayer_G = np.zeros((h, w), dtype=np.float64)
    bayer_M = np.zeros((h, w), dtype=np.float64)
    bayer_Y = np.zeros((h, w), dtype=np.float64)
    bayer_C = np.zeros((h, w), dtype=np.float64)
    
    bayer_G[0::2, 0::2] = input_bayer_cmyg[0::2, 0::2]
    bayer_M[0::2, 1::2] = input_bayer_cmyg[0::2, 1::2]
    bayer_Y[1::2, 0::2] = input_bayer_cmyg[1::2, 0::2]
    bayer_C[1::2, 1::2] = input_bayer_cmyg[1::2, 1::2]
    
    interpolated_G = interpolation_LT(bayer_G)
    interpolated_M = interpolation_RT(bayer_M)
    interpolated_Y = interpolation_LB(bayer_Y)
    interpolated_C = interpolation_RB(bayer_C)
    
    output_cmyg = np.zeros((h, w, 4), dtype=np.float64)
    output_cmyg[:, :, 0] = interpolated_C / max_val
    output_cmyg[:, :, 1] = interpolated_M / max_val
    output_cmyg[:, :, 2] = interpolated_Y / max_val
    output_cmyg[:, :, 3] = interpolated_G / max_val
    
    return output_cmyg
