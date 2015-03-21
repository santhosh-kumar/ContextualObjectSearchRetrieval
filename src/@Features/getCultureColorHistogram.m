%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes 11 dimensional culture color histogram
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
function [ccHist] = getCultureColorHistogram(imagePatch)

    hsvPatch = 255 * rgb2hsv(uint8(imagePatch));%converting rgb to hsv and de-normalizing it
 
    ccHist=zeros(1,11);%to store the culture color histogram
    [xDims,yDims,~]=size(imagePatch);%size of the patch

    rgbCentroids = [ 0 0 0;       %black
                    255 255 255; %white
                    255 0 0;   %red
                    0 0 255;     %blue
                    255 255 0;   %yellow
                    0 255 0;     %green
                    128 0 128;   %purple
                    255	192	203; %pink
                    255	165	 0;  %orange
                    165	 42	 42; %brown
                    128 128 128;]; %grey
                
                
    hsvCentroid = 255*rgb2hsv(uint8(rgbCentroids));
    HC = hsvCentroid(:,1);
    SC = hsvCentroid(:,2);
    VC = hsvCentroid(:,3);
    
    for j=1:yDims
        for i=1:xDims
            D=zeros(1,11);
            H=hsvPatch(i,j,1);
            S=hsvPatch(i,j,2);
            V=hsvPatch(i,j,3);
            for c=1:11
                D(c)=sqrt((H-HC(c)).^2 + (S-SC(c)).^2 + (V-VC(c)).^2);
            end
            [~,min_id]=min(D);
            ccHist(min_id)=ccHist(min_id)+1;
        end
    end

    %Normalizing the histogram
    ccHist=ccHist./sum(ccHist);
end