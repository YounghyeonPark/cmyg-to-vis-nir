function ccmat = train_linear4x4_rgbn(sRGB,sNIR,cRGB,cNIR)

ccmat = [sRGB;sNIR]/[cRGB;cNIR];

end
