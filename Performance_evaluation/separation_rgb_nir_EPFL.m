function [separated_rgb, separated_nir] = separation_rgb_nir_EPFL(bayer_rgb_nir)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % parameter for SL0 decomposition recovery algorithm

    % Parameters
    m = 1000;   % No of sources
    n = 400;   % No of sensors
    L = 3; % Maximum number of iterations for the internal steepest descent loop
    sigma_off = 0.001;

    % Important Algorithm's Parameters
    sigma_decrease_factor = 0.5;
    L = 3;
    if sigma_off>0
        sigma_min = sigma_off*4;
    else
        sigma_min = 0.00001;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    addpath('./SL0MatlabCodeV2/');


    img_width = size(bayer_rgb_nir,2);
    img_height = size(bayer_rgb_nir,1);

    block_size = 2;
    block_elements = block_size*block_size;


    crop_img_width = floor(img_width/block_size) * block_size;
    crop_img_height = floor(img_height/block_size) * block_size;

    combined = bayer_rgb_nir(1:crop_img_height,1:crop_img_width);


    combined_col = im2col(combined', [block_size block_size], 'distinct');

    length_col = size(combined_col,2);
    %y_r = zeros(length_col,1);
    %y_g = zeros(length_col * 2,1);
    %y_b = zeros(length_col,1);
    %x_g = zeros(length_col * 4,1);
    y_g = zeros((block_elements)/2,1);


    
     
     alpha1 = 0.5523;
     alpha2 = 0.4475;
     alpha3 = 0.5;
     alpha4 = 0.5;
     %beta1 = sqrt(1 - alpha1.^2);
    % %beta2 = sqrt(1 - alpha2.^2);
     beta1 = 1- alpha1;
     beta2 = 1-alpha2;
     beta3 = 1-alpha3;
     beta4 = 1-alpha4;
     phi_alpha = [alpha1 0; 0 alpha2];
     phi_beta = [beta1 0; 0 beta2];
    % 
     phi_alpha = repmat(phi_alpha, (block_elements)/4);
     phi_beta = repmat(phi_beta, (block_elements)/4);
     phi_alpha = phi_alpha .* eye(block_elements/2);
     phi_beta = phi_beta .* eye(block_elements/2);
    % 

    %phi_alpha = rand(block_elements/2,block_elements/2) .* eye(block_elements/2);

    %phi_beta = (1- phi_alpha) .* eye(block_elements/2);


    
    
    
    

    phi = [phi_alpha phi_beta];
    idct_kernel = idct(eye(block_elements/2));
    idct_matrix = zeros(block_elements, block_elements);
    idct_matrix(1:(block_elements/2),1:(block_elements/2)) = idct_kernel;
    idct_matrix((block_elements/2+1):size(idct_matrix,1),(block_elements/2+1):size(idct_matrix,2)) = idct_kernel;


    %idct_matrix = idct(eye(block_elements));

    theta = phi * idct_matrix; 

    recon_g_col = zeros(block_elements, length_col);
    recon_nir_g_col = zeros(block_elements, length_col);


    for i = 1:length_col
        %y_g(i * 2 - 1) = combined_col(1,i);
     %   y_b(i) = combined_col(2,i);
     %   y_r(i) = combined_col(3,i);
        %y_g(i * 2) = combined_col(4,i);
        cnt = 1;
        for j = 1:block_size
            for k = 1:block_size
                if (mod(k,2) == 1 && mod(j,2) == 1) || (mod(k,2) == 0 && mod(j,2) == 0)
                    y_g(cnt) = combined_col((j-1)*block_size + k,i); 
                    cnt = cnt + 1;
                end

            end
        end
        %temporary test
       % y_g = (phi_alpha * double(temp_y_g)) + (phi_beta * double(temp_y_nir));

        %  y_g(j) = combined_col(j,i);
         % y_g(j+1) = combined_col(j + 3,i);
        %end
        x_g = SL0(theta, y_g, sigma_min);

        x_g = idct_matrix * x_g;



        cnt = 1;
        for j = 1:block_size
            for k = 1:block_size
                if (mod(k,2) == 1 && mod(j,2) == 1) || (mod(k,2) == 0 && mod(j,2) == 0)
                    recon_g_col((j-1)*block_size + k,i) = x_g(cnt);
                    recon_nir_g_col((j-1)*block_size + k,i) = x_g((block_elements/2) + cnt);
                    cnt = cnt + 1;
                end

            end
        end


      %  recon_g_col(1,i) = x_g(1);
      %  recon_g_col(4,i) = x_g(2);

      %  recon_nir_g_col(1,i) = x_g(3);
      %  recon_nir_g_col(4,i) = x_g(4);
    end


    recon_g = col2im(recon_g_col, [block_size block_size], [crop_img_width crop_img_height], 'distinct')';
    recon_nir_g =  col2im(recon_nir_g_col, [block_size block_size], [crop_img_width crop_img_height], 'distinct')';
    %figure, imshow(uint8(recon_g));
    
    
    
    
    separated_g = interpolation_LT_RB(recon_g);
    %figure, imshow(uint8(separated_g));
    separated_nir = interpolation_LT_RB(recon_nir_g);
    separated_r = interpolation_LB(combined - (beta4.*separated_nir));
    separated_b = interpolation_RT(combined - (beta3.*separated_nir));

    
    
    separated_rgb(:,:,1) = separated_r .* (1/alpha4);
    separated_rgb(:,:,2) = separated_g;
    separated_rgb(:,:,3) = separated_b .* (1/alpha3);



end