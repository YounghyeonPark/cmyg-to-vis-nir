20150513
-------------------------------------------------------------------

  Pseudo four-channel denoising for CFA RAW data 
  MATLAB demo & code 

  Tokyo Institute of Technology.

Authors:                     Hiroki Akiyama
                             Masayuki Tanaka
                             Masatoshi Okutomi
        

project page: http://www.ok.ctrl.titech.ac.jp/res/CFADN/CFADN.html
-------------------------------------------------------------------

-------------------------------------------------------------------
 Citation
-------------------------------------------------------------------
Hiroki Akiyama, Masayuki Tanaka and Masatoshi Okutomi, Pseudo Four-Channel Image Denoising for Noisy CFA Raw Data,
Proceedings of IEEE International Conference on Image Processing (ICIP2015), 2015.

-------------------------------------------------------------------
 Installation
-------------------------------------------------------------------
The BM3D* and the Residual interpolation** should be installed to use this code.


*This CFA denoising algorithm requires a gray-scale denoiser, and we use BM3D for denoising.
So you need to take BM3D [1] MATLAB code. 
http://www.cs.tut.fi/~foi/GCF-BM3D/
If you would like to use another gray-scale denoiser, you need to replace 
BM3D(1,nrgb(:,:,i),BM3Dsigma(i),'np',0) in wholeBM3D.m
with such denoising algorithm.


**You need to take Residual interpolation [2] MATLAB code.
http://www.ok.ctrl.titech.ac.jp/res/DM/RI.html 
If you would like to use another demosaicking algorithm, you need to replace 
"dnimg = demosaick(dnraw3, pattern, 1)"
or
"dnraw3 = repmat(dnraw,[1,1,3]);
dnimg = demosaick(dnraw3, pattern, 1);"
in demoCFADenoising.m
with such denoising algorithm.


-------------------------------------------------------------------
 Demo
-------------------------------------------------------------------
Please run demoCFADenoising.m after the Installation of the BM3D and the Residual interpolation.

-------------------------------------------------------------------
 Contents
-------------------------------------------------------------------

demoCFADenoising.m
  |-rgb2bayerraw.m
  |-CFAdenoise.m
  |-demosaick.m

---
bayerraw = rgb2bayerraw(rgb, pattern)

The function that makes a bayer raw image from a rgb image

input
  - rgb:  RGB image (M*N*3)
  - pattern:  mosaic pattern
           pattern = 'grbg'
            G R ..
            B G ..
            : : 
           pattern = 'rggb'
            R G ..
            G B ..
            : :    
           pattern = 'gbrg'
            G B ..
            R G ..
            : : 
           pattern = 'bggr'
            B G ..
            G R ..
            : :    
output
  - bayerraw:  bayer image (M*N) 

---
dnRaw = CFAdenoise(nRaw, Nsigma, pattern)

The function of proposed CFA denoising 
  * This code uses BM3D [1]

input
 - nRaw:  noisy bayer raw data (M*N)
 - Nsigma: noise level in R-channel, G-channel and B-channel 
            Nlevel = [rsigma gsigma bsigma];  
 - pattern:  mosaic pattern

output
 -raw denoised bayer raw data (M*N)

---
rgb_dem = demosaick(rgb, pattern, sigma)

The function of demosaicking using **residual interpolation [2]

input
 - rgb: mosaicked (decimated) RGB image (M*N*3)
 - pattern:  mosaic pattern
 - sigma: standard deviation of gaussian filter(default : 1)
          For Kodak image data set, 1e8 works well.
output
 -rgb_dem: demosaicked image (M*N*3)

-------------------------------------------------------------------
 Reference
-------------------------------------------------------------------
[1]K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, “ Image denoising with block-matching and
3D filtering, Proc. SPIE Electronic Imaging, no.6064A–30, 2006.

[2] D. Kiku, Y. Monno, M. Tanaka, and M. Okutomi, “ Residual Interpolation for Color Image
Demosaicking,” Proc. of IEEE Int. Conf. on Image Processing (ICIP), pp. 2304–2308, 2013.

