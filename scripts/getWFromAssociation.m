clear all;
close all;
clc;

%% import src path
addpath( '../src' );

%% open the matlab pool
if Constants.MATLAB_POOL_ENABLED
    try
        matlabpool;
    catch ex
        fprintf( 'Pool is already running \n' );
    end
end

%% Compute Association Ground Truth
groundTruthPath = '../data/TestVideos/trajectory-1/gt';
dataPath        = '../data/TestVideos/trajectory-1/mats';

% load the association mat
associationFilePath = '../data/TestVideos/trajectory-1/associations/associations.txt';
cameraObjectAssociations = importdata( associationFilePath );

% initialize the list of cameras under analysis
cameraList = { '07_1', '08_1', '09_1', '32_1', '33_1', '34_1', '35_1', '37_1', '39_1', '44_1'};
cameraIndexList = [ 7, 8, 9, 32, 33, 34, 35, 37, 39, 44 ];
numberObjectsList = [37, 41, 41, 31, 12, 30, 33, 31, 18, 14];

% get the labels of combinations ( cameraId, objectId)
cameraIds = [];
objectIds = [];
for c = 1 : length(cameraIndexList)
    cameraIds = [ cameraIds; repmat( cameraIndexList(c), numberObjectsList(c), 1 ) ]; %#ok<AGROW>
    objectIds = [ objectIds; [1 : numberObjectsList(c)]']; %#ok<NBRAK,AGROW>
end
assert( length( cameraIds ) == length( objectIds ) );

% set the combination labels
camObjLabels = [cameraIds objectIds];

% initialize object association matrix
objectAssociationMat = zeros( length( objectIds ) );

% set object associations from the gt
for o = 1 : length( objectIds )
    objectId = objectIds(o);
    cameraId = cameraIds(o);
    
    i = intersect(find(camObjLabels(:,1) == cameraId), find(camObjLabels(:,2) == objectId));
    
    cameraAssociations = cameraObjectAssociations(find(cameraObjectAssociations(:,1) == cameraId),:); %#ok<FNDSB>
    
    objectAssociations = cameraAssociations( find(cameraAssociations(:,2) == objectId), :); %#ok<FNDSB>
    
    for a = 1 : size(objectAssociations, 1)
        assoCameraId = objectAssociations( a, 3);
        assoObjectId = objectAssociations( a, 4);
        j = intersect(find(camObjLabels(:,1) == assoCameraId), find(camObjLabels(:,2) == assoObjectId));
        
        objectAssociationMat(i,j) = 1;
        objectAssociationMat(j,i) = 1;
    end
end
figure;
imshow( objectAssociationMat );

% propagate the associations
for iter = 1 : length( cameraIndexList )
    for o = 1 : length( objectIds )
        objectId = objectIds(o);
        cameraId = cameraIds(o);

        i = intersect(find(camObjLabels(:,1) == cameraId), find(camObjLabels(:,2) == objectId));
        associations = find(objectAssociationMat(i,:) == 1);

        for a = 1 : size(associations,2)
            j = associations(a);
            jAssociations = find( objectAssociationMat(j,:) == 1 );
            objectAssociationMat(i,jAssociations) = 1;
            objectAssociationMat(jAssociations,i) = 1;
        end
    end
end
figure;
imshow( objectAssociationMat );

load(fullfile( dataPath, 'trackletList.mat'));

W_gt = zeros(length(trackletList));

parfor i =  1 : length(trackletList)
   cameraId1 = trackletList(i).cameraId;
   trackletId1 = trackletList(i).parentTrackId;
   
   a1 = intersect(find(camObjLabels(:,1) == cameraId1), find(camObjLabels(:,2) == trackletId1));
   w = zeros( 1,length( trackletList ) );
   for j = 1 : length(trackletList)
        cameraId2 = trackletList(j).cameraId;
        trackletId2 = trackletList(j).parentTrackId;
        a2 = intersect(find(camObjLabels(:,1) == cameraId2), find(camObjLabels(:,2) == trackletId2));

        if trackletList(i).cameraId == trackletList(j).cameraId
            if trackletList(i).parentTrackId == trackletList(j).parentTrackId
                w(j) = 1;
            end
        else
            w(j) = objectAssociationMat(a1,a2);
        end
   end
   
   W_gt(i,:) = w;
end

save(fullfile( dataPath, 'gtWeightMatrix.mat'), 'W_gt', '-v7.3' );

%% close the matlab pool
if Constants.MATLAB_POOL_ENABLED
    try
        matlabpool close;
    catch ex
        fprintf( 'Pool is already Closed \n' );
    end
end