%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for various contexts
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Context < handle
    properties(Constant)
        TAU2_SECONDS = 300;
        
        SCENE_CONTEXT_AR_THRESHOLD        = 0.5;
        SCENE_CONTEXT_SPEED_THRESHOLD     = 1;
        SCENE_NUMBER_ATTRIBUTES_G         = 4;
        SHOULD_DISPLAY_GRAPH_MATCHING     = 0;
        SHOULD_DISPLAY_MEDIAN_MATCHING    = 0;
        MAX_FRAMES_CONTEXT_COMPARISON     = 10;
    end%constant properties
    
    methods(Static, Access = public)
        % get appearance context weight
        w = getApperanceContextWeight(trackletList, i, j);
        
        % get spatial-temporal context weight
        w = getSpatialTemporalContextWeight(trackletList, i, j);
        
        % get scene context weight
        w = getSceneContextWeight(trackletList, i, j);
        
        % get clothing context weight
        [wAvg, wMax, wMedian, wMatch] = getClothingContextWeight(trackletList, colorDriftModel, i, j);
    end
    
     methods(Static, Access = public)
        % estimate gaussian distribution parameters for appearance context
        [mu, sigma] = estimateGaussianParameters( tracklet1, cooccurringTracklets );
        
        % encode spatial temporal context for co-occurring objects
        stc = encodeSpatialTemporalContext(tracklet, cooccurringTracklets);
        
        % encode scene context
        sc = encodeSceneContext(tracklet);
        
        % get graph matching score
        gmScore = getGraphMatchingScore( );
    end
end%classdef