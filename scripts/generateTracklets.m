clear all;
close all;
clc;
%% setup
addpath( '../src' );
setup;

%% define variables
trackletsSavePath   = '../data/TestVideos/trajectory-1/mats';
groundTruthPath     = '../data/TestVideos/trajectory-1/gt';
hoofFilesPath       = '../data/TestVideos/trajectory-1/hoof';
objectTypeFilePath  = '../data/TestVideos/trajectory-1/type';
videoPath           = '../data/TestVideos/trajectory-1/videos';
frameImageSavepath  = '../data/TestVideos/trajectory-1/trackletImgs/';
trackletVidsPath    = '../data/TestVideos/trajectory-1/trackletVids/';
isSuperPixelBased   = 1;
trackletFrameSize   = 60;
cameraList          = { '07_1', '08_1', '09_1', '32_1', '33_1', '34_1', '35_1', '37_1', '39_1', '44_1'};
cameraIndexList     = [ 7, 8, 9, 32, 33, 34, 35, 37, 39, 44 ];

%% generate tracklets
shapeInserter = vision.ShapeInserter;     
release(shapeInserter);
shapeInserter.BorderColor = 'Custom';
shapeInserter.CustomBorderColor = [0 255 0];

trackletList = [];

objectTypes = importdata( fullfile(objectTypeFilePath, 'obj_type.txt') );

trackletCount = 0;

for c = 1 : length(cameraIndexList)
    fprintf( 'Processing camera %s \n', cameraList{c} );  
    gt = importdata( fullfile(groundTruthPath, [ cameraList{c} '.gt2']) );
    
    videoObj = VideoReader(fullfile(videoPath,[ cameraList{c} '.avi']));
        
    Nr = size(gt,1);
    
    % load the hoof mat
    load( fullfile( hoofFilesPath, [ cameraList{c} '_hoof' ] ) );
    
    camObjectTypes = objectTypes( find(objectTypes(:,1) == cameraIndexList(c)) , 2:3 ); %#ok<FNDSB>
    
    objectIdList = unique( gt(:,6) );
    
    prevHoofRecord = [];
    for o = 1 : length(objectIdList)
        objectHoofRecords =  HOOFMat( find( HOOFMat(1:end,3) == objectIdList(o) ), :);%#ok<FNDSB>

        % Frame list of selected object
        objectRecords = gt(find(gt(:,6) == objectIdList(o)),:);
        frameList = objectRecords(:,1);
        
        % Pick a snapshot with a large area to compute superpixel graph
        objectAreas = objectRecords(:,4) .*  objectRecords(:,5);
        [ ~ , areaIndices ] = sort(objectAreas, 'descend');
        
        for r = 1 : length(areaIndices)
            selectedFrameIndex = areaIndices(r);
            hoofRecord = objectHoofRecords(find(objectHoofRecords(:,2) ==  frameList(selectedFrameIndex)), :);
            if ~isempty(hoofRecord)
                break;
            end
        end
        
        % initialize the current tracklet
        tracklet = [];
        F = length(frameList);
        
        for frameIndex = 1 : length(frameList)
            currentFrame = frameList(frameIndex);
            if currentFrame <= 0
                continue;
            end
            frameImage  = read(videoObj, currentFrame);
            
            % create a new tracklet if empty or tracklet size exceeded
            if isempty(tracklet)
                tracklet = NetworkModeling.getTracklet();
                
                trackletCount = trackletCount +1;
                
                % set the camera id
                tracklet.cameraId = cameraIndexList(c);
                
                % set the track id
                tracklet.parentTrackId = objectIdList(o);
                
                % set the object type
                tracklet.type = camObjectTypes(find(camObjectTypes(:,1) == objectIdList(o)), 2); %#ok<FNDSB>
                
                writerObj = VideoWriter(fullfile(trackletVidsPath,[num2str(trackletCount) '.avi'] ));
                writeObj.FrameRate = 20;
                writeObj.Quality = 100;
                open(writerObj);
            end
            
            tracklet.frames = [tracklet.frames objectRecords(frameIndex, 1)];
            tracklet.timeStamps = [tracklet.timeStamps objectRecords(frameIndex, 7)];
           
            % get the object bounding box
            center = objectRecords(frameIndex,2:3);
            w = objectRecords(frameIndex,4);
            h = objectRecords(frameIndex,5);
            bb = int16( [center(1)-w/2 center(2)-h/2 w h] );
            tracklet.boundingBoxes = [ tracklet.boundingBoxes; bb ];
            
            % get the optical flow histogram
            hoofRecord = objectHoofRecords(find(objectHoofRecords(:,2) ==  currentFrame), :);
            
            if ~isempty(hoofRecord)
                tracklet.HOOF = [ tracklet.HOOF; hoofRecord(4:end);];
            elseif isempty(prevHoofRecord)
                hoofRecord    = prevHoofRecord;
                tracklet.HOOF = [ tracklet.HOOF; hoofRecord(4:end);];
            end
            
            % get the complete color histogram
            [imHeight, imWidth, ~] = size(frameImage);
            inImage     = frameImage(max(1,bb(2)) : min(bb(2)+bb(4), imHeight), max(1,bb(1)) : min(bb(1)+bb(3),imWidth), :);
            tracklet.colorHistogram = [tracklet.colorHistogram; Features.getDenseColorAndSift( inImage, 0, 0 ) ];
            
            J=step(shapeInserter, frameImage, bb);
            
            % extract and store salient super pixels
            if frameIndex == selectedFrameIndex
                if isSuperPixelBased
                    [superPixelSegments, superPixelfeatures] = Features.getSalientSuperpixels( inImage, 0, 10, 25, 0.5, 0 );

                    tracklet.sp.salient             = superPixelSegments;
                    tracklet.sp.features            = superPixelfeatures;
                    tracklet.sp.imageSegment        = inImage;
                    tracklet.sp.selectedFrameIndex  = frameIndex;
                    tracklet.sp.ts                  = objectRecords(frameIndex, 7);
                    tracklet.sp.bb                  = bb;
                end
                
                if ~isempty(hoofRecord)
                    [alpha, index] = max(hoofRecord);
                    theta           = 360/16+360/8*(index-1);
                    tracklet.alpha  = alpha;
                    tracklet.theta  = theta;
                else
                    tracklet.alpha  = 0;
                    tracklet.theta  = 0;
                end
                
                imwrite(J, fullfile(frameImageSavepath, [num2str(trackletCount) '.jpg']), 'JPEG');
                %imwrite(J, fullfile(frameImageSavepath, [num2str(tracklet.cameraId) '_'  num2str(tracklet.parentTrackId) '.jpg']), 'JPEG');
            end
            
            writeVideo(writerObj,J); 
          
            prevHoofRecord = hoofRecord;
        end
        
        if ~isempty(tracklet)
            % finalize the tracklet
            if ~isempty(tracklet.HOOF)
                tracklet.averageHOOF = mean(tracklet.HOOF,1);
            else
                tracklet.averageHOOF = zeros(1,8);
            end
            tracklet.numFrames = length(tracklet.frames);
            
            tracklet.averageColorHistogram = mean(tracklet.colorHistogram,1);

            tracklet.startTime = tracklet.timeStamps(1);
            tracklet.endTime = tracklet.timeStamps(end);

            tracklet.startFrameIndex = tracklet.frames(1);
            tracklet.endFrameIndex = tracklet.frames(end);

            assert( tracklet.numFrames <= F );
            trackletList = [trackletList tracklet]; %#ok<AGROW>
                
            close(writerObj);
            
            % reset the tracklet object
            tracklet = [];
        end
    end
end

% Co-Occurring tracklet threshold
TAU1 = 5; %1 second
% find co-occurring tracklets
for t1 = 1 : length(trackletList)
    tracklet1 = trackletList(t1);
    fprintf( 'Processing Tracklet %d \n', t1 ); 
    for t2 = 1 : length(trackletList)      
        if t1 ~= t2
            tracklet2 = trackletList(t2);
            
            if tracklet2.cameraId == tracklet1.cameraId && tracklet1.parentTrackId ~= tracklet2.parentTrackId
                if ( abs(tracklet2.startTime-tracklet1.startTime) <= TAU1 || abs(tracklet2.startTime-tracklet1.endTime) <= TAU1...
                   ||  abs(tracklet2.endTime-tracklet1.endTime) <= TAU1 || abs(tracklet2.endTime-tracklet1.startTime) <= TAU1 )
                    tracklet1.cooccurringTrackletID = [tracklet1.cooccurringTrackletID t2];
                end
            end
            
        end     
    end
    
    trackletList(t1) = tracklet1; %#ok<SAGROW>
end

count = 0;
for i = 1 : length(trackletList)
    if ~isempty(trackletList(i).cooccurringTrackletID)
        count = count+1;
    end
end

assert(count>0);

%save the tracklet list
save( fullfile( trackletsSavePath, 'trackletList' ), 'trackletList', '-v7.3' );

%% generate W_gt from associations for the new set of tracklets
getWFromAssociation;