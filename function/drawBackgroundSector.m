%----------------------------------------------------------------------
%                      draw background sector use drawtexture
%----------------------------------------------------------------------



function [sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix)

dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
sectorDiam_in_cm = sectorRadius_in_pixel * (28/768);
sectorDiam_out_cm = sectorRadius_out_pixel * (28/768);

annulus_in_radian = radi2ang(atan(sectorDiam_in_cm/2/75));
annulus_out_radian = radi2ang(atan(sectorDiam_out_cm/2/75));
% InnerRadii = 400; % pixel
% contrastratio = 1;
sector1_color = blackcolor; %2 * backcolor * (1 - back.contrastratio); % backcolor * (1 - contrastratio); % backcolor
sector2_color = whitecolor; %((1 + back.contrastratio)/(1 - back.contrastratio)) * sector1_color;
% sector1_color = backcolor * (1 + contrastratio); % backcolor + backcolor * contrastratio;

contrastPara = (sector2_color - sector1_color); %2???black and white??? - 255

% sectorNumber = 6;

sector_angle = 360/sectorNumber;
[m2 n2] = meshgrid(- sectorRadius_out_pixel : sectorRadius_out_pixel, - sectorRadius_out_pixel : sectorRadius_out_pixel); % coordinate of sector
% mask = (m2.^2+n2.^2) <= (sectorRadius_mov.^2);
% InnerRadii = 0;
% define the background  annulus    from
mask = ((sectorRadius_in_pixel).^2 <= (m2.^2+n2.^2)) & ((m2.^2+n2.^2) <= (sectorRadius_out_pixel).^2);  %  ((InnerRadii).^2 <= (m2.^2+n2.^2) & ((m2.^2+n2.^2)<= (sectorRadius_mov).^2));
% have a look at mask
% spy(mask);

sector(:,:,1) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor; % *contrast;%
sector(:,:,2) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;
sector(:,:,3) =  (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;  %(MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle))*contrast;%.* mask);
sector(:,:,4) = mask * 255; % 255

end
