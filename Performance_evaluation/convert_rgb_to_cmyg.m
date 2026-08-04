function output_cmyg = convert_rgb_to_cmyg(input_rgb)

    resolution = size(input_rgb);
    cmyg_rgb = [-0.0566 0.3293 0.2021; 0.1235 0.1361 0.1358; 0.0943 0.3851 0.0415; -0.0342 0.3475 0.0848];
    
    output_cmyg = double(zeros(resolution(1), resolution(2),4));
    
   % cmyg_rgb = normc(cmyg_rgb);
    
    
    for i = 1:resolution(1)
        for j = 1:resolution(2)
            output_cmyg(i, j, :) = cmyg_rgb * [input_rgb(i,j,1); input_rgb(i,j,2);input_rgb(i,j,3)];
        end
    end


end