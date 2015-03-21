clear all;
close all;
clc;
%%  define variables
spatialTemporalDatapath = '../data/TestVideos/trajectory-1/mats/';
trackletsSavePath = '../data/TestVideos/trajectory-1/mats';
load(fullfile( trackletsSavePath, 'trackletList' ));

%% setup the system
addpath( '../src' );
setup;

%% Compute STT
cameraIndexList = [7, 8, 9];
stt = SpatialTemporalTopology( 10, cameraIndexList, 'gmm', spatialTemporalDatapath, 1, 0 );

transitionModel = stt.m_transitionModelList{2,3};

numComponents   = transitionModel.gmm.NComponents;
Sigma           = transitionModel.gmm.Sigma;
whMu            = transitionModel.whMu;
whMat           = transitionModel.whMat;
z = [];
s = [];
for i = 1 : numComponents
   mu = transitionModel.gmm.mu(i,:);
   sigma = Sigma(:,:,i);
   z  = [z; (mu * inv(whMat)) + whMu];
   s  = [s; (sigma * inv(whMat)) + whMu];
end

im1 = imread( '/Users/santhosh/Dropbox/Research/ContextualObjectSearchRetrieval/data/TestVideos/trajectory-1/snapshots/8.png' );
im2 = imread( '/Users/santhosh/Dropbox/Research/ContextualObjectSearchRetrieval/data/TestVideos/trajectory-1/snapshots/9.png' );

clrs = uniqueColors( numComponents, numComponents, 1);
randIndex = randperm(numComponents^2);
clrs = clrs(randIndex(1:numComponents), :);

figure(1);
hFig1 = subtightplot(1, 2, 1, [0.001 0.001], [0.001 0.001], [0.001 0.001]);
imshow(im1);
hold on;
hs1 = [];
for i = 1 : numComponents
    [h,hc,hl] = plotEllipse( z(i,2), z(i,1), sqrt(s(i,2)), sqrt(s(i,1)), 0, clrs(i,:), 100, 2, 1, '-');
    hs1 =[hs1;h];
end
hold off;

hFig2 = subtightplot(1, 2, 2, [0.001 0.001], [0.001 0.001], [0.001 0.001]);
imshow(im2);
hold on;
hs2 = [];
for i = 1 : numComponents
    [h,hc,hl] = plotEllipse( z(i,4), z(i,3), sqrt(s(i,4)), sqrt(s(i,3)),  0, clrs(i,:), 100, 2, 1, '-');
    hs2 = [hs2;h];
end
hold off;

legTitles = cell(1, numComponents);
for i = 1 : numComponents
    legTitles{i} = upper(num2str(z(i,5)));
end
legend([hs2;hFig2], legTitles, 'Location','SouthEast', 'FontSize',16);