clear all;
close all;
clc;

%%  setup
addpath( '../src' );
setup

%% define variables
colorFilesPath      = '../data/viper1/color';
colorDriftSavePath  = '../data/viper1/mats';
cameraList          = {'cam_a', 'cam_b'};
cameraIndexList     = [ 1, 2 ];
colorMatrixSuffix   = '_DSC';

%% Compute color drift matrix
colorDriftMatrix = cell( length(cameraIndexList) );
for c1 = 1 : length(cameraIndexList)
    
    % load the color mat
    colorMat1 = load( fullfile( colorFilesPath, [cameraList{c1} colorMatrixSuffix] ) );
    
    
    for c2 = 1  : length(cameraIndexList)
        if c1 ~= c2
            % load the color mat
            colorMat2 = load( fullfile( colorFilesPath, [cameraList{c2} colorMatrixSuffix] ) );
            
            cdMat = [];
            
            for i = 1 : size(colorMat1.colorMat, 1)
                objectId1     = colorMat1.colorMat(i,6);
                matchingIndex = find(colorMat2.colorMat(:,6) == objectId1);
                
                if ~isempty(matchingIndex)
                    cdMat = [cdMat;...
                             colorMat1.colorMat(i,8:295) ./ sum(colorMat1.colorMat(i,8:295)) colorMat2.colorMat(matchingIndex, 8:295)./ sum(colorMat2.colorMat(matchingIndex, 8:295));...
                             colorMat1.colorMat(i,296:end) ./ sum(colorMat1.colorMat(i,296:end)) colorMat2.colorMat(matchingIndex, 296:end)./ sum(colorMat2.colorMat(matchingIndex, 296:end))];
                end
            end

            colorDriftMatrix{c1,c2} = cdMat;
        end
    end
end

% save the cd mat
save( fullfile( colorDriftSavePath, 'colorDriftMatrix' ), 'colorDriftMatrix', '-v7.3'  );