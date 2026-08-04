function output_cmyg = convert_rgb_to_cmyg(input_rgb, input_nir)

    resolution = size(input_rgb);
    %cmyg_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];
    gamma = [0.8337 0.9833 0.8296 1.0000];
    cmygp_rgbn = [-0.0566 0.3293 0.2021 gamma(1); 0.1235 0.1361 0.1358 gamma(2); 0.0943 0.3851 0.0415 gamma(3); -0.0342 0.3475 0.0848 gamma(4)];
    output_cmyg = double(zeros(resolution(1), resolution(2),4));
    
  %  input_rgb = imnoise(input_rgb);
  %  input_nir = imnoise(input_nir);
    
   % cmyg_rgb = normc(cmyg_rgb);
    
    
    for i = 1:resolution(1)
        for j = 1:resolution(2)
            output_cmyg(i, j, :) = cmygp_rgbn * [input_rgb(i,j,1); input_rgb(i,j,2);input_rgb(i,j,3); input_nir(i,j)] + normrnd(0, 5);
        end
    end

    
end