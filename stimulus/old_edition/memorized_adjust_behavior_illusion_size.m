% in 7T onscan behavior experiment
% generate a flash-grab red wedge for flash-grab illusion
% adjust the illusion until the perception of the red flash is vertical
% record the illusion size of each subject

% flash tilt right:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1
% flash perceived tilt left : data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1
% the result for

% clear all;
clearvars;

if 1
    sbjname = 'k';
    debug = 'n';
    %     illusion = 'y';
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    %     illusion = input('>>>Illusion or no illusion? (y/n):  ','s');
    
end

illusion = 'y';
trialNumber = 20;  % total min = 40 trial * 6s/try/60 = 4 min
block = 1;

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
bluecolor = [0 0 200];
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

visualDegreeOrig = 10;
sectorRadius_in_out_magni = 1;
visualDegree = visualDegreeOrig * sectorRadius_in_out_magni;
visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75;
visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;



% %----------------------------------------------------------------------
% %                      draw background sector
% %----------------------------------------------------------------------
%
sectorNumber = 8;
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus

sectorRadius_in_pixel = sectorRadius_out_pixel - 100 * sectorRadius_in_out_magni;    % inner diameter of background annulus


dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
[sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree, blackcolor, whitecolor,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel);


%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

% sector rotation from the degree of half wedge
back.CurrentAngle = 360/sectorNumber/2;
% back.ground_alpha = 0.3;
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
flashPresentTimesCeiling = 2;
flashRepresentFrame = 2.2; % 2.2 means 3 frame

%----------------------------------------------------------------------
%             experiment condition parameters
%----------------------------------------------------------------------

% % each experiment generate the same sequence for flash direction,
% % different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
data.flashTiltDirection = Shuffle(back.flashTiltDirectionMat);
% data.flashTiltDirection = stimtype;
back.ground_alpha_step = 0.3/(0.8*framerate);

%----------------------------------------------------------------------
%      randomize the degree of the red wedge at response
%----------------------------------------------------------------------

degreeSetUpMatLeft = Shuffle(repmat([0;20],trialNumber/4,1));

degreeSetUpMatRight = Shuffle(repmat([0;-20],trialNumber/4,1));


%----------------------------------------------------------------------
%        load the screen adjust parameters
%----------------------------------------------------------------------
cd '../data/7T/screen_adjust_parameter/';
illusionSizeFileName = strcat(sbjname,'*.mat');
Files = dir([illusionSizeFileName]);
load (Files.name);

cd '../../../stimulus/'

sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;


%----------------------------------------------------------------------
%                      draw red wedge
%----------------------------------------------------------------------

coverSectorShrink = 4; % 2 big cover sector 4 small cover sector

% coverSectorRect = [xCenter + centerMoveHoriPix - xCenter/coverSectorShrink yCenter + centerMoveVertiPix - xCenter/coverSectorShrink...
%     xCenter + centerMoveHoriPix  + xCenter/coverSectorShrink  yCenter + centerMoveVertiPix + xCenter/coverSectorShrink];

redSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel...
    xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];

redSectorRectAdjust = CenterRectOnPoint(redSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);

InnerSectorRect = [xCenter  - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel...
    xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];

InnerSectorRectAdjust = CenterRectOnPoint(InnerSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);

sectorArcAngle = 360/sectorNumber;

%----------------------------------------------------------------------
%%%   draw radial lines on the backgound for mouse point
%----------------------------------------------------------------------
radial_line_number_long = 5;  %5
radial_line_length_long = 15; %15
startDistanceFromCenter = sectorRadius_out_pixel + 5;
radial_line_number_short = 25;%25
radial_line_length_short = 5; %5

[radial_line_mat_long] = drawRadialLinesMat(radial_line_number_long,radial_line_length_long,startDistanceFromCenter);
[radial_line_mat_short] = drawRadialLinesMat(radial_line_number_short,radial_line_length_short,startDistanceFromCenter);


%----------------------------------------------------------------------
%       present a start screen and wait for a key-press
%----------------------------------------------------------------------

% formatSpec = 'This is the %dth of %d block. Click s To Begin';
%
% A1 = block;
% A2 = blockNumber;
% str = sprintf(formatSpec,A1,A2);
% DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
DrawFormattedText(wptr, '\n\nPress s To Begin', 'center', 'center', blackcolor);
%         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);

Screen('Flip', wptr);


%     KbStrokeWait;
%     KbWait;

checkflag = 1;

while checkflag
    [~, ~, keyCode, ~] = KbCheck(-1);
    if keyCode(KbName('s'))
        checkflag = 0;
    end
end


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
scanOnset = GetSecs;
flashPresentTimes = 0;

% for block = 1 : blockNumber


for trial = 1:trialNumber
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    trailOnset = GetSecs;
    respToBeMade = true;
    back.ground_alpha = 0.3;
    flashPresentTimes = 0;
    
    wedgeTiltNow = wedgeTiltStart;
    trialOnset = GetSecs;
    %     keyPress = 0;
    
    % adjust the edge of the wedge on the vertical meridian
    adjustAngle = 360/2/sectorNumber;
    
    
    back.FlagSpinDirecA = 0;% flash tilt right
    back.FlagSpinDirecB = 0;% flash tilt left
    
    
    %     testDuration = stimlength(trial)
    testDuration = 10000;
    flashPresentFlag = 0;
    prekeyIsDown = 0;
    
    
    while respToBeMade && back.ground_alpha >= 0  % (GetSecs - trailOnset < testDuration) && respToBeMade  % back.RotateTimes < testDuration %  % &&  respToBeMade
        %             mouseclick_frame = mouseclick_frame + 1;
        %             HideCursor;
        
        flashPresentFlag = 0;
        
        %         if keyPress == 1
        %             back.CurrentAngle = wedgeTiltNow;
        %             keyPress = 0;
        %         end
        
        %         flashPresentFlag = 0;
        
        
        % tilt right  background first rotate clockwise until to the reverse angle
        if back.CurrentAngle >= back.ReverseAngle + adjustAngle + wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = - 1;
            back.FlagSpinDirecA = back.SpinDirec;
            % tilt left
        elseif back.CurrentAngle <= - back.ReverseAngle + adjustAngle + wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = 1;
            back.FlagSpinDirecB = back.SpinDirec;
        end
        
        %----------------------------------------------------------------------
        %       flash twice  and the sector gradually dissapear
        %----------------------------------------------------------------------
        if flashPresentTimes >= flashPresentTimesCeiling && back.ground_alpha >= 0
            back.ground_alpha = back.ground_alpha - back.ground_alpha_step;
        end
        
        %    draw background each frame
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
        
        %         % draw background radial lines for mouse click
        %         Screen('DrawLines', wptr, radial_line_mat_short, 4, blackcolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        %         Screen('DrawLines', wptr, radial_line_mat_long, 5, bluecolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        
        
        %         %    draw background each frame
        %         Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
        
        
        %----------------------------------------------------------------------
        %       flash at reverse onset
        %----------------------------------------------------------------------
        
        % present flash tilt right
        if data.flashTiltDirection(trial,block) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right
            
            % background on the vertical meridian the left part is always
            % white and the right part is always black
            %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
            
            % draw red wedge
            Screen('FillArc',wptr,redcolor,redSectorRectAdjust,back.CurrentAngle + 90 - 2*adjustAngle,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
            Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,back.CurrentAngle + 90 - 2*adjustAngle,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
            flashPresentTimes = flashPresentTimes + 1;
            flashPresentFlag = 1;
            
            % present flash tilt left
        elseif data.flashTiltDirection(trial,block) == 2  && back.FlagSpinDirecB ==  1   % flash tilt left
            
            % draw red wedge
            Screen('FillArc',wptr,redcolor,redSectorRectAdjust,back.CurrentAngle - 90 - 2*adjustAngle,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
            Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,back.CurrentAngle - 90 - 2*adjustAngle,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
            flashPresentTimes = flashPresentTimes + 1;
            flashPresentFlag = 1;
            
        end
        
        back.FlagSpinDirecA = 0;
        back.FlagSpinDirecB = 0;
        
        %           back.CurrentAngle = back.CurrentAngle + 3;
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        
        %             Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMoveHoriPix,xCenter+fixsize,yCenter+fixsize-centerMoveVertiPix]); % fixation
        Screen('DrawLines', wptr, allCoords,lineWidthPix, whitecolor, [xCenter+centerMoveHoriPix yCenter+centerMoveVertiPix]);
        Screen('Flip',wptr);
        
        % define the present frame of the flash
        if flashPresentFlag
            WaitSecs((1/framerate) * flashRepresentFrame);
        end
        
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        %         prekeyIsDown = 0;
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                %             elseif keyCode(KbName('3')) || keyCode(KbName('3#'))
                %                 respToBeMade = false;
                %                     WaitSecs(0.5);
            end
        end
        
        prekeyIsDown = keyIsDown;
        
        % for debug when flash present the simulus halt
        if debug== 'y' && flashPresentFlag
            KbWait;
        end
        
    end
    
    %     data.wedgeTiltEachBlock(block,trial) = wedgeTiltNow;
    WaitSecs (0.8);
    
    %----------------------------------------------------------------------
    % detect the cursor movement and make the flash move with the cursor
    %----------------------------------------------------------------------
    respToBeMade = true;
    
    
    while respToBeMade
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        %         prekeyIsDown = 0;
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyIsDown % && ~prekeyIsDown   % prevent the same press was treated twice
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                % the bar was on the left of the gabor
            elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
                wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                %                 keyPress = 1;
            elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                %                 keyPress = 1;
            elseif keyCode(KbName('3')) || keyCode(KbName('3#'))
                respToBeMade = false;
                %                     WaitSecs(0.5);
            end
        end
        
        %         prekeyIsDown = keyIsDown;
        
        
        %----------------------------------------------------------------------
        %              randomize the red wedge setup location degree
        %----------------------------------------------------------------------
        if data.flashTiltDirection(trial) == 2   % flash tilt left
            if mod(trial,2) == 1
                degreeSetUpLeft = degreeSetUpMatLeft((trial+1)/2);
            elseif mod(trial,2) == 0
                degreeSetUpLeft = degreeSetUpMatLeft(trial/2);
            end
            % draw flash - red wedge
            Screen('FillArc',wptr,redcolor,redSectorRectAdjust,180 - 360/sectorNumber/2 + wedgeTiltNow + degreeSetUpLeft,sectorArcAngle);
            Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,180 - 360/sectorNumber/2 + wedgeTiltNow + degreeSetUpLeft,sectorArcAngle);
            
        elseif data.flashTiltDirection(trial) == 1    % flash tilt right
            if mod(trial,2) == 1
                degreeSetUpRight = degreeSetUpMatRight((trial+1)/2);
            elseif mod(trial,2) == 0
                degreeSetUpRight = degreeSetUpMatRight(trial/2);
            end
            % draw flash - red wedge
            Screen('FillArc',wptr,redcolor,redSectorRectAdjust,180 - 360/sectorNumber/2 + wedgeTiltNow + degreeSetUpRight,sectorArcAngle);
            Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,180 - 360/sectorNumber/2 + wedgeTiltNow + degreeSetUpRight,sectorArcAngle);
        end
        
        
        
        
        %         % draw background radial lines for mousepress
        %         Screen('DrawLines', wptr, radial_line_mat_short, 4, blackcolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        %         Screen('DrawLines', wptr, radial_line_mat_long, 5, bluecolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        %
        % fixation cross
        Screen('DrawLines', wptr, allCoords,lineWidthPix, whitecolor, [xCenter+centerMoveHoriPix yCenter+centerMoveVertiPix]);
        Screen('Flip',wptr);
        
        
    end
    
    data.wedgeMoveDegreeMat(trial) = wedgeTiltNow;
    
    
end

%----------------------------------------------------------------------
%  average illusion size  save the variable to another folder for 7T exp
%  load
%----------------------------------------------------------------------

tiltRightIndex = find( data.flashTiltDirection(:,:) == 1 );
tiltLeftIndex = find( data.flashTiltDirection(:,:) == 2 );

illusionSizeR = data.wedgeTiltEachBlock(tiltRightIndex);
illusionSizeL = data.wedgeTiltEachBlock(tiltLeftIndex);

aveIlluSizeR = mean(illusionSizeR);
aveIlluSizeL = mean(illusionSizeL);

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end

if sectorRadius_in_out_magni == 1
    savePath = '../data/7T/illusionSize_fade/small/';
else
    savePath = '../data/7T/illusionSize_fade/magnification/';
end

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename1 = [savePath,filename];
% save(filename2,'data','back');
save(filename1);



% savePath = '../data/7T/illusionSize_7T/';
% filename2 = [savePath,filename];
% save(filename2,'aveIlluSizeL','aveIlluSizeR','sbjname');
% sca;
