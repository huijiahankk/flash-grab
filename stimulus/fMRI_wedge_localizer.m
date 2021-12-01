
% localizer for SC
% fixation baseline presented every other trial between tilt left and tilt
% right
% checkerboard wedge  alternate present left and right visual field in the
% perceived location of the subject


% Clear the workspace
close all;
clear all;
sca;

if 1
    sbjname = 'huijiahan';
else
    sbjname = input('>>>Please input the subject''s name:   ','s');
end


Screen('Preference', 'SkipSyncTests', 1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% swith curser to the commandwindow
commandwindow;

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
fixationwhite = 0.8 * white;
fixationblack = black + 0.2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,grey, [0 0 1024 768], [], [], [],0);    % [0 0 1024 768]   kPsychNeed32BPCFloat

% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% framerate = FrameRate(window);

% Screen resolution in Y
screenYpix = windowRect(4);
[xCenter,yCenter] = WindowCenter(window);
[centerMoveHoriPix,centerMoveVertiPix] = deal(0);
sectorRect = [0  yCenter - xCenter  2*xCenter yCenter + xCenter];

%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------


% load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;   %????????????????????????????????????????????????
% % load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro
%
% dacsize = 10;  %How many bits per pixel#
% maxcol = 2.^dacsize-1;
% ncolors = 256; % see details in makebkg.m
% newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
% newclut(1:ncolors,:) = newcmap./maxcol;
% newclut(isnan(newclut)) = 0;
%
% [Origgammatable, ~, ~] = Screen('ReadNormalizedGammaTable', wptr);
% Screen('LoadNormalizedGammaTable', wptr, newclut);

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

%----------------------------------------------------------------------
%              parameter of  background sector
%----------------------------------------------------------------------
%
sectorNumber = 8;
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus

sectorRadius_in_pixel = sectorRadius_out_pixel - 100 * sectorRadius_in_out_magni;    % inner diameter of background annulus


% dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
% [sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree, blackcolor, whitecolor,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel);

%----------------------------------------------------------------------
%      draw   checkerboard
%----------------------------------------------------------------------
trialNumber = 6;

% 2 localizer  left and right  and 1 control nothing
localizerMat = repmat([1; 3; 2; 3],trialNumber/2,1);
% localizerMatRand = localizerMat(Shuffle(1:length(localizerMat)));


% Number of white/black circle pairs
rcycles = 4; %2

% Number of white/black angular segment pairs (integer)
tcycles = 12;

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (sectorRadius_out_pixel*2 - 1): xylim,...
    -xylim: 2 * xylim / (sectorRadius_out_pixel*2  - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* checks + grey * ~circle;

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/7.5;  %7.5
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% % Sync us to the vertical retrace
vbl = Screen('Flip', window);


% the duration of checkerboard flickering in seconds

checkerboardFlickDura = 16; % seconds
% colorSwitchTimesMain = 3;  % during the checkerboard flickering the color of fixation switch times
fixFlashTimesMat = repmat([2; 3],trialNumber/2,1);
fixFlashTimesRand = fixFlashTimesMat(Shuffle(1:length(fixFlashTimesMat)));
fixFlashDura = 1;  % time duration of fixation color change (total time of ramp up and ramp down)

%----------------------------------------------------------------------
%        load the screen adjust parameters
%----------------------------------------------------------------------
cd '../data/7T/screen_adjust_parameter/';
illusionSizeFileName = strcat(sbjname,'*.mat');
Files = dir(illusionSizeFileName);
load (Files.name);

cd '../../../stimulus/'

%----------------------------------------------------------------------
%     load subject illusion size data
%----------------------------------------------------------------------

cd '../data/7T/illusionSize_memorized_illusion_adjust/small/';
illusionSizeFileName = strcat(sbjname,'*.mat');
Files = dir(illusionSizeFileName);
load (Files.name,'aveIlluSizeL','aveIlluSizeR');

cd '../../../../stimulus/'



%----------------------------------------------------------------------
%                       fixation parameters
%----------------------------------------------------------------------
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 10;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;

% random the present numbers for fixation color changing time
colorChangeTimesStartNumberMat = repmat([12; 15; 18],trialNumber/2,1);
colorChangeTimesStartNumberRand = colorChangeTimesStartNumberMat(Shuffle(1:length(colorChangeTimesStartNumberMat)));

%----------------------------------------------------------------------
%               mask the part of checkerboard
%----------------------------------------------------------------------
maskSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel...
    xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];

maskSectorRectAdjust = CenterRectOnPoint(maskSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
maskSectorArcAngle = 315;

% mask the sector made it into a wedge
maskInnerSectorRect = [xCenter  - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel...
    xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];
maskInnerSectorRectAdjust = CenterRectOnPoint(maskInnerSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
maskInnerSectorArcAngle = 45;

% %----------------------------------------------------------------------
% %      fixation baseline test before the localizer
% %----------------------------------------------------------------------
% % if the subject forget to press the keyboard, treat the response as -1
% responseFixbaselineFront = - 1;
%
% fixBaselineDura = 8; % 20s
% keyPressTimes = 0;
% prekeyIsDown = 0;
% colorSwitchTimesBaselineFront = 4;
%
% colorSwitchTimeBaselineMat = sort(randperm(fixBaselineDura,colorSwitchTimesBaselineFront));

%----------------------------------------------------------------------
%       present a start screen and wait for a 's'     key-press
%----------------------------------------------------------------------
DrawFormattedText(window, '\n\nPress s To Begin', 'center', 'center', black);
Screen('Flip', window);
% baselineOnset = GetSecs;

checkflag = 1;

while checkflag
    [~, ~, keyCode, ~] = KbCheck(-1);
    if keyCode(KbName('s'))
        checkflag = 0;
    end
end



% %----------------------------------------------------------------------
% %      fixation baseline exp   duration = fixBaselineDura = 20s
% %----------------------------------------------------------------------
%
% while GetSecs - baselineOnset <= fixBaselineDura
%
%     if GetSecs - baselineOnset < colorSwitchTimeBaselineMat(1)
%         fixationColor = white;
%     elseif (colorSwitchTimeBaselineMat(1) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < colorSwitchTimeBaselineMat(2))
%         fixationColor = black;
%     elseif (colorSwitchTimeBaselineMat(2) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < colorSwitchTimeBaselineMat(3))
%         fixationColor = white;
%     elseif (colorSwitchTimeBaselineMat(3) < GetSecs - baselineOnset) && (GetSecs - baselineOnset< colorSwitchTimeBaselineMat(4))
%         fixationColor = black;
%     elseif( colorSwitchTimeBaselineMat(4) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < fixBaselineDura)
%         fixationColor = white;
%     end
%
%
%     Screen('DrawLines', window, allCoords,lineWidthPix, fixationColor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
%     % Flip to the screen
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     %----------------------------------------------------------------------
%     %                      Response record
%     %----------------------------------------------------------------------
%
%     [keyIsDown,secs,keyCode] = KbCheck(-1);
%     if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
%         if keyCode(KbName('ESCAPE'))
%             ShowCursor;
%             sca;
%             return
%             % the bar was on the left of the gabor
%         elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
%             responseFixbaselineFront = 1;
%
%         elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
%             responseFixbaselineFront = 2;
%
%         elseif keyCode(KbName('Space'))
%             responseFixbaselineFront = 0;
%             respToBeMade = false;
%         end
%     end
%
%
%     if keyIsDown && ~prekeyIsDown
%         keyPressTimes = keyPressTimes + 1;
%         responseFixbaselineMat(keyPressTimes) = responseFixbaselineFront;
%     end
%     prekeyIsDown = keyIsDown;
%
% end


stimulusOnset = GetSecs;

for trial  = 1:trialNumber
    
    
    trialOnset(trial) = GetSecs;
    localizerType = localizerMat(trial);
    fixSwitchTimes = fixFlashTimesRand(trial);
    
    % fixation flash time point in the second part(/3) of one window
    fixFlashTimeWinRange = checkerboardFlickDura/fixSwitchTimes/3;
    % Random pick up Numbers Within a Specific Range
    % make fixation flash in the second part of the time window
    fixFlashTimePoint = fixFlashTimeWinRange .* rand(1,fixSwitchTimes) + fixFlashTimeWinRange;
    
    frameCounterFixation = 0;
    
    %----------------------------------------------------------------------
    %             fixation color setting
    %----------------------------------------------------------------------
    %     colorMat = randi([0 checkerboardFlickDura],trialNumber,colorSwitchTimes);
    %     color = colorMat(trial,:);
    
%     % sorts the elements of A in ascending order
%     colorSwitchTimeMat = sort(randperm(checkerboardFlickDura,colorSwitchTimesMain));
%     colorSwitchWindows = checkerboardFlickDura/3;
    
    
    while GetSecs - trialOnset(trial) <= checkerboardFlickDura
        
        % Increment the counter
        frameCounter = frameCounter + 1;
        
        % Draw our texture to the screen
        Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)),[],maskSectorRectAdjust);  %sectorDestinationRect
        
        if localizerType == 1
            
            % checkerboard left    mask right     angle start from right above
            Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 45, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180,maskInnerSectorArcAngle);
            
        elseif localizerType == 2
            % checkerboard right    mask left     angle start from right above
            Screen('FillArc',window,grey,maskSectorRectAdjust,180, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 45, maskInnerSectorArcAngle);
        elseif localizerType == 3
            Screen('FillArc',window,grey,maskSectorRectAdjust,0, 360);
        end
        
        
        
        fixaColorChangeCycleRadian = 0:pi/(fixFlashDura/ifi+1):pi/2; %pi*ifi/fixFlashDura
%         fixaColorChangeCycleRadian = 0:0.05:pi;
        %         if frameCounterFixation >= length(theta)
        %             frameCounterFixation = 0;
        %         end
%         if fixaColorChangeCycleRadian(frameCounterFixation+1) >= pi
%             frameCounterFixation = 0;
%         end
        
        if fixSwitchTimes == 2

            % from the first switch time  point the
            % fixation color gradually change from white to black
            if GetSecs - trialOnset(trial) > fixFlashTimePoint(1) &&  GetSecs - trialOnset(trial) <= (fixFlashTimePoint(1) + fixFlashDura)
                frameCounterFixation = frameCounterFixation + 1;
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian(frameCounterFixation));
                                
                % from the second time point the fixation color gradually change from black to white
            elseif GetSecs - trialOnset(trial) > fixFlashTimePoint(2)+fixFlashTimeWinRange*3 &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(2) +fixFlashTimeWinRange*3 + fixFlashDura
                frameCounterFixation = frameCounterFixation + 1;
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian(frameCounterFixation));
                
            else 
                fixationColor = fixationwhite;
                frameCounterFixation = 0; 
            end
            
        elseif fixSwitchTimes == 3            
                   
             if GetSecs - trialOnset(trial) > fixFlashTimePoint(1) &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(1) + fixFlashDura
                frameCounterFixation = frameCounterFixation + 1;
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian(frameCounterFixation));
                              
            elseif GetSecs - trialOnset(trial) > fixFlashTimePoint(2)+fixFlashTimeWinRange*3 &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(2)+fixFlashTimeWinRange*3 + fixFlashDura
                frameCounterFixation = frameCounterFixation + 1;
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian(frameCounterFixation));
                
            elseif GetSecs - trialOnset(trial) > fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 + fixFlashDura
                frameCounterFixation = frameCounterFixation + 1;
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian(frameCounterFixation));

            else
                fixationColor = fixationwhite;
                frameCounterFixation = 0; 
                
            end
        end
        
        
        Screen('DrawLines', window, allCoords,lineWidthPix, fixationColor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        %                 Screen('Flip', window);
        
        % Reverse the texture cue to show the other polarity if the time is up
        if frameCounter == checkFlipTimeFrames
            textureCue = fliplr(textureCue);
            frameCounter = 0;
        end
        
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyCode(KbName('ESCAPE'))
            ShowCursor;
            sca;
        end
        
    end
end
%----------------------------------------------------------------------
%                      Response record
%----------------------------------------------------------------------

colorChangeTimes =  colorChangeTimesStartNumberRand(trial);
respToBeMade = true;
prekeyIsDown = 0;

while  respToBeMade
    formatSpec = 'How many times does the fixation change the color?\n\n\n The fixation color changed %d times. \n\n\n  1   increasing  \n  2  decreasing  \n 3 confirm';
    
    str = sprintf(formatSpec,colorChangeTimes);
    
    DrawFormattedText(window, str, 'center', 'center', black);
    
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
        if keyCode(KbName('ESCAPE'))
            ShowCursor;
            respToBeMade = false;
            sca;
            return
        elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
            colorChangeTimes = colorChangeTimes + 1;
            
        elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
            colorChangeTimes = colorChangeTimes - 1;
            
        elseif keyCode(KbName('3')) ||keyCode(KbName('3#'))
            respToBeMade = false;
        end
    end
    
    prekeyIsDown = keyIsDown;
    
    Screen('Flip', window);
    
end

colorChangeTimesMat(trial) = colorChangeTimes;


%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end


savePath = '../data/7T/localizer/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename1 = [savePath,filename];
% save(filename2,'data','back');
save(filename1);


% Clear up and leave the building
sca;
close all;
