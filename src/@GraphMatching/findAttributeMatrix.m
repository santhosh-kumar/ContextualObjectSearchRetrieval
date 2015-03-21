%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method find the attributes for super pixel nodes
%
%   @param superPixelBB             - super pixel bounding boxes
%   @param superPixelFeatures       - super pixel features
%   @return A                       - attribute cell matrix
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = findAttributeMatrix( superPixelBB,...
                                  th,...
                                  superPixelFeatures )

    N = length(superPixelBB); %Number of nodes in the graph
    A = cell( 1, N );         %Attribute Matrix
    
    for i = 1 : N
        bb = superPixelBB(i).BoundingBox;
        centerX = bb(1) + bb(3)/2;
        centerY = bb(2) + bb(4)/2;
        A{i} = [centerX centerY th superPixelFeatures(i, :)];
    end
end

