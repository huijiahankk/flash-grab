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
    eyelinkfilename_eye = sbjname;
    
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
sectorRadius_out_visual_degree = 16; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 14; % sunnannan 5.5   mali7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);

% eye gaze distance from center
gaze_away_visual_degree = 0.5;
gaze_away_pixel = round(tand(gaze_away_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);


%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 8;

% sectorRadius_in_pixel = floor((visualHeightIn7T_pixel - 400)/2);    % inner diameter of background annulus
% sectorRadius_out_pixel = floor((visualHeightIn7T_pixel - 20)/2);%  %         annnulus outer radius
dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
[sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%----------------------------------------------------------------------
%%%                     parameters of red dot  and red bar
%----------------------------------------------------------------------
barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);

% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barWidth, barLength);
barMat(:,:,2) = repmat(0,  barWidth, barLength);
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
% back.contrastratio = 1;
% trialNumber = 3;
back.CurrentAngle = 0;
% back.AngleRange = 180;

% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left

barTiltStep = 1; %2.8125   1.40625;
back.alpha = 0; % background transparence
barTiltStartLower = 0;
barTiltStartUpper =  0;

% wedgeTiltIncre = 0;
back.SpinSpeed = 6;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
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
    
    formatSpec = 'This is the %dth of %d block. Press Any Key To Begin';
    A1 = block;
    A2 = blockNumber;
    str = sprintf(formatSpec,A1,A2);
    DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    %         DrawFormattedText(wptr, '\n\nPress Any Key To Begin', 'center', 'center', blackcolor);
    %         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);
    
    Screen('Flip', wptr);
    
    KbStrokeWait;
    
    
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
            
            %    draw background each frame
            Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.alpha); %  + backGroundRota
            
            
            % present flash tilt right
            if data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                if barLocation == 'l' | barLocation == 'lowerleft'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barTiltNow), yCenter + dotRadius2Center * cosd(barTiltNow));
                elseif  barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barTiltNow), yCenter - dotRadius2Center * cosd(barTiltNow));
                    
                end
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,back.CurrentAngle);
                
                flashPresentFlag = 1;
                % present flash tilt left
            elseif data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1    % flash tilt left
                
                
                if barLocation == 'l' | barLocation == 'lowerleft'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barTiltNow), yCenter + dotRadius2Center * cosd(barTiltNow));
                elseif barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barTiltNow), yCenter - dotRadius2Center * cosd(barTiltNow));
                    
                end
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,back.CurrentAngle);
                
                
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
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
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
