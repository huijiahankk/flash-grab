%% ============================= read me =========================
% 1. run the code directly
% 2. input patient order (such as 01)
% 3. input eyelink edf file name

% 4. select five  sites for calibration 
%    (for each site,
%     left-click, then move by down/up/left/right arrow, 
%     scale down by pressing '1', scale up by '2'
%     press 'space' to end this site,
%     after having selected five sites, double click to end this step)

% 5. calibrate
%    (press any key to initiate Eyelink to calibrate and validate)

% 6. check the exact blind and normal area
%    (left-click, move by down/up/left/right arrow, 
%     scale down by pressing '1', scale up by '2',
%     press 'return' to end, 
%     then flickering disc appears in the normal area,
%     after verifying the normal area, press 'escape')

% 7. double check
%    (left-click to display stimuli in the blind and normal area,
%     scale down by pressing '3',
%     press '4' to end)

% 8. press any key and wait for 3 seconds to end this code.

% 9. a file will be saved by this code,
%    (named such as P1_blindPara.mat, 
%     containing center coordinates and visual angle of stimuli,
%     as well as coordinates of five calibration sites).
%% ===============================================================
% input the order of patients
pOrder = num2str(input('patient order: '));

% eyelink_init1;
 dummymode=0;
if ~IsOctave
    commandwindow;
else
    more off;
end

%%%%%%%%%%
% STEP 1 %
%%%%%%%%%%

% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
if IsOctave
    edfFile = 'DEMO';
else
    prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
    dlg_title = 'Create EDF file';
    num_lines= 1;
    def     = {'DEMO'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    edfFile = answer{1};
    fprintf('EDFFile: %s\n', edfFile );
end

% open a window
ShowCursor(0);
Screen('Preference', 'SkipSyncTests',0);
Screen('Preference', 'ConserveVRAM',8);
Screen('Preference','VisualDebugLevel', 1);
AssertOpenGL;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
[window,screenRect] = Screen('OpenWindow',screenNumber,black,[100 100 800 800]);
[x,y] = WindowCenter(window);
pwidth = screenRect(1,3);
pheight = screenRect(1,4);
wy = pheight;
wx = pwidth;
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('TextFont',window,'Arial');
Screen('TextSize',window,18);   
priorityLevel = MaxPriority(window);
Priority(priorityLevel);
vdist = 85; % distance between eye and monitor    
screenWidth = 59; % screen's physical width 
pix = screenWidth/pwidth;  %calculates the size of a pixel in cm  

% draw the fixcross
fixCrossDimPix = 15;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords]; 
LineWithPix = 6;
Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]);
Screen('Flip',window); 

% select five dots as calibration sites
xx_cali = [];
yy_cali = [];
n = 0;
firstCircleDegree = 2;
CircleDegree = firstCircleDegree;
f = 7.5;

while 1 
  [clicks,x_cali,y_cali] = GetClicks(window,1);
  if clicks==2
      break;
      
  elseif clicks==1
      n=n+1;      
      Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]);
      tic
      
      while 1 
          t = toc;
          locEcc = round(2*tan((firstCircleDegree/2)*pi/180) * vdist / pix); 
          color=255*(round(127.5*sin(2*pi*f*t)+127.5) >= 127.5);
          Screen('FillOval',window,color,[x_cali-locEcc,y_cali-locEcc,x_cali+locEcc,y_cali+locEcc]);
          Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
          Screen('Flip',window); 
          
          KbName('UnifyKeyNames');
          [kid,~,kc] = KbCheck;
          if kc(KbName('DownArrow'))
              y_cali=y_cali+10;
              locsEcc = round(2 *tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window);  

          elseif kc(KbName('UpArrow'))
              y_cali=y_cali-10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window);   
              
          elseif kc(KbName('LeftArrow'))
              x_cali=x_cali-10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window); 
          
          elseif kc(KbName('RightArrow'))
              x_cali=x_cali+10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window); 
              
          elseif kc(KbName('1'))     
              CircleDegree = firstCircleDegree-0.1;
              if CircleDegree < 0
                  CircleDegree = 0;
              end 
              locsEcc = round(2 *tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window);  
              
          elseif kc(KbName('2'))

              CircleDegree = firstCircleDegree+0.1;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',window,color,[x_cali-locsEcc,y_cali-locsEcc,x_cali+locsEcc,y_cali+locsEcc]);
              Screen('DrawLines', window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',window);  
              
          end 
          
          firstCircleDegree = CircleDegree;
          
          if  kc(KbName('space'))==1 
              break;
          end
      end
      
      xx_cali(n) = x_cali;
      yy_cali(n) = y_cali;
  end
end

if n==5
    x_cali1 = xx_cali(1);
    x_cali2 = xx_cali(2);
    x_cali3 = xx_cali(3);
    x_cali4 = xx_cali(4);
    x_cali5 = xx_cali(5);

    y_cali1 = yy_cali(1);
    y_cali2 = yy_cali(2);
    y_cali3 = yy_cali(3);
    y_cali4 = yy_cali(4);
    y_cali5 = yy_cali(5);
end


KbWait; 


% calibrate at above five sites

% eyelink_init2;
%%%%%%%%%%
% STEP 3 %
%%%%%%%%%%

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).

% el=EyelinkInitDefaults(window);
El=EyelinkInitDefaults(window);
% We are changing calibration to a black background with white targets,
% no sound and smaller targets
El.backgroundcolour = grey;
El.msgfontcolour  = WhiteIndex(El.window);
El.imgtitlecolour = WhiteIndex(El.window);
El.targetbeep = 0;
El.calibrationtargetcolour= grey*1.5;

% for lower resolutions you might have to play around with these values
% a little. If you would like to draw larger targets on lower res
% settings please edit PsychEyelinkDispatchCallback.m and see comments
% in the EyelinkDrawCalibrationTarget function
El.calibrationtargetsize = 1;
El.calibrationtargetwidth = 0.5;
% call this function for changes to the calibration structure to take
% affect
EyelinkUpdateDefaults(El);

%%%%%%%%%%
% STEP 4 %
%%%%%%%%%%

% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.

if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
%     cleanup;  % cleanup function
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

% open file to record data to
i = Eyelink('Openfile', edfFile);
if i~=0
    fprintf('Cannot create EDF file ''%s'' ', edffilename);
%     cleanup;
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && ~dummymode
%     cleanup;
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end


%%%%%%%%%%
% STEP 5 %
%%%%%%%%%%

% SET UP TRACKER CONFIGURATION
% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;
Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');  %Must be used immediately after open_data_file, to add a note on file history.

[winWidth, winHeight] = Screen('WindowSize', screenNumber);

% This command is crucial to map the gaze positions from the tracker to
% screen pixel positions to determine fixation
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);

% set calibration type.
Eyelink('command', 'calibration_type = HV5');  
Eyelink('command', 'generate_default_targets = YES');
% STEP 5.1 modify calibration and validation target locations
Eyelink('command','calibration_samples = 6');
Eyelink('command','calibration_sequence = 0,1,2,3,4,5');
Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
    x_cali1,y_cali1,  x_cali2,y_cali2,  x_cali3,y_cali3,  x_cali4,y_cali4,  x_cali5,y_cali5 );
Eyelink('command','validation_samples = 5');
Eyelink('command','validation_sequence = 0,1,2,3,4,5');
Eyelink('command','validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
    x_cali1,y_cali1,  x_cali2,y_cali2,  x_cali3,y_cali3,  x_cali4,y_cali4,  x_cali5,y_cali5 );

% set parser (conservative saccade thresholds)
Eyelink('command', 'saccade_velocity_threshold = 22');
Eyelink('command', 'saccade_acceleration_threshold = 4000');
% set EDF file contents
% 5.1 retrieve tracker version and tracker software version
[v,vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );
vsn = regexp(vs,'\d','match');

if v ==3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx

    % remote mode possible add HTARGET ( head target)
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
else
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

% allow to use the big button on the eyelink gamepad to accept the 
% calibration/drift correction target
Eyelink('command', 'button_function 5 "accept_target_fixation"');

%%%%%%%%%%
% STEP 6 %
%%%%%%%%%%

if ~dummymode
    % Hide the mouse cursor and setup the eye calibration window
    Screen('HideCursorHelper', window);
end
% enter Eyetracker camera setup mode, calibration and validation
EyelinkDoTrackerSetup(El);

%%%%%%%%%
% STEP 7%
%%%%%%%%%
 
% % Now starts running individual trials
% % You can keep the rest of the code except for the implementation
% % of graphics and event monitoring
% % Each trial should have a pair of "StartRecording" and "StopRecording"
% % calls as well integration messages to the data file (message to mark
% % the time of critical events and the image/interest area/condition
% % information for the trial)
 
% % STEP 7.2
% % Do a drift correction at the beginning of each trial
% % Performing drift correction (checking) is optional for
% % EyeLink 1000 eye trackers. Drift correcting at different
% % locations x and y depending on where the ball will start
% % we change the location of the drift correction to match that of
% % the target start position
% EyelinkDoDriftCorrection(el,[],[],1);    % will show a white rectangle on the screen.

% % STEP 7.3
% % start recording eye position (preceded by a short pause so that
% % the tracker can finish the mode transition)
% % The paramerters for the 'StartRecording' call controls the
% % file_samples, file_events, link_samples, link_events availability

% Before recording, we place reference graphics on the host display
% Must be offline to draw to EyeLink screen
Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0');
% Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
% returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
if eye_used == 2
    eye_used = 1; % use the right_eye data
end

% % STEP 7.4
% % Prepare and show the screen.
Eyelink('Message', 'SYNCTIME');

% KbWait;
Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
Screen('Flip',El.window); 

% calibration done, then draw a circle in the blind area
firstCircleDegree = 2;
CircleDegree = firstCircleDegree;
f = 7.5;

[clicks,x_blind,y_blind] = GetClicks(El.window,1);
if clicks==1 
      Screen('FillRect',El.window,[0,0,0]);
      Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
      tic
      Eyelink('Message','check the blind area');
      while 1 
          t = toc;
          locEcc = round(2*tan((firstCircleDegree/2)*pi/180) * vdist / pix); 
          color=255*(round(127.5*sin(2*pi*f*t)+127.5) >= 127.5);
          Screen('FillOval',El.window,color,[x_blind-locEcc,y_blind-locEcc,x_blind+locEcc,y_blind+locEcc]);
          Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
          Screen('Flip',El.window); 
          
          KbName('UnifyKeyNames');
          [kid,~,kc] = KbCheck;
          if kc(KbName('DownArrow'))
              y_blind=y_blind+10;
              locsEcc = round(2 *tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window);  

          elseif kc(KbName('UpArrow'))
              y_blind=y_blind-10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window);   
              
          elseif kc(KbName('LeftArrow'))
              x_blind=x_blind-10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window); 
          
          elseif kc(KbName('RightArrow'))
              x_blind=x_blind+10;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window); 
              
          elseif kc(KbName('1'))     
              CircleDegree = firstCircleDegree-0.1;
              if CircleDegree < 0
                  CircleDegree = 0;
              end 
              locsEcc = round(2 *tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window);  
              
          elseif kc(KbName('2'))

              CircleDegree = firstCircleDegree+0.1;
              locsEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
              Screen('FillOval',El.window,color,[x_blind-locsEcc,y_blind-locsEcc,x_blind+locsEcc,y_blind+locsEcc]);
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]); 
              Screen('Flip',El.window);  
              
          end 
          
          firstCircleDegree = CircleDegree;
          
          if  kc(KbName('return'))==1 
              break;
          end

      end 
 
end


% draw a circle in the contralateral normal area
tic
Eyelink('Message','check the normal area');
while 1 
    KbName('UnifyKeyNames');
    [kid,~,kc] = KbCheck;
        t = toc;
        locEcc = round(2*tan((CircleDegree/2)*pi/180) * vdist / pix); 
        color = 255*(round(127.5*sin(2*pi*f*t)+127.5) >= 127.5);
        x_normal = x-(x_blind-x);
        y_normal = y_blind;
        Screen('FillOval',El.window,color,[x_normal-locsEcc,y_blind-locsEcc,x_normal+locsEcc,y_blind+locsEcc]);
        Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
        Screen('Flip',El.window); 

     if  kc(KbName('ESCAPE'))
           break;
     end
end


% calculate stimuli position in the blind area and normal area
% scale stimuli size
verAngle = atan(abs(x_blind-x)/abs(y_blind-y));
ratio = 4/4; % 4 degrees visual angel at 4 degrees eccentricity
eccPixels = abs(x_blind-x)/sin(verAngle);
eccDeg = atan(eccPixels/2*pix/vdist)*2*180/pi;
stimDeg = eccDeg*ratio;

stimRadius = round(tan((stimDeg/2)*pi/180)*vdist/pix);
edgeDeg = 2;
edgePixels = round(2*tan((edgeDeg/2)*pi/180)*vdist/pix);

% if stimuli size is beyond the blind area,
% scaling down the blind area by 1 degree as the stimuli size 

% stimRadius is the radius of the stimuli
% locsEcc is the radius of the blind area
% CircleDegree is the half of the blind area degree
if stimRadius<locsEcc && (simRadius*2+edgePixels)<locsEcc*2  
    stimRadius = stimRadius;
    stimDeg = stimDeg;
else
    stimDeg = CircleDegree*2-1;
    stimRadius = round(2*tan((stimDeg/2)*pi/180)*vdist/pix);
    
end

x_stimBlind = x+(eccPixels-locsEcc+edge+stimRadius)*sin(verAngle)*(x_blind-x)/abs(x_blind-x);
y_stimBlind = y+(eccPixels-locsEcc+edge+stimRadius)*cos(verAngle)*(y_blind-y)/abs(y_blind-y);
 
x_stimNormal = x-(x_stimBlind-x);
y_stimNormal = y_stimBlind;

% display stimuli to double check
Disc = imread( '0.png');
ref = Screen('MakeTexture',El.window,Disc);
    
pixsPic = round(2*tan((stimDeg/2)*pi/180) * vdist / pix);
picrect = [0 0 pixsPic pixsPic];
rect(1,:) = CenterRectOnPoint(picrect,x_stimBlind,y_stimBlind);% blind area
rect(2,:) = CenterRectOnPoint(picrect,x_stimNormal,y_stimNormal); % normal area

[click_stim,x_stim,y_stim] = GetClicks(El.window,1);
if click_stim==1 
      Screen('FillRect',windowPtr,[128,128,128]);
      Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
      Eyelink('Message','double check stimuli in the blind and normal area');
      while 1
          Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
          Screen('DrawTextures', El.window,ref',[],rect');
          Screen('Flip', El.window);
          KbName('UnifyKeyNames');
          [kid,~,kc] = KbCheck;
          if kc(KbName('3'))
              stimDeg = stimDeg-0.1;
              if stimDeg<0
                  stimDeg = 0;
              end
              pixsPic = round(2*tan((stimDeg/2)*pi/180) * vdist / pix);
              picrect = [0 0 pixsPic pixsPic];

              rect_blind = CenterRectOnPoint(picrect,x_stimBlind,y_stimBlind);% blind area
              rect_normal = CenterRectOnPoint(picrect,x_stimNormal,y_stimNormal); % normal area
              Screen('DrawLines', El.window, allCoords, LineWithPix, [255,0,0], [x y]);
              Screen('DrawTextures', El.window,ref',[],rect');
              Screen('Flip', El.window);
          end
          if kc(KbName('4'))
              break;
          end
      end
end
              

% save stimuli center coordinates,stimuli visual angle
% and five calibration sites
para.stimDeg = stimDeg;
para.x_stimBlind = x_stimBlind;
para.y_stimBlind = y_stimBlind;
para.x_stimNormal = x_stimNormal;
para.y_stimNormal = y_stimNormal;

para.x_cali1 = x_cali1;
para.x_cali2 = x_cali2;
para.x_cali3 = x_cali3;
para.x_cali4 = x_cali4;
para.x_cali5 = x_cali5;

para.y_cali1 = y_cali1;
para.y_cali2 = y_cali2;
para.y_cali3 = y_cali3;
para.y_cali4 = y_cali4;
para.y_cali5 = y_cali5;

save(['P' pOrder(1) '_blindPara.mat'],'para');  

Eyelink('StopRecording');

KbWait; 
WaitSecs(3);
Screen('CloseAll');
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
Eyelink('CloseFile');

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
catch %#ok<*CTCH>
    fprintf('Problem receiving data file ''%s''\n', edfFile );
end


%%%%%%%%%%
% STEP 9 %
%%%%%%%%%%

% run cleanup function (close the eye tracker and window).
Eyelink('Shutdown');
  























