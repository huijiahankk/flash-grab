% draw background texture and sector rect 


function [sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree,sector1_color,sector2_color,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel)


%----------------------------------------------------------------------
%               7T Screen parameter
%----------------------------------------------------------------------
% for 7T scanner the resolution of the screen is 1024*768   the height and
% width of the screen is 35*28cm  the distance from the subject to screen is 75cm    the visual degree for the subject is 10
% degree totally

% % visualDegree = 10;
% visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75;
% visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
% visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;
% 
% 
% % sectorNumber = 8;
% sectorRadius_in_pixel = floor((visualHerghtIn7T_pixel - 200)/2);    % inner diameter of background annulus
% %         annnulus outer radius
% sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus
% dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
sectorDiam_in_cm = sectorRadius_in_pixel * (28/768);
sectorDiam_out_cm = sectorRadius_out_pixel * (28/768);

annulus_in_radian = radi2ang(atan(sectorDiam_in_cm/2/75));
annulus_out_radian = radi2ang(atan(sectorDiam_out_cm/2/75));
% InnerRadii = 400; % pixel
% contrastratio = 1;

% sector1_color = blackcolor; %2 * backcolor * (1 - back.contrastratio); % backcolor * (1 - contrastratio); % backcolor
% sector2_color = whitecolor; %((1 + back.contrastratio)/(1 - back.contrastratio)) * sector1_color;

% sector1_color = backcolor * (1 + contrastratio); % backcolor + backcolor * contrastratio;

% contrastPara = (sector2_color - sector1_color); %2（black and white） - 255


sector_angle = 360/sectorNumber;
[m2, n2] = meshgrid(- sectorRadius_out_pixel : sectorRadius_out_pixel, - sectorRadius_out_pixel : sectorRadius_out_pixel); % coordinate of sector

% define the background  annulus    from
mask = ((sectorRadius_in_pixel).^2 <= (m2.^2+n2.^2)) & ((m2.^2+n2.^2) <= (sectorRadius_out_pixel).^2);  %  ((InnerRadii).^2 <= (m2.^2+n2.^2) & ((m2.^2+n2.^2)<= (sectorRadius_mov).^2));

% spy(mask);

sector(:,:,1) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor; % *contrast;%
sector(:,:,2) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;
sector(:,:,3) =  (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;  %(MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle))*contrast;%.* mask);
sector(:,:,4) = mask * 255; % 255

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
% sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end