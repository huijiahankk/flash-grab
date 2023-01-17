% generate a flash-grab checkerboard event-related for testing whether SC
% response to the illusion or physical position
% flash tilt right:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1
% flash perceived tilt left :   data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1


clear all;close all;

if 1
    sbjname = 'hjh';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    isEyelink = 0;
    eyelinkfilename_eye = 'bar_only_hjh';
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    dotOrWedgeFlag = input('>>>Use dot flash Or wedge flash or bar flash? (d/w/b):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    isEyelink = input('>>>Use eye link? (y for yes\n for no):  ','s');
    eyelinkfilename_eye = sbjname;
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../../function;
% addpath ../../../FGE_subcortex_new/flashgrabExp_7T_layer;
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

HideCursor;
centerMovePix = 0;
framerate = FrameRate(wptr);

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
sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

% eye gaze distance from center
gaze_away_visual_degree = 0.5;
gaze_away_pixel = round(tand(gaze_away_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);


%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 8;

[sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%----------------------------------------------------------------------
%%%                     parameters of red bar
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

trialNumber = 2;
blockNumber = 2;

back.CurrentAngle = 0;
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left

barTiltStep = 1; %2.8125   1.40625;
back.alpha = 0; % background transparence
barTiltStartUpper = 0;
barTiltStartLower = 120;

back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';


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
    
    %     str = 'Fixation on the cross then the next trial will began';
    %     %     DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    %     Screen('DrawText', wptr, str, xCenter - 100, yCenter - 100, blackcolor);
    %     Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
    %     Screen('Flip', wptr);
    %     WaitSecs (2);
    
    formatSpec = 'This is the %dth of %d block. Fixation on the cross to start the trial';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    %     DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    Screen('DrawText', wptr, str, xCenter - 400, yCenter - 100, blackcolor);
    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
    Screen('Flip', wptr);
    WaitSecs (2);
    
    
    for trial = 1:trialNumber
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        data.flashTiltDirection(block,trial) = back.flashTiltDirectionMatShuff(trial);
        currentframe = 0;
        flashtimes = 0;
        
        % the first row is for upper field
        if block == 1
            barLocation = 'u';
            barTiltNow = barTiltStartUpper;
            % the second row is for lower field
        elseif block == 2
            barLocation = 'l';
            barTiltNow = barTiltStartLower;
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
                    
                    
                    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                    Screen('Flip',wptr);
                end
            end
        end
        
        
        while respToBeMade
            
            currentframe = currentframe + 1;
            back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
            
            % make sure the red bar didn't show up at the beginning of
            % the rotation
            if currentframe == 1
                back.CurrentAngle = barTiltNow - 1;  % back.reverse_anlge_end
                %                     back.CurrentAngle = back.reverse_anlge_start - barTiltNow ;
            end
            
            if data.flashTiltDirection(trial) == 1    % CCW
                % when larger than certain degree reverse  CCW
                if back.CurrentAngle >= 0 + barTiltNow %   back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                    back.SpinDirec = - 1;
                    back.FlagSpinDirecA = back.SpinDirec;
                    %  when lower than certain degree reverse  CW
                elseif back.CurrentAngle <= - 180 + barTiltNow %  - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                    back.SpinDirec = 1;
                    back.FlagSpinDirecB = back.SpinDirec;
                end
            elseif data.flashTiltDirection(trial) == 2   % CW
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
            
            if data.flashTiltDirection(trial) == 1  && back.FlagSpinDirecA ==  - 1
                
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barTiltNow);  % DrawTexture 0 deg. = upright
                
                flashtimes = flashtimes + 1;
                barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                
            elseif data.flashTiltDirection(trial) == 2  && back.FlagSpinDirecB == 1
                
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barTiltNow);
                
                flashtimes = flashtimes + 1;
                barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
            end
            
            
            
            
            back.FlagSpinDirecA = 0;
            back.FlagSpinDirecB = 0;
            
            
            
            % draw fixation
            %             Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
            Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
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
                    barTiltNow = barTiltNow + 5 * barTiltStep;
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                    %                     prekeyIsDown = 1;
                    %                 WaitSecs(0.5);
                end
            end
            prekeyIsDown = keyIsDown;
            
            %----------------------------------------------------------------------
            %                      Eyelink  stamp
            %----------------------------------------------------------------------
            if isEyelink
                if currentframe==1
                    if block == 1
                        if trial == 1
                            Eyelink('Message','upper-trial1');
                        elseif trial ==2
                            Eyelink('Message','upper-trial2');
                        end
                    end
                    if block == 2
                        if trial == 1
                            Eyelink('Message','lower-trial1');
                        elseif trial ==2
                            Eyelink('Message','lower-trial2');
                        end
                    end
                end
                
                %                     if frameK == PresentFlyFrames+1
                %                         Eyelink('Message',['ball ' num2str(Ntrial) 'stopped at' num2str(GetSecs(), '%10.5f')]);
                %                     end
                
            end
            
            
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/framerate) * flashRepresentFrame);
                
            end
            
            % for debug when flash present the simulus halt
            if debug== 'y' && flashPresentFlag
                KbWait;
            end
            
            
            
        end
        
        
        data.wedgeTiltEachBlock(block,trial) = barTiltNow;
        WaitSecs (1);
        
    end
    
    %     display(GetSecs - ScanOnset);
    
end

display(GetSecs - ScanOnset);

%----------------------------------------------------------------------
%              stop eyelink recording
%----------------------------------------------------------------------
if isEyelink
    Eyelink('stopRecording');
    Eyelink('command','set_idle_mode');
    %     iSuccess = Eyelink('ReceiveFile', [], edfDir, 1);
    %             disp(conditional(iSuccess > 0, ['Eyelink File Received, file size is ' num2str(iSuccess)], ...
    %                 'Something went wrong with receiving the Eyelink File'));
    WaitSecs(0.5);
    Eyelink('CloseFile')
    
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        
        eyelinkDataSavePath = '../../../data/corticalBlindness/Eyelink_guiding/';
        
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, eyelinkDataSavePath );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    
    Eyelink('ShutDown');
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

% dir = sprintf(['../../../data/corticalBlindness/Eyelink_guiding/'  '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end
%
% savePath = dir;

savePath = '../../../data/corticalBlindness/Eyelink_guiding/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------

blindFieldUpper = mean(data.wedgeTiltEachBlock(1,:));
blindFieldLower = mean(data.wedgeTiltEachBlock(2,:));

sca;