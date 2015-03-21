clear all;
close all;
clc;

%% setup the system
addpath( '../src' );
setup;

%% define variables
groundTruthPath     = '../data/TestVideos/trajectory-1/gt';
colorFilesPath      = '../data/TestVideos/trajectory-1/color';
hoofFilesPath       = '../data/TestVideos/trajectory-1/hoof';
objectTypeFilePath  = '../data/TestVideos/trajectory-1/type';
colorDriftSavePath  = '../data/TestVideos/trajectory-1/mats';
associationFilePath = '../data/TestVideos/trajectory-1/associations/associations.txt';
colorMatSuffix      = '_DSC';

cameraList          = { '07_1', '08_1', '09_1', '32_1', '33_1', '34_1', '35_1', '37_1', '39_1', '44_1'};
cameraIndexList     = [ 7, 8, 9, 32, 33, 34, 35, 37, 39, 44 ];
numberObjectsList   = [37, 41, 41, 31, 12, 30, 33, 31, 18, 14];

%% Compute Associations
cameraObjectAssociations = importdata( associationFilePath );

% initialize the list of cameras under analysis
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

 
imageWidth  = 640;
imageHeight = 480;
%% Compute Color Drift matrix for every pair of camera views
block = [6 8];
sizeX = imageHeight ./ block(1);
sizeY = imageWidth ./ block(2);

colorDriftMatrix = cell( length(cameraIndexList) );
for c1 = 1 : length(cameraIndexList)
    % read the ground truth data
    gt1 = importdata( fullfile(groundTruthPath, [ cameraList{c1} '.gt2']) );  
    
    cameraObjectIndex1 = find(camObjLabels(:,1) == cameraIndexList(c1));
    
    % load the color mat
    colorMat1 = load( fullfile( colorFilesPath, [cameraList{c1} colorMatSuffix] ) );

    % load the hoof mat
    hoofMat1 = load( fullfile( hoofFilesPath, [ cameraList{c1} '_hoof' ] ) );
    
    for c2 = 1  : length(cameraIndexList)
        if c1 ~= c2
            cdMat = [];
            
            fprintf( 'Calculating Color Drift between %s and %s \n', cameraList{c1}, cameraList{c2});
            
            % read the ground truth data
            gt2 = importdata( fullfile(groundTruthPath, [ cameraList{c2} '.gt2']) );

            cameraObjectIndex2 = find(camObjLabels(:,1) == cameraIndexList(c2));
            
            oneToOneAssociations = objectAssociationMat(cameraObjectIndex1, cameraObjectIndex2);
            
            [objectIds1, objectIds2] = find(oneToOneAssociations==1);

            % load the color mat
            colorMat2 = load( fullfile( colorFilesPath, [cameraList{c2} colorMatSuffix] ) );

            % load the hoof mat
            hoofMat2 = load( fullfile( hoofFilesPath, [ cameraList{c2} '_hoof' ] ) );
            
            for o = 1 : length( objectIds1 )
                i = objectIds1(o);
                j = objectIds2(o);
                
                objectColorRecordsTemp1 = colorMat1.colorMat( find( colorMat1.colorMat(2:end,6) == i ), :); %#ok<FNDSB>
                objectColorRecords1 = [];
                for r = 1 : size(objectColorRecordsTemp1,1)
                    if objectColorRecordsTemp1(r,6) == i
                        objectColorRecords1 = [objectColorRecords1; objectColorRecordsTemp1(r,:)];
                    end
                end
                if isempty(objectColorRecords1)
                    continue;
                end
                assert(sum(objectColorRecords1(:,6)~=i) == 0);
                

                objectColorRecordsTemp2 = colorMat2.colorMat( find( colorMat2.colorMat(2:end,6) == j ), :); %#ok<FNDSB>
                objectColorRecords2 = [];
                for r = 1 : size(objectColorRecordsTemp2,1)
                    if objectColorRecordsTemp2(r,6) == j
                        objectColorRecords2 = [objectColorRecords2; objectColorRecordsTemp2(r,:)];
                    end
                end
                if isempty(objectColorRecords2)
                    continue;
                end
                assert(sum(objectColorRecords2(:,6)~=j) == 0);
                
                % randomly choose 20 records from each tracklets for
                r1 = size(objectColorRecords1,1);
                r2 = size(objectColorRecords2,1);
                
                r1Index = randperm(r1);
                r2Index = randperm(r2);
                                
                objectColorRecords1 = objectColorRecords1(r1Index(1:min(20, r1)), :);
                objectColorRecords2 = objectColorRecords2(r2Index(1:min(20, r2)), :);

                for n1 = 1 : size(objectColorRecords1,1)

                   bb1 = objectColorRecords1( n1, 2:5 );
                   torsoCenter1 = [bb1(1) bb1(2) - (3/16)*bb1(4)];
                   legCenter1 = [bb1(1) bb1(2) + (4/16)*bb1(4)];
                   for n2 = 1 : size(objectColorRecords2,1)
                       bb2 = objectColorRecords2( n2, 2:5 );
                       torsoCenter2 = [bb2(1) bb2(2) - (3/16)*bb2(4)];
                       legCenter2 = [bb2(1) bb2(2) + (4/16)*bb2(4)];

                       %cdTorso = [torsoCenter1 1 objectColorRecords1(n1,8:18) torsoCenter2 1 objectColorRecords2(n2,8:18)];
                       %cdLegs = [legCenter1 1 objectColorRecords1(n1,19:end) legCenter2 1 objectColorRecords2(n2,19:end)];
                       cdTorso = [objectColorRecords1(n1,8:295) ./ sum(objectColorRecords1(n1,8:295)) objectColorRecords2(n2,8:295) ./ sum(objectColorRecords2(n2,8:295))];
                       cdLegs = [objectColorRecords1(n1,296:end)./ sum(objectColorRecords1(n1,296:end)) objectColorRecords2(n2,296:end) ./ sum(objectColorRecords2(n2,296:end))];
                      
                       cdMat = [ cdMat; cdTorso; cdLegs];
                    end 
                end
                
            end
            
            colorDriftMatrix{c1,c2} = cdMat;
        end
    end
end

% save the cd mat
save( fullfile( colorDriftSavePath, 'colorDriftMatrix' ), 'colorDriftMatrix', '-v7.3'  );