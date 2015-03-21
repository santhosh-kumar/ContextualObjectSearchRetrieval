%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This network graph weight with clothing context and ST topology
%                                                                               
%   Input --   
%       @Xk                  - data points
%       @K                   - range of cluster sizes
%
%   Output --
%       @G                   - number of clusters
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )           
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = getNumberOfClusters( Xk, K )
    n = length(K);
    d = zeros(1,n); % residual distortion
    Y = size(Xk,2)/2;       % transformation power
    
    % compute residual distortion for different values of K
    for k = 1 : length(K)    
        [~, ~, dist] = vl_kmeans(Xk',K(k));
        d(k) = dist ./ size( Xk, 1);
    end

    % compute transformation power
    Dky = d.^(-Y);

    % compute the jump
    d1 = [Dky 0];
    d2 = [0 Dky];
    [~,P] = max(d1(1:n)-d2(1:n));
    
    % compute the index with maximum jump
    G = K(P);
end