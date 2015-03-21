function [med, idx] = medianWithIndex(x)
    %# MYMEDIAN
    %#
    %# Input:   x        vector
    %# Output:  med      median value
    %# Output:  idx      corresponding index
    %#
    %# Note: If vector has even length, idx contains two indices
    %# (their average is the median value)
    %#
    %# Example:
    %#    x = rand(100,1);
    %#    [med idx] = mymedian(x)
    %#    median(x)
    %#
    %# Example:
    %#    x = rand(99,1);
    %#    [med idx] = mymedian(x)
    %#    median(x)
    %#
    %# See also: median
    %#

    assert(isvector(x));
    [~,ord] = sort(x);
    num = numel(x);

    if rem(num,2)==0
        %# even
        idx = ord(floor(num/2):floor(num/2)+1);
        med = mean( x(idx) );
    else
        %# odd
        idx = ord(floor(num/2)+1);
        med = x(idx);
    end
end