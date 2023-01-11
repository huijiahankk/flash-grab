%%%%%%%%%%
% STEP 3 %
%%%%%%%%%%

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).

el=EyelinkInitDefaults(windowPtr);

% We are changing calibration to a black background with white targets,
% no sound and smaller targets
el.backgroundcolour = gray;
el.msgfontcolour  = WhiteIndex(el.windowPtr);
el.imgtitlecolour = WhiteIndex(el.windowPtr);
el.targetbeep = 0;
el.calibrationtargetcolour= gray*1.5;

% for lower resolutions you might have to play around with these values
% a little. If you would like to draw larger targets on lower res
% settings please edit PsychEyelinkDispatchCallback.m and see comments
% in the EyelinkDrawCalibrationTarget function
el.calibrationtargetsize= 1;
el.calibrationtargetwidth=0.5;
% call this function for changes to the calibration structure to take
% affect
EyelinkUpdateDefaults(el);


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
end;


%%%%%%%%%%
% STEP 5 %
%%%%%%%%%%

% SET UP TRACKER CONFIGURATION
% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;
Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');

[winWidth, winHeight]=Screen('WindowSize', screenNumber);

% This command is crucial to map the gaze positions from the tracker to
% screen pixel positions to determine fixation
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);

% set calibration type.
Eyelink('command', 'calibration_type = HV5');
Eyelink('command', 'generate_default_targets = YES');
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
    Screen('HideCursorHelper', windowPtr);
end
% enter Eyetracker camera setup mode, calibration and validation
EyelinkDoTrackerSetup(el);


%%%%%%%%%
% STEP 7%
%%%%%%%%%
% 
% % Now starts running individual trials
% % You can keep the rest of the code except for the implementation
% % of graphics and event monitoring
% % Each trial should have a pair of "StartRecording" and "StopRecording"
% % calls as well integration messages to the data file (message to mark
% % the time of critical events and the image/interest area/condition
% % information for the trial)
% 
% 
% 
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
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
% % returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
if eye_used == 2
    eye_used = 1; % use the right_eye data
end
% 
% % STEP 7.4
% % Prepare and show the screen.
Eyelink('Message', 'SYNCTIME');   %% ????????