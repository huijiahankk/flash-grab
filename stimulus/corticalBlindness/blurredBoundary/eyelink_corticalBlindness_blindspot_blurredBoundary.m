
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
    sbjname = 'k';
    debug = 'n';
    flashRepresentFrame = 4.2;  % 2.2 means 3 frame
    barLocation = 'l';  % u  upper visual field   l   lower visual field n  normal
    condition = 'invi2vi';   % 'vi2invi'  'invi2vi'   'normal'
    isEyelink = 0;
    eyelinkfilename_eye = 'hjh' ;
    blindspot = 'y';
    blurredBoundaryExp = 'y';
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = 'n';
    %     debug = input('>>>Debug? (y/n):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 4.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
    condition = input('>>>visible2invisible or invisible2visible? (vi2invi  invi2vi normal):  ','s');
    isEyelink = 0;
    eyelinkfilename_eye = 'hjh' ;
    blindspot = input('>>>blindspot experiment for normal participants? (y for yes n for no):  ','s');
    blurredBoundaryExp = input('>>>blurred boundary background experiment? (y for yes n for no):  ','s');
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
bottomcolor = 128; %(whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[0 0 1024 768],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);
fixsize = 12;

HideCursor;

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
if blindspot == 'n'
    sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
    sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali7.9
elseif blindspot == 'y'
    sectorRadius_out_visual_degree = 15.25; % sunnannan 9.17  mali 11.5
    sectorRadius_in_visual_degree = 13.5; % sunnannan 5.5   mali7.9
end

sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

% eye gaze distance from center
gaze_away_visual_degree = 0.5;
gaze_away_pixel = round(tand(gaze_away_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);


%----------------------------------------------------------------------
%%%          parameters of blurred boundary
%----------------------------------------------------------------------
if blurredBoundaryExp == 'y'
    ramp_slope = 0.1;
    ramp_degree = 20;
    ringBlurredBoundaryMat = DrawRingWithBlurredBoundary(sectorRadius_out_pixel*2,sectorRadius_in_pixel*2,blackcolor,1,ramp_slope,ramp_degree);
    % imshow(ringBlurredBoundaryMat);
    ringBlurredBoundaryMat = whitecolor*ringBlurredBoundaryMat;
    backgroundTexture = Screen('MakeTexture', wptr, ringBlurredBoundaryMat);
    backgroundRect = Screen('Rect',backgroundTexture);
    backgroundDestinationRect = CenterRectOnPoint(backgroundRect,xCenter,yCenter);
    Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
     
    %----------------------------------------------------------------------
    %                      draw background 8 sector
    %----------------------------------------------------------------------
elseif blurredBoundaryExp == 'n'
    sectorNumber = 8;
    [sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);
    backgroundTexture = Screen('MakeTexture', wptr, sector);
    backgroundRect = Screen('Rect',backgroundTexture);
    backgroundDestinationRect = CenterRectOnPoint(backgroundRect,xCenter,yCenter-centerMovePix);
    Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end

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
%%%            Eyelink setting up
%----------------------------------------------------------------------
if isEyelink
    dummymode = 0;
    enableCallbacks = 1;
    %     % script trial run without link eyelink
    %     [status] = Eyelink('Initialize',displayCallbackFunction);
    
    %Initialize
    el=EyelinkInitDefaults(wptr);
    if ~EyelinkInit(dummymode,enableCallbacks)   % enableCallbacks = 1 show  eye image
        fprintf('Eyelink Init aborted.\n');
        cleanup;
        return;
    end
    
    % open file to record data to
    edfFile=[eyelinkfilename_eye '.edf'];
    open=Eyelink('Openfile',edfFile);
    if open ~=0
        fprintf('Can not open the edfile');
        Eyelink('Shutdown');
        return;
    end
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && ~dummymode
        %     cleanup;
        Eyelink('Shutdown');
        Screen('CloseAll');
        return;
    end
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by FGI experiment''');
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, ScreenRect(3)-1, ScreenRect(4)-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, ScreenRect(3)-1, ScreenRect(4)-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV5'); %  setting the usual 5-point calibration
    
    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    
    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');
    
    
    %     Eyelink('command','link sample data = LEFT,GAZE ,GAZERES,HREF,AREA,PUPIL');
    %     Eyelink('command','link event data = GAZE ,GAZERES,HREF,AREA,VELOCITY');
    %     Eyelink('command','link event filter = LEFT,FIXATION,FIXUPDATE,BLINK,SACCADE,MESSAGE,BUTTON');
    %
    %     Eyelink('command','file sample data = LEFT,GAZE ,GAZERES,HREF,AREA,PUPIL');
    %     Eyelink('command','file event data = GAZE ,GAZERES,HREF,AREA,VELOCITY');
    %     Eyelink('Command','file_event_filter = LEFT,FIXATION,FIXUPDATE,BLINK,SACCADE,MESSAGE,BUTTON');
    
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && input.dummymode == 0
        exit_flag = 'ESC';
        return;
    end
    
    % possible changes from EyelinkPictureCustomCalibration
    
    % set sample rate in camera setup screen
    Eyelink('command', 'sample_rate = %d', 1000);
    
    % Will call the calibration routine
    EyelinkDoTrackerSetup(el);
    
    
    %Calibrate
    % EyelinkUpdateDefaults(el); what dose this mean?
    EyelinkDoTrackerSetup(el);
    
    % Must be offline to draw to EyeLink screen
    Eyelink('Command', 'set_idle_mode');
    % clear tracker display
    Eyelink('Command', 'clear_screen 0');
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

blockNumber = 4;

if strcmp(condition, 'normal')
    trialNumber = 1;
else
    if strcmp(blurredBoundaryExp,'y')
        trialNumber = 5;
    elseif strcmp(blurredBoundaryExp,'n')
        trialNumber = 4;
    end
end

back.CurrentAngle = 0;
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% back.alpha = 1; % background transparence

back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = Shuffle(repmat([1;2],blockNumber/2,1))';

barTiltStep = 1; %2.8125   1.40625;
barTiltStartUpper = 90;
barTiltStartLower = 90;
barTiltStartNormal = 0;

if blindspot == 'y'
    perc_loc_shift_dva = 3;
elseif blindspot == 'n'
    perc_loc_shift_dva = 0;
end
perc_loc_shift_pixel = round(tand(perc_loc_shift_dva) * eyeScreenDistence *  rect(4)/screenHeight);

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

ScanOnset = GetSecs;


for block = 1:blockNumber
    
    BlockOnset = GetSecs;
    
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    
    formatSpec = 'This is the %dth of %d block. \n Press Any Key To Begin';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    
    Screen ('TextSize',wptr,30);
    Screen('TextFont',wptr,'Courier');
    
    topLeftQuadRect = [0 0 xmid ymid];
    topRightQuadRect = [xmid 0 0 ymid];
    bottomLeftQuadRect = [0 ymid xmid 0];
    bottomRightQuadRect = [xmid ymid 0 0];
    
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor,[],[],[],[],[],topLeftQuadRect);
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
    
    
    data.flashTiltDirection = back.flashTiltDirectionMat(block);
    
    for trial = 1:trialNumber
        
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        currentframe = 0;
        flashtimes = 0;
        
        
        if barLocation ~= 'n'
            switch trial
                case  1    % flash bar only
                    back.alpha = 0;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_trial = ['Adjust the bar from visible to invisible.\n '   '\n\n Fixation on the cross to start the trial. \n'];
                    elseif strcmp(condition,'invi2vi')
                        str_trial = ['Adjust the bar from invisible to visible.\n '    '\n\n Fix on the cross to start the trial. \n'];
                    end
                case 2   % for blurredBoundaryExp  boundary; for 8 sectorExp off-sync
                    back.alpha = 1;
                    if  strcmp(blurredBoundaryExp,'y')
                        redbarflash_flag = 0;
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the bourdary from visible to invisible'    '\n\n Fix on the cross to start the trial'];
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the boundary from invisible to visible'     '\n\n Fix on the cross to start the trial'];
                        end
                    elseif  strcmp(blurredBoundaryExp,'n')
                        redbarflash_flag = 1;
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the bar from visible to invisible'    '\n\n Fix on the cross to start the trial'];
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the bar from invisible to visible'     '\n\n Fix on the cross to start the trial'];
                        end
                    end
                    
                case 3   % for blurredBoundaryExp  off_sync; for 8 sectorExp flash grab
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if  strcmp(blurredBoundaryExp,'y')
                        if strcmp(condition, 'vi2invi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the bar from visible to invisible'    '\n\n Fix on the cross to start the trial'];
                        elseif strcmp(condition,'invi2vi')
                            barTiltNow = bar_only(block);
                            str_trial = ['\n Adjust the bar from invisible to visible'     '\n\n Fix on the cross to start the trial'];
                        end
                    elseif strcmp(blurredBoundaryExp,'n')
                        if strcmp(condition, 'vi2invi')
                            str_trial = ['\n Adjust the bar from visible to invisible and \n\n remember the last location you have seen'  '\n\n Fix on the cross to start the trial'];
                            barTiltNow = bar_only(block) + multiplier * 10;
                        elseif strcmp(condition,'invi2vi')
                            str_trial = ['\n Adjust the bar from invisible to visible and remember the location'   '\n\n Fix on the cross to start the trial'];
                            barTiltNow = bar_only(block);
                        end
                    end
                    
                case 4  % for blurredBoundaryExp  flash grab; for 8 sectorExp perceived location
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if  strcmp(blurredBoundaryExp,'y')
                        if strcmp(condition, 'vi2invi')
                            str_trial = ['\n Adjust the bar from visible to invisible and \n\n remember the last location you have seen'  '\n\n Fix on the cross to start the trial'];
                            barTiltNow = bar_only(block) + multiplier * 10;
                        elseif strcmp(condition,'invi2vi')
                            str_trial = ['\n Adjust the bar from invisible to visible and remember the location'   '\n\n Fix on the cross to start the trial'];
                            barTiltNow = bar_only(block);
                        end
                    elseif strcmp(blurredBoundaryExp,'n')
                        str_trial = ['\n Adjust the bar to the perceived location'    '\n\n Fix on the cross to start the trial'];
                        barTiltNow = bar_only(block);
                    end
                    
                case  5
                    str_trial = ['\n Adjust the bar to the perceived location'    '\n\n Fix on the cross to start the trial'];
                    barTiltNow = bar_only(block);
            end
            
        elseif barLocation == 'n'
            barTiltNow = barTiltStartNormal;
            str_trial = '\n Adjust the bar until horizon   \n\n Fix on the cross to start the trial'
        end
        
        
        %----------------------------------------------------------------------
        %  Eyelink file transfer to Display PC and check if fixation correct
        %  'Fast' method (sample only)
        %----------------------------------------------------------------------
        if isEyelink
            while 1
                err = Eyelink('CheckRecording');
                
                if (err ~= 0)
                    fprint('EyeLink Recording stopped! \n')
                    % Transfer a copy of the EDF file to Display PC
                    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
                    Eyelink('CloseFile'); % Close EDF file on Host PC
                    Eyelink('Commond','clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                    WaitSecs(0.1) %Allow some time for screen drawing
                    % Transfer a copy of the EDF to Display PC
                    transferFile; % See transferFile function below
                    cleanup ; % Abort experiment(see cleanup function below)
                    return
                end
                
                % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
                % This is equivalent to eyeLink_newest_float_samp() in C API.
                % See Eyelink programmers Guidmanual > function lists > Message
                % and Command Sending/Recording
                % Fast method (sample only)
                if Eyelink('NewFloatSampleAvailable') > 0
                    
                    % Get sample data in a Matlab structure
                    evt = Eyelink('NewestFloatSample');
                    
                    % save sample properties as variables. See Eyelink
                    % Programmers Guide manual > Data Structures > FSAMPLE
                    x = evt.gx(eyeUsed + 1); % [left eye gaze x, right eye gaze x] + 1 as we're accessing a Matlab array
                    y = evt.gy(eyeUsed + 1); % [Left eye gaze y,right eye gaze y]
                    
                    
                    if (x >= xCenter - gaze_away_pixel && x <= xCenter + gaze_away_pixel) && ...
                            (y >= yCenter - gaze_away_pixel && y <= yCenter + gaze_away_pixel)
                        break;
                    end
                    
                    % The following sample properties are also available online
                    % but are not used in this script;
                    % evt.time; % Sample EDF time
                    % evt.type; % Event type (SAMPLE = 200)
                    % evt.pa; % [left eye poupil size, right eye pupil size]
                    % evt.rx; % Gaze x 'pixel per degree' value
                    % evt.ry; % Gaze y 'pixel per degree' value
                    
                    %        %----------------------------------------------------------------------
                    %        %            Buffered data (samples, events)
                    %        %----------------------------------------------------------------------
                    %          % Get next data item (sample or event) from link buffer.
                    %          evtype = Eyelink('GetNextDataType')
                    %
                    %          % Read item type returned by getnextdatatype. Wait for end of
                    %          % saccade (ENDSACC) event
                    %          if evtype == el.ENDSACC % if end of saccade (ENDSACC) event is returned
                    %              evt = Eyelink('GetFloatData',evtype); % access the ENDSACC event structure
                    %
                    
                    DrawFormattedText(wptr, str_trial, 'center', 'center', blackcolor,[],[],[],[],[],topLeftQuadRect);
                    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                    Screen('Flip',wptr);
                end
            end
        end
        
        
        if trial ~= trialNumber
            
            while respToBeMade
                
                currentframe = currentframe + 1;
                back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
                
                
                % make sure the red bar didn't show up at the beginning of
                % the rotation
                if currentframe == 1
                    back.CurrentAngle = barTiltNow - 2;  % back.reverse_anlge_end
                    %                     back.CurrentAngle = back.reverse_anlge_start - barTiltNow ;
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
                if strcmp(blurredBoundaryExp,'y')
                    if trial == 3
                        back.presentAngle = back.CurrentAngle + 90;
                    else
                        back.presentAngle = back.CurrentAngle;
                    end
                elseif strcmp(blurredBoundaryExp,'n')
                    if trial == 2
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
                        
                    elseif data.flashTiltDirection == 2  && back.FlagSpinDirecB == 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        
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
            
            
        elseif trial == trialNumber
            
            barMovStep = 0.1;
            
            while respToBeMade
                
                barRectTiltDegree =  barTiltNow;
                barDrawTiltDegree = barTiltNow;
                
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree) - perc_loc_shift_pixel, yCenter - centerRingRadius2Center * cosd(barRectTiltDegree));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
                
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
                
                
                %----------------------------------------------------------------------
                %                      Eyelink  recording
                %----------------------------------------------------------------------
                if isEyelink
                    if currentframe==1
                        if trial == 1
                            Eyelink('Message','Bar Only');
                        end
                        if trial == 2
                            Eyelink('Message','Off Sync');
                        end
                        if trial == 3
                            Eyelink('Message','Flash Grab');
                        end
                        if trial == 4
                            Eyelink('Message','Perceived Location');
                        end
                    end
                    
                    %                     if frameK == PresentFlyFrames+1
                    %                         Eyelink('Message',['ball ' num2str(Ntrial) 'stopped at' num2str(GetSecs(), '%10.5f')]);
                    %                     end
                    
                end
                
                
            end
        end
        
        if barLocation ~= 'n'
            if  trial == 1      % flash bar only
                bar_only(block) = barTiltNow;
            elseif trial == 2   % off-sync
                off_sync(block) = barTiltNow;
            elseif trial == 3     % flash grab
                flash_grab(block) = barTiltNow;
            elseif trial == 4  % perceived location or none
                perceived_location(block) = barTiltNow;
            end
            
        else
            grab_effect_degree(block) = barTiltNow;
        end
        
        WaitSecs (0.5);
    end
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
    KbWait;
    WaitSecs(3);
    Screen('CloseAll');
    Eyelink('CloseFile');
    
    
    try
        fprint('Receiving data file "%s"\n',edfFile);
        status = Eyelink('ReceivingFile');
        if status > 0
            fprintf('ReciveFile status %d\n',status);
        end
        
        eyelinkDataSavePath = '../../../data/corticalBlindness/Eyelink_guiding/';
        
        if exist(edfFile,'file') == 2
            fprintf('Data file "%s" can be found in "%s"\n',edfFile,pwd)
        end
        
        fprintf('Problem Receiving data file "%s"\n',edfFile);
    end
    
    Eyelink('ShutDown');
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

subdir = sprintf(['../../../data/corticalBlindness/Eyelink_guiding/' '%s/'],sbjname);
if ~isdir(subdir)
    mkdir(subdir)
end

if strcmp(blurredBoundaryExp,'y')
    expdir = strcat(subdir,'blurredBoundary');
elseif strcmp(blurredBoundaryExp,'n')
    expdir = strcat(subdir,'sectorEight');
end

if strcmp(blindspot,'y')
    expdir = strcat(subdir,'blindspot');
end

if ~isdir(expdir)
    mkdir(expdir)
end

savePath = expdir;

time = clock;

filename = sprintf('%s_%s_%s_%02g_%02g_%02g_%02g_%02g',sbjname,condition,barLocation,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);


% %----------------------------------------------------------------------
% %                    average illusion size
% %----------------------------------------------------------------------
%
% illusionCCWIndex = find(data.flashTiltDirection == 1);
% illusionCWIndex = find(data.flashTiltDirection == 2);
%
% % if strcmp(barlocation,'u')
% %     quardant
% bar_CCWDegree = mean(bar_only(illusionCCWIndex));
% bar_CWDegree = mean(bar_only(illusionCWIndex));
% off_sync_CCWDegree = mean(off_sync(illusionCCWIndex));
% off_sync_CWDegree = mean(off_sync(illusionCWIndex));
% flash_grab_CCWDegree = mean(flash_grab(illusionCCWIndex));
% flash_grab_CWDegree = mean(flash_grab(illusionCWIndex));
%
% if strcmp(condition, 'invi2vi')
%     perceived_location_CCWDegree = mean(perceived_location(illusionCCWIndex));
%     perceived_location_CWDegree = mean(perceived_location(illusionCWIndex));
% end
%
% if strcmp(condition, 'vi2invi')
%     y = [bar_CCWDegree off_sync_CCWDegree flash_grab_CCWDegree bar_CWDegree off_sync_CWDegree flash_grab_CWDegree];
%     h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1);
%     set(gca, 'XTick', 1:6, 'XTickLabels', {'bar-CCW' 'off-sync-CCW' 'grab-CCW'  'bar-CW' 'off-sync-CW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
% elseif strcmp(condition, 'invi2vi')
%     y = [bar_CCWDegree off_sync_CCWDegree flash_grab_CCWDegree perceived_location_CCWDegree bar_CWDegree off_sync_CWDegree flash_grab_CWDegree perceived_location_CWDegree];
%     h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1);
%     set(gca, 'XTick', 1:8, 'XTickLabels', {'bar-CCW' 'off-sync-CCW' 'grab-CCW' 'perc-CCW' 'bar-CW' 'off-sync-CW' 'grab-CW' 'perc-CW'},'fontsize',20,'FontWeight','bold');
% end
%
%
% set(gcf,'color','w');
% set(gca,'box','off');
% % title('Illusion size','FontSize',25);

sca;
