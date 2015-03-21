%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Returns the range of for tracklet in a given camera view
%   @param dataPath     - location to data mats
%   @param cameraId     -  camera Id
%   @param trackletId   - tracklet Id
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function range = getIndexFromCameraAndTrackletId(cameraId, trackletId, trackletList)
    range = [];

    for i = 1 : length(trackletList)  
        if trackletList(i).cameraId == cameraId && trackletList(i).parentTrackId == trackletId
           range = [ range; i]; %#ok<AGROW>
        end
    end
end