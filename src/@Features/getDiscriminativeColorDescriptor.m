%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function computes discriminative color descriptor
%                                                                               
%   Input --   
%       @imagePatch - imagePatch
%   Output --
%       @ccHist
%
%   Author(s) -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%             
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function descColorDescriptor = getDiscriminativeColorDescriptor( imagePatch )
    try
        [w,h,~] = size( imagePatch );
        
        if (h == 0 || w == 0)
            descColorDescriptor = zeros(1,11);
            return;
        end
        det = [w/2 h/2 2 0 0];

        out = ColorDescriptors(imagePatch, det, 2);

        descColorDescriptor = out(6:end);
    catch ex
        fprintf( 'Failed to compute discriminative color descriptor' );
        descColorDescriptor = zeros(1,11);
    end
end