%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method returns a template for the tracklet
%
%   @param tracklet             - tracklet of interest
%   @param cooccurringTracklets - co-occurring tracklets
%
%   @return mu        - mean of difference matrix
%   @return sigma     - co-variance of difference matrix
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mu, sigma] = estimateGaussianParameters( tracklet,...
                                                   cooccurringTracklets )

    assert( ~isempty(tracklet) );
    assert( ~isempty(cooccurringTracklets) );

    % initialize feature difference matrix
    featureDifferenceMatrix = [];
    
    % get the tracklet color histogram
    trackletColorHistogram = tracklet.colorHistogram;
    
    % assert number of histograms == size of temporal window
    assert( size(trackletColorHistogram, 1) == tracklet.numFrames );
    
    % iterate over co-occurring tracklet
    for n = 1 : length( cooccurringTracklets )
        % get the nth cooccurring tracklet
        cooccurringTracklet = cooccurringTracklets(n);
        
        % iterate over tracklet frames
        for f = 1 : min(tracklet.numFrames, Context.MAX_FRAMES_CONTEXT_COMPARISON)
            featureDiff = cooccurringTracklet.colorHistogram ...
                - repmat( trackletColorHistogram(f,:), size(cooccurringTracklet.colorHistogram,1), 1 );
            featureDifferenceMatrix = [featureDifferenceMatrix; abs(featureDiff)]; %#ok<AGROW>
        end
    end

    % Estimate mean and sigma
    mu      =  mean( featureDifferenceMatrix );
    sigma   = diag( max(var( featureDifferenceMatrix ),1)' );
end