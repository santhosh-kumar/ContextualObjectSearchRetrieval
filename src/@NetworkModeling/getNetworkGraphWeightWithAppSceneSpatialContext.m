%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This network graph weight with appearance, ST, scene contexts and ST topology
%                                                                               
%   Input --   
%       @dataPath               - path to the data folder
%       @cameraIndexList        - camera id list
%       @shouldUseContext       - whether to use context or not
%       @shouldUseSpatialTemporal - whether to use spatial temporal info
%       @weightMatrixFileName   - weight matrix file name
%       @trackletMatrixFileName - tracklet matrix file name
%
%   Output --
%       @W                   - network graph weight matrix
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )           
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function W = getNetworkGraphWeightWithAppSceneSpatialContext(dataPath,...
                                                            cameraIndexList,...
                                                            shouldUseContext,...
                                                            shouldUseSpatialTemporal,...
                                                            weightMatrixFileName,...
                                                            trackletMatrixFileName)
    tic;
    if ~exist( fullfile(dataPath, weightMatrixFileName) ) %#ok<EXIST>
        trackletList = [];
        % load the tracklet list
        load(fullfile( dataPath, trackletMatrixFileName));
        
        assert( ~isempty( trackletList ) );
        
        %% 0) Compute Intra-Camera Weighting
        fprintf( 'Computing intra camera Weight Matrix \n' );
        W_intra = zeros(length( trackletList ));
        parfor i = 1 : length( trackletList )
            w = zeros( 1,length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    if trackletList(i).parentTrackId == trackletList(j).parentTrackId
                        w(j) = Constants.DEFAULT_WEIGHT_SAME_PARENT;
                    elseif abs(trackletList(i).startTime - trackletList(j).startTime) <= Constants.TAU1_SECONDS
                        w(j) = Constants.DEFAULT_WEIGHT_CONTEXT_LINK;
                    else
                        w(j) = 0;
                    end
                else
                    w(j) = 0;
                end
            end
            
            W_intra(i,:) = w;
        end
        
        %% 1) Compute Appearance Context Based Weight Matrix
        fprintf( 'Computing Appearance Context Weight Matrix \n' );
        W_AC = zeros(length( trackletList ));
        
        parfor i = 1 : length( trackletList )
            w = zeros( 1,length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    w(j) = 0;
                else
                    w(j) = Context.getApperanceContextWeight( trackletList, i, j );
                end
            end
            
            W_AC(i,:) = w;
        end
        
        %% 2) Compute Spatial-Temporal Context Based Weight Matrix
        fprintf( 'Computing Spatial-Temporal Context Weight Matrix \n' );
        W_STC = zeros(length( trackletList ));
        
        parfor i = 1 : length( trackletList )
            w = zeros( 1,length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    w(j) = 0;
                else
                    w(j) = Context.getSpatialTemporalContextWeight( trackletList, i, j );
                end
            end
            W_STC(i,:) = w;
        end
        
        %% 3) Compute Scene Context Based Weight Matrix
        fprintf( 'Computing Scene Context Weight Matrix \n' );
        W_SC = zeros(length( trackletList ));
        
        parfor i = 1 : length( trackletList )
            w = zeros( 1,length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    w(j) = 0;
                else
                    w(j) = Context.getSceneContextWeight( trackletList, i, j );
                end
            end
            
            W_SC(i,:) = w;
        end
        
        %% 4) Compute Spatial-Temporal Topology based weight matrix
        fprintf( 'Computing Spatial-Temporal Topology Weight Matrix \n' );
        stt = SpatialTemporalTopology( length(cameraIndexList), cameraIndexList, 'kde', fullfile( dataPath), 1, 1 );
        W_STT = zeros(length( trackletList ));
        
        imageWidth  = 640;
        imageHeight = 480;
        
        block = [6 8];
        sizeX = imageHeight ./ block(1);
        sizeY = imageWidth ./ block(2);
        
        for i = 1 : length( trackletList )
            w = zeros( 1, length( trackletList ) );
            for j = 1 : length( trackletList )
                if trackletList(i).cameraId == trackletList(j).cameraId
                    w(j) = 0;
                else
                    
                    bb1 = trackletList(i).sp.bb;
                    bb2 = trackletList(j).sp.bb;

                    z = [ ( (ceil(bb1(1)/sizeX)-1) * sizeX+ ceil(bb1(1)/sizeX)*sizeX) / 2 ...
                        ( (ceil(bb1(2)/sizeY)-1) * sizeY+ ceil(bb1(2)/sizeY)*sizeY) / 2 ...
                        ( (ceil(bb2(1)/sizeX)-1) * sizeX+ ceil(bb2(1)/sizeX)*sizeX) / 2 ...
                        ( (ceil(bb2(2)/sizeY)-1) * sizeY+ ceil(bb2(2)/sizeY)*sizeY) / 2 ...
                        (trackletList(i).sp.ts - trackletList(j).sp.ts) ];
                    
                    w(j) = stt.getSpatialTemporalTransitionProbability( trackletList(i).cameraId, trackletList(j).cameraId, double(z) );
                end
            end
            
            W_STT(i,:) = w;
        end

        
        fprintf( 'Normalizing and saving weight matrix \n' );
      
        weightMatrix.W_intra = W_intra;
        weightMatrix.W_AC    = W_AC;
        weightMatrix.W_STC   = W_STC;
        weightMatrix.W_SC    = W_SC;
        weightMatrix.W_STT   = W_STT;
        
        % save the weight matrix
        save( fullfile(dataPath, weightMatrixFileName), 'weightMatrix',  '-v7.3');
        
    else
        load( fullfile(dataPath, weightMatrixFileName) );
        
        assert( ~isempty(weightMatrix) ); %#ok<NODEF>
    end
    
    W_intra = weightMatrix.W_intra;
    W_AC    = weightMatrix.W_AC;
    W_STC   = weightMatrix.W_STC;
    W_SC    = weightMatrix.W_SC;
    W_STT   = weightMatrix.W_STT;
            
    % normalize the appearance weight matrix
    Wn_AC = W_AC ./ max( max(W_AC) );
    Wn_AC(Wn_AC<0.95) = 0;
     
    % normalize the spatial temporal weight matrix
    Wn_STC = W_STC ./ max( max(W_STC) ); 
    
    % normalize the scene context weight matrix
    Wn_SC = W_SC ./ max( max(W_SC) ); 
      
    % normalize the spatial temporal topology weight matrix
    Wn_STT = W_STT ./ max(max(W_STT));
    
    alpha = 1/3;
    beta = 1/3;
    gamma = 1/3;
    eta = 1;
    
    % Compute the network weight matrix
    if shouldUseContext
        if shouldUseSpatialTemporal
            Wn = 1/2 .* (alpha .* Wn_AC + beta .* Wn_STC + gamma .* Wn_SC + eta .* Wn_STT);
        else
            Wn = alpha .* Wn_AC + beta .* Wn_STC + gamma .* Wn_SC;
        end
    else
        assert(shouldUseSpatialTemporal == 1);
        Wn = eta .* Wn_STT;
    end

    W    = cell(1,1);
    W{1} = W_intra + Wn ./ max(max(Wn));

    assert( ~isempty(W) );
    toc;
end