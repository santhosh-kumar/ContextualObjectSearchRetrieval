%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph using Similarity Ranking
%
%   @param Wlist            - Weight matrix list
%   @param r                - Preference Vector
%   @param K                - number of top ranked items
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rankIndex = SR( Wlist, r, K )
    assert( nargin == 3 );
    assert( ~isempty(Wlist) );
    
    W = zeros( size(Wlist{1}) );
    for i = 1 : length(Wlist)
    W = W + Wlist{i} .* (1/length(Wlist));
    end
    
    W = W ./ repmat(sum(W,2), 1, size(W, 1)); % row normalized

    assert( ~isempty( W ) && size(W, 1) == size(W, 2) );
    assert( ~isempty( r ) && (sum(r) == 1) );
    assert( K > 0 );
        
    [~, topIndexes] = sort( W(find(r==1), :), 'descend' );
    
    rankIndex = topIndexes(1:K)';
end