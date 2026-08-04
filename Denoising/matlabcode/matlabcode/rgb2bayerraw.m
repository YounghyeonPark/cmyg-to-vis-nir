function bayerraw = rgb2bayerraw(rgb, pattern)
[mosaic mask] = mosaic_bayer(rgb, pattern);
bayerraw = sum(mosaic .* mask, 3 );

