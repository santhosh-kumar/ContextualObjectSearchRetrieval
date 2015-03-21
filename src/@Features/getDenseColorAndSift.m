%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes dense color and sift features
%                                                                               
%   Input --   
%       @I                          - Input color image ( can be a vectorized image)
%       @shouldComputeSift          - should compute sift feature
%   Output --
%       @denseFeat                  - Salient superpixel segments

%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%             
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function denseFeat = getDenseColorAndSift( I, shouldComputeSift, shouldMaxPool )

    [h,w,~]     = size(I);
    gridstep    = 1;
    patchsize   = 10;
    nx          = length(patchsize/2:gridstep:w-patchsize/2);
    ny          = length(patchsize/2:gridstep:h-patchsize/2);
    nynx        = ny*nx;
      
    options_color.gridspacing = gridstep;
    options_color.patchsize   = patchsize;
    options_color.scale       = [0.5 , 0.75 , 1];
    options_color.nbins       = 32;
    options_color.sigma       = 0.6;
    options_color.clamp       = 0.2;
    
    options_sift.gridspacing            = gridstep;
    options_sift.patchsize              = patchsize;
    options_sift.color                  = 3;
    options_sift.nori                   = 8;
    options_sift.alpha                  = 9;
    options_sift.nbins                  = 4;
    options_sift.norm                   = 4;
    options_sift.clamp                  = 0.2;
    options_sift.sigma_edge             = 1.2;
    [options_sift.kernely,...
     options_sift.kernelx]              = gen_dgauss(options_sift.sigma_edge);
    
    
    % dense color [nbins=32][nx*ny][nscales=3][ncolor=3]
    dcolor_tmp  = sp_dense_color(I, options_color);
    if shouldComputeSift
        dsift_tmp   = reshape(sp_dense_sift(I, options_sift), 128, nynx, options_sift.color);
    end
    
    if shouldComputeSift
        dfeat       = zeros(options_color.nbins*3*3 + 128*3, nynx);
    else
        dfeat       = zeros(options_color.nbins*3*3, nynx);
    end
    
    for i = 1:nynx
        if shouldComputeSift
            dfeat(:, i) = [reshape(dcolor_tmp(:, i, :, :), [], 1); ...
                reshape(dsift_tmp(:, i, :), [], 1)];
        else
            dfeat(:, i) = [reshape(dcolor_tmp(:, i, :, :), [], 1)];
        end
    end
    
    if shouldMaxPool
        denseFeat = max(dfeat', [], 1);
    else 
        denseFeat = mean(dfeat',1); %max(dfeat', [], 1);
    end
end