
% for cortical blindness patient
% generate the flash grab illusion with 2 sector.  one boundary was blurred
% and the other with sharp bounday so this stimulus could generate flash grab illusion
% without integrated red bar flash.
% Test this blurred boundary pattern as control with bar only condition.
% If this moving boundary the same as off_sync condition

%  5 condition :(all from vi2invi  and then invi2vi)
% bar_only
% blurred boundary
% off_sync
% grab
% perceived



clear all;close all;

if 1
    sbjname = 'k';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame    for blindspot normal subject is 4.2 frame
    redbarflash_flag = 1; % barflash_flag = 0  no red flash bar    barflash_flag = 1  with red flashed bar
    barLocation = 'l';  % u  upper visual field   l   lower visual field n  normal
    condition = 'invi2vi';   % 'vi2invi'  'invi2vi'   'normal'
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = 'n';
    %     debug = input('>>>Debug? (y/n):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
    condition = input('>>>visible2invisible or invisible2visible? (vi2invi  invi2vi normal):  ','s');
    
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../../function;
addpath ../../../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
bottomcolor = (whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[displaywidth, ~] = Screen('DisplaySize', screenNumber);
% [screenXpixels, screenYpixels] = Screen('WindowSize', wptr);
[xCenter,yCenter] = WindowCenter(wptr);
fixsize = 12;

HideCursor;

centerMovePix = 0;
% fixcolor = [0:1:255  255:-1:0]; % 200
framerate = FrameRate(wptr);


%----------------------------------------------------------------------
%                 Setup LiveTrack
%----------------------------------------------------------------------
viewDist = 300;
% Set the duration of the sample buffer. The dot shown on the screen is
% placed at the average position of the samples in the buffer. Set buffer
% duration to zero to show the dot at the most recent sample (no averaging)
bufferDuration = 30; % duration in mS

% Mimic window view scale. Sets the size of the mimic window relative to
% the stimilus
cnrViewScale = 0.5; % show a half-sized window of stimulus on control monitor
% Select whether or not to draw gaze point in stimulus window (gaze point
% is always shown in the mimic window)
drawGazeInStimWin = true;

% Define the raduis of the fixation point (in screen pixels) - used for
% drift calibration
fixRadIn = 4; % inner circle
fixRadOut = 20;  % outer circle


% Initialise LiveTrack
crsLiveTrackInit;

% Start streaming calibrated results
crsLiveTrackSetResultsTypeCalibrated;

% Start buffering data to the library
crsLiveTrackStartTracking;

% Get the sample rate
[ width, height, sampleRate, offsetX, offsetY, ErrorCode ] = crsLiveTrackGetCaptureConfig; %  #ok<ASGLU>

% Calculate how many data samples the fixation duration (fixDur) contains
bufferLength = round((bufferDuration/1000)*sampleRate);

% Make sure the buffer has a length of at least 1
if bufferLength<1
    bufferLength = 1;
end

% Calculate stimulus screen specification
% Use default settings for Psychtoolbox
PsychDefaultSetup(2);

% get the resolution of the stimulus monitor
ResStim=Screen('Resolution', wptr);

% get screen width (in mm)
screenW = Screen('DisplaySize', wptr);

% calculate pixel size (in mm) assuming square pixels
pixSize = screenW/ResStim.width;

% Get the resolution of the experimenter's monitor (where the mimic window
% will be shown)

ResExp = Screen('Resolution', wptr);


% Set default values for parameters used in the screen refresh loop
getOffset = false;
OL=[0 0];
OR=[0 0];
tgtLocsL=[0 0];
tgtLocsR=[0 0];
curimg = 1;

% Begin the screen refresh loop (runs once per monitor refresh)
% while true
%
%     % Get the most recent samples in the buffer
%     Data = crsLiveTrackGetLatestEyePosition(bufferLength);
%
%     % Calculate the gaze location in screeen pixel coordinates and apply
%     % offset, for left and right eye
%     tgtLocsL(1) = round((OL(1)+mean(Data.mmPositions(:,1)))/pixSize+ResStim.width/2);
%     tgtLocsL(2) = round((OL(2)+mean(Data.mmPositions(:,2)))/pixSize+ResStim.height/2);
%     tgtLocsR(1) = round((OR(1)+mean(Data.mmPositionsRight(:,1)))/pixSize+ResStim.width/2);
%     tgtLocsR(2) = round((OR(2)+mean(Data.mmPositionsRight(:,2)))/pixSize+ResStim.height/2);



%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
% spaceKey = KbName('space');

%----------------------------------------------------------------------
%               Screen parameter
%----------------------------------------------------------------------

eyeScreenDistence = 78;  % cm  68sunnannan
screenHeight = 26.8; % cm
sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali 7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

%----------------------------------------------------------------------
%%%          parameters of blurred boundary
%----------------------------------------------------------------------
ramp_slope = 0.1;
ramp_degree = 20;
ringBlurredBoundaryMat = DrawRingWithBlurredBoundary(sectorRadius_out_pixel*2,sectorRadius_in_pixel*2,blackcolor,1,ramp_slope,ramp_degree);
% imshow(ringBlurredBoundaryMat);
ringBlurredBoundaryMat = whitecolor*ringBlurredBoundaryMat;
ringBlurredBoundaryTexture = Screen('MakeTexture', wptr, ringBlurredBoundaryMat);
ringBlurredBoundaryRect = Screen('Rect',ringBlurredBoundaryTexture);
ringBlurredBoundaryDestinationRect = CenterRectOnPoint(ringBlurredBoundaryRect,xCenter,yCenter);

%----------------------------------------------------------------------
%%%          parameters of red bar
%----------------------------------------------------------------------


barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];


% Define a vertical red rectangle
barMat(:,:,1) = repmat(255,  barLength,barWidth);
barMat(:,:,2) = zeros(barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

trialNumber = 2;

if strcmp(condition, 'normal')
    subtrialNumber = 1;
else
    subtrialNumber = 5;
end

barTiltStartUpper = -20;
barTiltStartLower = - 77.5;
barTiltStartNormal = 90;

currentframe = 0;
back.CurrentAngle = 0;

back.SpinDirec = 0; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;
back.FlagSpinDirecB = 0;
barTiltStep = 1;
% back.alpha = 1; % background transparence

back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;

% back.flashTiltDirection = 1 means sharp border grab CCW
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

ScanOnset = GetSecs;


for trial = 1:trialNumber
    
    BlockOnset = GetSecs;
    
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    
    formatSpec = 'This is the %dth of %d trial. Press Any Key To Begin';
    A1 = trial;
    A2 = trialNumber;
    str = sprintf(formatSpec,A1,A2);
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    %         DrawFormattedText(wptr, '\n\nPress Any Key To Begin', 'center', 'center', blackcolor);
    %         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);
    
    Screen('Flip', wptr);
    
    KbStrokeWait;
    
    
    if barLocation == 'u'
        barTiltNow = barTiltStartUpper;
        multiplier = - 1;   % in vi2invi condition  off_sync degree  over than bar_only degree
    elseif barLocation == 'l'
        barTiltNow = barTiltStartLower;
        multiplier = 1;
    elseif barLocation == 'n'
        barTiltNow = barTiltStartNormal;
    end
    
    
    for subtrial = 1:subtrialNumber
        
        %-----------------------------------------------------------------
        %              task instruction  adjust the bar
        %-----------------------------------------------------------------
        respToBeMade = true;
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        data.flashTiltDirection = back.flashTiltDirectionMatShuff(trial);
        back.CurrentAngle = 0;
        currentframe = 0;
        flashtimes = 0;
        barTiltStep = 1;
        
        if barLocation ~= 'n'
            switch subtrial
                case 1    % flash bar only
                    back.alpha = 0;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 1  Adjust the bar from visible to invisible   \n\n Press Any Key To Begin';
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 1  Adjust the bar from invisible to visible   \n\n Press Any Key To Begin';
                    end
                case 2   % blurred boundary
                    back.alpha = 1;
                    redbarflash_flag = 0;
                    if strcmp(condition, 'vi2invi')
                        barTiltNow = bar_only(trial) + multiplier * 10;
                        str_subtrial = '\n 2  Adjust the sharp bondary from visible to invisible   \n\n Press Any Key To Begin';
                    elseif strcmp(condition,'invi2vi')
                        barTiltNow = bar_only(trial);
                        str_subtrial = '\n 2  Adjust the sharp bondary from invisible to visible   \n\n Press Any Key To Begin';
                    end
                    
                case 3   % off-sync
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 3  Adjust the bar from visible to invisible   \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(trial) + multiplier * 10;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 3  Adjust the bar from invisible to visible and  \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(trial);
                    end
                    
                case 4   % flash grab
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 4  Adjust the bar from visible to invisible and \n\n remember the last location you have seen \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(trial) + multiplier * 0;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 4  Adjust the bar from invisible to visible and \n\n  remember the location  \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(trial);
                    end
                    
                case 5  % perceived location
                    
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 5  Adjust the bar to the perceived location where you last saw  \n\n Press Any Key To Begin' ;
                        barTiltNow = barTiltNow;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 5  Adjust the bar to the perceived location   \n\n Press Any Key To Begin';
                    end
            end
            
        elseif  barLocation == 'n'   % normal visual field
            barTiltNow = barTiltStartNormal;
            str_subtrial = '\n Adjust the bar until horizon   \n\n Press Any Key To Begin';
        end
        
        DrawFormattedText(wptr, str_subtrial, 'center', 'center', blackcolor);
        Screen('Flip', wptr);
        KbStrokeWait;
        
        
        %----------------------------------------------------------------------
        %               background rotate   subtrial 1 - 4
        %----------------------------------------------------------------------
        
        if subtrial ~= 5  % subtrial 1 - 4
            
            if data.flashTiltDirection == 1
                back.reverse_anlge_start = 0;
                back.reverse_anlge_end = - 180;
            elseif data.flashTiltDirection == 2
                back.reverse_anlge_start = 180;
                back.reverse_anlge_end = 0;
            end
            
            while respToBeMade
                
                currentframe = currentframe + 1;
                
                %  back.SpinDirec    1 means clockwise     -1 means counter-clockwise
                back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
                
                % make sure the red bar didn't show up at the beginning of
                % the rotation
                if currentframe == 1
                    back.CurrentAngle = back.reverse_anlge_end - barTiltNow ;
                    back.CurrentAngle = back.reverse_anlge_start - barTiltNow ;
                end
                
                % when larger than certain degree reverse  CCW
                if back.CurrentAngle >= back.reverse_anlge_start - barTiltNow % back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                    back.SpinDirec = - 1;
                    back.FlagSpinDirecA = back.SpinDirec;
                    %  when lower than certain degree reverse  CW
                elseif back.CurrentAngle <= back.reverse_anlge_end - barTiltNow  % - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                    back.SpinDirec = 1;
                    back.FlagSpinDirecB = back.SpinDirec;
                end
                
                if subtrial ~= 1 && subtrial ~= 3 % rotating background didn't presented in bar_only condition
                    Screen('DrawTexture',wptr,ringBlurredBoundaryTexture,ringBlurredBoundaryRect,ringBlurredBoundaryDestinationRect,back.CurrentAngle,[],back.alpha);
                elseif subtrial == 3
                    Screen('DrawTexture',wptr,ringBlurredBoundaryTexture,ringBlurredBoundaryRect,ringBlurredBoundaryDestinationRect,back.CurrentAngle + 90,[],back.alpha);
                end
                
                barRectTiltDegree = barTiltNow + 180;
                barDrawTiltDegree = back.CurrentAngle + 180;
                
                
                
                if redbarflash_flag == 1
                    % present flash tilt right  CCW
                    if data.flashTiltDirection == 1  && back.FlagSpinDirecA ==  - 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter + centerRingRadius2Center * cosd(barRectTiltDegree));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,subtrial,flashtimes) = barTiltNow;
                        back_currentAngleMat(trial,subtrial,flashtimes) = back.CurrentAngle;
                        
                    elseif data.flashTiltDirection == 2  && back.FlagSpinDirecB == 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter + centerRingRadius2Center * cosd(barRectTiltDegree));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,subtrial,flashtimes) = barTiltNow;
                        back_currentAngleMat(trial,subtrial,flashtimes) = back.CurrentAngle;
                        
                        flashPresentFlag = 1;
                    else
                        flashPresentFlag = 0;
                    end
                end
                
                back.FlagSpinDirecA = 0;
                back.FlagSpinDirecB = 0;
                
                fixcolor = 0;
                
                Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                
                
                %----------------------------------------------------------------------
                %                 draw eye fixation dot
                %----------------------------------------------------------------------
                % Get the most recent samples in the buffer
                Data = crsLiveTrackGetLatestEyePosition(bufferLength);
                
                % Calculate the gaze location in screeen pixel coordinates and apply
                % offset, for left and right eye
                tgtLocsL(1) = round((OL(1)+mean(Data.mmPositions(:,1)))/pixSize+ResStim.width/2);
                tgtLocsL(2) = round((OL(2)+mean(Data.mmPositions(:,2)))/pixSize+ResStim.height/2);
                tgtLocsR(1) = round((OR(1)+mean(Data.mmPositionsRight(:,1)))/pixSize+ResStim.width/2);
                tgtLocsR(2) = round((OR(2)+mean(Data.mmPositionsRight(:,2)))/pixSize+ResStim.height/2);
                
                % Draw a dot for each eye on the stimilus monitor (if enabled by
                %                         if Data.tracked
                Screen('FillOval', wptr,[130 130 130], round([tgtLocsL(1)-fixRadOut  tgtLocsL(2)-fixRadOut tgtLocsL(1)+fixRadOut tgtLocsL(2)+fixRadOut]));  % [255 0 0]
                %                           end
                %                         if Data.trackedRight
                %                             Screen('FillOval', wptr, [0 255 0], round([tgtLocsR(1)-fixRadOut...
                %                                 tgtLocsR(2)-fixRadOut tgtLocsR(1)+fixRadOut tgtLocsR(2)+fixRadOut]));
                %                         end
                
                %                 Screen('FrameOval',wptr,fixcolor,)
                Screen('Flip',wptr);
                
                %----------------------------------------------------------------------
                %                      Response
                %----------------------------------------------------------------------
                
                [keyIsDown,secs,keyCode] = KbCheck(-1);
                if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        return
                        % the bar was on the left of the gabor
                    elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
                        barTiltNow = barTiltNow + barTiltStep;
                    elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                        barTiltNow = barTiltNow - barTiltStep;
                    elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                        barTiltNow = barTiltNow + 2 * barTiltStep;
                    elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                        barTiltNow = barTiltNow - 2 * barTiltStep;
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
            
            %----------------------------------------------------------------------
            %         adjustable  smoothly moving red  bar
            %----------------------------------------------------------------------
            
        elseif subtrial == 5
            
            barTiltStep = 0.1;
            
            while respToBeMade
                
                barRectTiltDegree =  barTiltNow;
                barDrawTiltDegree = - barTiltNow - 180;
                
                if barLocation == 'l' | barLocation == 'n'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter + centerRingRadius2Center * cosd(barRectTiltDegree));
                elseif barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter - centerRingRadius2Center * sind(barRectTiltDegree), yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
                end
                
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
                
                % draw fixation
                
                fixcolor = 0;
                
                Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                %             Screen('DrawLine',wptr,fixcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
                %             Screen('DrawLine',wptr,fixcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
                Screen('Flip',wptr);
                
                
                %----------------------------------------------------------------------
                %                      Response
                %----------------------------------------------------------------------
                
                [keyIsDown,secs,keyCode] = KbCheck(-1);
                %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyCode(KbName('ESCAPE'))
                    Screen('CloseAll');
                    break;
                    ShowCursor;
                    sca;
                    return
                    % the bar was on the left of the gabor
                elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
                    if barLocation == 'l'| barLocation == 'n'
                        barTiltNow = barTiltNow - barTiltStep;
                    elseif barLocation == 'u'
                        barTiltNow = barTiltNow + barTiltStep;
                    end
                elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                    if barLocation == 'l'| barLocation == 'n'
                        barTiltNow = barTiltNow + barTiltStep;
                    elseif barLocation == 'u'
                        barTiltNow = barTiltNow - barTiltStep;
                    end
                elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                    if barLocation == 'l'| barLocation == 'n'
                        barTiltNow = barTiltNow - 2 * barTiltStep;
                    elseif barLocation == 'u'
                        barTiltNow = barTiltNow + 2 * barTiltStep;
                    end
                    
                elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                    if barLocation == 'l'| barLocation == 'n'
                        barTiltNow = barTiltNow + 2 * barTiltStep;
                    elseif barLocation == 'u'
                        barTiltNow = barTiltNow - 2 * barTiltStep;
                    end
                    
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                    %                     prekeyIsDown = 1;
                    %                 WaitSecs(0.5);
                end
                %                 end
                %                 prekeyIsDown = keyIsDown;
            end
        end
        
        %-----------------------------------------------------------------
        %           Response  record
        %-----------------------------------------------------------------
        
        
        if barLocation ~= 'n'
            if  subtrial == 1      % flash bar only
                bar_only(trial) = barTiltNow;
            elseif subtrial == 2   % off-sync
                off_sync(trial) = barTiltNow;
            elseif subtrial == 3     % flash grab
                blurred_bounday(trial) = barTiltNow;
            elseif subtrial == 4  % perceived location or none
                flash_grab(trial) = barTiltNow;
            elseif subtrial == 5  % perceived location or none
                perceived_location(trial) = barTiltNow;
            end
            
        else
            if data.flashTiltDirection == 1
                grab_effect_degree_CCW_from_vertical(trial) = barTiltNow;
            elseif   data.flashTiltDirection == 2
                grab_effect_degree_CW_from_vertical(trial) = barTiltNow;
            end
        end
        
        WaitSecs (0.5);
    end
    
end

% % Exit the script if Esc key is pressed
% if keyCode(KbName('ESCAPE'))
%     Screen('CloseAll');
%     disp('Esc pressed. Stopping demo');
%     break;
% end


display(GetSecs - ScanOnset);

%----------------------------------------------------------------------
%                  close eye tracker
%----------------------------------------------------------------------

% Stop buffering data to the library
crsLiveTrackStopTracking;

% Clear the buffer
crsLiveTrackClearDataBuffer;

% Close LiveTrack
crsLiveTrackClose;

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end

if  barLocation == 'u'
    if condition == 'vi2invi'
        savePath = '../../data/corticalBlindness/ringBlurredBoundary/upper_field/vi2invi/';
    elseif condition == 'invi2vi'
        savePath = '../../data/corticalBlindness/ringBlurredBoundary/upper_field/invi2vi/';
    end
elseif  barLocation == 'l'
    if condition == 'vi2invi'
        savePath = '../../data/corticalBlindness/ringBlurredBoundary/lower_field/vi2invi/';
    elseif condition == 'invi2vi'
        savePath = '../../data/corticalBlindness/ringBlurredBoundary/lower_field/invi2vi/';
    end
elseif  barLocation == 'n'
    savePath = '../../data/corticalBlindness/ringBlurredBoundary/normal_field/';
end



time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------

grab_effect_degree_CCW_from_vertical
grab_effect_degree_CW_from_vertical

sca;

figure;
plot(Data.timeStamps./1000,Data.mmPositions,'r'); hold on;
plot(Data.timeStamps./1000,Data.mmPositions,'g'); hold on;
xlabel('time (mS)');
ylabel('Pupil Diameter (mm)');



