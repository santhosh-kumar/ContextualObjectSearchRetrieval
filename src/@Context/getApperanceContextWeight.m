%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get appearance context weight
%
%   @param trackletList - tracklet of interest
%   @param i - ith tracklet of interest
%   @param j - jth tracklet of interest
%
%   @return - w
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = getApperanceContextWeight( trackletList,...
                                        i,...
                                        j)
    assert ( nargin ==  3 );
    assert ( length( trackletList) >= i && length(trackletList) >= j );
    
    % get the first tracklet
    tracklet1 = trackletList(i);
    
    % get the second tracklet
    tracklet2 = trackletList(j);
    
    
    % if the tracklets are from different cameras
    if tracklet1.cameraId ~= tracklet2.cameraId
        
        % get the average color histogram
        averageHist1 = tracklet1.averageColorHistogram;
        if sum(averageHist1) > 0
            averageHist1 = averageHist1 ./ sum(averageHist1);
        end
        
        averageHist2 = tracklet2.averageColorHistogram;
        if sum(averageHist2)
            averageHist2 = averageHist2 ./ sum(averageHist2);
        end
        
        % get the co-occurring tracking ids
        cooccurringTrackletId1 = tracklet1.cooccurringTrackletID;
        cooccurringTrackletId2 = tracklet2.cooccurringTrackletID;

        
        if isempty(cooccurringTrackletId1) || isempty(cooccurringTrackletId2 )
            % use bhattacharya distance for appearance weighting
            w =  sum ( (averageHist1 .* averageHist2).^(1/2) );
        else
            % estimate the feature difference distribution parameter for
            % the first tracklet
            cooccurringTracklets1 = [];
            for k = 1 : length(cooccurringTrackletId1)
                cooccurringTracklets1 = [ cooccurringTracklets1 trackletList(cooccurringTrackletId1(k))]; %#ok<AGROW>
            end
            [mu1, sigma1] = Context.estimateGaussianParameters( tracklet1, cooccurringTracklets1 );
            
            % estimate the feature difference distribution parameter for
            % the second tracklet
            cooccurringTracklets2 = [];
            for k = 1 : length(cooccurringTrackletId2)
                cooccurringTracklets2 = [ cooccurringTracklets2 trackletList(cooccurringTrackletId2(k))]; %#ok<AGROW>
            end
            [mu2, sigma2] = Context.estimateGaussianParameters( tracklet2, cooccurringTracklets2 );
            
            % calculate multi-variate Bhattacharya distance
            sigma = (sigma1 + sigma2) ./ 2;
            sigmaInv = diag(1./diag(sigma));
            w1 = (1/8) .* ( mu1-mu2) * sparse(sigmaInv) * (mu1-mu2)' + (1/2) .* log( prod(diag(sigma)) ./ sqrt( prod(diag(sigma1)) * prod(diag(sigma2)) ) );
            
            % calculate bhattacharya distance for the average color
            % histograms
            w2 = sum ( (averageHist1 .* averageHist2).^(1/2) );
            
            w = (w1 + w2) ./ 2;
        end        
    else
        error( 'Appearance context is not valid within the camera' );
    end
end