
addpath('./images');
addpath('./guidedfilter');
addpath('./toolbox_v1.3');
number_of_images = 54;
%number_of_images = 1;

psnr_rgb_EPFL = double(zeros(number_of_images,1));
psnr_nir_EPFL = double(zeros(number_of_images,1));
psnr_rgb_SKKU = double(zeros(number_of_images,1));
psnr_nir_SKKU = double(zeros(number_of_images,1));


for i=1:number_of_images

    filename = sprintf('%04d_',i-1);


    input_rgb = double(imread([filename 'rgb.tiff']));
    input_nir = double(imread([filename 'nir.tiff']));

    re_img_width = (floor(size(input_rgb,2)/128) * 128) - 16;
    re_img_height = (floor(size(input_rgb,1)/128) * 128) - 16;
    %input_rgb = imresize(input_rgb, [re_img_height, re_img_width]);
    %original_nir = imresize(input_nir, [re_img_height, re_img_width]); 
    input_rgb = input_rgb(9:(re_img_height + 8), 9:(re_img_width + 8),:);
    original_nir = input_nir(9:(re_img_height + 8), 9:(re_img_width + 8),:); 
 
    [optimizer, metric] = imregconfig('multimodal');
    original_nir = imregister(original_nir, input_rgb(:,:,2), 'affine', optimizer, metric);
    %original_rgb = input_rgb;
    bayer_rgb = mosaic_rgb(input_rgb);
    original_rgb = demosaic_rgb(bayer_rgb);
    bayer_rgb_nir = mosaic_rgb_nir(original_rgb, original_nir);


    cmyg = convert_rgb_to_cmyg(original_rgb);
    cmyg_nir = convert_rgbn_to_cmygp(original_rgb, original_nir);
    bayer_cmyg_nir = mosaic_cmyg_nir(cmyg, original_nir);


    [separated_rgb_EPFL, separated_nir_EPFL] = separation_rgb_nir_EPFL(bayer_rgb_nir);
    [separated_rgb_SKKU, separated_nir_SKKU] = separation_rgb_nir_SKKU(bayer_cmyg_nir);
    %[separated_rgb_SKKU, separated_nir_SKKU] = separation_rgb_nir_SKKU_nodemosaic(cmyg_nir);


    separated_rgb_EPFL = uint8(separated_rgb_EPFL);
    separated_rgb_SKKU = uint8(separated_rgb_SKKU);
    separated_nir_EPFL = uint8(separated_nir_EPFL);
    separated_nir_SKKU = uint8(separated_nir_SKKU);
    original_rgb = uint8(original_rgb);
    original_nir = uint8(original_nir);



    psnr_rgb_EPFL(i) = PSNR(original_rgb, separated_rgb_EPFL);
    psnr_nir_EPFL(i) = PSNR(original_nir, separated_nir_EPFL);


    psnr_rgb_SKKU(i) = PSNR(original_rgb, separated_rgb_SKKU);
    psnr_nir_SKKU(i) = PSNR(original_nir, separated_nir_SKKU);


    imwrite(separated_rgb_EPFL, [filename 'rgb_EPFL.jpg']);
    imwrite(separated_nir_EPFL, [filename 'nir_EPFL.jpg']);
    
    imwrite(separated_rgb_SKKU, [filename 'rgb_SKKU.jpg']);
    imwrite(separated_nir_SKKU, [filename 'nir_SKKU.jpg']);
    
    separated_xyz_SKKU = rgb2xyz(separated_rgb_SKKU);
    separated_lab_SKKU = rgb2lab(separated_rgb_SKKU);
    separated_hsv_SKKU = rgb2hsv(separated_rgb_SKKU);
    
    separated_xyz_EPFL = rgb2xyz(separated_rgb_EPFL);
    separated_lab_EPFL = rgb2lab(separated_rgb_EPFL);
    separated_hsv_EPFL = rgb2hsv(separated_rgb_EPFL);

    original_xyz = rgb2xyz(original_rgb);
    original_lab = rgb2lab(original_rgb);
    original_hsv = rgb2hsv(original_rgb);
    
    colordist_rgb_SKKU(i) = evcc(original_rgb, separated_rgb_SKKU);
    colordist_rgb_EPFL(i) = evcc(original_rgb, separated_rgb_EPFL);
    
    colordist_xyz_SKKU(i) = evcc(original_xyz, separated_xyz_SKKU);
    colordist_xyz_EPFL(i) = evcc(original_xyz, separated_xyz_EPFL);
    
    colordist_lab_SKKU(i) = evcc(original_lab, separated_lab_SKKU);
    colordist_lab_EPFL(i) = evcc(original_lab, separated_lab_EPFL);
    
    colordist_hsv_SKKU(i) = evcc(original_hsv, separated_hsv_SKKU);
    colordist_hsv_EPFL(i) = evcc(original_hsv, separated_hsv_EPFL);
    
    colordist_nir_SKKU(i) = evcc(original_nir, separated_nir_SKKU);
    colordist_nir_EPFL(i) = evcc(original_nir, separated_nir_EPFL);
    
    
    hist_original_r = imhist(original_rgb(:,:,1));
    hist_original_g = imhist(original_rgb(:,:,2));
    hist_original_b = imhist(original_rgb(:,:,3));
    hist_original_nir = imhist(original_nir);

    hist_original_x = imhist(original_xyz(:,:,1));
    hist_original_y = imhist(original_xyz(:,:,2));
    hist_original_z = imhist(original_xyz(:,:,3));
    
    hist_original_l = imhist(original_lab(:,:,1));
    hist_original_a = imhist(original_lab(:,:,2));
    hist_original_b = imhist(original_lab(:,:,3));
    
    hist_original_h = imhist(original_hsv(:,:,1));
    hist_original_s = imhist(original_hsv(:,:,2));
    hist_original_v = imhist(original_hsv(:,:,3));
    
    hist_separated_r_SKKU = imhist(separated_rgb_SKKU(:,:,1));
    hist_separated_g_SKKU = imhist(separated_rgb_SKKU(:,:,2));
    hist_separated_b_SKKU = imhist(separated_rgb_SKKU(:,:,3));
    hist_separated_nir_SKKU = imhist(separated_nir_SKKU);

    hist_separated_r_EPFL = imhist(separated_rgb_EPFL(:,:,1));
    hist_separated_g_EPFL = imhist(separated_rgb_EPFL(:,:,2));
    hist_separated_b_EPFL = imhist(separated_rgb_EPFL(:,:,3));
    hist_separated_nir_EPFL = imhist(separated_nir_EPFL);

    hist_separated_x_SKKU = imhist(separated_xyz_SKKU(:,:,1));
    hist_separated_y_SKKU = imhist(separated_xyz_SKKU(:,:,2));
    hist_separated_z_SKKU = imhist(separated_xyz_SKKU(:,:,3));
    

    hist_separated_x_EPFL = imhist(separated_xyz_EPFL(:,:,1));
    hist_separated_y_EPFL = imhist(separated_xyz_EPFL(:,:,2));
    hist_separated_z_EPFL = imhist(separated_xyz_EPFL(:,:,3));
    
    hist_separated_l_SKKU = imhist(separated_lab_SKKU(:,:,1));
    hist_separated_a_SKKU = imhist(separated_lab_SKKU(:,:,2));
    hist_separated_b_SKKU = imhist(separated_lab_SKKU(:,:,3));
    

    hist_separated_l_EPFL = imhist(separated_lab_EPFL(:,:,1));
    hist_separated_a_EPFL = imhist(separated_lab_EPFL(:,:,2));
    hist_separated_b_EPFL = imhist(separated_lab_EPFL(:,:,3));
    
    
    hist_separated_h_SKKU = imhist(separated_hsv_SKKU(:,:,1));
    hist_separated_s_SKKU = imhist(separated_hsv_SKKU(:,:,2));
    hist_separated_v_SKKU = imhist(separated_hsv_SKKU(:,:,3));
    

    hist_separated_h_EPFL = imhist(separated_hsv_EPFL(:,:,1));
    hist_separated_s_EPFL = imhist(separated_hsv_EPFL(:,:,2));
    hist_separated_v_EPFL = imhist(separated_hsv_EPFL(:,:,3));
    
    colordist_hist_r_SKKU(i) = evcchist(hist_original_r, hist_separated_r_SKKU);
    colordist_hist_g_SKKU(i) = evcchist(hist_original_g, hist_separated_g_SKKU);
    colordist_hist_b_SKKU(i) = evcchist(hist_original_b, hist_separated_b_SKKU);
    
    colordist_hist_x_SKKU(i) = evcchist(hist_original_x, hist_separated_x_SKKU);
    colordist_hist_y_SKKU(i) = evcchist(hist_original_y, hist_separated_y_SKKU);
    colordist_hist_z_SKKU(i) = evcchist(hist_original_z, hist_separated_z_SKKU);
    
    colordist_hist_l_SKKU(i) = evcchist(hist_original_l, hist_separated_l_SKKU);
    colordist_hist_a_SKKU(i) = evcchist(hist_original_a, hist_separated_a_SKKU);
    colordist_hist_b_SKKU(i) = evcchist(hist_original_b, hist_separated_b_SKKU);
    
    colordist_hist_h_SKKU(i) = evcchist(hist_original_h, hist_separated_h_SKKU);
    colordist_hist_s_SKKU(i) = evcchist(hist_original_s, hist_separated_s_SKKU);
    colordist_hist_v_SKKU(i) = evcchist(hist_original_v, hist_separated_v_SKKU);
    
    colordist_hist_rgb_SKKU(i) = evcchist3(hist_original_r, hist_original_g, hist_original_b, hist_separated_r_SKKU, hist_separated_g_SKKU, hist_separated_b_SKKU);
    colordist_hist_xyz_SKKU(i) = evcchist3(hist_original_x, hist_original_y, hist_original_z, hist_separated_x_SKKU, hist_separated_y_SKKU, hist_separated_z_SKKU);
    colordist_hist_hsv_SKKU(i) = evcchist3(hist_original_h, hist_original_s, hist_original_v, hist_separated_h_SKKU, hist_separated_s_SKKU, hist_separated_v_SKKU);
    colordist_hist_lab_SKKU(i) = evcchist3(hist_original_l, hist_original_a, hist_original_b, hist_separated_l_SKKU, hist_separated_a_SKKU, hist_separated_b_SKKU);
    colordist_hist_nir_SKKU(i) = evcchist(hist_original_nir, hist_separated_nir_SKKU);
    
    
    colordist_hist_r_EPFL(i) = evcchist(hist_original_r, hist_separated_r_EPFL);
    colordist_hist_g_EPFL(i) = evcchist(hist_original_g, hist_separated_g_EPFL);
    colordist_hist_b_EPFL(i) = evcchist(hist_original_b, hist_separated_b_EPFL);
    
    colordist_hist_x_EPFL(i) = evcchist(hist_original_x, hist_separated_x_EPFL);
    colordist_hist_y_EPFL(i) = evcchist(hist_original_y, hist_separated_y_EPFL);
    colordist_hist_z_EPFL(i) = evcchist(hist_original_z, hist_separated_z_EPFL);
    
    colordist_hist_l_EPFL(i) = evcchist(hist_original_l, hist_separated_l_EPFL);
    colordist_hist_a_EPFL(i) = evcchist(hist_original_a, hist_separated_a_EPFL);
    colordist_hist_b_EPFL(i) = evcchist(hist_original_b, hist_separated_b_EPFL);
    
    colordist_hist_h_EPFL(i) = evcchist(hist_original_h, hist_separated_h_EPFL);
    colordist_hist_s_EPFL(i) = evcchist(hist_original_s, hist_separated_s_EPFL);
    colordist_hist_v_EPFL(i) = evcchist(hist_original_v, hist_separated_v_EPFL);
    
    colordist_hist_rgb_EPFL(i) = evcchist3(hist_original_r, hist_original_g, hist_original_b, hist_separated_r_EPFL, hist_separated_g_EPFL, hist_separated_b_EPFL);
    colordist_hist_xyz_EPFL(i) = evcchist3(hist_original_x, hist_original_y, hist_original_z, hist_separated_x_EPFL, hist_separated_y_EPFL, hist_separated_z_EPFL);
    colordist_hist_hsv_EPFL(i) = evcchist3(hist_original_h, hist_original_s, hist_original_v, hist_separated_h_EPFL, hist_separated_s_EPFL, hist_separated_v_EPFL);
    colordist_hist_lab_EPFL(i) = evcchist3(hist_original_l, hist_original_a, hist_original_b, hist_separated_l_EPFL, hist_separated_a_EPFL, hist_separated_b_EPFL);
    colordist_hist_nir_EPFL(i) = evcchist(hist_original_nir, hist_separated_nir_EPFL);
    
   disp(i) 
end

