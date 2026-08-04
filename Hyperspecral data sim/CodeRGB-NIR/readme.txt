%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This is the source code of basic implementation of the RGB-NIR imaging
%   pipeliene.
%   
%   The code first converts the 59-band hyperspectral data to a camera
%   RGB-NIR image, given camera spectral sensitivity. Then, the camera
%   RGB-NIR image is transformed to the target color space by color
%   correction. In our implementation, sRGB is the target color space
%   for RGB domain, while the target space for NIR domain is manually set.
%
%   Please see the following paper for details. (This code does not
%   include mosaicking and demosaicking processes, which are particular to
%   single-sensor RGB-NIR imaging.
%
%   Yusuke Monno, Hayato Teranaka, Kazunori Yoshizaki, Masayuki Tanaka,
%   and Masatoshi Okutomi,
%   "Single-Sensor RGB-NIR Imaging: High-Quality System Design
%   and Prototype Implementation,"
%   IEEE Sensors Journal, 2018 (accepted).
%
%   The code is available only for research purpose. If you use this
%   code for publications, please cite the above paper. If you have any
%   questions, please feel free to ask Yusuke Monno.
%
%   Dataset page:
%   http://www.ok.sc.e.titech.ac.jp/res/MSI/MSIdata59.html
%
%   Project page:
%   http://www.ok.sc.e.titech.ac.jp/res/MSI/SENJ-RGB-NIR.html
%
%   Copyright (C) 2018 Yusuke Monno. All rights reserved.
%   ymonno@ok.sc.e.ctrl.titech.ac.jp
%   http://www.ok.sc.e.titech.ac.jp/~ymonno/
%
%   October 31, 2018.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
