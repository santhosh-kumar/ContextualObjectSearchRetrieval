%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get clothing context weight
%
%   @param trackletList     - tracklet of interest
%   @param colorDriftModel  - Color Drift Model
%   @param i                - ith tracklet of interest
%   @param j                - jth tracklet of interest
%
%   @return - wAvg, wMax, wMatch
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wAvg, wMax, wMedian, wMatch] = getClothingContextWeight( trackletList,...
                                                           colorDriftModel,...
                                                           i,...
                                                           j)
                                   
    try
        assert ( nargin ==  4 );
        assert ( length( trackletList) >= i && length(trackletList) >= j );

        % get the first tracklet
        tracklet1 = trackletList(i);

        % get the second tracklet
        tracklet2 = trackletList(j);
        
        % if the tracklets are from different cameras
        if tracklet1.cameraId ~= tracklet2.cameraId
            % get color drift model
            cdm = colorDriftModel.getColorDriftModel(tracklet1.cameraId, tracklet2.cameraId);
            assert( ~isempty( cdm ) );

            A1 = GraphMatching.findAttributeMatrix(tracklet1.sp.salient, 1, tracklet1.sp.features);
            A2 = GraphMatching.findAttributeMatrix(tracklet2.sp.salient, 1, tracklet2.sp.features);
            
            if length(A1) > 1 && length(A2) > 1
                [ X12, ~, W, ~ ] = GraphMatching.balancedGraphMatching( A1, A2, cdm );
                X = X12(:);
                wMatch = (X' * W * X) ./ ( X'*X);
                w = [];
                for i = 1 : length(A1)
                    j = find(X12(i,:)==1);
                    if ~isempty(j)
                        f1 = A1{i};
                        f2 = A2{j};

                        h1 = f1(4:end) ./ sum( f1(4:end) );
                        h2 = f2(4:end) ./ sum( f2(4:end) );
                        z  = [h1 h2];
                        histProb = GraphMatching.compareHistograms(h1, h2).* ColorDrift.evaluateDensity(z, cdm);
                        w = [w; histProb];
                    end
                end
                wAvg    = mean(w);
                wMax    = max(w);
                wMedian = median(w);
                
%                 if Context.SHOULD_DISPLAY_GRAPH_MATCHING
%                     GraphMatching.displayGraphMatching(tracklet1.sp, tracklet2.sp, X12, [], 0);
%                 end
%                 
%                 if Context.SHOULD_DISPLAY_MEDIAN_MATCHING
%                    GraphMatching.displayGraphMatching(tracklet1.sp, tracklet2.sp, X12, w, 1);
%                 end
            else
                wAvg    = 0;
                wMax    = 0;
                wMedian = 0;
                wMatch  = 0;
            end
        else
            error( 'Appearance context is not valid within the camera' );
        end
    catch ex
        wAvg    = 0;
        wMax    = 0;
        wMedian = 0;
        wMatch  = 0;
        fprintf( ['\n Failed to compute clothing context weight tracklets i=' num2str(i) ' and j=' num2str(j) ' , ex:' ex.message ] );        
    end
end