%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for learning color drift model
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef ColorDrift < handle
    % Member properties
    properties
        m_numberOfCameras;
        m_cameraIds;
        m_colorDriftList;
        m_colorDriftModelType;
    end
           
    
    % Constant properties
    properties(Constant)
        NUMBER_TRAINING_SAMPLES             = 2000;
        NUMBER_PCA_COMPONENTS               = 34;
        METHOD_KERNEL_DENSITY_ESTIMATE      = 'kde';
        METHOD_RANDOM_FOREST_DISTANCE       = 'rfd';
        SHOULD_USE_PCA                      = 0;
    end

    
    % Member methods
    methods( Access = public )
        % Constructor
        function obj = ColorDrift( numberOfCameras, cameraIds, type, colorDriftMatPath )
           obj.m_numberOfCameras        = numberOfCameras;
           obj.m_cameraIds              = cameraIds;
           obj.m_colorDriftModelType    = type;
           obj.m_colorDriftList         = cell( numberOfCameras, numberOfCameras );
           
           % initialize spatial temporal topology
           obj.initialize( colorDriftMatPath );
        end
        
        
        % Load color drift data and model
        function obj = initialize( obj, colorDriftMatPath )
            assert( ~isempty(colorDriftMatPath) );
            
            % load the spatial temporal mat
            load( colorDriftMatPath );
            assert( ~isempty( colorDriftMatrix ) );
           
            % lLearn a model for every pair of distinct cameras
            for i = 1 : length( obj.m_cameraIds )
                for j = 1 : length( obj.m_cameraIds )
                    if i ~= j
                        datapoints = colorDriftMatrix{i,j};
                        % neglect nan
                        datapoints(isnan(datapoints))=0;
                        if ~isempty( datapoints )
                            obj.learnModel( obj.m_cameraIds(i), obj.m_cameraIds(j), datapoints' );
                        end
                    end
                end
            end
        end
        
        
        % Learn color drift model
        function obj = learnModel( obj, cameraId1, cameraId2, datapoints )
            assert( ~isempty( datapoints ) );
            index1 =  obj.m_cameraIds==cameraId1;
            index2 =  obj.m_cameraIds==cameraId2;
              
            if strcmp( obj.m_colorDriftModelType, ColorDrift.METHOD_KERNEL_DENSITY_ESTIMATE )
                % whiten the data
                randIndexes = randperm( size(datapoints, 2) );
                numSamples = min( ColorDrift.NUMBER_TRAINING_SAMPLES, length(randIndexes));
                X           = datapoints(:, randIndexes(1:numSamples))';
                [Xwh, whMu, invMat, whMat] = whiten(X, 0.0001);
                
                if ColorDrift.SHOULD_USE_PCA
                    [U, mu, ~] = pca( Xwh );                
                    Yk = pcaApply( Xwh, U, mu, ColorDrift.NUMBER_PCA_COMPONENTS );                
                    Xk = Xwh*Yk';
                else
                    Xk = Xwh;
                    Yk = eye(size(Xwh, 2));
                end
                
                de = kde( Xk', 'rot' );
                
                % store the model
                CDM.Yk      = Yk;
                CDM.kde     = de;
                CDM.whMat   = whMat;
                CDM.whMu    = whMu;
                CDM.invMat  = invMat;
                CDM.type    = ColorDrift.METHOD_KERNEL_DENSITY_ESTIMATE;
                
                obj.m_colorDriftList{index1,index2} = CDM;
                
            elseif strcmp( obj.m_colorDriftModelType, ColorDrift.METHOD_RANDOM_FOREST_DISTANCE )
                % get the data dimension
                datapoints  = datapoints';
                d           = size(datapoints,2)/2;
                numSamples  = min(ColorDrift.NUMBER_TRAINING_SAMPLES, size(datapoints,1));
                sampleIndexes = randperm( size(datapoints,1) );
                
                % compute datamatrix with Similar(1) and Dissimilar(-1)
                [Xt, Yt]    = ColorDrift.formEquivalenceConstraints(datapoints(sampleIndexes(1:numSamples), :), d);
             
                % Apply PCA
                if ColorDrift.SHOULD_USE_PCA
                    [U, mu, ~] = pca( Xt );                
                    Yk = pcaApply( Xt, U, mu, ColorDrift.NUMBER_PCA_COMPONENTS );                
                    Xk = Xt*Yk';
                else
                    Xk = Xt;
                    Yk = [];
                end
                
                extra_options.replace   = 1;
                extra_options.nodesize  = 1;
                nTree                   = 4;
                model                   = classRF_train(Xt, Yt, nTree*200, 0, extra_options);
                
                % store the model
                CDM.rfModel = model;
                CDM.d       = d;
                CDM.type    = ColorDrift.METHOD_RANDOM_FOREST_DISTANCE;
                CDM.Yk      = Yk;
                obj.m_colorDriftList{index1,index2} = CDM;
            else
                error( 'Unsupported Model' );
            end            
        end
        
        
        % Get color drift model
        function cdm = getColorDriftModel( obj, cameraId1, cameraId2 )
            index1 =  find(obj.m_cameraIds==cameraId1);
            index2 =  find(obj.m_cameraIds==cameraId2);
            cdm = [];
            if ~isempty(obj.m_colorDriftList{index1,index2})
                cdm = obj.m_colorDriftList{index1,index2};
            end
        end
        
        
        % Get Color Drift probability
        function w = getColorDriftProbability( obj, cameraId1, cameraId2, z )
            % get the learned model
            CDM    = obj.getColorDriftModel( cameraId1, cameraId2 );
            if isempty(CDM)
                w   = 0;
                return;
            end
            
            w = ColorDrift.evaluateDensity(z, CDM);   
        end        
    end
    
    
    % Static public methods 
    methods(Static, Access = public)
        % evaluate density
        function w = evaluateDensity(z, CDM)
            if strcmp( CDM.type, ColorDrift.METHOD_KERNEL_DENSITY_ESTIMATE )
                zWh = (z-CDM.whMu)*CDM.whMat;
                if ColorDrift.SHOULD_USE_PCA
                    zk  = zWh * CDM.Yk';
                else
                    zk  = zWh;
                end
                w   = evaluate(CDM.kde, zk');
            elseif strcmp( CDM.type, ColorDrift.METHOD_RANDOM_FOREST_DISTANCE )
                rfModel = CDM.rfModel;
                d       = CDM.d;
                
                assert(CDM.d == length(z)/2);
                X1      = z(1:d);
                X2      = z(d+1:end);
                Xtst    = [abs(X1-X2) (X1+X2)/2];
                if ColorDrift.SHOULD_USE_PCA
                    zk  = Xtst * CDM.Yk';
                else
                    zk  = Xtst;
                end
                
                [~, ~, votes, ~, ~] = classRF_predict_dis(Xtst, rfModel);
                
                w       = votes(2) / rfModel.ntree;
            else
                error( 'Unsupported Model' );
            end
        end
        
        % Form Equivalence Constraints
        function [Xt, Yt] = formEquivalenceConstraints(datapoints, d)
            X1 = datapoints(:,1:d);
            X2 = datapoints(:,d+1 : end);
            
            Xtp = [abs(X1-X2) (X1+X2)/2];
            Ytp = ones(size(Xtp,1),1);
            
            Xtn = [];
            Ytn = [];
            
            randIndexes = randperm( size(datapoints, 1) );
            for i = 1:length(randIndexes)
                if i ~= randIndexes(i)
                    Xtn = [Xtn; abs(X1(i,:)-X2(randIndexes(i),:)) (X1(i,:)+X2(randIndexes(i),:))/2];
                    Ytn = [Ytn; -1];
                    
                    Xtn = [Xtn; abs(X1(randIndexes(i),:)-X2(i,:)) (X1(randIndexes(i),:)+X2(i,:))/2];
                    Ytn = [Ytn; -1];
                    
                end
            end
            
            X = [Xtp; Xtn];
            Y = [Ytp; Ytn];
            
            % random permute the data
            randIndexes = randperm( size(X, 1) );
            Xt  = X(randIndexes, :);
            Yt  = Y(randIndexes, :);
        end
    end
end%classdef