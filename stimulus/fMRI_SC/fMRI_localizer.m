
% localizer for SC
% fixation baseline presented every other trial between tilt left and tilt
% right
% checkerboard wedge  alternate present left and right visual field in the
% perceived location of the subject

function  fMRI_localizer(sbjname,run_no)


if nargin < 1
    sbjname = 'dingyingshi';
    run_no='1';
else
    sbjname=sbjname;
    run_no=run_no;
end
% Clear the workspace
% close all;
% clear all;


% if 0
%     sbjname = 'huijiahan';
%     run_no = '1';
% else    
%     run_no = input('>>>The number of the run:   ','s');
%     sbjname = input('>>>Please input the subject''s name:   ','s');
% end

trialNumber = 20;

%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------
% Screen('Preference', 'SkipSyncTests', 1);
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
% the color change of the fixation  diminish the color change effect on SC
fixationwhite = 0.8 * white;
fixationblack = black + 0.3; 

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,grey, [], [], [], [],0); 
HideCursor;
% [0 0 1280 720]   kPsychNeed32BPCFloat  PsychImaging
% Screen('FrameRate')
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
addpath ../../function;

load ../../function/calib-PC-03-Dec-2021_3t.mat;  % this is for 3T screen on the black mac pro

dacsize = 10;  %How many bits per pixel#
maxcol = 2.^dacsize-1;
ncolors = 256; % see details in makebkg.m
newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
newclut(1:ncolors,:) = newcmap./maxcol;
newclut(isnan(newclut)) = 0;

[Origgammatable, ~, ~] = Screen('ReadNormalizedGammaTable', window);
Screen('LoadNormalizedGammaTable', window, newclut);

%----------------------------------------------------------------------
%               3T Screen parameter
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
outpara = 10;%  2 * xCenter*2/192;
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - outpara)/2);%  + centerMovePix;   % outer radii of background annulus
inpara = 100;% 10 * xCenter*2/192;
sectorRadius_in_pixel = sectorRadius_out_pixel - inpara * sectorRadius_in_out_magni;    % inner diameter of background annulus


% dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
% [sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree, blackcolor, whitecolor,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel);

%----------------------------------------------------------------------
%      draw checkerboard and setting parameters
%----------------------------------------------------------------------

[checks] = makecheckerboard_localizer(sectorRadius_out_pixel,white,black,grey);

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/7.5;  %7.5
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
% frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% % Sync us to the vertical retrace
% vbl = Screen('Flip', window);


if run_no == '1'
    % 2 types of localizer  1 left and 2 right  and 3 control nothing
    localizerMat = repmat([1; 3; 2; 3],trialNumber/4,1);   % the first subject localizerMat size is (40,1)
elseif run_no == '2'
    localizerMat = repmat([2; 3; 1; 3],trialNumber/4,1);
end
% localizerMatRand = localizerMat(Shuffle(1:length(localizerMat)));

% the duration of checkerboard flickering in seconds
checkerboardFlickDura = 16; % seconds
% colorSwitchTimesMain = 3;  % during the checkerboard flickering the color of fixation switch times

% make sure the response switch number change over runs
if run_no == '1'
    localizerSwitchTimeSeg = [2; 3; 3; 3];
elseif run_no == '2'
    localizerSwitchTimeSeg = [2; 2; 3; 3];
elseif run_no == '3'
    localizerSwitchTimeSeg = [2; 2; 2; 3];
end

fixFlashTimesMat = repmat(localizerSwitchTimeSeg,trialNumber/4,1);
fixFlashTimesRand = fixFlashTimesMat(Shuffle(1:length(fixFlashTimesMat)));
fixFlashDura = 0.5;  % time duration of fixation color change (total time of ramp up and ramp down)

% %----------------------------------------------------------------------
% %        load the screen adjust parameters
% %----------------------------------------------------------------------
% cd '../data/7T/screen_adjust_parameter/';
% illusionSizeFileName = strcat(sbjname,'*.mat');
% Files = dir(illusionSizeFileName);
% load (Files.name);
% 
% cd '../../../stimulus/'

%----------------------------------------------------------------------
%     load subject illusion size data
%----------------------------------------------------------------------

cd '../../data/3T/illusionSize_3T/';
illusionSizeFileName = strcat(sbjname,'*.mat');
Files = dir(illusionSizeFileName);
load (Files.name,'aveIlluSizeL','aveIlluSizeR');

cd '../../../stimulus/'



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

% DrawFormattedText(window, '\n\n Press s To Begin', 'center', 'center', black);
DrawFormattedText(window, '\n\n\n\n How many times does the white color switch to black', 'center', 'center', black);

Screen('DrawLines', window, allCoords,lineWidthPix, fixationwhite, [xCenter+centerMoveHoriPix yCenter+centerMoveVertiPix]);
Screen('Flip', window);


checkflag = 1;

while checkflag
    [~, ~, keyCode, ~] = KbCheck(-1);
    if keyCode(KbName('s'))
        checkflag = 0;
    end
end

dummyScanTime = 4;
WaitSecs(dummyScanTime); % dummy scan
scanOnset = GetSecs;
frametimepoint = scanOnset;
trialOnset = zeros(trialNumber,1);

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
    frameCounter = 0;
    
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
       
        fixaColorChangeCycleRadian = fixationblack;   
        % Draw our texture to the screen
        Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)),[],maskSectorRectAdjust);  %sectorDestinationRect
        %localizerType = 1 left and localizerType = 2 right  and 3 control nothing
        if localizerType == 1
            
%             % checkerboard left    mask right     angle start from right above
%             Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 45, maskSectorArcAngle);
%             Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180,maskInnerSectorArcAngle);
            
            % checkerboard location left use aveIlluSizeL   so mask right 
            Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 22.5 + aveIlluSizeL, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 22.5 + aveIlluSizeL,maskInnerSectorArcAngle);
            
            
        elseif localizerType == 2
%             % checkerboard right    mask left     angle start from right above
%             Screen('FillArc',window,grey,maskSectorRectAdjust,180, maskSectorArcAngle);
%             Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 45, maskInnerSectorArcAngle);
            
             % checkerboard location right use aveIlluSizeR(negtive) so mask left      angle start from right above
            Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 22.5 + aveIlluSizeR, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 22.5 + aveIlluSizeR, maskInnerSectorArcAngle);
            
%         elseif  localizerType == 3  
%             % checkerboard at the center of bottom
%              Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 22.5, maskSectorArcAngle);
%             Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 22.5, maskInnerSectorArcAngle);
            
        % no checkerboard only fixation
        elseif localizerType == 3
            Screen('FillArc',window,grey,maskSectorRectAdjust,0, 360);
        end
        
        
        
%         fixaColorChangeCycleRadian = 0:pi/(fixFlashDura/ifi+1):pi/2; %pi*ifi/fixFlashDura
%         fixaColorChangeCycleRadian = 0:0.03:pi/2;
        %         if frameCounterFixation >= length(theta)
        %             frameCounterFixation = 0;
        %         end
%         if fixaColorChangeCycleRadian(frameCounterFixation+1) >= pi
%             frameCounterFixation = 0;
%         end
%         currentTimepoint = GetSecs - trialOnset(trial) ;
        if fixSwitchTimes == 2

            % from the first switch time  point the
            % fixation color gradually change from white to black
           currentTimepoint = GetSecs - trialOnset(trial) ;
            if currentTimepoint > fixFlashTimePoint(1) && currentTimepoint <= (fixFlashTimePoint(1) + fixFlashDura) ...
                    || currentTimepoint > fixFlashTimePoint(2)+fixFlashTimeWinRange*3 && currentTimepoint <= fixFlashTimePoint(2) +fixFlashTimeWinRange*3 + fixFlashDura
                fixaColorChangeCycleRadian = fixaColorChangeCycleRadian + pi/(fixFlashDura/ifi);
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian);
            else 
                fixationColor = fixationwhite;
                frameCounterFixation = 0; 
            end      
           

            
        elseif fixSwitchTimes == 3
            currentTimepoint = GetSecs - trialOnset(trial) ;
            
            if currentTimepoint > fixFlashTimePoint(1) && currentTimepoint <= (fixFlashTimePoint(1) + fixFlashDura) ...
                    || currentTimepoint > fixFlashTimePoint(2)+fixFlashTimeWinRange*3 && currentTimepoint <= fixFlashTimePoint(2) +fixFlashTimeWinRange*3 + fixFlashDura...
                    || currentTimepoint > fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 && currentTimepoint <= fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 + fixFlashDura
                
                fixaColorChangeCycleRadian = fixaColorChangeCycleRadian + pi/(fixFlashDura/ifi);
                fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian);
            else
                fixationColor = fixationwhite;
                frameCounterFixation = 0;
            end
                
            
%              if GetSecs - trialOnset(trial) > fixFlashTimePoint(1) &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(1) + fixFlashDura
%                 frameCounterFixation = frameCounterFixation + 1;
%                 fixaColorChangeCycleRadian = fixaColorChangeCycleRadian + pi/(fixFlashDura/ifi + 1);
%                 fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian);
%                               
%             elseif GetSecs - trialOnset(trial) > fixFlashTimePoint(2)+fixFlashTimeWinRange*3 &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(2)+fixFlashTimeWinRange*3 + fixFlashDura
%                 frameCounterFixation = frameCounterFixation + 1;
%                 fixaColorChangeCycleRadian = fixaColorChangeCycleRadian + pi/(fixFlashDura/ifi + 1);
%                 fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian);
%                 
%             elseif GetSecs - trialOnset(trial) > fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 &&  GetSecs - trialOnset(trial) <= fixFlashTimePoint(3)+2*fixFlashTimeWinRange*3 + fixFlashDura
%                 frameCounterFixation = frameCounterFixation + 1;
%                 fixaColorChangeCycleRadian = fixaColorChangeCycleRadian + pi/(fixFlashDura/ifi + 1);
%                 fixationColor = fixationwhite * sin(fixaColorChangeCycleRadian);
% 
%             else
%                 fixationColor = fixationwhite;
%                 frameCounterFixation = 0; 
%                 
%             end
        end
        
        
        Screen('DrawLines', window, allCoords,lineWidthPix, fixationColor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        
       
        % Flip to the screen
%         vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        Screen('Flip', window);
        
        frametimepoint = [frametimepoint GetSecs];                
                        
        frameCounter = frameCounter + 1;
        
                        
                        
                        
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

display(GetSecs - scanOnset);
%----------------------------------------------------------------------
%                      Response record
%----------------------------------------------------------------------

colorChangeTimes =  colorChangeTimesStartNumberRand(trial);
respToBeMade = true;
prekeyIsDown = 0;

while  respToBeMade
%     formatSpec = 'How many times does the fixation change the color?\n\n\n The fixation color changed %d times. \n\n\n  1   increasing  \n  2  decreasing  \n 3 confirm';
      formatSpec = 'The fixation color change 40 times.\n\n\n  1   right  \n  2  wrong ';

    str = sprintf(formatSpec,colorChangeTimes);
    Screen('TextSize', window,40);
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
            respToBeMade = false;
        elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
            colorChangeTimes = colorChangeTimes - 1;
            respToBeMade = false;
%         elseif keyCode(KbName('3')) ||keyCode(KbName('3#'))
%             respToBeMade = false;
        end
    end
    
    prekeyIsDown = keyIsDown;
    
    Screen('Flip', window);
    
    
end

colorChangeTimesMat = colorChangeTimes;

display(GetSecs - scanOnset);
%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end


savePath = '../data/3T/localizer/';

time = clock;

filename = sprintf('%s_%s_%02g_%02g_%02g_%02g_%02g',sbjname,run_no,time(1),time(2),time(3),time(4),time(5));
filename1 = [savePath,filename];
% save(filename2,'data','back');
save(filename1);


% Clear up and leave the building
sca;

frameinterval = frametimepoint(2:end)-frametimepoint(1:end-1);
plot(frameinterval);

% end 