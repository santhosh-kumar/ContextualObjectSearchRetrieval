%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph using Manifold Ranking with Sink Points method
%
%   @param Wlist            - Weight matrix list (cell)
%   @param r                - Preference Vector
%   @param K                - number of top ranked items
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rankIndex = MRSP( Wlist, r, K)
    
    assert( nargin == 3 );
    assert( ~isempty(Wlist) );
    
    W = zeros( size(Wlist{1}) );
    for i = 1 : length(Wlist)
        W = W + Wlist{i} .* (1/length(Wlist));
    end
    
    assert( ~isempty( W ) && size(W, 1) == size(W, 2) );
    assert( ~isempty( r ) );
    assert( K > 0 );
    
    % number of nodes
    N = size( W, 1 );
    
    assert( N >= K );
    
    % set of sink points
    Xs = [];
    
    If = eye(N);
    
    % initial ranking scores
    f0 = r;
    
    for i = 1 : GraphRanking.MSRP_NUMBER_TOP_ITEMS : K
        fDel = Inf;
        
        iter = 1;
        
        % until convergence of the limit of ranking scores
        while ( fDel > GraphRanking.MRSP_DELTA && iter <=  GraphRanking.MRSP_MAX_NUMBER_ITERATION )
            tic;
            D12 = diag(sum(W,2).^(-1/2));
            S = sparse(D12) * W * sparse(D12);
            
            f1 = GraphRanking.MRSP_MU * sparse(S) * sparse(If) * f0 + (1-GraphRanking.MRSP_MU) * r;
           
            fDel = norm(f0-f1,2);
            
            f0 = f1;
            
            iter = iter + 1;
            toc;
        end
        
        [~,topIndices] = sort(f1,'descend');
        
        count = 0;
        for j = 1 : length(topIndices)
            topIndex = topIndices(j);
            if length(find(Xs==topIndex)) == 0 
                Xs =[Xs; topIndex];
                count = count+1;
            end
            
            if count > min(K, GraphRanking.MSRP_NUMBER_TOP_ITEMS)
                break;
            end
        end

        If(Xs, Xs) = 0;
    end

    rankIndex = unique(Xs,'stable');
    
    assert(~isempty(rankIndex));
end