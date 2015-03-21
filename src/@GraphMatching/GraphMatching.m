%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for different graph matching
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GraphMatching < handle
    properties(Constant)
        HISTOGRAM_COMPARISION_METHOD = 'histint'; % 'histint'
    end%constant properties

    methods(Static, Access = public) 
        % match graphs using balanced graphmatching technique
        [ X12, X_SMAC, W, timing ] = balancedGraphMatching( A1, A2, cdm );
        
        % compute attribute matrix for matching graphs
        A = findAttributeMatrix( superPixelBB,...
                                 th,...
                                 superPixelFeatures )
         
        % display results of super pixels matching
        displayGraphMatching(superPixelSegment1, superPixelSegment2, X12, w, shouldDisplayMedian);
        
        % compare two histograms
        function prob = compareHistograms(h1, h2)
           h1 = h1 ./ sum(h1);
           h2 = h2 ./ sum(h2);
           
           if strcmp(GraphMatching.HISTOGRAM_COMPARISION_METHOD, 'histint')
               prob = sum(min(h1,h2));
           elseif strcmp(GraphMatching.HISTOGRAM_COMPARISION_METHOD, 'none')
               prob = 1;
           else
               error( 'Unsupported Histogram Comparison' );
           end
        end
        
        % compare two difference histograms
        function prob = compareDifferenceHistograms(dh1, dh2)
           D = length(dh1);
           prob = (1/D) .* sum(max( (dh1 == dh2), min(dh1,dh2) ./ max(dh1,dh2)));
        end
        
    end%static methods
end%classdef