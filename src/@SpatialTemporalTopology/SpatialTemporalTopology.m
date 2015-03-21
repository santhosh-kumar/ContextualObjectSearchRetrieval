%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for learning spatial temporal topology model
%
%   SpatialTemporalTopology learns the transition probability for every
%   pair of camera views
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef SpatialTemporalTopology < handle
    % member properties
    properties
        m_numberOfCameras;
        m_cameraIds;
        m_transitionModelList;
        m_transitionModelType;
        m_shouldUsePCA;
    end
           
    %constant properties
    properties(Constant)
        NUMBER_TRAINING_SAMPLES         = 50000;
        MIN_NUMBER_GAUSSIAN_COMPONENTS  = 10;
        MAX_NUMBER_GAUSSIAN_COMPONENTS  = 20;
        PCA_DIMENSION                   = 4;
        
        SPATIALTEMPORALMATRIX1          = 'spatialTemporalMatrix1.mat';
        SPATIALTEMPORALMATRIX2          = 'spatialTemporalMatrix2.mat';
    end

    % member methods
    methods( Access = public )
        % Constructor
        function obj = SpatialTemporalTopology(numberOfCameras, cameraIds, type, spatialTemporalDatapath, dataType, shouldUsePCA)
           obj.m_numberOfCameras        = numberOfCameras;
           obj.m_cameraIds              = cameraIds;
           obj.m_transitionModelType    = type;
           obj.m_shouldUsePCA           = shouldUsePCA;
           
           obj.m_transitionModelList    = cell( numberOfCameras, numberOfCameras );
           
           % initialize spatial temporal topology
           obj.initialize(spatialTemporalDatapath, dataType);
        end
        
        % Load spatial temporal data and model
        function obj = initialize( obj, spatialTemporalDatapath, dataType)
            assert( ~isempty(spatialTemporalDatapath) );
            
            % load the spatial temporal mat
            if dataType == 1
                load( fullfile(spatialTemporalDatapath, SpatialTemporalTopology.SPATIALTEMPORALMATRIX1));
            elseif dataType == 2
                load( fullfile(spatialTemporalDatapath, SpatialTemporalTopology.SPATIALTEMPORALMATRIX2));
            else
                error('Unknown spatialTemporalMat file');
            end
            
            assert( ~isempty( spatialTemporalMatrix ) );
           
            for i = 1 : length( obj.m_cameraIds )
                for j = 1 : length( obj.m_cameraIds )
                    if i ~= j
                        datapoints = spatialTemporalMatrix{i,j};
                        if ~isempty( datapoints )
                            obj.learnModel( obj.m_cameraIds(i), obj.m_cameraIds(j), datapoints' );
                        end
                    end
                end
            end
        end
        
        % Learn spatial temporal topology model
        function obj = learnModel( obj, cameraId1, cameraId2, datapoints )
            assert( ~isempty( datapoints ) );
            index1 =  find(obj.m_cameraIds==cameraId1);
            index2 =  find(obj.m_cameraIds==cameraId2);
            
            randIndexes = randperm( size(datapoints, 2) );
            numSamples  = min( SpatialTemporalTopology.NUMBER_TRAINING_SAMPLES, length(randIndexes));
            X           = datapoints(:, randIndexes(1:numSamples))';

            % whiten the data
            [Xwh, whMu, ~, whMat] = whiten(X,0.0001);
            
            % apply PCA
            Yk = [];
            if obj.m_shouldUsePCA
                [U, mu, ~] = pca( Xwh );  
                Yk = pcaApply( Xwh, U, mu, SpatialTemporalTopology.PCA_DIMENSION );                
                Xk = Xwh*Yk';
            else
                Xk = Xwh;
            end

            if strcmp( obj.m_transitionModelType, 'kde' )
                STT.kde = kde( Xk', 'rot'); %#ok<FNDSB>
            elseif strcmp( obj.m_transitionModelType, 'gmm' )
                % get the number of clusters
                G = SpatialTemporalTopology.getNumberOfClusters( Xk, 1:1:SpatialTemporalTopology.MAX_NUMBER_GAUSSIAN_COMPONENTS );
  
                % fit Gaussians
                gmm = gmdistribution.fit( Xk, max(SpatialTemporalTopology.MIN_NUMBER_GAUSSIAN_COMPONENTS, G),...
                                         'CovType', 'diagonal',...
                                         'Regularize', 1e-9 );
                % save the parameters
                STT.gmm     = gmm;
            else
                error( 'Unsupported Model' );
            end
            
            STT.Yk      = Yk;
            STT.whMu    = whMu;
            STT.whMat   = whMat;
            
            % set the stt
            obj.m_transitionModelList{index1,index2} = STT;
        end
        
        % Get spatial temporal transition probability
        function w = getSpatialTemporalTransitionProbability( obj, cameraId1, cameraId2, z )
            index1 =  find(obj.m_cameraIds==cameraId1);
            index2 =  find(obj.m_cameraIds==cameraId2);
            if ~isempty(obj.m_transitionModelList{index1,index2})
                % get the spatial temporal matrix
                STT = obj.m_transitionModelList{index1,index2};
                zWh = (z-STT.whMu)*STT.whMat;
                if obj.m_shouldUsePCA
                    Xk = zWh * STT.Yk';
                else
                    Xk = zWh;
                end
                
                % compute transition probability
                if strcmp( obj.m_transitionModelType, 'kde' )
                    w = evaluate(STT.kde, Xk');
                elseif strcmp( obj.m_transitionModelType, 'gmm' )
                    w = sum( STT.gmm.PComponents .* STT.gmm.posterior( Xk ) );
                else
                    error( 'Unsupported Model' );
                end
            else
                w = 0;
            end
        end
    end
    
    % static public methods 
    methods(Static, Access = public)
        G = getNumberOfClusters( Xk, K );
    end
end%classdef