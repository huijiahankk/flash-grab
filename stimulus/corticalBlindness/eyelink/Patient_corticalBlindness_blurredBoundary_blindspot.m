
% for cortical blindness patient/normal subject for blindspot experiment
% generate the flash grab illusion with 2 sector.  one boundary was blurred
% and the other with sharp bounday so this stimulus could generate flash grab illusion
% without integrated red bar flash.
% Test this blurred boundary pattern as control with bar only condition.
% If this moving boundary the same as off_sync condition

% blurred boundary exp  5 condition :(all from vi2invi  and then invi2vi)
% 1 bar_only
% 2 blurred boundary
% 3 off_sync
% 4 grab
% 5 perceived

% 8 sectors  4 condition :(all from vi2invi  and then invi2vi)
% 1 bar_only
% 2 off_sync
% 3 grab
% 4 perceived

% flash at reverse CCW :   data.flashTiltDirection(block,trial) == 2  &&r  back.FlagSpinDirecA ==  - 1
% reverse CW:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecB ==  1


clear all;close all;

if 1
    sbjname = 'hjh';
    debug = 'n';  
    %     flashRepresentFrame = 4.2;  % 2.2 means 3 frame
    barLocation = 'u';  % u  upper visual field   l   lower visual field n  normal
    condition = 'vi2invi';   % 'vi2invi'  'invi2vi'   'normal'
    isEyelink = 0;  % 0 1
    annulusPattern = 'sector'; % blurredBoundary  sector
    annulusWidth =  'blindspot'; % blindspot   artificialScotoma
%     artificialScotomaExp = 'n';
else
    %     sbjname = input('>>>Please input the subject''s name:   ','s');
    %     barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
    %     condition = input('>>>visible2invisible or invisible2visible? (vi2invi  invi2vi normal):  ','s');
    %     isEyelink = 0;
    %     whichExp = input('>>>which experiment? (blindspot/blurredBoundary/sectorEight?):  ','s');
    
    prompt = {'subject''s name','barLocation(u for upper\l for lower\n for normal)',...
        'condition(vi2invi  invi2vi normal)', 'isEyelink(without eyelink 0 or use eyelink 1)',...
        'annulusPattern(blurredBoundary/sector)','annulusWidth(blindspot/artificialScotoma)'};
    dlg_title = 'Set experiment parameters ';
    answer  = inputdlg(prompt,dlg_title);
    [sbjname,barLocation,condition,isEyelink,annulusPattern,annulusWidth] = answer{:};
    fprintf(['sbjname: %s\n','barLocation: %s\n','condition: %s\n','isEyelink: %d\n','annulusType: %s\n','annulusWidth: %s\n'],...
        sbjname,barLocation,condition,isEyelink,annulusPattern,annulusWidth);
    isEyelink = str2num(isEyelink);
end

debug = 'n';
flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
eyelinkfilename_eye = sbjname;

%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../../function;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
greycolor = 128; %(whitecolor + blackcolor) / 2; % 128
blindfieldColor = 110;
[wptr,rect]=Screen('OpenWindow',screenNumber,greycolor,[0 0 1024 768],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);
% HideCursor;

centerMovePix = 0;
framerate = FrameRate(wptr);

[wWidth,wHeight]=Screen('WindowSize',wptr);

xmid=round(wWidth/2);
ymid=round(wHeight/2);

% draw the fixcross
fixCrossDimPix = 15;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;

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

eyeScreenDistence = 66;  % 78cm  68sunnannan
screenHeight = 33.5; % 26.8 cm
if strcmp(annulusWidth,'blindspot')
    %----------------------------------------------------------------------
    %            load blindspot test file and data
    %----------------------------------------------------------------------
%     datapath = '../../../data/corticalBlindness/Eyelink_guiding/blindspottest/';
%     cd(datapath);
%     s1 = sbjname;
%     s2 = '*.mat';
%     s3 = strcat(s1,s2);
%     Files = dir(s3);
%     load (Files.name,'blindspot_loc_x_dva','blindspot_loc_y_dva','blindspot_width');
    sectorRadius_in_visual_degree = 13;% blindspot_loc_x_dva; % sunnannan 5.5   mali7.9
    sectorRadius_out_visual_degree =16; % sectorRadius_in_visual_degree + blindspot_width; % sunnannan 9.17  mali 11.5
%     cd('../../../../stimulus/corticalBlindness/eyelink/');
else
    sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
    sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali7.9
end

sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

% eye gaze distance from center
fixRadius_dva = 3;
fixRadius = round(tand(fixRadius_dva) * eyeScreenDistence *  rect(4)/screenHeight);
% fixateTimeDura = 600; %ms
driftDuation_pre = 1; %  sec
driftDuation_dur = 2; % sec
%----------------------------------------------------------------------
%             Blind field parameter
%----------------------------------------------------------------------

blindfield_deviate_center_visual_degree = 8;  % degree from horizontal meridian
blindfield_deviate_center_pixel = round(tand(blindfield_deviate_center_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);
blindfieldRadius_visual_degree = 4;
blindfieldRadius_pixel = round(tand(blindfieldRadius_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);

blindfield_from_horizontal_degree = asind(blindfieldRadius_pixel/blindfield_deviate_center_pixel);
% centerRingRadius2Center * sind(blindfield_visual_degree);  %pixel
% blindfield_shift = centerRingRadius2Center + 65;

%----------------------------------------------------------------------
%%%          parameters of blurred boundary
%----------------------------------------------------------------------
if strcmp(annulusPattern,'blurredBoundary')
    ramp_slope = 0.1;
    ramp_degree = 20;
    ringBlurredBoundaryMat = DrawRingWithBlurredBoundary(sectorRadius_out_pixel*2,sectorRadius_in_pixel*2,blackcolor,1,ramp_slope,ramp_degree);
    % imshow(ringBlurredBoundaryMat);
    ringBlurredBoundaryMat = whitecolor*ringBlurredBoundaryMat;
    backgroundTexture = Screen('MakeTexture', wptr, ringBlurredBoundaryMat);
    %----------------------------------------------------------------------
    %                      draw background 8 sector
    %----------------------------------------------------------------------
else
    sectorNumber = 8;
    [sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);
    backgroundTexture = Screen('MakeTexture', wptr, sector);
end
backgroundRect = Screen('Rect',backgroundTexture);
backgroundDestinationRect = CenterRectOnPoint(backgroundRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%----------------------------------------------------------------------
%%%          parameters of red bar
%----------------------------------------------------------------------

barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
% barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];


% Define a vertical red rectangle
barMat(:,:,1) = repmat(255,  barLength,barWidth);
barMat(:,:,2) = zeros(barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%          parameters of black adjustable line
%----------------------------------------------------------------------

lineWidth = 8;
lineLength = 20;
% lineRect = [-lineLength/2  -lineWidth/2  lineLength/2  lineWidth/2];

% Define a vertical red rectangle
lineMat(:,:,1) = zeros(lineLength,lineWidth);
lineMat(:,:,2) = zeros(lineLength,  lineWidth) * 255;
lineMat(:,:,3) = lineMat(:,:,2);

% % % Make the rectangle into a texure
lineTexture = Screen('MakeTexture', wptr, lineMat);
lineRect = Screen('Rect',lineTexture);

%----------------------------------------------------------------------
%%%            Eyelink setting up
%----------------------------------------------------------------------

constants.eyelink_data_fname = [sbjname, '.edf'];
window.pointer = wptr;
window.background = greycolor;
window.white = whitecolor;
window.winRect = ScreenRect;
[el, exit_flag] = setupEyeTracker(isEyelink, window, constants );

if isEyelink
    % Must be offline to draw to EyeLink screen
    Eyelink('Command', 'set_idle_mode');
    % clear tracker display
    Eyelink('Command', 'clear_screen 0');
    Eyelink('Command','draw_box %d %d %d %d ',xCenter-50,yCenter-50,xCenter+50,yCenter+50);
    EyelinkDoDriftCorrection(el);
    Eyelink('StartRecording');
    
    eyeUsed = Eyelink('EyeAvailable'); % get eye that's tracked
    % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
    if eyeUsed == 2
        eyeUsed = 1; % use the right_eye data
    end
    % always wait a moment for recording to have definitely started
    WaitSecs(0.1);
    % mark when the experiment has actually started
    Eyelink('message', 'SYNCTIME');
end

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
if strcmp(condition,'normal')
    blockNumber = 10;
else
    blockNumber = 6;  % 6 for normal subjects
end

if strcmp(condition, 'normal')
    trialNumber = 1;
    upperStartAdjustDegree = 0;
    lowerStartAdjustDegree = 0;
else
    if strcmp(annulusPattern,'blurredBoundary')
        trialNumber = 5;
    else
        trialNumber = 4;
    end
end

back.CurrentAngle = 0;
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% back.alpha = 1; % background transparence
if framerate > 63
    back.SpinSpeed = 1.5;
else
    back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
end
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
% preblockNumber = 10;
% back.flashTiltDirectionMat = Shuffle(repmat([1;2],preblockNumber,1))';
% back.flashTiltDirectionMat = repmat([1;2],preblockNumber,1)'
abandonBlockMat = zeros(1,20);
barTiltStep = 1; %2.8125   1.40625;

if strcmp(annulusWidth,'artificialScotoma')
    if strcmp(condition,'invi2vi')
        upperStartAdjustDegree = - blindfield_from_horizontal_degree + 5;
        lowerStartAdjustDegree = blindfield_from_horizontal_degree - 5;
        
    elseif strcmp(condition,'vi2invi')
        upperStartAdjustDegree = -15 - blindfield_from_horizontal_degree;
        lowerStartAdjustDegree = 15 + blindfield_from_horizontal_degree;
    end
else
    if strcmp(condition,'invi2vi')
        upperStartAdjustDegree = 0;
        lowerStartAdjustDegree = 0;
    elseif strcmp(condition,'vi2invi')
        upperStartAdjustDegree = -15;
        lowerStartAdjustDegree = 15;
    end
end

barTiltStartUpper = 90 + upperStartAdjustDegree;
barTiltStartLower = 90 + lowerStartAdjustDegree;
bar_only = repmat(barTiltStartUpper,1,blockNumber);

barTiltStartNormal = 270;

if strcmp(annulusWidth,'blindspot')
    perc_loc_shift_dva = 5;
else
    perc_loc_shift_dva = 2;
end
perc_loc_shift_pixel = round(tand(perc_loc_shift_dva) * eyeScreenDistence *  rect(4)/screenHeight);

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

ScanOnset = GetSecs;
block = 1;

while block <= blockNumber
    
    BlockOnset = GetSecs;
    abandonTrialFlag = 0;
    trial = 1;
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    
    formatSpec = 'This is the %dth of %d block. \n \n Press Any Key To Begin';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    
    Screen ('TextSize',wptr,30);
    Screen('TextFont',wptr,'Courier');
    
    %     topLeftQuadRect = [0 0 xCenter yCenter];
    topCenterQuadRect = [xCenter/2 0  xCenter*3/2 yCenter];
    %     topRightQuadRect = [xCenter 0 0 yCenter];
    %     bottomLeftQuadRect = [0 yCenter xCenter 0];
    %     bottomRightQuadRect = [xCenter yCenter 0 0];
    
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor,[],[],[],[],[],topCenterQuadRect);
    
    
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
    
    % in each block the illusion direction is CCW 
    if block == 1
        data.flashTiltDirection = 1;
    end
    
    
    while abandonTrialFlag == 0 && trial <= trialNumber
        
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        currentframe = 0;
        flashtimes = 0;
        fixDriftFrame = 0;
        isOutFixationWindowFrame = 0;
        isOutFixationWindowTimes = 0;
        readIntruTime = 1;
        
        if barLocation ~= 'n'
            switch trial
                case  1    % flash bar only
                    back.alpha = 0;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_trial = ['Adjust the bar from visible to invisible.\n '   '\n\n Fix the cross to start the trial. \n'];
                    elseif strcmp(condition,'invi2vi')
                        str_trial = ['Adjust the bar from invisible to visible.\n '    '\n\n Fix the cross to start the trial. \n'];
                    end
                    readIntruTime = 2;
                case 2
                    back.alpha = 1;
                    if  strcmp(annulusPattern,'blurredBoundary') % for blurredBoundaryExp  boundary;
                        redbarflash_flag = 0;
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block) + multiplier * 10;
                            str_trial = '\n Adjust the bourdary from visible to invisible'  ;
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block) - multiplier * 10;
                            str_trial = '\n Adjust the boundary from invisible to visible' ;
                        end
                    else    % for 8 sectorExp off-sync
                        redbarflash_flag = 1;
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block) + multiplier * 10;
                            str_trial = '\n Adjust the bar from visible to invisible' ;
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block) - multiplier * 10;
                            str_trial = '\n Adjust the bar from invisible to visible'  ;
                        end
                    end
                    readIntruTime = 2;
                case 3
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if  strcmp(annulusPattern,'blurredBoundary') % for blurredBoundaryExp  off_sync;
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block) + multiplier * 10;
                            str_trial = '\n Adjust the bar from visible to invisible' ;
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block) - multiplier * 10;
                            str_trial = '\n Adjust the bar from invisible to visible'  ;
                        end
                    else  % for 8 sectorExp flash grab
                        if strcmp(condition, 'vi2invi')
                            str_trial = '\n Adjust the bar from visible to invisible and \n\n remember the last location you have seen';
                            barTiltNow = bar_only(block) + multiplier * 10;
                        elseif strcmp(condition,'invi2vi')
                            str_trial = '\n Adjust the bar from invisible to visible and remember the location' ;
                            barTiltNow = bar_only(block) - multiplier * 10;
                        end
                    end
                    readIntruTime = 2;
                case 4
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if  strcmp(annulusPattern,'blurredBoundary')  % for blurredBoundaryExp  flash grab;
                        if strcmp(condition, 'vi2invi')
                            str_trial = '\n Adjust the bar from visible to invisible and \n\n remember the last location you have seen'  ;
                            barTiltNow = bar_only(block) + multiplier * 10;
                        elseif strcmp(condition,'invi2vi')
                            str_trial = '\n Adjust the bar from invisible to visible and remember the location'  ;
                            barTiltNow = bar_only(block) - multiplier * 10;
                        end
                        readIntruTime = 2;
                    end
                    
            end
            
        elseif barLocation == 'n'
            barTiltNow = barTiltStartNormal;
            back.alpha = 1;
            redbarflash_flag = 1;
            str_trial = '\n Adjust the bar until horizon   \n\n Fix on the cross to start the trial';
        end
        DrawFormattedText(wptr, str_trial, 'center', 'center', blackcolor,[],[],[],[],[],topCenterQuadRect);
        str_trial = [];
        Screen('Flip',wptr);
        WaitSecs(readIntruTime);
        
        %----------------------------------------------------------------------
        %  Eyelink file transfer to Display PC and check if fixation correct
        %  'Fast' method (sample only)
        %----------------------------------------------------------------------
        if isEyelink
            while 1
                [x, y] = getEyelinkCoordinates();
                
                if isnan(x) || isnan(y)
                    fprintf('Eye tracker lost track of eyes \n');
                else
                    % Check if gaze is within fixation window
                    if isWithinFixationWindow(x, y, xCenter, yCenter, fixRadius)
                        gazeRect=[ x-9 y-9 x+10 y+10];
                        %                     fixationcolour=round(rand(3,1)*255); % coloured dot
                        fixationcolour = greycolor + 10;
                        %                         str = 'Fix on the cross to start the trial';
                        %                         Screen('DrawText', wptr, str, xCenter - 100, yCenter - 100, blackcolor);
                        Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                        Screen('FillOval', wptr, fixationcolour, gazeRect);
                        Screen('Flip',wptr);
                        fixDriftFrame = fixDriftFrame + 1;
                        isOutFixationWindowFrame  = fixDriftFrame;
                    else  isOutFixationWindowFrame >= driftDuation_pre*framerate;
                        Eyelink('Message','BLOCKID %d',block);
                        break;
                    end
                end
            end
        end
        
        fixDriftFrame = 0;
        isOutFixationWindowFrame = 0;
        isOutFixationWindowTimesMat = [];
        
        if trialNumber == 1 ||  trial ~= trialNumber
            
            while respToBeMade
                
                currentframe = currentframe + 1;
                back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
                
                
                % make sure the red bar didn't show up at the beginning of
                % the rotation
                if currentframe == 1
                    back.CurrentAngle = barTiltNow - 2;  % back.reverse_anlge_end
                    if isEyelink
                        Eyelink('Message','TRIALID %d',trial);
                    end
                end
                
                if isEyelink
%                     Eyelink('Message','TRIALID %d',trial);
                    [x, y] = getEyelinkCoordinates();
                    if isnan(x) || isnan(y)
                        fprintf('Eye tracker lost track of eyes \n');
                    else
                        % Check if gaze is within fixation window
                        if isWithinFixationWindow(x, y, xCenter, yCenter, fixRadius)
                            gazeRect=[ x-9 y-9 x+10 y+10];
                            %                     fixationcolour=round(rand(3,1)*255); % coloured dot
                            fixationcolour = greycolor + 5;
                            Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
%                             Screen('FillOval', wptr, fixationcolour, gazeRect);
                            %                             Screen('Flip',wptr);
                        elseif  isOutFixationWindowFrame <= driftDuation_dur * framerate
                            fixDriftFrame = fixDriftFrame + 1;
                            isOutFixationWindowFrame  = fixDriftFrame;
                        elseif isOutFixationWindowFrame  > driftDuation_dur * framerate
                            isOutFixationWindowTimes = isOutFixationWindowTimes + 1;
                            isOutFixationWindowTimesMat = [isOutFixationWindowTimes;    isOutFixationWindowTimesMat];
                            if strcmp(annulusPattern,'corticalBlindness') == 0
                                sprintf('Gaze is outside fixation window during block %d  trial  %d\n',  block, trial)
                                abandonTrialFlag = 1;  % the whole block was abandoned
                                blockNumber = blockNumber + 1;
                                abandonBlockMat(block) = abandonTrialFlag;
                                break;
                            end
                        end
                    end
                end
                
                if data.flashTiltDirection == 1    % CCW
                    % when larger than certain degree reverse  CCW
                    if back.CurrentAngle >= 0 + barTiltNow  %   back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = - 1;
                        back.FlagSpinDirecA = back.SpinDirec;
                        %  when lower than certain degree reverse  CW
                    elseif back.CurrentAngle <= - 180 + barTiltNow%  - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = 1;
                        back.FlagSpinDirecB = back.SpinDirec;
                    end
                elseif data.flashTiltDirection == 2   % CW
                    % when larger than certain degree reverse  CCW
                    if back.CurrentAngle >= 180 + barTiltNow %   back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = - 1;
                        back.FlagSpinDirecA = back.SpinDirec;
                        %  when lower than certain degree reverse  CW
                    elseif back.CurrentAngle <= barTiltNow  %  - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = 1;
                        back.FlagSpinDirecB = back.SpinDirec;
                    end
                end
                
                %    draw background each frame
                if strcmp(annulusPattern,'blurredBoundary')
                    if trial == 3
                        back.presentAngle = back.CurrentAngle + 90;
                    else
                        back.presentAngle = back.CurrentAngle;
                    end
                else
                    if  trial == 2
                        back.presentAngle = back.CurrentAngle + 22.5;
                    else
                        back.presentAngle = back.CurrentAngle;
                    end
                end
                
                
                Screen('DrawTexture',wptr,backgroundTexture,backgroundRect,backgroundDestinationRect,back.presentAngle,[],back.alpha);
                
                barRectTiltDegree = barTiltNow;
                barDrawTiltDegree = barTiltNow; % back.CurrentAngle
                
                if redbarflash_flag == 1
                    % present flash tilt right  CCW
                    if data.flashTiltDirection  == 1  && back.FlagSpinDirecA ==  - 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);  % DrawTexture 0 deg. = upright
                                            
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        flashPresentFlag = 1;
                        if isEyelink
                            Eyelink('Message','flash');
                        end
                        
                    elseif data.flashTiltDirection == 2  && back.FlagSpinDirecB == 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                        
                      flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        if isEyelink
                            Eyelink('Message','flash');
                        end
                        
                        flashPresentFlag = 1;
                    else
                        flashPresentFlag = 0;
                    end
                end
                back.FlagSpinDirecA = 0;
                back.FlagSpinDirecB = 0;
                
                % draw fixation
                
                fixcolor = 0;
                
                Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                %                 Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                if strcmp(annulusWidth,'artificialScotoma')
                    Screen('FillOval',wptr,blindfieldColor,[xCenter + blindfield_deviate_center_pixel - blindfieldRadius_pixel, yCenter - blindfieldRadius_pixel,...
                        xCenter + blindfield_deviate_center_pixel + blindfieldRadius_pixel, yCenter + blindfieldRadius_pixel]);
                end
                
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
                        barTiltNow = barTiltNow - barTiltStep;
                    elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                        barTiltNow = barTiltNow + barTiltStep;
                    elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                        barTiltNow = barTiltNow - 2 * barTiltStep;
                    elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                        barTiltNow = barTiltNow + 2 * barTiltStep;
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
            
            
            
        elseif ~strcmp(condition,'normal') &&  trial == trialNumber 
            
            barMovStep = 0.2;
             if barLocation == 'u'
            barTiltNow = 70 + randn * 10;
             elseif  barLocation == 'l'
                  barTiltNow = 100 + randn * 10;
             end
            
            if isEyelink
                Eyelink('Message','TRIALID %d',trial);
            end
            
            while respToBeMade
                
                
                
                if strcmp(annulusWidth,'blindspot')
                    lineRectTiltDegree =  barTiltNow;
                    lineDrawTiltDegree = barTiltNow;
                    lineDestinationRect = CenterRectOnPoint(lineRect,xCenter + (centerRingRadius2Center - perc_loc_shift_pixel) * sind(lineRectTiltDegree), yCenter - (centerRingRadius2Center - perc_loc_shift_pixel) * cosd(lineRectTiltDegree));
                    Screen('DrawTexture',wptr,lineTexture,lineRect,lineDestinationRect,lineDrawTiltDegree);
                    
                    refFrameDestinationRect = [xCenter - centerRingRadius2Center + perc_loc_shift_pixel,...
                        yCenter - centerRingRadius2Center + perc_loc_shift_pixel,...
                        xCenter + centerRingRadius2Center - perc_loc_shift_pixel,...
                        yCenter + centerRingRadius2Center - perc_loc_shift_pixel];
                    
                    % draw a black circle in the visible visual area
                    Screen('FrameOval', wptr, blackcolor, refFrameDestinationRect,3,3);
                else strcmp(annulusWidth,'artificialScotoma')
%                     % using red bar to present the perceived location
%                     barRectTiltDegree =  barTiltNow;
%                     barDrawTiltDegree = barTiltNow;
%                     barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
%                     Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                    % using black dot to present the perceived location
                        lineRectTiltDegree =   barTiltNow;   % barTiltNow
                    lineDrawTiltDegree =  barTiltNow;% barTiltNow
                    lineDestinationRect = CenterRectOnPoint(lineRect,xCenter + (centerRingRadius2Center - perc_loc_shift_pixel) * sind(lineRectTiltDegree), yCenter - (centerRingRadius2Center - perc_loc_shift_pixel) * cosd(lineRectTiltDegree));
                    Screen('DrawTexture',wptr,lineTexture,lineRect,lineDestinationRect,lineDrawTiltDegree);
                    
                    refFrameDestinationRect = [xCenter - centerRingRadius2Center + perc_loc_shift_pixel,...
                        yCenter - centerRingRadius2Center + perc_loc_shift_pixel,...
                        xCenter + centerRingRadius2Center - perc_loc_shift_pixel,...
                        yCenter + centerRingRadius2Center - perc_loc_shift_pixel];
                    
                    % draw a black circle in the visible visual area
                    Screen('FrameOval', wptr, blackcolor, refFrameDestinationRect,3,3);
                end
                
                % draw fixation
                fixcolor = 0;
                Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                %                 Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                
                Screen('Flip',wptr);
                
                
                %----------------------------------------------------------------------
                %                      Response record
                %----------------------------------------------------------------------
                
                [keyIsDown,secs,keyCode] = KbCheck(-1);
                %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyCode(KbName('ESCAPE'))
                    ShowCursor;
                    sca;
                    return
                    % the bar was on the left of the gabor
                elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
                    barTiltNow = barTiltNow - barMovStep;
                elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                    barTiltNow = barTiltNow + barMovStep;
                elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                    barTiltNow = barTiltNow - 2 * barMovStep;
                elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                    barTiltNow = barTiltNow + 2 * barMovStep;
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                    %                     prekeyIsDown = 1;
                    %                 WaitSecs(0.5);
                end
                %                 end
                %                 prekeyIsDown = keyIsDown;
                
            end
        end
        
        if barLocation ~= 'n'
            switch trial
                case  1      % flash bar only
                    bar_only(block) = barTiltNow;
                case  2   % blurred boundary
                    if strcmp(annulusPattern,'blurredBoundary')
                        boundary(block) = barTiltNow;
                    else  % off-sync
                        off_sync(block) = barTiltNow;
                    end
                case 3
                    if strcmp(annulusPattern,'blurredBoundary')
                        off_sync(block) = barTiltNow;
                    else
                        % flash grab
                        flash_grab(block) = barTiltNow;
                    end
                case 4
                    if strcmp(annulusPattern,'blurredBoundary')
                        flash_grab(block) = barTiltNow;
                    else
                        % perceived location or none
                        perceived_location(block) = barTiltNow;
                    end
                case 5
                    perceived_location(block) = barTiltNow;
            end
            
        else
            grab_effect_degree(block) = barTiltNow;
        end
        trial = trial + 1;
        WaitSecs (0.5);
        
%         if keyCode(KbName('q'))
%             break;
%         end
    end
    
    data.flashTiltDirectionMat(block) = data.flashTiltDirection;
    
    if abandonTrialFlag == 1
        data.flashTiltDirection = data.flashTiltDirectionMat(block);
    elseif abandonTrialFlag == 0
        if data.flashTiltDirectionMat(block) == 2
            data.flashTiltDirection = data.flashTiltDirectionMat(block) - 1;
        elseif data.flashTiltDirectionMat(block) == 1
            data.flashTiltDirection = data.flashTiltDirectionMat(block) + 1;
        end
    end
     
    abandonBlock(block) = abandonTrialFlag;
    block = block + 1;
   
end

if ~strcmp(condition,'normal')
    runTrialIndex = ones(1,length(perceived_location));
    validTrialIndex = find(perceived_location ~= 0);
end

display(GetSecs - ScanOnset);

%----------------------------------------------------------------------
%              stop eyelink recording
%----------------------------------------------------------------------
if isEyelink
    Eyelink('stopRecording');
    Eyelink('command','set_idle_mode');
    %     iSuccess = Eyelink('ReceiveFile', [], edfdir, 1);
    %     disp(conditional(iSuccess > 0, ['Eyelink File Received, file size is ' num2str(iSuccess)], ...
    %         'Something went wrong with receiving the Eyelink File'));
    
    try
        fprintf('Receiving data file ''%s''\n',  constants.eyelink_data_fname );
        status = Eyelink('ReceiveFile',constants.eyelink_data_fname) ;
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n',  constants.eyelink_data_fname, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n',  constants.eyelink_data_fname );
    end
    Eyelink('ShutDown');
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------


datadir = strcat( '../../../data/corticalBlindness/eyelink_guiding/',  annulusPattern,'/',annulusWidth,'/');

if barLocation == 'n'
  datadir = strcat( datadir,condition,'/');
end

expdir = sprintf([datadir '%s/'],sbjname);
if ~isdir(expdir)
    mkdir(expdir)
end

savePath = expdir;
time = clock;

filename = sprintf('%s_%s_%s_%02g_%02g_%02g_%02g_%02g',sbjname,condition,barLocation,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

sca;
