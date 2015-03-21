clear all;
close all;
clc;

%% setup 
addpath('../src/');
setup;

%% define variables
groundTruthPath     = '../data/TestVideos/trajectory-1/gt';
saveColorPath       = '../data/TestVideos/trajectory-1/color';
videoPath           = '../data/TestVideos/trajectory-1/videos';
cameraList          = { '07_1', '08_1', '09_1', '32_1', '33_1', '34_1', '35_1', '37_1', '39_1', '44_1'};
cameraIndexList     = [ 7, 8, 9, 32, 33, 34, 35, 37, 39, 44 ];
isPartBased         = 1;
fileNameSuffix      = '_DSC';

%% process individual camera objects
if isPartBased
    numberOfColorBins   = 576;
else
    numberOfColorBins   = 288;
end

for c = 2 : length(cameraIndexList)
    fprintf( 'Processing camera %s \n', cameraList{c} );
    
    gt = importdata( fullfile(groundTruthPath, [ cameraList{c} '.gt2']) );
    
    Nr = size(gt,1);
    
    colorMat = zeros(Nr, size(gt,2)+numberOfColorBins);
    colorMat( 1:Nr, 1:size(gt,2)) = gt;
   
    videoObj = VideoReader(fullfile(videoPath,[ cameraList{c} '.avi']));
    
    for r = 1 : Nr
        if gt(r,1) > 0
            frameImage = hist_eq(read(videoObj,gt(r,1)));
            center = gt(r,2:3);
            w = gt(r,4);
            h = gt(r,5);

            bb = int16( [ center(1)-w/2 center(2)-h/2 w h] );

            imagePatch = frameImage( double( max(bb(2),1) : min(bb(2) + h, size(frameImage,1))),...
                                     double(max(bb(1),1) : min(bb(1) + w, size(frameImage,2))),...
                                     : );
            
            if isPartBased
                imH = size(imagePatch, 1);
                torsoPatch  = imagePatch( int16((1/8)*bb(4)) : min(imH,int16((1/2)*bb(4))), :, : );
                legsPatch   = imagePatch( min(imH,int16((1/2)*bb(4) )) : end, :, : );

                if min( size(torsoPatch,1), size(torsoPatch,2)  ) > 10
                    torsoCCHist  = Features.getDenseColorAndSift( torsoPatch, 0, 0 );
                else
                    torsoCCHist = zeros(1, numberOfColorBins/2);
                end
                
                if min( size(legsPatch,1), size(legsPatch,2)  ) > 10
                	legsCCHist  = Features.getDenseColorAndSift( legsPatch, 0, 0 );
                else
                    legsCCHist = zeros(1, numberOfColorBins/2);
                end

                colorMat( r, 7+1 : 7+numberOfColorBins/2 )   = torsoCCHist;
                colorMat( r, 7+numberOfColorBins/2+1 : end)  = legsCCHist;
            else
                ccHist = Features.getDenseColorAndSift( imagePatch, 0, 0 );
                colorMat( r, size(gt,2)+1 : end ) = ccHist;
            end
        else
            ccHist =   zeros(1, numberOfColorBins);
            colorMat( r, 7+1 : end ) = ccHist;
        end
    end
    
    %save the color mat
    save( [fullfile( saveColorPath, cameraList{c} ) fileNameSuffix], 'colorMat' );
end