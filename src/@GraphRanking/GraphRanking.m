%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class for different graph ranking techniques.
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GraphRanking < handle
    properties(Constant)
        MRSP_MU                             = 0.1;
        MRSP_MAX_NUMBER_ITERATION           = 10;
        MRSP_DELTA                          = 1e-10;
        MSRP_NUMBER_TOP_ITEMS               = 5;
        
        HR_NUMBER_NEAREST_NEIGHBOR          = 10;
        HR_GAMMA                            = 0.1;
        HRAN_MAX_NUMBER_ITERATION           = 1;
        HRAN_NUMBER_TOP_ITEMS               = 10;
        HRAN_DELTA                          = 1e-10;
        
        GRASSHOPPER_LAMBDA                  = 0.25;
        
        PAGERANK_ALPHA                      = 0.75;
        PAGERANK_EPSILON                    = 1e-10;
        PAGERANK_LAMBDA                     = 0.75;
    end%constant properties
    
    methods(Static, Access = public)
        % Rank the given rank nodes according to the specified type
        rankIndex = rank( Wlist, r, numberOfItems, type);
    end

    methods(Static, Access = private)       
        % Manifold ranking with sink points for ranking graph nodes
        rankIndex = MRSP(Wlist, r, numberOfItems);
        
        % Manifold ranking
        rankIndex = MR(Wlist, r, numbderOfItems);
                
        % Hypergraph ranking
        rankIndex = HR(Wlist, r, numberOfItems); 
        
        % Hypergraph ranking with absorbing nodes
        rankIndex = HRAN(Wlist, r, numberOfItems); 
        
        % Grasshopper ranking
        [rankIndex, v, q] = GH(Wlist, r, numberOfItems);
        
        % Similarity Ranking
        rankIndex = SR( Wlist, r, numberOfItems );
        
        % Page Ranking algorithm
        rankIndex = PR( Wlist, r, numberOfItems );
    end%static methods
end%classdef