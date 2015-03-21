%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method encodes the spatial temporal context for the given tracklet
%   with respect to other co-occurring tracklets
%
%   @param tracklet             - tracklet of interest
%   @param cooccurringTracklets - co-occurring tracklets
%
%   @return stc - spatial temporal context
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STC = encodeSpatialTemporalContext(tracklet, cooccurringTracklets)
    assert( ~isempty(tracklet) );
    assert( ~isempty(cooccurringTracklets) );
    
    boundingBoxes = tracklet.boundingBoxes;
    
    % assert number of bounding boxes == size of temporal window
    assert( size(boundingBoxes, 1) == tracklet.numFrames );
    
    stc = zeros(length(cooccurringTracklets ), 3);
    % iterate over co-occurring tracklet
    for n = 1 : length( cooccurringTracklets )
        % get the nth cooccurring tracklet
        cooccurringTracklet = cooccurringTracklets(n);
        cooccurringBoundingBoxes = cooccurringTracklet.boundingBoxes;
        
        assert( ~isempty( cooccurringBoundingBoxes ) );
        
        prevDist = dist( [ boundingBoxes(1,1) + boundingBoxes(1,3)/2 boundingBoxes(1,2) + boundingBoxes(1,4)/2 ],...
                      [ cooccurringBoundingBoxes(1,1) + cooccurringBoundingBoxes(1,3)/2 cooccurringBoundingBoxes(1,2) + cooccurringBoundingBoxes(1,4)/2 ]');
                  
        for f = 2 : min( tracklet.numFrames, cooccurringTracklet.numFrames )
            curDist = dist( [ boundingBoxes(f,1) + boundingBoxes(f,3)/2 boundingBoxes(f,2) + boundingBoxes(f,4)/2 ],...
                      [ cooccurringBoundingBoxes(f,1) + cooccurringBoundingBoxes(f,3)/2 cooccurringBoundingBoxes(f,2) + cooccurringBoundingBoxes(f,4)/2 ]');
                  
            if curDist < prevDist
                stc( n, 1 ) = stc( n, 1 ) + 1;
            elseif curDist == prevDist
                stc( n, 2 ) = stc( n, 2 ) + 1;
            else
                stc( n, 3 ) = stc( n, 3 ) + 1;
            end
            
            prevDist = curDist;
        end
        
        stc(n,:) = stc(n,:) ./ (min( tracklet.numFrames, cooccurringTracklet.numFrames )-1);
    end
    
    STC = mean(stc,1);
    
    % normalize the values
    STC = STC ./ sum(STC);
end