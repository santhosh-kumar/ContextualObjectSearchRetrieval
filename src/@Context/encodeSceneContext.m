%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method encodes the scene context for the given tracklet
%
%   @param tracklet - tracklet of interest
%
%   @return sc      - scene context
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sc = encodeSceneContext(tracklet)
    assert( ~isempty(tracklet) );
        
    % assign the list size
    sc = cell(1,Context.SCENE_NUMBER_ATTRIBUTES_G);
    
    % speed based scene context
    averageHOOF = tracklet.averageHOOF;
    [maxSpeed,maxIndex] = max(averageHOOF);
    
    sc{1} = [ maxSpeed >= Context.SCENE_CONTEXT_SPEED_THRESHOLD...
              maxSpeed < Context.SCENE_CONTEXT_SPEED_THRESHOLD];
    
    % aspect ratio
    averageBoundingBox = mean(tracklet.boundingBoxes,1);
    sc{2} = [ averageBoundingBox(3)./averageBoundingBox(4) >= Context.SCENE_CONTEXT_AR_THRESHOLD...
              averageBoundingBox(3)./averageBoundingBox(4) <= Context.SCENE_CONTEXT_AR_THRESHOLD];
    
    % object type
    sc{3} = [0 0 0];
    sc{3}(tracklet.type) = 1;
    
    % direction of motion
    sc{4} = zeros( 1, length(averageHOOF) );
    sc{4}(maxIndex) = 1;
    
    assert( length(sc{4}) ==  length(averageHOOF));
end