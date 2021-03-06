clear all;
close all;
clc;

% import src path
addpath( '../src' );

groundTruthPath = '../data/TestVideos/trajectory-1/gt';
colorFilesPath = '../data/TestVideos/trajectory-1/color';
hoofFilesPath = '../data/TestVideos/trajectory-1/hoof';
objectTypeFilePath = '../data/TestVideos/trajectory-1/type';

% save path for spatial temporal mat
stSavePath = '../data/TestVideos/trajectory-1/mats';

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

 
imageWidth  = 640;
imageHeight = 480;

block = [6 8];
sizeX = imageHeight ./ block(1);
sizeY = imageWidth ./ block(2);

% find the spatial-temporal topolgy matrix for every pair of cameras
spatialTemporalMatrix = cell( length(cameraIndexList) );
for c1 = 1 : length(cameraIndexList)
    % read the ground truth data
    gt1 = importdata( fullfile(groundTruthPath, [ cameraList{c1} '.gt2']) );  
    
    cameraObjectIndex1 = find(camObjLabels(:,1) == cameraIndexList(c1));
    
    % load the color mat
    colorMat1 = load( fullfile( colorFilesPath, [cameraList{c1}] ) );

    % load the hoof mat
    hoofMat1 = load( fullfile( hoofFilesPath, [ cameraList{c1} '_hoof' ] ) );
    
    for c2 = 1  : length(cameraIndexList)
        if c1 ~= c2
            stMat = [];
            
            fprintf( 'Calculating ST topology between %s and %s \n', cameraList{c1}, cameraList{c2});
            
            % read the ground truth data
            gt2 = importdata( fullfile(groundTruthPath, [ cameraList{c2} '.gt2']) );

            cameraObjectIndex2 = find(camObjLabels(:,1) == cameraIndexList(c2));
            
            oneToOneAssociations = objectAssociationMat(cameraObjectIndex1, cameraObjectIndex2);
            
            [objectIds1, objectIds2] = find(oneToOneAssociations==1);

            % load the color mat
            colorMat2 = load( fullfile( colorFilesPath, [cameraList{c2}] ) );

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
                
                objectHoofRecords1 =  hoofMat1.HOOFMat( find( hoofMat1.HOOFMat(1:end,3) == i ), :);%#ok<FNDSB>
                framesColor1 = objectColorRecords1(:,1);
                framesHoof1 = objectHoofRecords1(:,2);
                % frame list of selected object
                frameList1 = intersect(framesColor1,framesHoof1);

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
                
                objectHoofRecords2 =  hoofMat2.HOOFMat( find( hoofMat2.HOOFMat(1:end,3) == j ), :);%#ok<FNDSB>
                framesColor2 = objectColorRecords2(:,1);
                framesHoof2 = objectHoofRecords2(:,2);
                % frame list of selected object
                frameList2 = intersect(framesColor2,framesHoof2);
                
                objectRecords1 = [];
                
                for f1 = 1 : length(frameList1)
                    objectRecords1 = [objectRecords1; objectColorRecords1(objectColorRecords1(:,1)==frameList1(f1), 1:7) objectHoofRecords1(objectHoofRecords1(:,2)==frameList1(f1), 4:end) ]; %#ok<FNDSB>
                end
                
                objectRecords2 = []; %#ok<FNDSB>
                for f2 = 1 : length(frameList2)
                    objectRecords2 = [objectRecords2; objectColorRecords2(objectColorRecords2(:,1)==frameList2(f2), 1:7) objectHoofRecords2(objectHoofRecords2(:,2)==frameList2(f2), 4:end) ]; %#ok<FNDSB>
                end

                for n1 = 1 : size(objectRecords1,1)
                    for n2 = 1 : size(objectRecords2,1)
                       [alpha,index] = max(objectRecords1(n1,8:end));
                       theta = 360/16+360/8*(index-1);
                       st = [ objectRecords1(n1,2) objectRecords1(n1,3) objectRecords2(n2,2) objectRecords2(n2,3) alpha theta ( objectRecords1(n1,7) - objectRecords2(n2,7) )];
                       stMat = [ stMat; st];
                    end 
                end
                
            end
            
            spatialTemporalMatrix{c1,c2} = stMat;
        end
    end
end

% save the ST mat
save( fullfile( stSavePath, 'spatialTemporalMatrix2' ), 'spatialTemporalMatrix' );