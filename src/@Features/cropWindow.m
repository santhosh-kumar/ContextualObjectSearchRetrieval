%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function crops image window
%                                                                               
%   Input --   
%       @I              
%       @nBit
%       @pos
%       @wd
%       @ht
%
%   Output --
%       @Ic - 
%       @Qc -
%
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Ic,Qc] = cropWindow( I, nBit, pos, wd, ht )
    row = max(1,pos(2)-ht/2);  col = max(1,pos(1)-wd/2);
    rowEnd = min(row+ht-1,size(I,1));
    colEnd = min(col+wd-1, size(I,1));
    Ic = I(row:rowEnd,col:colEnd,:);
    if(nargout==2); Qc=bitshift(reshape(Ic,[],3),nBit-8); end;
end