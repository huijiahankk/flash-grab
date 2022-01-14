% subject adjust the stimulus area in the visible field in 7T fMRI


clearvars;

if 0
    sbjname = 'k';      
else    
    sbjname = input('>>>Please input the subject''s name:   ','s');    
end

%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../function;
addpath ../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
bottomcolor = 128; %(whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);

fixsize = 5;
% coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
% coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink]; %[0 0 256 192];
% redSectorRect = [xCenter - xCenter*coverSectorShrink yCenter - xCenter*coverSectorShrink  xCenter  + xCenter*coverSectorShrink  yCenter + xCenter*coverSectorShrink];
sectorRect = [0  yCenter - xCenter  2*xCenter yCenter + xCenter];

% Create rotation matrix
% theta = 90; % to rotate 90 counterclockwise
% R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% % Rotate your point(s)
% point = coverSectorRect'; % arbitrarily selected
% rotpoint = R .* point;


%% set parameters
fixcolor = 200; % 0 255
framerate = FrameRate(wptr);
redcolor = [256 0 0];

% blackColor = BlackIndex(screenNumber);
% whiteColor = WhiteIndex(screenNumber);
[centerMoveHoriPix, centerMoveVertiPix, resp] = deal(0);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 10;
respSwitch = 0;


%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------

% load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro
% 
% dacsize = 10;  %How many bits per pixel#
% maxcol = 2.^dacsize-1;
% ncolors = 256; % see details in makebkg.m
% newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
% newclut(1:ncolors,:) = newcmap./maxcol;
% newclut(isnan(newclut)) = 0;


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
% spaceKey = KbName('space');
 

%----------------------------------------------------------------------
%               7T Screen parameter
%----------------------------------------------------------------------
% for 7T scanner the resolution of the screen is 1024*768   the height and
% width of the screen is 35*28cm  the distance from the subject to screen is 75cm    the visual degree for the subject is 10
% degree totally

visualDegree = 10;
visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75;
visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;
% 
% %----------------------------------------------------------------------
% %                      draw background sector
% %----------------------------------------------------------------------
% 
sectorNumber = 8;
sectorRadius_in_pixel = floor((visualHerghtIn7T_pixel - 200)/2);    % inner diameter of background annulus
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus

[sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree, blackcolor, whitecolor,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

% sector rotation from the degree of half wedge 
back.CurrentAngle = 360/sectorNumber/2;
back.ground_alpha = 0.24;
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
% back.FlagSpinDirecA = 0;  % flash tilt right
% back.FlagSpinDirecB = 0;  % flash tilt left

wedgeTiltStart = 0;
wedgeTiltStep = 1;

back.SpinSpeed = 3;   % 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
% back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
% data.flashTiltDirection = Shuffle(back.flashTiltDirectionMat);

% how many times does the flash present before it gradually dissappear
flashPresentTimesCeiling = 1;
flashRepresentFrame = 2.2; % 2.2 means 3 frame



%----------------------------------------------------------------------
%          adjust the fixation cross
%----------------------------------------------------------------------
respToBeMade = true;

while respToBeMade
    
    resp = 0;
    prekeyIsDown = 0;
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
        if keyCode(KbName('ESCAPE'))
            ShowCursor;
            sca;
            return
            
        elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
            resp = - 1;
            
        elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
            resp = 1;
            
        elseif keyCode(KbName('3')) ||keyCode(KbName('3#'))
            respSwitch = 1;
            
        elseif keyCode(KbName('4')) ||keyCode(KbName('4$'))
            respToBeMade = false;
        end
        
    end
    prekeyIsDown = keyIsDown;
    
    
    
    if  respSwitch == 0
        centerMoveHoriPix = centerMoveHoriPix + resp * 1;
    elseif  respSwitch == 1
        centerMoveVertiPix = centerMoveVertiPix + resp * 1;
    end
    
    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    
    % Set the line width for our fixation cross
    lineWidthPix = 4;
    
    sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
    Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
    
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', wptr, allCoords,lineWidthPix, whitecolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
    Screen('Flip',wptr);
    
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end


savePath = '../data/7T/screen_adjust_parameter/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename1 = [savePath,filename];

save(filename1,'centerMoveHoriPix','centerMoveVertiPix','sbjname');
sca;
