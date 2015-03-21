%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph using Manifold Ranking
%
%   @param Wlist            - Weight matrix list (cell)
%   @param r                - Preference Vector
%   @param K                - number of top ranked items
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rankIndex = MR(Wlist, r, K)

    assert( nargin == 3 );
    assert( ~isempty(Wlist) );
    
    W = zeros( size(Wlist{1}) );
    for i = 1 : length(Wlist)
        W = W + Wlist{i} .* (1/length(Wlist));
    end
    
    W = W ./ repmat(sum(W,2), 1, size(W, 1)); % row normalized
    
    assert( ~isempty( W ) && size(W, 1) == size(W, 2) );
    assert( ~isempty( r ) );
    assert( K > 0 );
    
    % number of nodes
    N = size( W, 1 );
    assert( N >= K );
    
    % compute ranking scores
    If = eye( N );    
    D12 = diag(sum(W,2).^(-1/2));
    S = sparse(D12) * W * sparse(D12);
    f = (1-GraphRanking.MRSP_MU) * pinv(If - GraphRanking.MRSP_MU .* sparse(S)) * r;
           
    % return top K rank indices
    [~,topIndices] = sort(f,'descend');
    
    rankIndex = topIndices(1:K);
    
    assert(~isempty(rankIndex));
end