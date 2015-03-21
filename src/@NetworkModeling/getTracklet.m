%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method returns a template for the tracklet
%
%   @return - tracklet
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracklet = getTracklet( )

    tracklet.numFrames  = 0;
    
    tracklet.timeStamps = [];
    tracklet.startTime  = 0;
    tracklet.endTime    = 0;
    
    tracklet.frames         = [];
    tracklet.startFrameIndex = 0;
    tracklet.endFrameIndex = 0;
    
    tracklet.cameraId       = 0;
    tracklet.parentTrackId  = 0;
    
    tracklet.boundingBoxes  = []; %[x y w h]
    
    
    tracklet.colorHistogram         = [];
    tracklet.averageColorHistogram  = [];
    
    tracklet.HOOF   = [];
    tracklet.averageHOOF = [];
    
    % Speed and Direction
    tracklet.alpha = [];
    tracklet.theta = [];
    
    tracklet.type = 1; % 1-biker, 2-pedestrian, 3-skate-boarder
    
    tracklet.cooccurringTrackletID = [];
    
    %store salient super pixels and corresponding features
    tracklet.sp.salient = [];
    tracklet.sp.features = [];
    tracklet.sp.imageSegment = [];
    tracklet.sp.selectedFrameIndex = 1;
    
    tracklet.frameImage = [];
    
    % cached appearance, spatial-temporal and scene context
    tracklet.cache.ac  = [];
    tracklet.cache.stc = [];
    tracklet.cache.sc  = [];
end