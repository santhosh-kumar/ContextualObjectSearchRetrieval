%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A wrapper class storing constant values.
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Constants < handle
    properties(Constant)
        TAU1_SECONDS                = 2.0;
        DEFAULT_WEIGHT_SAME_PARENT  = 1.0;
        DEFAULT_WEIGHT_CONTEXT_LINK = 0.01;
        MATLAB_POOL_ENABLED         = 0;
    end%constant properties
end%classdef