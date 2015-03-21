%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph using Hypergraph ranking with absorbing nodes method
%
%   @param Wlist            - Cell of W matrices
%   @param r                - Preference Vector
%   @param K                - number of top ranked items
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rankIndex = HRAN(Wlist, r, K)
    assert( nargin == 3 );
    assert( ~isempty( Wlist ) );
    assert( ~isempty( r ) );
    assert( K > 0 );
    
    % Compute hyperedges per W{i}
    assert( nargin == 3 );
    assert( ~isempty(Wlist) );

    W = Wlist;
    
    N = size(W{1},1);
    C = length(W);
    
    assert( GraphRanking.HR_NUMBER_NEAREST_NEIGHBOR > 0 );
    
    load('/Users/santhosh/Dropbox/Research/ContextualObjectSearchRetrieval/data/TestVideos/trajectory-1/mats/trackletList.mat');
    
    % Find node neighbors to construct hyperedges
    nodeNeighbors = cell(N, C);
    for c = 1 : length(W)
        A= W{c} ./ repmat(sum(W{c},2), 1, N); % row normalized;        
        assert( size(A,1) == size(A,2) );        
        for i = 1 : N
            [~,indexes] = sort(A(i,:),'descend');
            nodeNeighbors{i,c} = unique([i+(c-1)*N indexes(1:GraphRanking.HR_NUMBER_NEAREST_NEIGHBOR)+(c-1)*N trackletList(i).cooccurringTrackletID+(c-1)*N], 'stable');
        end
    end
    
    % Compute hyperedge similarity matrix
    An = zeros(N, C*N);
    for c = 1 : C
       A= W{c};
       for  i = 1 : N
           startEdgeIndex = (c-1)*N+1;
           endEdgeIndex = c*N;
           nodeIndex = 1;
           for j = startEdgeIndex : endEdgeIndex
              An(i,j) =  A(i,nodeIndex);
              nodeIndex =  nodeIndex + 1;
           end
        end
    end

    % Compute Hyperedge Weight matrix
    Wn = zeros(C*N, C*N);
    for c = 1 : C
        startHyperEdgeIndex = (c-1)*N+1;
        endHyperEdgeIndex = c*N;
        p = 0;
        for e = startHyperEdgeIndex : endHyperEdgeIndex
            p = p + 1;
            neighbors = nodeNeighbors{p,c};
            we = 0;
            for i = 1 : length(neighbors)
               for j =  i : length(neighbors)
                   if i ~= j
                        we = we + An(neighbors(i) - (c-1)*N, neighbors(j));
                   else
                        we = we + 0;
                   end
               end
            end
            Wn(e, e) = we;
        end
    end
    
    % Compute Hyperedge Incidence Matrix
    Hn = zeros(N, N*C);
    for i =  1 : N
        for c = 1 : C
            startHyperEdgeIndex = (c-1)*N+1;
            endHyperEdgeIndex = c*N;
            p = 0;
            for e = startHyperEdgeIndex : endHyperEdgeIndex
                p = p + 1;
                neighbors = nodeNeighbors{p,c};                
                if length(find(neighbors == (i + (c-1)*N) )) > 0
                    if i~=e
                        Hn(i, e) = An(i, e);
                    else
                        Hn(i, e) = 1;
                    end
                end
            end
        end
    end
    
    % Compute the Node Degree Matrix
    Dv = zeros(N, N);
    for i = 1 : N
        nodeWeight = 0;
        for e = 1 : N*C
            nodeWeight = nodeWeight + Wn(e,e) .* Hn(i,e);
        end
        Dv(i,i) = nodeWeight;
    end
    
    % Compute the edge degree matrix
    De = zeros(N*C, N*C);        
    for i = 1 : N
        for c = 1 : C
            edgeIndex = (c-1)*N + i;
            neighbors = nodeNeighbors{i,c};
            nodeIndex = mod(neighbors, N);
            nodeIndex(nodeIndex==0) = N;
            
            De(edgeIndex, edgeIndex) = sum(Hn(nodeIndex, edgeIndex));            
        end        
    end
    
    dvDiag = diag(Dv);
    dvDiag(dvDiag>0) = (dvDiag(dvDiag>0)).^(-1/2);
    Dv12 =  diag(dvDiag);
    
    deDiag = diag(De);
    deDiag(deDiag>0) = (deDiag(deDiag>0)) .^ (-1);
    De1  = diag(deDiag);
    
    Theta = sparse(Dv12 * sparse(Hn) * sparse(Wn) * De1 * sparse(Hn)' * Dv12);
    
    % set of absorbing nodes
    Xa = [];
    
    If = eye(N);
    
    % initial ranking scores
    f0 = r;
    
    for i = 1 : GraphRanking.HRAN_NUMBER_TOP_ITEMS : K
        fDel = Inf;
        iter = 1;
        
        % until convergence of the limit of ranking scores
        while ( fDel > GraphRanking.HRAN_DELTA && iter <=  GraphRanking.HRAN_MAX_NUMBER_ITERATION )
            tic;
                        
            f1 = GraphRanking.HR_GAMMA * Theta * sparse(If) * f0 + (1-GraphRanking.HR_GAMMA) * r;
           
            fDel = norm(f0-f1,2);
            
            f0 = f1;
            
            iter = iter + 1;
            toc;
        end
        
        [~,topIndices] = sort(f1,'descend');
        
        count = 0;
        for j = 1 : length(topIndices)
            count = count+1;
            if count > min(K, GraphRanking.HRAN_NUMBER_TOP_ITEMS)
                break;
            end
            
            topIndex = topIndices(j);
            Xa =[Xa; topIndex];
        end
        If(Xa, Xa) = 0;
    end

    rankIndex = unique(Xa,'stable');
    
    assert(~isempty(rankIndex));
end