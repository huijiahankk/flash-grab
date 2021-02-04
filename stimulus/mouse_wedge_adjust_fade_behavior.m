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
    expmark = 2;
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    %     data.sectorRadiusIn = 300;   % inner radii of flsh wedge
    %     flashRedWedgeFlag = 'n';
    dotOrWedgeFlag = 'w';
    %     contrastratio = 0.06;
    %     whiteBlackContrast = 'n';
    back.contrastTrend = '1';  % 1 low - high   2  high - low
    %     sectorFlag = 1;   % 1 DrawTexture/2 FillArc
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    % session = input('>>>Please input the session:  ','s');
    % session 1
    % 1  annulus segment condition
    % sectorNumber = input('>>>> How many background segment ? (e.g.: 8/12):  ');
    % savePath = '../data/'
    % InnerRadii = input('>>>> Inner radii of the annulus? (e.g.: 200/400):  ');
    % back.SpinSpeed = input('>>>> Background spin velocity(deg/frame)? (e.g.: 2.3/4):  ');
    debug = input('>>>Debug? (y/n):  ','s');
    dotOrWedgeFlag = input('>>>Use dot flash Or wedge flash? (d/w):  ','s');
    expmark = 2; % input('>>>Which experiment? (1 background tilt，flash vertical/2 flash/background vertical):  ');
    % 1 background tilt，flash vertical  2 flash/background vertical
    % flash represent for 3 frames
    %     flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    %     flashRedDiskFlag =  'y'; %input('>>>> Flash with red disk ? (e.g.: y/n):  ','s');
    %     InnerRadii = 0; % input('>>>> Inner Radius of annulus ? (e.g.: 0/200):  ');
    if  flashRedDiskFlag == 'n'
        data.sectorRadiusIn = input('>>>> CheckerBoard wedge Inner Radius(degree) ? (e.g.: 0/300):  ');
    else
        data.sectorRadiusIn = 300;
    end
    %     whiteBlackContrast = input('>>>> background white and black ? (e.g.: y/n):  ','s');
    %     contrastratio = input('>>>background contrast ratio? (0.06/0.12/0.24/0.48/0.96):  ');
    back.contrastTrend = input('>>>> background contrast trend ? (e.g.: 1 low2high/2 high2low):  ','s');
    sectorFlag = input('>>>> Use drawTexture of FillArc to draw sector? (e.g.: 1 DrawTexture/2 FillArc):  ');
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

centerMovePix = 0;
%% set parameters
fixcolor = 200; % 0 255
framerate = FrameRate(wptr);
redcolor = [256 0 0];
bluecolor = [0 0 200];

%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------

load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro

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

% % %----------------------------------------------------------------------
% % %                      background sector setup
% % %----------------------------------------------------------------------
% %
% % sectorNumber = 6;
% % [sector,InnerSectorRect]= MakeSector(xCenter,yCenter,centerMovePix,contrastratio,backcolor,sectorNumber,InnerRadii);
% % sectorTex = Screen('MakeTexture', wptr, sector);
% % sectorRect = Screen('Rect',sectorTex);
% % sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
% if back.contrastTrend == '1' % 'higher'
%     back.contrastratioMat = [0.06 0.12 0.24 0.48 0.96]; % [0.96 0.48 0.24 0.12 0.06]
% elseif back.contrastTrend == '2'     %'lower'
%     back.contrastratioMat = [0.96 0.48 0.24 0.12 0.06];
% end
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
sectorRadius_in_pixel = floor((visualHerghtIn7T_pixel - 400)/2);    % inner diameter of background annulus
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

% InnerSectorRect = [xCenter - InnerRadii  yCenter - InnerRadii  xCenter + InnerRadii  yCenter + InnerRadii];

% sector(:,:,1) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrastPara+backcolor; % *contrast;%
% sector(:,:,2) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrastPara+backcolor;
% sector(:,:,3) =  (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrastPara+backcolor;  %(MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle))*contrast;%.* mask);
% sector(:,:,4) = mask * 255; % 255

sector(:,:,1) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor; % *contrast;%
sector(:,:,2) = (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;
sector(:,:,3) =  (MakeSectorDisc(sectorRadius_out_pixel,sectorRadius_out_pixel,sector_angle).*mask-1);%  *contrastPara+backcolor;  %(MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle))*contrast;%.* mask);
sector(:,:,4) = mask * 255; % 255

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% spy(sector(:,:,1));


% sectorDisc = MakeSectorDisc(5, 5, 360/16);
% spy(sectorDisc)
%----------------------------------------------------------------------
%                      draw red wedge
%----------------------------------------------------------------------

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
%%%                     parameters of red dot
%----------------------------------------------------------------------

% dotSizePix = floor((sectorDiam_out_pixel - sectorDiam_in_pixel)*0.8);
dotColor = [255 0 0];
% radius of the red dot to the annulus center
dotCenter2ScreenCenter =  ((sectorRadius_out_pixel + sectorRadius_in_pixel)/2)/2;
dotRadius =(dotCenter2ScreenCenter - sectorRadius_in_pixel/2)*2*0.9;
% dotRect = [xCenter - dotRadius, yCenter + dotCenter2ScreenCenter - dotRadius,xCenter + dotRadius,yCenter + dotCenter2ScreenCenter + dotRadius];
dotRect = CenterRectOnPoint([-dotRadius,-dotRadius,dotRadius,dotRadius],xCenter,yCenter + dotCenter2ScreenCenter * 2);  %  + dotCenter2ScreenCenter

%----------------------------------------------------------------------
%%%                  for a big cursor
%----------------------------------------------------------------------
% spriteSize = 30; % The height and width of the sprite in pixels (the sprite is square)
% numberOfSpriteFrames = 25; % The number of animation frames for our sprite
%
% for i = 1 : numberOfSpriteFrames
%         % Create the frames for the animated sprite.  Here the animation
%         % consists of noise.
%         spriteFrame(i) = Screen('MakeTexture', wptr, blackcolor + bottomcolor * rand(spriteSize));
% end
%
% spriteRect = [0 0 spriteSize spriteSize]; % The bounding box for our animated sprite
% spriteFrameIndex = 1; % Which frame of the animation should we show?



%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% VisualField = [1 1 1 1];

if back.contrastTrend == '1' % 'higher'
    back.ground_alphaMat = [0.06 0.12 0.24 0.48 0.96]; % [0.96 0.48 0.24 0.12 0.06]
    back.ground_alpha_stepMat = back.ground_alphaMat/(0.4*framerate);
elseif back.contrastTrend == '2'     %'lower'
    back.ground_alphaMat = [0.96 0.48 0.24 0.12 0.06];
    back.ground_alpha_stepMat = back.ground_alphaMat/(0.4*framerate);
end


trialNumber = 4;
blockNumber = length(back.ground_alphaMat);
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


% wedgeTiltIncre = 0;
back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
% data.flashTiltDirection = Shuffle(back.flashTiltDirectionMat);


% back.ground_alpha_step = 0.005; %1/(0.4*framerate); %framerate/1000
% how many times does the flash present before it gradually dissappear
flashPresentTimesCeiling = 1;

% flashTiltDirectionMat = ['l','r'];
% flashTiltDirectionShu = Shuffle(1:length(flashTiltDirection));
% responseKey = 1;
% flashCurrentFrame = 0;  % initial flash frame
% data.wedgeTiltTotal = [];
% tiltFlag = 0;
TR = 2; % second
% the sector first rotate rightward 90 degree and then leftward 180 degree
% rightward 180 degree and so on
% sectorTimeRound = back.AngleRange/(back.SpinSpeed * framerate);% how many second does the background rotate rightward and then leftward cost





%----------------------------------------------------------------------
%                       optseq parameters
%----------------------------------------------------------------------
% [timepoint,stim_type,SOA,~,~] = read_optseq2_data(['optimal_seq/' fileName '/par-00' run_no '.par']);

% event.TypeNumericIdMat = [0 1 2];  % 0 no sector checkerboard(scb) 1 checkerboard tilt left and perceived right  2 checkerboard tilt right and perceived left
% event.InterTimeMat = [4 4 4];

testDuration = 10000;


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
    
    formatSpec = 'This is the %dth of %d block. Click Mouse To Begin';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    %         DrawFormattedText(wptr, '\n\nPress Any Key To Begin', 'center', 'center', blackcolor);
    %         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);
    
    Screen('Flip', wptr);
    
        while 1
            [~,~,button] = GetMouse(wptr);
            if any(button)
                break
            end
        end
%     KbStrokeWait;
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
    
    
    for trial = 1:trialNumber
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        %         prekeyIsDowna = 0;
        %     flashTiltDirection = Shuffle(flashTiltDirectionMat);
        responseFlag = 0;
        %         mouseclick_frame = 0;
        wedgeTiltNow = wedgeTiltStart;
        %         click_mouse = 1;
        back_ground_alpha = back.ground_alphaMat(block);
        back.ground_alpha_step = back.ground_alpha_stepMat(block);
%         back.CurrentAngle = 0;
        
        if dotOrWedgeFlag == 'd'
            adjustAngleL = 0;%11.25;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed); % 360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)/2 - 0.25;
            adjustAngleR = 0;%11.25;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed);% - 0.25;
        elseif dotOrWedgeFlag == 'w'
            adjustAngleL = 360/2/sectorNumber;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed); % 360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)/2 - 0.25;
            adjustAngleR = 360/2/sectorNumber;%360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed) - mod((360/sectorNumber/2 - mod(back.ReverseAngle,back.SpinSpeed)),back.SpinSpeed);% - 0.25;
        end
        
        flashPresentTimes = 0;
        
%         HideCursor;
        
        while respToBeMade  && back_ground_alpha >= 0   % GetSecs - BlockOnset < testDuration  && 
            %             mouseclick_frame = mouseclick_frame + 1;
            %             HideCursor;
            % tilt right  background first rotate clockwise until to the reverse angle
            if back.CurrentAngle >= back.ReverseAngle + adjustAngleL + wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = - 1;
                back.FlagSpinDirecA = back.SpinDirec;
                %                 back.RotateTimes = back.RotateTimes + 1;
                % tilt left
            elseif back.CurrentAngle <= - back.ReverseAngle + adjustAngleR + wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = 1;
                back.FlagSpinDirecB = back.SpinDirec;
                %                 back.RotateTimes = back.RotateTimes + 1;
                
            end
            %----------------------------------------------------------------------
            %       flash twice  and the sector gradually dissapear
            %----------------------------------------------------------------------
            if flashPresentTimes >= flashPresentTimesCeiling && back_ground_alpha >= 0
                back_ground_alpha = back_ground_alpha - back.ground_alpha_step;
            end
            
            %    draw background each frame
            Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back_ground_alpha); %  + backGroundRota
            
            % draw background radial lines for mouse click
            Screen('DrawLines', wptr, radial_line_mat_short, 4, blackcolor, [xCenter yCenter]);
            Screen('DrawLines', wptr, radial_line_mat_long, 5, bluecolor, [xCenter yCenter]);
            
            
            
            % present flash tilt right
            if data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1  && flashPresentTimes <= (flashPresentTimesCeiling - 1) % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                 if dotOrWedgeFlag == 'd'
                    %  dotcoord = [xCenter + dotRadius2Center * cosd(90-wedgeTiltNow)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    Screen('FillOval', wptr,dotColor,dotRect);
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
                end
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
                % present flash tilt left
            elseif data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1  && flashPresentTimes <= (flashPresentTimesCeiling - 1)  % flash tilt left
                
                if dotOrWedgeFlag == 'd'
                    %  dotcoord = [xCenter + dotRadius2Center * cosd(90-wedgeTiltNow)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    % draw dots
                    %  Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    
                    Screen('FillOval', wptr,dotColor,dotRect);
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL ,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    
                end
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
            end
            
            back.FlagSpinDirecA = 0;
            back.FlagSpinDirecB = 0;
            
            
            [keyIsDown,secs,keyCode] = KbCheck(-1);
            if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyCode(KbName('ESCAPE'))
                    sca;
                    return
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                end
            end
            
            
            Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]); % fixation
            Screen('Flip',wptr);
            
            back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;

            
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/framerate) * flashRepresentFrame);
                
            end
            
            % for debug when flash present the simulus halt
            if debug== 'y' && flashPresentFlag
                KbWait;
            end
            
        end
        
        
        %----------------------------------------------------------------------
        % detect the cursor movement and make the flash move with the cursor
        %----------------------------------------------------------------------
        ShowCursor;
        %         mouseclick_frame = 0;
        [x,y] = GetMouse(wptr);
        WaitSecs(0.5);
        data.mousePressCenterCoordinate_x(block,trial) = x;
        data.mousePressCenterCoordinate_y(block,trial) = y;
        
        
        while 1
            
            [mouse_x,mouse_y,buttons] = GetMouse(wptr);
            mouseMoveDegree = rad2deg(atan((x - mouse_x)/(mouse_y - (y - dotRadius2Center))));
            Screen('FillArc',wptr,redcolor,redSectorRect,  180 - adjustAngleL + mouseMoveDegree,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
            Screen('FillArc',wptr,bottomcolor,InnerSectorRect,180 - adjustAngleL + mouseMoveDegree,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
            
            
            
            [keyIsDown,secs,keyCode] = KbCheck(-1);
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                click_mouse = 1;
                sca;
                return
            end
            
            % draw background radial lines for mousepress
            Screen('DrawLines', wptr, radial_line_mat_short, 4, blackcolor, [xCenter yCenter]);
            Screen('DrawLines', wptr, radial_line_mat_long, 5, bluecolor, [xCenter yCenter]);
            Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]); % fixation
            Screen('Flip',wptr);
            
            if any(buttons)
                data.mousePressCoordinate_x(block,trial) = mouse_x;
                data.mousePressCoordinate_y(block,trial) = mouse_y;
                WaitSecs(0.5);
                break
            end
        end
        click_mouse = 1;
        %         clear buttons;
        data.mouseMoveDegreeMat(block,trial) = mouseMoveDegree;
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
    savePath = '../data/illusionSize/mousePress/Dot/';
elseif dotOrWedgeFlag == 'w'
    savePath = '../data/illusionSize/mousePress/Wedge/';
end

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------

for n = 1:size(data.mouseMoveDegreeMat,1)
    
    tiltRightIndex = find( data.flashTiltDirection(n,:) == 1 );
    tiltLeftIndex = find( data.flashTiltDirection(n,:) == 2 );
    
    for  m = 1:size(data.mouseMoveDegreeMat,2)/2
        illusionSizeR(n,m) = data.mouseMoveDegreeMat(n,tiltRightIndex(m));
        illusionSizeL(n,m) = data.mouseMoveDegreeMat(n,tiltLeftIndex(m));
    end
end


aveIllusionSizeL(:,sbjnum)= mean(illusionSizeL,2);
aveIllusionSizeR(:,sbjnum) = abs(mean(illusionSizeR,2));

aveIllusionSize(:,sbjnum) = (aveIllusionSizeL(:,sbjnum) + aveIllusionSizeR(:,sbjnum))/2;


X = categorical({'Background contrast'});

% legend('Dot','Wedge');
% bar([aveIllusionSizeAll(1) aveIllusionSizeAll(2)],0.4,'r');
bar([mean(aveIllusionSize,2)],'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar([aveIllusionSizeL aveIllusionSizeR aveIllusionSize],30,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
ylim([0 40]);
set(gca, 'XTick', 1:5, 'XTickLabels', {'0.06' '0.12' '0.24' '0.48' '0.96'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Flash shift at different background contrast','FontSize',25);


sca;
