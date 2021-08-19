% generate a flash-grab checkerboard event-related for testing whether SC
% response to the illusion or physical position
% flash tilt right:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1
% flash perceived tilt left :   data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1

% duration = (12+12+12+12)*6+12+4=304,TR=2s,152TR
%% 7T fMRI parameter (6 scans 6 blocks)
% Bandawidth=1200(<1000);
% TE=30;
% Slice=30;
% thickness=2mm;
% patial_fourier_factor=7/8;
% FOV=128*128;
% Dim=64*64;
% grappa=off;
%%
clear all;close all;

if 1
    sbjname = 'k';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    dotOrWedgeFlag = 'b';
    barLocation = 'lowerleft';
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    dotOrWedgeFlag = input('>>>Use dot flash Or wedge flash or bar flash? (d/w/b):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\lowerleft for lower left):  ','s');
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../function;
addpath ../../FGE_subcortex_new/flashgrabExp_7T_layer;
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

fixsize = 8;
% coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
% coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink]; %[0 0 256 192];
% redSectorRect = [xCenter - xCenter*coverSectorShrink yCenter - xCenter*coverSectorShrink  xCenter  + xCenter*coverSectorShrink  yCenter + xCenter*coverSectorShrink];
% sectorRect = [0  yCenter - xCenter  2*xCenter yCenter + xCenter];

HideCursor;

% Create rotation matrix
% theta = 90; % to rotate 90 counterclockwise
% R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% % Rotate your point(s)
% point = coverSectorRect'; % arbitrarily selected
% rotpoint = R .* point;

centerMovePix = 0;
%% set parameters
fixcolor = 200; % 0 255
framerate = FrameRate(wptr);
redcolor = [256 0 0];
bluecolor = [0 0 200];

%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------

load ../../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro

dacsize = 10;  %How many bits per pixel#
maxcol = 2.^dacsize-1;
ncolors = 256; % see details in makebkg.m
newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
newclut(1:ncolors,:) = newcmap./maxcol;
newclut(isnan(newclut)) = 0;


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

% visualHeightIn7T_cm = tan(deg2rad(10/2)) * 75 * 2;
% visualHerghtIn7T_pixel = visualHeightIn7T_cm * 768/28;

visualDegree = 10;
visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75 * 2;
visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;

%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 8;
sectorRadius_in_pixel = floor((visualHerghtIn7T_pixel - 300)/2);    % inner diameter of background annulus
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus
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

contrastPara = (sector2_color - sector1_color); %2（black and white） - 255

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

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% spy(sector(:,:,2));


% sectorDisc = MakeSectorDisc(5, 5, 360/16);
% spy(sectorDisc)
%----------------------------------------------------------------------
%                      draw red wedge
%----------------------------------------------------------------------

if dotOrWedgeFlag == 'd'|| 'b'
    adjustAngleL = 0;%11.25;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed); % 360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)/2 - 0.25;
    adjustAngleR = 0;%11.25;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed);% - 0.25;
elseif dotOrWedgeFlag == 'w'
    adjustAngleL = 360/2/sectorNumber;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed); % 360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)/2 - 0.25;
    adjustAngleR = 360/2/sectorNumber;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed);% - 0.25;
    % elseif dotOrWedgeFlag == 'b'
    %     adjustAngleL = 0;
    %     adjustAngleR = 0;
    
end

coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink];
redSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel  xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];
InnerSectorRect = [xCenter - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel  xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];
sectorArcAngle = 360/sectorNumber;

%----------------------------------------------------------------------
%%%   draw radial lines on the backgound for mouse point
%----------------------------------------------------------------------
radial_line_number_long = 5;
radial_line_length_long = 15;
startDistanceFromCenter = sectorRadius_out_pixel + 5;
radial_line_number_short = 25;
radial_line_length_short = 5;

[radial_line_mat_long] = drawRadialLinesMat(radial_line_number_long,radial_line_length_long,startDistanceFromCenter);
[radial_line_mat_short] = drawRadialLinesMat(radial_line_number_short,radial_line_length_short,startDistanceFromCenter);

%----------------------------------------------------------------------
%%%                     parameters of red dot  and red bar
%----------------------------------------------------------------------

dotRadiusPix = floor((sectorRadius_out_pixel - sectorRadius_in_pixel)*0.8)/2;
dotColor = [255 0 0];
barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];
% radius of the red dot to the annulus center
dotCenter2ScreenCenter =  ((sectorRadius_out_pixel + sectorRadius_in_pixel)/2)/2;
dotRadius =(dotCenter2ScreenCenter - sectorRadius_in_pixel/2)*2*0.9;
% dotRect = [xCenter - dotRadius, yCenter + dotCenter2ScreenCenter - dotRadius,xCenter + dotRadius,yCenter + dotCenter2ScreenCenter + dotRadius];
dotRect = CenterRectOnPoint([-dotRadius,-dotRadius,dotRadius,dotRadius],xCenter,yCenter + dotCenter2ScreenCenter * 2);  %  + dotCenter2ScreenCenter



% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barWidth, barLength);
barMat(:,:,2) = repmat(0,  barWidth, barLength);
barMat(:,:,3) = barMat(:,:,2);

% % Define a horizontal red rectangle
% barMat(:,:,1) = repmat(255, barLength, barWidth);
% barMat(:,:,2) = repmat(0,  barLength, barWidth);
% barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
bartRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% VisualField = [1 1 1 1];

% if back.contrastTrend == '1' % 'higher'
%     back.ground_alphaMat = [0.06 0.12 0.24 0.48 0.96]; % [0.96 0.48 0.24 0.12 0.06]
%     back.ground_alpha_stepMat = back.ground_alphaMat/(0.4*framerate);
% elseif back.contrastTrend == '2'     %'lower'
%     back.ground_alphaMat = [0.96 0.48 0.24 0.12 0.06];
%     back.ground_alpha_stepMat = back.ground_alphaMat/(0.4*framerate);
% end

back_ground_alpha = 1;
trialNumber = 10;
blockNumber = 2;
% back.contrastratio = 1;
% trialNumber = 3;
back.CurrentAngle = 0;
% back.AngleRange = 180;

% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;

wedgeTiltStartLowerRight = - 15;
% wedgeTiltIncre = 0;
back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
% back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);

% 1  flash tilt right

if barLocation == 'l'
    % back.flashTiltDirection = 2 is tilt left
    back.flashTiltDirectionMat = repmat([2],trialNumber,1);
elseif barLocation == 'u'
    % back.flashTiltDirection = 1 is tilt left
    back.flashTiltDirectionMat = repmat([1],trialNumber,1);
elseif barLocation == 'lowerleft'
    % back.flashTiltDirection = 1 is tilt right
    back.flashTiltDirectionMat = repmat([2],trialNumber,1);
end

% data.flashTiltDirection = Shuffle(back.flashTiltDirectionMat);


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
ScanOnset = GetSecs;




for block = 1 : blockNumber
    BlockOnset = GetSecs;
    
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    
    formatSpec = 'This is the %dth of %d block. Press Any Key To Begin';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    %         DrawFormattedText(wptr, '\n\nPress Any Key To Begin', 'center', 'center', blackcolor);
    %         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);
    
    Screen('Flip', wptr);
    %     while 1
    %         [~,~,button] = GetMouse(wptr);
    %         if any(button)
    %             break
    %         end
    %     end
    KbStrokeWait;
    %     KbWait;
    
    %     checkflag = 1;
    %
    %     while checkflag
    %         [~, ~, keyCode, ~] = KbCheck(-1);
    %         if keyCode(KbName('s'))
    %             checkflag = 0;
    %         end
    %     end
    
    data.flashTiltDirection(block,:) = Shuffle(back.flashTiltDirectionMat)';
    data.wedgeTiltEachBlock(block,1) = 0;
    
    for trial = 1:trialNumber
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        
        
        
        if mod(trial,2) == 1
            back_ground_alpha = 0;
            if barLocation == 'lowerleft'
                wedgeTiltNow = wedgeTiltStartLowerRight;
            else
                wedgeTiltNow = wedgeTiltStart;
            end
        elseif mod(trial,2) == 0
            back_ground_alpha = 1;
            wedgeTiltNow = data.wedgeTiltEachBlock(block,trial - 1);
            
        end
        
       
        
        
        
        while respToBeMade
            
            back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
            
            % tilt right  background first rotate clockwise until to the reverse angle
            if back.CurrentAngle >= back.ReverseAngle + adjustAngleL - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = - 1;
                back.FlagSpinDirecA = back.SpinDirec;
                % tilt left
            elseif back.CurrentAngle <= - back.ReverseAngle + adjustAngleR - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = 1;
                back.FlagSpinDirecB = back.SpinDirec;
            end
            
            %    draw background each frame
            Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back_ground_alpha); %  + backGroundRota
            
            
            
            % present flash tilt right
            if data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                if dotOrWedgeFlag == 'd'
                    dotCentercoord = [xCenter + dotRadius2Center * cosd(back.CurrentAngle)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    dotRect = [dotCentercoord(1) - dotRadiusPix  dotCentercoord(2) - dotRadiusPix   dotCentercoord(1) + dotRadiusPix  dotCentercoord(2) + dotRadiusPix];
                    Screen('FillOval', wptr,dotColor,dotRect);
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
                elseif dotOrWedgeFlag == 'b'
                    if barLocation == 'l' | barLocation == 'lowerleft'
                        % vertical bar lower visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter + dotRadius2Center * sind(wedgeTiltNow), yCenter + dotRadius2Center * cosd(wedgeTiltNow));
                    elseif  barLocation == 'u'
                        % vertical bar upper visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter - dotRadius2Center * sind(wedgeTiltNow), yCenter - dotRadius2Center * cosd(wedgeTiltNow));
                        
                    end
                    Screen('DrawTexture',wptr,barTexture,bartRect,barDestinationRect,back.CurrentAngle);
                end
                flashPresentFlag = 1;
                % present flash tilt left
            elseif data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1    % flash tilt left
                
                if dotOrWedgeFlag == 'd'
                    dotCentercoord = [xCenter - dotRadius2Center * cosd(back.CurrentAngle)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    % draw dots
                    %  Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    dotRect = [dotCentercoord(1) - dotRadiusPix  dotCentercoord(2) - dotRadiusPix   dotCentercoord(1) + dotRadiusPix  dotCentercoord(2) + dotRadiusPix];
                    Screen('FillOval', wptr,dotColor,dotRect);
                    
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL ,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    
                elseif dotOrWedgeFlag == 'b'
                    if barLocation == 'l' | barLocation == 'lowerleft'
                        % vertical bar lower visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter + dotRadius2Center * sind(wedgeTiltNow), yCenter + dotRadius2Center * cosd(wedgeTiltNow));
                    elseif barLocation == 'u'
                        % vertical bar upper visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter - dotRadius2Center * sind(wedgeTiltNow), yCenter - dotRadius2Center * cosd(wedgeTiltNow));
                        
                    end
                    Screen('DrawTexture',wptr,barTexture,bartRect,barDestinationRect,back.CurrentAngle);
                end
                
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
            end
            
            back.FlagSpinDirecA = 0;
            back.FlagSpinDirecB = 0;
            
            
            
            % draw fixation
            Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
            
            %             Screen('DrawLine',window,blackColor,xCenter-fixationSize,yCenter,xCenter+fixationSize,yCenter,5);
            %             Screen('DrawLine',window,blackColor,xCenter,yCenter-fixationSize,xCenter,yCenter+fixationSize,5);
            Screen('Flip',wptr);
            
            %----------------------------------------------------------------------
            %                      Response record
            %----------------------------------------------------------------------
            
            [keyIsDown,secs,keyCode] = KbCheck(-1);
            if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyCode(KbName('ESCAPE'))
                    ShowCursor;
                    sca;
                    return
                    % the bar was on the left of the gabor
                elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
                    if barLocation == 'l'| barLocation == 'lowerleft'
                        wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                    end
                elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                    if barLocation == 'l'| barLocation == 'lowerleft'
                        wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                    end
                elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                    if barLocation == 'l'| barLocation == 'lowerleft'
                        wedgeTiltNow = wedgeTiltNow - 3 * wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow + 3 * wedgeTiltStep;
                    end
                    
                elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                    if barLocation == 'l'| barLocation == 'lowerleft'
                        wedgeTiltNow = wedgeTiltNow + 3 * wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow - 3 * wedgeTiltStep;
                    end
                    
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                    %                     prekeyIsDown = 1;
                    %                 WaitSecs(0.5);
                end
            end
            prekeyIsDown = keyIsDown;
            
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/framerate) * flashRepresentFrame);
                
            end
            
            % for debug when flash present the simulus halt
            if debug== 'y' && flashPresentFlag
                KbWait;
            end
            
        end
        
        
        %         if mod(trial,2) == 1
        %             data.flashTilt(block,trial) = wedgeTiltNow;
        %             data.illusionTilt(block,trial) = 0;
        %             data.flashTiltDirectionFlash(block,trial) = data.flashTiltDirection;
        %         elseif mod(trial,2) == 0
        %             data.illusionTilt(block,trial) = wedgeTiltNow;
        %             data.flashTilt(block,trial) = 0;
        %             data.flashTiltDirectionIllusion = data.flashTiltDirection;
        %         end
        
        data.wedgeTiltEachBlock(block,trial) = wedgeTiltNow;
        wedgeTiltNow
        WaitSecs (0.5);
        
    end
    
    %     display(GetSecs - ScanOnset);
    
end




display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% time = clock;
% RespMat = [event.TypeNumericIdAll  event.InterTimeAll  flashTimePointAll];
% fileName = ['../data/' sbjname '-' num2str(time(1)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5)) '.mat'];
% % save(fileName,'RespMat','meanSubIlluDegree','time','all','gauss','cueVerDisDegree','gabor','viewingDistance','trialNumber','blockNumber');
% save(fileName,'RespMat');



% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end

if dotOrWedgeFlag == 'd'
    savePath = '../data/illusionSize/blindsight/dot/';
elseif dotOrWedgeFlag == 'b'
    %     savePath = '../data/illusionSize/blindsight/bar/';
    if  barLocation == 'u';
        savePath = '../data/illusionSize/blindsight/bar/upper_field/';
    elseif  barLocation == 'l';
        savePath = '../data/illusionSize/blindsight/bar/lower_field/';
    elseif  barLocation == 'lowerleft';
        savePath = '../data/illusionSize/blindsight/bar/lowerLeft_field/';
    end
end

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------
% % 1  flash tilt right
% 
% if barLocation == 'l'
%     % back.flashTiltDirection = 2 is tilt left
%     back.flashTiltDirectionMat = repmat([2],trialNumber,1);
% elseif barLocation == 'u'
%     % back.flashTiltDirection = 1 is tilt left
%     back.flashTiltDirectionMat = repmat([1],trialNumber,1);
% elseif barLocation == 'lowerleft'
%     % back.flashTiltDirection = 1 is tilt right
%     back.flashTiltDirectionMat = repmat([1],trialNumber,1);
% end


%----------------------------------------------------------------------
%                    average flash shift
%----------------------------------------------------------------------

%flash tilt degree
flashTiltDegree = data.wedgeTiltEachBlock(:,1:2:trialNumber);
% illusion degree
flashTiltDegree = data.wedgeTiltEachBlock(:,1:2:trialNumber);
% average illusion tilt left
flashTiltLeftIndex = data.flashTiltDirection(:,1:2:trialNumber) == 1;
flashTiltLeftDegree = flashTiltDegree(flashTiltLeftIndex);
flashAveTiltLeft = mean(flashTiltLeftDegree);



% average illusion tilt right
flashTiltRightIndex = data.flashTiltDirection(:,1:2:trialNumber) == 1;
flashTiltRightDegree = flashTiltDegree(flashTiltRightIndex);
flashAveTiltRight = mean(flashTiltRightDegree);

aveFlashShift = (abs(flashAveTiltLeft)+abs(flashAveTiltRight))/2;

%----------------------------------------------------------------------
%                    average illusion shift
%----------------------------------------------------------------------
if barLocation == 'l' | barLocation == 'lowerleft'  % back.flashTiltDirection = 2 is tilt left
    % illusion degree
    illusionTiltDegree = data.wedgeTiltEachBlock(:,2:2:trialNumber);
    % average illusion tilt left
    illusionTiltLeftIndex = data.flashTiltDirection(:,2:2:trialNumber) == 2;
    illusionTiltLeftDegree = illusionTiltDegree(illusionTiltLeftIndex);
    illusionAveTiltLeft = mean(illusionTiltLeftDegree);
    aveIllutionShift = abs(illusionAveTiltLeft);
    
elseif barLocation == 'u'
    
    % average illusion tilt right
    illusionTiltRightIndex = data.flashTiltDirection(:,2:2:trialNumber) == 1;
    illusionTiltRightDegree = illusionTiltDegree(illusionTiltRightIndex);
    illusionAveTiltRight = mean(illusionTiltRightDegree);
    aveIllutionShift = abs(illusionAveTiltRight);
end

% aveIllutionShift = (abs(illusionAveTiltLeft)+abs(illusionAveTiltRight))/2;


% bar(illusionAveTilt );
y = [aveFlashShift aveIllutionShift];
h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(gca, 'XTick', 1:2, 'XTickLabels', {'Flash' 'Illusion'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Illusion size','FontSize',25);

sca;
