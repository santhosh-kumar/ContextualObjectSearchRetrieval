%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get scene context weight
%
%   @param trackletList - tracklet of interest
%   @param i            - ith tracklet of interest
%   @param j            - jth tracklet of interest
%
%   @return  - w
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = getSceneContextWeight(trackletList, i, j)
    assert ( nargin ==  3 );
    assert ( length( trackletList) >= i && length(trackletList) >= j );
    
    % get the first tracklet
    tracklet1 = trackletList(i);
    
    % get the second tracklet
    tracklet2 = trackletList(j);
    
    % encode the scene context for tracklets
    sc1 = Context.encodeSceneContext( tracklet1 );
    sc2 = Context.encodeSceneContext( tracklet2 );
    
    % compute scene context weight
    w = 0;
    for g = 1 : Context.SCENE_NUMBER_ATTRIBUTES_G
        assert( length(sc1{g}) == length(sc2{g}) );
        
        ng = length(sc1{g});
        w = w + sum(sc1{g} == sc2{g}) ./ ng;
    end
    
    % normalize the weight
    w = w ./ Context.SCENE_NUMBER_ATTRIBUTES_G;
end