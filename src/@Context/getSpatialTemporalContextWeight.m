%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get spatial-temporal context weight
%
%   @param trackletList - tracklet of interest
%   @param i            - ith tracklet of interest
%   @param j            - jth tracklet of interest
%
%   @return  - w
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = getSpatialTemporalContextWeight(trackletList, i, j)

    assert ( nargin ==  3 );
    assert ( length( trackletList) >= i && length(trackletList) >= j );
    
    % get the first tracklet
    tracklet1 = trackletList(i);
    
    % get the second tracklet
    tracklet2 = trackletList(j);
    
    % if the tracklets are from different cameras
    if tracklet1.cameraId ~= tracklet2.cameraId
        % get the co-occurring tracking ids
        cooccurringTrackletId1 = tracklet1.cooccurringTrackletID;
        cooccurringTrackletId2 = tracklet2.cooccurringTrackletID;
        
        if abs( tracklet1.startTime - tracklet2.startTime ) > Context.TAU2_SECONDS
            w = 0;
        elseif isempty(cooccurringTrackletId1) || isempty(cooccurringTrackletId2)
            w = 0;
        else
            cooccurringTracklets1 = [];
            for k = 1 : length(cooccurringTrackletId1)
                cooccurringTracklets1 = [ cooccurringTracklets1 trackletList(cooccurringTrackletId1(k))]; %#ok<AGROW>
            end
            
            % encode spatial temporal context based
            stc1 = Context.encodeSpatialTemporalContext(tracklet1, cooccurringTracklets1);
            
            cooccurringTracklets2 = [];
            for k = 1 : length(cooccurringTrackletId2)
                cooccurringTracklets2 = [ cooccurringTracklets2 trackletList(cooccurringTrackletId2(k))]; %#ok<AGROW>
            end
            
            % encode spatial temporal context based
            stc2 = Context.encodeSpatialTemporalContext(tracklet2, cooccurringTracklets2);
            
            w = 1 - pdist3( stc1, stc2, 'emd' );
        end        
    else
        error( 'Spatial-temporal context is not valid within the camera' );
    end
end