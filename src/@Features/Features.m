%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for various contexts
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Features < handle
    properties(Constant)        
    end%constant properties
    
    methods(Static, Access = public)
        % build kernel for the specified width and height
        kernel = buildKernel( wd, ht );
        
        % build histogram
        p = buildHist( Qc, kernel, nBit )
        
        % crop window
        [Ic,Qc] = cropWindow( I, nBit, pos, wd, ht );
        
        % compute culture color histogram
        [ccHist] = getCultureColorHistogram(imagePatch, convertHsv);
        
        % Local Binary Patter
        lbpDescriptor = getLBP( varargin );
        
        % Discriminative Color Feature
        descColorDescriptor = getDiscriminativeColorDescriptor( imagePatch );
        
        % dense color and sift based features
        denseFeat = getDenseColorAndSift( imagePatch, shouldComputeSift, shouldUseMaxPooling );
        
        % multi-dimensional color histogram
        multiDimensionalColorHistogram ...
                    = getMultiDimensionalColorHistogram( I,...
                                                        isVectorized,...
                                                        numberOfBins,...
                                                        imageROI );
                                                    
        % get salient superpixel segments from median distance
        [superPixelSegments, superPixelfeatures] = getSalientSuperpixels(inImage,...
                                                                          shouldUseLBP,...
                                                                          numberSalientIndexes,...
                                                                          maxSize,...
                                                                          regularizer,...
                                                                          shouldDisplay);
                                                                      
    end
end%classdef