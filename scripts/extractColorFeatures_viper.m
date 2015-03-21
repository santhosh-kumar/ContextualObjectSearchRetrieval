clear all;
close all;
clc;

%% setup 
addpath('../src/');
setup;

%% define variables
saveColorPath       = '../data/viper/color';
imgsPath            = '../data/viper/imgs';
cameraList          = { 'cam_a', 'cam_b'};
cameraIndexList     = [ 1, 2 ];
isPartBased         = 1;
fileNameSuffix      = '_DSC';
partitionsFilePath  = '../libs/salience_reid-master/mat/partition_viper';
partitionIndex      = 1;

%% process individual camera objects
if isPartBased
    numberOfColorBins   = 576; %11 for torso and 11 for legs
else
    numberOfColorBins   = 288;
end

if partitionIndex ~= 0 
    load(partitionsFilePath);
    trnSet = partition(partitionIndex).trnSet;
else
    range = [317:632] *2;
    trnSet = [range'-1 range'];
end

for c = 1 : length(cameraIndexList)
    fprintf( 'Processing camera %s \n', cameraList{c} );

    imgs        = dir( fullfile( imgsPath, cameraList{c}, '*.bmp' ) )';

    Nr          = size(trnSet,1);
    colorMat    = zeros(Nr, 7+numberOfColorBins);
    index       = 1;
    
    for i = 1 : Nr
        frameImage = hist_eq(imread( fullfile( imgsPath, cameraList{c}, imgs(ceil(trnSet(i,c)/2)).name) ));
        
        [imHeight, imWidth, ~] = size(frameImage);
        bb = [8 5 imWidth-16 imHeight-10];
        xCenter = bb(1) + bb(3)/2;
        yCenter = bb(2) + bb(4)/2;
        
        colorMat(index,1)   = 1;                             %frame number
        colorMat(index,2:5) = [xCenter yCenter bb(3) bb(4)]; %bounding box
        colorMat(index,6)   = str2num(imgs(i).name(1:3));    %object Id
        colorMat(index,7)   = 0;                             %timestamp
        imagePatch = frameImage(max(1,bb(2)) : min(bb(2)+bb(4), imHeight), max(1,bb(1)) : min(bb(1)+bb(3),imWidth), :);
        
        if isPartBased
            imH = size(imagePatch, 1);
            torsoPatch  = imagePatch( int16((2/8)*bb(4)) : min(imH,int16((1/2)*bb(4))), :, : );
            legsPatch   = imagePatch( min(imH,int16((1/2)*bb(4) )) : end, :, : );

            torsoCCHist = Features.getDenseColorAndSift( torsoPatch, 0, 0 );
            legsCCHist  = Features.getDenseColorAndSift( legsPatch, 0, 0 );

            colorMat( index, 7+1 : 7+numberOfColorBins/2 )   = torsoCCHist;
            colorMat( index, 7+numberOfColorBins/2+1 : end)  = legsCCHist;
        else
            ccHist =   Features.getDenseColorAndSift( imagePatch, 0, 0 );
            colorMat( index, 7+1 : end ) = ccHist;
        end
        index = index + 1;
    end
    
    %save the color mat
    save( [fullfile( saveColorPath, cameraList{c} ) fileNameSuffix], 'colorMat' );
end