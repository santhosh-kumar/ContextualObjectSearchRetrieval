%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Displays retrieved results
%   @param trackletList     - list of tracklets
%   @param rankIndex        - ranked indexes
%   @param rankIndexLabels  - labels of the ranked indices
%   @param trackletImgsPath - path to tracklet images
%   @param queryIndexes     - query indexes
%   @param countDisplay     - number of ranked items to display
%   @param camIDNameMap     - map of index and camera id
%   @param shouldOrderByTime - should order by time
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayRetrievedResults( trackletList, rankIndex, rankIndexLabels, trackletImgsPath, queryIndexes, countDisplay, camIDNameMap, shouldOrderByTime )
    hFig1 = figure;
    set(hFig1, 'Position', [1090 1 640 480])
    for i = 1 : length(queryIndexes)
        subtightplot(1, length(queryIndexes), i, [0.01 0.01], [0.01 0.01], [0.01 0.01]);
        imshow( fullfile( trackletImgsPath, [ num2str(queryIndexes(i)) '.jpg'] ) );
        bb = trackletList(queryIndexes(i)).sp.bb;
        rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [0 0 1] );
        
        hnd1=text(10,30, ['Cam ID:' num2str(trackletList(queryIndexes(i)).cameraId)]);
        set(hnd1,'FontSize',20,'FontWeight','bold', 'Color', [1 1 1]);
        
        hnd2=text(400,30, ['Obj ID:' num2str(trackletList(queryIndexes(i)).parentTrackId)]);
        set(hnd2,'FontSize',20,'FontWeight','bold', 'Color', [1 1 1]);

        hnd3=text(10,440, ['ts:' num2str(trackletList(queryIndexes(i)).startTime) '(s)']);
        set(hnd3,'FontSize',20,'FontWeight','bold', 'Color', [1 0 0]);
    end
    
    numItems = min(countDisplay, length(rankIndex));
    itemOrder = [1:numItems];
    if shouldOrderByTime
        spInfo = [trackletList(rankIndex(1:numItems)).sp];
        ts = [spInfo.ts]';
        [~,itemOrder] = sort(ts);
    end

    hFig2 = figure;
    set(hFig2, 'Position', [1 1 1080 960])
    m = floor(sqrt(countDisplay));
    for i = 1 : min(m^2, length( rankIndex ))
        im = imread( fullfile( trackletImgsPath, [ num2str(rankIndex(itemOrder(i))) '.jpg'] ) );
        [imHeight, imWidth, ~] = size(im);
        subtightplot(m, m, i, [0.001 0.001], [0.001 0.001], [0.001 0.001]);
        imshow(im);
        [ posD, wD, hD ] = NetworkModeling.getValidBoundingBox( trackletList(rankIndex(itemOrder(i))).sp.bb, imWidth, imHeight );
        bb = [posD wD hD];

        if rankIndexLabels(itemOrder(i)) == 1
            rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [0 1 0] );
        elseif length( find( queryIndexes == rankIndex(itemOrder(i)) ) ) > 0
            rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [0 0 1] );
        elseif rankIndexLabels(itemOrder(i)) == 2
            rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [1 1 0] );
        elseif rankIndexLabels(itemOrder(i)) == 3
            rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [0 1 1] );
        else
            rectangle('Position', bb, 'LineWidth', 2, 'EdgeColor', [1 0 0] );
        end
        
        hnd1=text(10,30, ['Cam ID:' camIDNameMap(trackletList(rankIndex(itemOrder(i))).cameraId)]);
        set(hnd1,'FontSize',24,'FontWeight','bold', 'Color', [1 1 1]);
        
        hnd2=text(400,30, ['Obj ID:' num2str(trackletList(rankIndex(itemOrder(i))).parentTrackId)]);
        set(hnd2,'FontSize',24,'FontWeight','bold', 'Color', [1 1 1]);

        if ~isempty(trackletList(rankIndex(itemOrder(i))).startTime)
            hnd3=text(10,440, ['ts: ' num2str(trackletList(rankIndex(itemOrder(i))).startTime) '(s)']);
            set(hnd3,'FontSize',24,'FontWeight','bold', 'Color', [1 1 1]);
        end
        
        hnd4=text(400,440, ['rank:' num2str(find(rankIndex==rankIndex(itemOrder(i))))]);
        set(hnd4,'FontSize',24,'FontWeight','bold', 'Color', [1 1 1]);
    end
end