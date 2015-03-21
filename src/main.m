clear all;
close all;
clc;

%% open the matlab pool
if Constants.MATLAB_POOL_ENABLED
    try
        matlabpool;
    catch ex
        fprintf( 'Pool is already running \n' );
    end
end

%% Set up the system
setup();

%% define variables
dataPath            = '../data/TestVideos/trajectory-1/mats';
trackletImgsPath    = '../data/TestVideos/trajectory-1/trackletImgs';
gtWeightMatrix      = 'gtWeightMatrix.mat';
trackletMatrix      = 'trackletList.mat';
rankingAlgorithm    = 'HR';
numberItemsToRank   = 200;
cameraIndexList     = [ 7, 8, 9, 32, 33, 34, 35, 37, 39, 44 ];
shouldUseContext    = 1;
shouldUseSpatialTemporal = 1;
networkModelingType = 2;
shouldOrderByTime   = 1;
isSummarization     = 1;
%% load matrices
% load the ground truth
load( fullfile(dataPath, gtWeightMatrix) );

% load the tracklet list
load(fullfile( dataPath, trackletMatrix));

%% get the network weight
W                   = NetworkModeling.getNetworkWeight(dataPath,...
                                                       cameraIndexList,...
                                                       shouldUseContext,...
                                                       shouldUseSpatialTemporal,...
                                                       networkModelingType,...
                                                       trackletMatrix);
                                                   
%% Analyze user queries
cameraId    = 33;
trackletId  = 6;

queryObjectIndexes  = NetworkModeling.getIndexFromCameraAndTrackletId(cameraId, trackletId, trackletList);
queryIndexes        = [queryObjectIndexes(1)];
r                   = zeros( length(trackletList), 1 );
r(queryIndexes)     = 1 / length( queryIndexes );
tic;
rankIndex           = GraphRanking.rank( W, r, numberItemsToRank, rankingAlgorithm);
toc;

% get precision and recall
rankIndexLabels     = zeros(1,length(rankIndex));
if ~isSummarization
    precisionDepths     = [ 5 10 15 20 25 30 35 40 45 50];
    gt                  = W_gt(queryIndexes,:);
    [~,n]               = find(gt~=0);
    n                   = setdiff(n, queryObjectIndexes);
    [~,m]               = intersect(rankIndex, n);
    rankIndexLabels(m) = 1;
    precision           = [];
    recall              = sum(rankIndexLabels) ./ length(n);
    for p = 1 : length(precisionDepths)
        if precisionDepths(p) <= length(rankIndex)
            precision  =   [precision sum(rankIndexLabels(1:precisionDepths(p)))./  precisionDepths(p)];
        end
    end
else
    precisionDepths     = [5 10];
    coOccurringIndexes = [trackletList(queryIndexes).cooccurringTrackletID];
    indexes = [queryIndexes];

    gt = W_gt(indexes,:);
    [~,n] = find(gt~=0);
    n = unique(setdiff(n, queryIndexes));
    [~,m] = intersect(rankIndex, n);
    rankIndexLabels(m) = 1;
    if ~isempty([trackletList(n).cooccurringTrackletID])
        [~,m1] = intersect(rankIndex, [trackletList(n).cooccurringTrackletID coOccurringIndexes]);
        rankIndexLabels(m1) = 2;
    end
    n1 = [trackletList(n).cooccurringTrackletID coOccurringIndexes];
    
    precision           = [];
    recall              = sum((rankIndexLabels>0)) ./ (length(n) + length(n1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  );
    for p = 1 : length(precisionDepths)
        if precisionDepths(p) <= length(rankIndex)
            precision  =   [precision sum(rankIndexLabels(1:precisionDepths(p))>0)./  precisionDepths(p)];
        end
    end
end

fprintf(['recall:' num2str(recall) '\n']);
fprintf(['precision:' num2str(precision) '\n']);
fprintf(['average precision:' num2str(mean(precision)) '\n']);

% Display results
camIDNameMap = containers.Map({7, 8, 9, 32, 33, 34, 35, 37, 39, 44}, {'3', '2', '1', '10', '9', '8', '7', '4', '5', '6'});
NetworkModeling.displayRetrievedResults( trackletList, rankIndex, rankIndexLabels, trackletImgsPath, queryIndexes, 25, camIDNameMap, shouldOrderByTime );

%% close the matlab pool
if Constants.MATLAB_POOL_ENABLED
    try
        matlabpool close;
    catch ex
        fprintf( 'Pool is already Closed \n' );
    end
end