%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes salient super pixels and corresponding features
%                                                                               
%   Input --   
%       @inImage                 - Input color image ( can be a vectorized image)
%       @shouldUseLBP            - Should Use LBP computing saliency
%       @numberSalientIndexes    - Number of Salient Super Pixels
%       @maxSize                 - Maximum allowed size for SP segments
%       @regularizer             - SP regularizer parameter
%       @shouldDisplay           - Should Display Super Pixel output
%
%   Output --
%       @superPixelSegments - Salient superpixel segments
%       @spfeatures         - Corresponding Superpixel features
%
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%             
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [superPixelSegments, superPixelfeatures] = getSalientSuperpixels(inImage,...
                                                                          shouldUseLBP,...
                                                                          numberSalientIndexes,...
                                                                          maxSize,...
                                                                          regularizer,...
                                                                          shouldDisplay)
    % convert to single type
    im    = im2single(inImage);
    
    % get super pixel segments using SLIC
    segments = vl_slic(single(im), maxSize, regularizer);
    
    % get number of segments and superpixel bounding boxes and pixels
    numberSegments = max( max(segments) );
    boundingBoxes  = regionprops( segments, 'BoundingBox' );
    pixelIdxList   = regionprops( segments, 'PixelIdxList' );

    [imHeight, imWidth, ~] = size(im);
   
    spFeatures = [];
    for i = 1 : numberSegments
       bb = int16(boundingBoxes(i).BoundingBox);
       imSegment = inImage( max(1,bb(2)) : min(bb(2)+bb(4), imHeight), max(1,bb(1)) : min(bb(1)+bb(3),imWidth), :);
       ccHist = Features.getDenseColorAndSift( imSegment, 0, 0 );
       if shouldUseLBP
           lbp = Features.getLBP(imSegment, 1, 8);
           lbp = lbp ./ sum(lbp);
       else
           lbp = [];
       end
       
       spFeatures = [spFeatures; [ccHist lbp]];
    end

    % compute distance w.r.t  kth super pixel and order by distance
    [~, d] = knnsearch(spFeatures, spFeatures,'k', numberSegments, 'distance','euclidean');
    medianDistanceIndex = floor(median( double(1:numberSegments) ));
    kthDist = d(:, medianDistanceIndex);
    [ ~ , salientIndexes ] = sort( kthDist, 'descend' );
    topIndexes = salientIndexes( 1:min( length(salientIndexes), numberSalientIndexes) );
    
    % store the salient super pixels and corresponding features
    superPixelSegments = boundingBoxes( topIndexes );
    superPixelfeatures = spFeatures( topIndexes, 1:size(ccHist, 2) );
    
    % display the super pixels and saliency
    if shouldDisplay
        [sx,sy] = vl_grad( double(segments), 'type', 'forward' );
        s = find(sx | sy) ;
        
        imp = im ;
        numPoints = size([s s+numel(im(:,:,1)) s+2*numel(im(:,:,1))],1);
        imp([s s+numel(im(:,:,1)) s+2*numel(im(:,:,1))]) = repmat([255 0 0],numPoints,1);
        figure(1);
        imshow(imp);
        
        imp1 = inImage;
        for i = 1 : numberSegments
            if length( (find(topIndexes==i) ) ) > 0
                 imp1( pixelIdxList(i).PixelIdxList ) = uint8(255 * kthDist(i) ./ max(kthDist));
            end
        end

        figure(2);
        imshow(uint8(imp1));
    end
end