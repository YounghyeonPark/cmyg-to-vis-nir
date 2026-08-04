
---------------------------------------------------------------
Descriptions:
	
	This package includes the demo of
	'Effective Color Correction Pipeline for a Noisy Image'
	
	This code is available only for reserch purpose.
	If you use this code for future publications,
	please cite the following paper.
	
	Kenta Takahashi, Yusuke Monno, Masayuki Tanaka and Masatoshi Okutomi,
	'Effective Color Correction Pipeline for a Noisy Image',
	IEEE International Conference on Image Processing 2016.
	
	Copyright (C) 2016 Kenta Takahashi. All rights reserved.


---------------------------------------------------------------
Usage:

	1. Please download the BM3D package from the following cite.
		http://www.cs.tut.fi/~foi/GCF-BM3D/
	2. Please copy all the BM3D files into the BM3D folder.
	3. Try demo.m file

	If you don't have the parallel computing toolbox,
	please replace "parfor" with "for".


---------------------------------------------------------------
functions:

	pro_func: main function of the proposed method
		[output] = pro_func(X,M,nl,k,div_size)
		
		input arguments:
		1) X ( H x W x 3 )   : noisy input image
		2) M ( 3 x 3 )       : color correction matrix for noise-free case
		3) nl ( 3 x1 )       : noise level (std. dev.) of input image
		4) k                 : block size of SVCC (k must be odd)
		5) div_size          : interval width of assumed noise levels
		
		output:
		1) out               : output image


	svcc: spatially varying color correction
		[Y,nl_map] = svcc(X,M,nl,k)
		
		input arguments:
		1) X ( H x W x 3 )   : noisy input image
		2) M ( 3 x 3 )       : color correction matrix for noise-free case
		3) nl ( 3 x 1 )      : noise level (std. dev.) of input image
		4) k                 : block size of SVCC (k must be odd)
		
		outputs:
		1) Y                 : color corrected image
		2) nl_map            : noise level distribution map


---------------------------------------------------------------
Questions:

	If you have any questions, please feel free to ask Yusuke Monno.
	e-mail : ymonno@ok.ctrl.titech.ac.jp
	website: http://www.ok.ctrl.titech.ac.jp/~ymonno/


---------------------------------------------------------------
Project page:
	http://www.ok.ctrl.titech.ac.jp/res/CC/CC.html


---------------------------------------------------------------
August 24, 2016


