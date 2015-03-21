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
dataPath            = '../data/viper/mats';
trackletImgsPath    = '../data/viper/trackletImgs';
gtWeightMatrix      = 'gtWeightMatrix.mat';
trackletMatrix      = 'trackletList.mat';
rankingAlgorithm    = 'SR';
numberItemsToRank   = 100;
cameraIndexList     = [ 1, 2 ];
precisionDepths     = [ 5 10 15 20 25 30 35 40 45 50];
shouldUseContext    = 1;
shouldUseSpatialTemporal = 0;
networkModelingType = 2;
shouldOrderByTime   = 0;
%% load matrices
% load the ground truth
load( fullfile(dataPath, gtWeightMatrix) );

% load the tracklet list
load(fullfile( dataPath, trackletMatrix));

% %% get the network weight
W                   = NetworkModeling.getNetworkWeight(dataPath,...
                                                       cameraIndexList,...
                                                       shouldUseContext,...
                                                       shouldUseSpatialTemporal,...
                                                       networkModelingType,...
                                                       trackletMatrix);

%% Analyze user queries
cameraId    = 1;
trackletId  = 3;

queryObjectIndexes  = NetworkModeling.getIndexFromCameraAndTrackletId(cameraId, trackletId, trackletList);
queryIndexes        = queryObjectIndexes(1);
r                   = zeros( length(trackletList), 1 );
r(queryIndexes)     = 1 / length( queryIndexes );
rankIndex           = GraphRanking.rank( W, r, numberItemsToRank, rankingAlgorithm);

% Get Precision and Recall
rankIndexLabels     = zeros(1,length(rankIndex));
gt                  = W_gt(queryIndexes,:);
[~,n]               = find(gt~=0);
[~,m]               = intersect(rankIndex, n);
rankIndexLabels(m)  = 1;

precision           = [];
recall              = sum(rankIndexLabels) ./ length(n);
for p = 1 : length(precisionDepths)
   precision  =   [precision sum(rankIndexLabels(1:precisionDepths(p)))./  precisionDepths(p)];
end

fprintf(['recall:' num2str(recall) '\n']);
fprintf(['precision:' num2str(precision) '\n']);
fprintf(['average precision:' num2str(mean(precision)) '\n']);

% compute cummulative matching score
dist    = 1 - [W{1}(1:316, 317:end); W{1}(317:end, 1:316);];
result  = zeros(1, 316);
for pairCounter=1:632
    distPair = dist(pairCounter,:);  
    [~,idx] = sort(distPair,'ascend');
    result(idx==pairCounter) = result(idx==pairCounter) + 1;
end
cmc = cumsum(result ./ 316);
%hold on;plot([1:126], cmc,'LineWidth', 3, 'Color', g');hold off;
fprintf( ['CMC:' num2str(cmc(1:20) * 100) '\n'] );

% Display results
camIDNameMap = containers.Map({1,2}, {'cam_a', 'cam_b'});

NetworkModeling.displayRetrievedResults( trackletList, rankIndex, rankIndexLabels, trackletImgsPath, queryIndexes, numberItemsToRank, camIDNameMap, shouldOrderByTime );

%% close the matlab pool
if Constants.MATLAB_POOL_ENABLED
    try
        matlabpool close;
    catch ex
        fprintf( 'Pool is already Closed \n' );
    end
end