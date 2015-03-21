%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Display Graph Matching between super pixel segments
%
%   @param superPixelSegment1     - Super Pixel Segments (1)
%   @param superPixelSegment2     - Super Pixel Segments (2)
%   @param X12                    - Super Pixel Associations
%   @param w                      - matching weights
%   @param shouldDisplayMedian    - shouldDisplayMedianMatch
% 
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayGraphMatching(superPixelSegment1, superPixelSegment2, X12, w, shouldDisplayMedian)

    if shouldDisplayMedian
        [~,medianIndexes] = medianWithIndex(w);
        segment1 = medianIndexes;
    else
        segment1 = 1 : size(X12,1);
    end
    clrs = uniqueColors( 10, 10, 0, 1 );
    hFig2 = figure;
    set(hFig2, 'Position', [1 1 1080 960]);
    subtightplot(1, 2, 1, [0.001 0.001], [0.001 0.001], [0.001 0.001]);
    imshow(superPixelSegment1.imageSegment);
    for s = 1 : length( segment1 )
        rectangle('Position', superPixelSegment1.salient(segment1(s)).BoundingBox, 'LineWidth', 3, 'EdgeColor', clrs(s,:) );
    end

    subtightplot(1, 2, 2, [0.001 0.001], [0.001 0.001], [0.001 0.001]);
    imshow(superPixelSegment2.imageSegment);

    for s = 1 : length( segment1 )
        assoIndex = find(X12(segment1(s),:)==1);
        rectangle('Position', superPixelSegment2.salient(assoIndex).BoundingBox, 'LineWidth', 3, 'EdgeColor', clrs(s,:) );
    end
end