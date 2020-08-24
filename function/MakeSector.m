% draw backgroud sector 
% sectorNumber : how many sector does the background have
% contrastratio : the contrast of the adjecent sector 
% backcolor : sector base color 
% InnerRadii : if the sector is  round dish or an annulus 

function  [sector,InnerSectorRect]= MakeSector(xCenter,yCenter,centerMovePix,contrastratio,backcolor,sectorNumber,InnerRadii)

% Check number of inputs.
if nargin > 7
    error('MakeSector:TooManyInputs','requires at most 7 optional inputs');
end
% set default sector is a round dish
if nargin == 6
    InnerRadii = 0;
end

sectorRadius_mov = xCenter + centerMovePix;
% InnerRadii = 400; % pixel
% contrastratio = 1;
sector1_color = backcolor * (1 + contrastratio); % backcolor + backcolor * contrastratio;
sector2_color = backcolor; % backcolor * (1 - contrastratio); % backcolor 
contrast = (sector1_color - sector2_color)/2; %2（black and white） - 255 

% sectorNumber = 6;

sector_angle = 360/sectorNumber;
[m2 n2] = meshgrid(- sectorRadius_mov : sectorRadius_mov, - sectorRadius_mov : sectorRadius_mov); % coordinate of sector
% mask = (m2.^2+n2.^2) <= (sectorRadius_mov.^2);
% InnerRadii = 0;
mask = ((InnerRadii).^2 <= (m2.^2+n2.^2) & ((m2.^2+n2.^2)<= (sectorRadius_mov).^2));
% have a look at mask
% spy(mask);

InnerSectorRect = [xCenter - InnerRadii  yCenter - InnerRadii  xCenter + InnerRadii  yCenter + InnerRadii];

sector(:,:,1) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor; % *contrast;%
sector(:,:,2) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,3) =  (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;  %(MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle))*contrast;%.* mask); 
sector(:,:,4) = mask * 255; % 255

% sectorTex = Screen('MakeTexture', wptr, sector);
% 
% sectorRect = Screen('Rect',sectorTex);
% 
% sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
end