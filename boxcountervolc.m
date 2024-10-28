function [boxCounts,boxSizes] = boxcountervolc(imageIn,constVol,boxSizes,varargin)
%%

if ismatrix(imageIn)
   
    imageZeros=zeros(size(imageIn));
    imageIn=cat(3,imageIn,imageZeros);
    
end

% trim boxSizes to smallest possible box size to contain entire image
imageSize=size(imageIn);
boxWidth = max(imageSize);
maxSizes=boxSizes(find(boxSizes>=boxWidth));
boxWidth=maxSizes(1);
boxSizes=boxSizes(boxSizes<=boxWidth);

% place image in box along the edge
% unless placement in 'center' of box is requested.

newBox=false(boxWidth,boxWidth,boxWidth);
newBoxVol=false(boxWidth,boxWidth,boxWidth);

if ~isempty(varargin)&& strcmp(varargin{1},'center')
    
    % Center padded
    xLoc=floor((boxWidth-imageSize(1))/2);
    yLoc=floor((boxWidth-imageSize(2))/2);
    zLoc=floor((boxWidth-imageSize(3))/2);

    newBox(xLoc:xLoc+imageSize(1)-1,...
        yLoc:yLoc+imageSize(2)-1,...
        zLoc:zLoc+imageSize(3)-1) = imageIn;

    newBoxVol(xLoc:xLoc+imageSize(1)-1,...
        yLoc:yLoc+imageSize(2)-1,...
        zLoc:zLoc+imageSize(3)-1) = constVol;
else
    
    % Edge padded
    newBox(1:imageSize(1), 1:imageSize(2), 1:imageSize(3)) = imageIn;
    newBoxVol(1:imageSize(1), 1:imageSize(2), 1:imageSize(3)) = constVol;
    
end

imageIn = newBox;
expectVolIn = newBoxVol;

boxCounts=zeros(1,length(boxSizes)); % pre-allocate boxCount vector

for n=1:length(boxSizes)
    count=0;
    actual=boxSizes(n)*boxSizes(n)*boxSizes(n);
    if boxSizes(n)~=1
        for i=1:boxSizes(n):(boxWidth-boxSizes(n)+1)
            for j=1:boxSizes(n):(boxWidth-boxSizes(n)+1)
                for k=1:boxSizes(n):(boxWidth-boxSizes(n)+1)
                    if any(imageIn(i:i+boxSizes(n)-1 ,j:j+boxSizes(n)-1,k:k+boxSizes(n)-1),'all')
                        
                        expected=sum(expectVolIn(i:i+boxSizes(n)-1 ,j:j+boxSizes(n)-1,k:k+boxSizes(n)-1),'all');
                        count=count+1*expected/actual;

                    end
                end
            end
        end
    else
        expected = sum(expectVolIn,'all');
        count = sum(imageIn(:))*expected/actual; % this is r=1
    end
    boxCounts(n)= count;
end

end