%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This network graph weight with clothing context and ST topology
%                                                                               
%   Input --   
%       @dataPath               - path to the data folder
%       @cameraIndexList        - camera id list
%       @shouldUseContext       - whether to use context or not
%       @shouldUseSpatialTemporal - whether to use spatial temporal info
%       @weightMatrixFileName   - weight matrix file name
%       @trackletMatrixFileName - tracklet matrix file name
%   Output --
%       @W                   - network graph weight matrix
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )           
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function W = getNetworkGraphWeightClothingContext( dataPath,...
                                                  cameraIndexList,...
                                                  shouldUseContext,...
                                                  shouldUseSpatialTemporal,...
                                                  weightMatrixFileName,...
                                                  trackletMatrixFileName )
    tic;
    
    trackletList = [];
    % load the tracklet list
    load(fullfile( dataPath, trackletMatrixFileName));        
    assert( ~isempty( trackletList ) );
    
    if ~exist( fullfile(dataPath, weightMatrixFileName) ) %#ok<EXIST>        
        %% 0) Compute Intra-Camera Weighting
        fprintf( 'Computing intra camera Weight Matrix \n' );
        W_intra = zeros(length( trackletList ));
        parfor i = 1 : length( trackletList )
            w = zeros( 1,length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    if i ~= j && trackletList(i).parentTrackId == trackletList(j).parentTrackId
                        w(j) = Constants.DEFAULT_WEIGHT_SAME_PARENT;
                    elseif ~isempty(trackletList(i).cooccurringTrackletID)
                        if ~isempty(find(trackletList(i).cooccurringTrackletID == j, 1))
                            w(j) = 1 ./ (length(trackletList(i).cooccurringTrackletID) + 1);
                        end
                    else
                        w(j) = 0;
                    end
                else
                    w(j) = 0;
                end
            end
            
            W_intra(i,:) = w;
        end
        
        %% 1) Compute Clothing Context Based Weight Matrix
        if shouldUseContext
            fprintf( 'Computing Clothing Context Weight Matrix \n' );
            W_CC1 = zeros(length( trackletList ));
            W_CC2 = zeros(length( trackletList ));
            W_CC3 = zeros(length( trackletList ));
            W_CC4 = zeros(length( trackletList ));
            
            colorDriftModel =  ColorDrift( length(cameraIndexList),...
                                           cameraIndexList,...
                                           ColorDrift.METHOD_RANDOM_FOREST_DISTANCE,...
                                           fullfile(dataPath, 'colorDriftMatrix' ) );
                                                     
            for i = 1 : length( trackletList )
                fprintf( ['Processing clothing context for tracklet ID = ' num2str(i) '\n'] );
                w1 = zeros( 1,length( trackletList ) );
                w2 = zeros( 1,length( trackletList ) );
                w3 = zeros( 1,length( trackletList ) );
                w4 = zeros( 1,length( trackletList ) );
                
                for j = 1 : length( trackletList )
                    if trackletList(i).cameraId == trackletList(j).cameraId
                        w1(j) = 0;
                        w2(j) = 0;
                        w3(j) = 0;
                        w4(j) = 0;
                    else
                        [w1(j), w2(j), w3(j), w4(j)] = Context.getClothingContextWeight( trackletList, colorDriftModel, i, j );
                    end
                end

                W_CC1(i,:) = w1;
                W_CC2(i,:) = w2;
                W_CC3(i,:) = w3;
                W_CC4(i,:) = w4;
            end
        end
          
        %% 2) Compute Spatial-Temporal Topology based weight matrix
        if shouldUseSpatialTemporal
            fprintf( 'Computing Spatial-Temporal Topology Weight Matrix \n' );
            stt = SpatialTemporalTopology( length(cameraIndexList), cameraIndexList, 'gmm', fullfile( dataPath), 1, 1 );
            W_STT = zeros(length( trackletList ));
            for i = 1 : length( trackletList )
                fprintf( ['Processing STT for tracklet ID = ' num2str(i) '\n'] );
                w = zeros( 1, length( trackletList ) );
                for j = 1 : length( trackletList )
                    if trackletList(i).cameraId == trackletList(j).cameraId
                        w(j) = 0;
                    else
                        bb1 = trackletList(i).sp.bb;
                        bb2 = trackletList(j).sp.bb;

                        z = double([ bb1(1) bb1(2) bb2(1) bb2(2) (trackletList(i).sp.ts - trackletList(j).sp.ts)]);
                        w(j) = stt.getSpatialTemporalTransitionProbability( trackletList(i).cameraId, trackletList(j).cameraId, z );
                    end
                end

                W_STT(i,:) = w;
            end
        end
        
        fprintf( 'Normalizing and saving weight matrix \n' );
      
        weightMatrix.W_intra = W_intra;
        if shouldUseContext
            weightMatrix.W_CC1 = W_CC1;
            weightMatrix.W_CC2 = W_CC2;
            weightMatrix.W_CC3 = W_CC3;
            weightMatrix.W_CC4 = W_CC4;
        end
        
        if shouldUseSpatialTemporal
            weightMatrix.W_STT   = W_STT;
        end
        
        % save the weight matrix
        save( fullfile(dataPath, weightMatrixFileName), 'weightMatrix',  '-v7.3' );        
    else
        load( fullfile(dataPath, weightMatrixFileName) );        
        assert( ~isempty(weightMatrix) ); %#ok<NODEF>
    end
    
    W_intra = weightMatrix.W_intra;
    
    if shouldUseContext
        W_CC    = weightMatrix.W_CC3;                    
        % normalize the clothing context weight matrix
        Wn_CC   = W_CC ./ max( max(W_CC) );
        %Wn_CC(Wn_CC<0.8) = 0;
    end
    
    if shouldUseSpatialTemporal
        W_STT   = weightMatrix.W_STT;
        % normalize the spatial temporal topology weight matrix
        Wn_STT = W_STT ./ max( W_STT(:) );
        %Wn_STT(Wn_STT<0.2) = 0;
    end
    
    if shouldUseContext
        if shouldUseSpatialTemporal
            W = cell(1,2);
            %W{1} = (Wn_CC + Wn_STT) * (1/2) + W_intra;
            W{1} = Wn_CC + W_intra;
            W{2} = Wn_STT + W_intra;
        else
            W = cell(1,1);
            W{1} = eye(length(trackletList), length(trackletList)) + Wn_CC;
        end
    else
        assert( shouldUseSpatialTemporal == 1 );
        W = cell(1);
        W{1} = W_intra + Wn_STT;
    end
   
    toc;
end