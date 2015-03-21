%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Ranks a given graph according to the specified type
%
%   @param Wlsit            - Weight matrix list
%   @param r                - Preference Vector
%   @param K                - number of top ranked items to return
%   @param type             - {'MRSP','MR','HR','GH','SR','PR'}
%
%   @return rankIndex       - Ranked index
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rankIndex = rank( Wlist, r, K, type)
    assert( nargin == 4 );
    assert( ~isempty( Wlist ) );
    assert( ~isempty( r ) );
    assert( K > 0 );
    
    % Perform graph ranking according to the specified algorithm
    if ( strcmp( type, 'MRSP' ) )
        rankIndex = GraphRanking.MRSP( Wlist, r, K );
    elseif ( strcmp( type, 'MR' ) )
        rankIndex = GraphRanking.MR( Wlist, r, K );
    elseif ( strcmp( type, 'HR' ) )
        rankIndex = GraphRanking.HR( Wlist, r, K );
    elseif ( strcmp( type, 'HRAN' ) )
        rankIndex = GraphRanking.HRAN( Wlist, r, K );
    elseif ( strcmp( type, 'GH' ) )
        rankIndex = GraphRanking.GH( Wlist, r, K );
    elseif ( strcmp( type, 'SR' ) )
        rankIndex = GraphRanking.SR( Wlist, r, K );
    elseif ( strcmp( type, 'PR' ) )
        rankIndex = GraphRanking.PR( Wlist, r, K );
    else
        error( 'Invalid ranking type' );
    end
end