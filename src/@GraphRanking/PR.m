%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph using PageRank algorithm
%
%   @param Wlist            - Weight matrix list
%   @param r                - Preference Vector
%   @param K                - number of top ranked items
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [l, v, q] = PR(Wlist, r, k)
    assert( nargin == 3 );
    assert( ~isempty(Wlist) );
    lambda = GraphRanking.PAGERANK_LAMBDA;
    W = zeros( size(Wlist{1}) );
    for i = 1 : length(Wlist)
    W = W + Wlist{i} .* (1/length(Wlist));
    end

    assert( ~isempty( W ) && size(W, 1) == size(W, 2) );
    assert( ~isempty( r ) );
    assert( k > 0 );
    
    n = size(W,1);
    
    % sanity check first
    if (min(min(W))<0),
    error('Found a negative entry in W! Stop.');
    elseif (abs(sum(r)-1)>1e-5),
    error('The vector r does not sum to 1! Stop.');
    elseif (lambda<0 | lambda>1)
    error('lambda is not in [0,1]! Stop.');
    elseif (k<0 | k>n)
    error('k is not in [0,n]! Stop.');
    end

    disp('normalizing (W -> P)....');
    % creating the graph-based transition matrix P
    P = W ./ repmat(sum(W,2), 1, n); % row normalized

    disp('making hatP....');
    % incorporating user-supplied initial ranking by adding teleporting 
    hatP = lambda*P + (1-lambda)*repmat(r', n, 1);

    %  finding the highest ranked item from the stationary distribution
    %  of hatP:  q=hatP'*q.  The item with the largest stationary probability
    %  is our higest ranked item.
    disp('computing the top ranked item....');
    q = stationary(hatP);
    
    %  the most probably state is our first absorbing node. Put it in l.
    [v, l]=sort(q', 'descend');
end

%------------------------------------------------------------------------
function q = stationary(P)
% find the stationary distribution of the transition matrix P
% the stationary distribution is q=P'*q
 [V,D]=eigs(sparse(P'),1,'LR');
 q=abs(V); % to avoid an all-negative vector
 q=q/sum(q); % make it a prob dist
end