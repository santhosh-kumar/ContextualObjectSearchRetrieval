clear all;
close all;
clc;

%% Setup
addpath( '../src' );
setup;

%% Define variables
trackletsSavePath   = '../data/viper/mats';
imgsPath            = '../data/viper/imgs';
frameImageSavepath  = '../data/viper/trackletImgs/';
cameraList          = {'cam_a', 'cam_b'};
cameraIndexList     = [1, 2];
partitionsFilePath  = '../libs/salience_reid-master/mat/partition_viper';
partitionIndex      = 1;

%% generate tracklets
if partitionIndex ~= 0 
    load(partitionsFilePath);
    tstSet = partition(partitionIndex).tstSet;
else
    range = [1:316] *2;
    tstSet = [range'-1 range'];
end

trackletList        = [];
trackletCount       = 0;
for c = 1 : length(cameraIndexList)
    fprintf( 'Processing camera %s \n', cameraList{c} );
    imgs    = dir( fullfile( imgsPath, cameraList{c}, '*.bmp' ) )';
    Nr      = size(tstSet,1);
    objectIdList    = [];
    for i = 1 : length(imgs)
        objectIdList = [objectIdList; str2num(imgs(i).name(1:3))];
    end
    
    for o = 1 : Nr
        % frame counter      
        f = 1;
        
        index = ceil(tstSet(o,c)/2);
        
        % initialize the current tracklet
        tracklet        = NetworkModeling.getTracklet();
        trackletCount   = trackletCount +1;

        % set the camera id
        tracklet.cameraId = cameraIndexList(c);

        % set the track id
        tracklet.parentTrackId = objectIdList(index);         
        
        tracklet.numFrames              = f;
        frameImage                      = hist_eq(imread( fullfile( imgsPath, cameraList{c}, imgs(index).name) ));
        imwrite(frameImage, fullfile(frameImageSavepath, [num2str(trackletCount) '.jpg']), 'JPEG');
        
        [imHeight, imWidth, ~] = size(frameImage);
        bb = [7 5 imWidth-14 imHeight-10];
        tracklet.boundingBoxes          = bb;
        tracklet.colorHistogram         = [];
        inImage                         = frameImage(max(1,bb(2)) : min(bb(2)+bb(4), imHeight), max(1,bb(1)) : min(bb(1)+bb(3),imWidth), :);
        [superPixelSegments, superPixelfeatures] = Features.getSalientSuperpixels( inImage, 0, 10, 20, 0.5, 0 );
                
        tracklet.sp.salient             = superPixelSegments;
        tracklet.sp.features            = superPixelfeatures;
        tracklet.sp.imageSegment        = inImage;
        tracklet.sp.selectedFrameIndex  = f;
        tracklet.sp.bb                  = bb;
        
        tracklet.averageColorHistogram  = [];
        
        trackletList = [trackletList; tracklet];
    end
end

%save the tracklet list
save( fullfile( trackletsSavePath, 'trackletList' ), 'trackletList', '-v7.3' );

%% generate ground truth matrix
W_gt = zeros(length(trackletList), length(trackletList));
for i = 1 : length(trackletList)
    for j = 1 : length(trackletList)
       if i ~= j
           if trackletList(i).cameraId ~=  trackletList(j).cameraId &&...
                   trackletList(i).parentTrackId == trackletList(j).parentTrackId
               W_gt(i,j) = 1;
           end
       end
    end
end

save(fullfile( trackletsSavePath, 'gtWeightMatrix.mat'), 'W_gt', '-v7.3' );