%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for computing network graph weight
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef NetworkModeling < handle
    % Member properties
    properties
    end
           
    % Constant properties
    properties(Constant)
        WEIGHTMATRIX1 = 'weightMatrixASS.mat';
        WEIGHTMATRIX2 = 'weightMatrixCC.mat';
    end
    
    methods(Static, Access = private)
        % Algorithm 1 
        W = getNetworkGraphWeightWithAppSceneSpatialContext(dataPath, cameraIndexList, shouldUseContext, shouldUseSpatialTemporal, weightMatrixFileName, trackletMatrixFileName);

        % Algorithm 2
        W = getNetworkGraphWeightClothingContext(dataPath, cameraIndexList, shouldUseContext, shouldUseSpatialTemporal, weightMatrixFileName, trackletMatrixFileName);

        % Algorithm 3
        W = getNetworkGraphWeightWithContextualLinks(dataPath, cameraIndexList, shouldUseContext, shouldUseSpatialTemporal, weightMatrixFileName, trackletMatrixFileName);
    end
    
    % Static public methods 
    methods(Static, Access = public)
        % get tracklet template
        tracklet = getTracklet( );
        
        % get tracklet indices from camera and object id
        range = getIndexFromCameraAndTrackletId(cameraId, trackletId, trackletList);
        
        % display results from graph ranking
        displayRetrievedResults( trackletList, rankIndex, rankIndexLabels, trackletImgsPath, queryIndexes, countDisplay, camIDNameMap, shouldOrderByTime );
        
        % get networkweight
        function W = getNetworkWeight(dataPath, cameraIndexList, shouldUseContext, shouldUseSpatialTemporal, type, trackletMatrixFileName)
            switch type
                case 1
                    W = NetworkModeling.getNetworkGraphWeightWithAppSceneSpatialContext(dataPath,...
                                                                                      cameraIndexList,...
                                                                                      shouldUseContext,...
                                                                                      shouldUseSpatialTemporal,...
                                                                                      NetworkModeling.WEIGHTMATRIX1,...
                                                                                      trackletMatrixFileName);
                case 2
                    W = NetworkModeling.getNetworkGraphWeightClothingContext(dataPath,...
                                                                          cameraIndexList,...
                                                                          shouldUseContext,...
                                                                          shouldUseSpatialTemporal,...
                                                                          NetworkModeling.WEIGHTMATRIX2,...
                                                                          trackletMatrixFileName);
                otherwise
                    error('Unknown method for computing network graph weighting');
            end
        end
        
        % getValidBoundingBox
        function [ posD, wD, hD ] = getValidBoundingBox( Bd, imWidth, imHeight )

           if Bd(1) < 1
                dStartX = 1;
            elseif Bd(1) > imWidth
                dStartX = imWidth;
            else
                dStartX = Bd(1);
           end

            if Bd(2) < 1
                dStartY = 1;
            elseif Bd(2) > imHeight
                dStartY = imHeight;
            else
                dStartY = Bd(2);
            end

            
            if ( Bd(1) + Bd(3) ) > imWidth
                wD = max( imWidth -  Bd(1), 0 );
            elseif ( Bd(1)+Bd(3) ) < 1
                wD = 0;
            else
                wD = Bd(3);
            end
            
            if ( Bd(2)+Bd(4) ) > imHeight
                hD = max( imHeight -  Bd(2), 0);
            elseif ( Bd(2) + Bd(4) ) < 1
                hD = 0;
            else
                hD = Bd(4);
            end
                
            posD = uint16( [ dStartX  dStartY ] );

        end
    end
end%classdef