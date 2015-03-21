%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes kernel histogram
%                                                                               
%   Input --   
%       @Qc              
%       @kernel
%       @nBit
%
%   Output --
%       @p - histogram
%
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%             
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = buildHist( Qc, kernel, nBit )
    p = ktHistcRgb_c( Qc, kernel.K, nBit ) / kernel.sumK;
    if(0); p=gaussSmooth(p,.5,'same',2); p=p*(1/sum(p(:))); end;
end