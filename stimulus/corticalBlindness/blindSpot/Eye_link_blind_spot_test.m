% test the right eye blind spot using an adjustable red dot
% '1' for bar length reduce '2' for enlarge
% 'right arrow' for moving rightward and 'left arrow' for moving leftward
% At the beginning of each trial the fixation should within
% "gaze_away_visual_degree"  then the trial could begin
% 20230117 Jiahan Hui


clear all;close all;

if 1
    sbjname = 'hjh';
    isEyelink = 1;
else
    sbjname = input('>>>Please input the subject''s name:   ','s');
    isEyelink = input('>>>Use eye link? (y for yes\n for no):  ','s');
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
redcolor = [255 0 0]; %(whitecolor + blackcolor) / 2; % 128
greycolor = (whitecolor + blackcolor) / 2;
[wptr,rect]=Screen('OpenWindow',screenNumber,greycolor,[],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);

% HideCursor;
centerMovePix = 0;
framerate = FrameRate(wptr);

% draw the fixcross
fixCrossDimPix = 15;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;


trialNumber = 4;

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

eyeScreenDistence = 63;  % 78cm  68sunnannan
screenHeight = 33.5; % 26.8 cm
sectorRadius_out_visual_degree = 11; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 11; % sunnannan 5.5   mali7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

% eye gaze distance from center
fixRadius_dva = 2;
fixRadius = round(tand(fixRadius_dva) * eyeScreenDistence *  rect(4)/screenHeight);
fixateTimeDura = 600; %ms
driftDuation = 30; %  frame
%----------------------------------------------------------------------
%    flash dot parameter to map the blind spot postion
%----------------------------------------------------------------------
dot.radius_dva = 0.5;
dot.radius_pixel = round(tand(dot.radius_dva) * eyeScreenDistence *  rect(4)/screenHeight);
dot.moveStep_dva = 0.1; % dva
dot.moveStep =  round(tand(dot.moveStep_dva) * eyeScreenDistence *  rect(4)/screenHeight); % pixel
dot.startPosition = centerRingRadius2Center; % pixel
dot.flashFreq = 10; % Hz
dot.flashRepresentFrame = 8; % frame
dot.rightBorderShift_dva = 2 ; %dva
dot.rightBorderShift =  round(tand(dot.rightBorderShift_dva) * eyeScreenDistence *  rect(4)/screenHeight);  ; %dva
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
%                       Experimental loop
%----------------------------------------------------------------------
trial = 0;
while trial <= trialNumber
    trial = trial +1;
    TrialOnset = GetSecs;
    respToBeMade = true;
    currentframe = 0;
    flashPresentFlag = 0;
    fixDriftFrame = 0;
    isOutFixationWindowFrame = 0;
    isOutFixationWindowTimes = 0;
    
    %     if trial == 1
    str = 'Fix on the cross to start the trial';
    %     DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
    Screen('DrawText', wptr, str, xCenter - 100, yCenter - 100, blackcolor);
    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
    Screen('Flip', wptr);
    WaitSecs (1);
    %     end
    
    %----------------------------------------------------------------------
    %  Eyelink file transfer to Display PC and check if fixation correct
    %  'Fast' method (sample only)
    %----------------------------------------------------------------------
    if isEyelink
        %             fixateTime = GetSecs + fixateTimeDura;
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
            
            [x, y] = getEyelinkCoordinates();
            if isnan(x) || isnan(y)
                fprintf('Eye tracker lost track of eyes \n');
            else
                % Check if gaze is within fixation window
                if isWithinFixationWindow(x, y, xCenter, yCenter, fixRadius)
                    gazeRect=[ x-9 y-9 x+10 y+10];
                    %                         fixationcolour=round(rand(3,1)*255); % coloured dot
                    fixationcolour = greycolor + 10;
                    Screen('DrawText', wptr, str, xCenter - 100, yCenter - 100, blackcolor);
                    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                    Screen('FillOval', wptr, fixationcolour, gazeRect);
                    Screen('Flip',wptr);
                    fixDriftFrame = fixDriftFrame + 1;
                    isOutFixationWindowFrame  = fixDriftFrame;
                else  isOutFixationWindowFrame >= driftDuation
                    break;
                    %                 elseif isOutFixationWindowFrame  < driftDuation
                    %                     fprintf('Gaze is outside fixation window before experiment   \n');
                end
            end
        end
    end
    fixDriftFrame = 0;
    isOutFixationWindowFrame = 0;
    %----------------------------------------------------------------------
    %%%                  parameters of red dot
    %----------------------------------------------------------------------
    if mod(trial,2) == 1
        dot.position = dot.startPosition;
    else
        dot.position = data.position(trial - 1) + dot.rightBorderShift;
    end
    
    while respToBeMade
        
        currentframe = currentframe + 1;
        
        if mod(trial,2) == 1 && currentframe < 20
            dotcolor = redcolor;
        else
            dotcolor = redcolor;
        end
        
        if  mod(currentframe,60/dot.flashFreq) == 0
            flashPresentFlag = 1;
            % Draw the dot
            Screen('DrawDots', wptr, [xCenter + dot.position    yCenter], dot.radius_pixel, dotcolor, [], 2);
        end
        
        if isEyelink
            %             fixateTime = GetSecs + fixateTimeDura;
            %             while GetSecs <  fixateTime
            [x, y] = getEyelinkCoordinates();
            if isnan(x) || isnan(y)
                fprintf('Eye tracker lost track of eyes \n');
            else
                % Check if gaze is within fixation window
                if isWithinFixationWindow(x, y, xCenter, yCenter, fixRadius)
                    gazeRect=[ x-9 y-9 x+10 y+10];
                    %                     fixationcolour=round(rand(3,1)*255); % coloured dot
                    fixationcolour = greycolor + 10;
                    Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
                    Screen('FillOval', wptr, fixationcolour, gazeRect);
                    Screen('Flip',wptr);
                elseif  isOutFixationWindowFrame <= driftDuation
                    fixDriftFrame = fixDriftFrame + 1;
                    isOutFixationWindowFrame  = fixDriftFrame;
                elseif isOutFixationWindowFrame  > driftDuation
                    trialNumber = trialNumber + 1;
                    isOutFixationWindowTimes = isOutFixationWindowTimes + 1;
                    fprintf('Gaze is outside fixation window during experiment   \n');
                    break;
                end
            end
            
        else
            % draw fixation
            %             Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
            Screen('DrawLines', wptr, allCoords, LineWithPix, blackcolor, [xCenter,yCenter]);
            vbl = Screen('Flip',wptr);
        end
        %         end
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        %         if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
        if keyCode(KbName('ESCAPE'))
            ShowCursor;
            sca;
            return
            % the bar was on the left of the gabor
        elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
            dot.position = dot.position - dot.moveStep;
        elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
            dot.position = dot.position + dot.moveStep;
        elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
            dot.position = dot.position - 3 * dot.moveStep;
        elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
            dot.position = dot.position + 3 * dot.moveStep;
        elseif keyCode(KbName('Space'))
            respToBeMade = false;
            break;
            %                     prekeyIsDown = 1;
            %                 WaitSecs(0.5);
        end
        %         end
        %         prekeyIsDown = keyIsDown;
        
        if flashPresentFlag
            WaitSecs((1/framerate) * dot.flashRepresentFrame);
        end
        
        %----------------------------------------------------------------------
        %                      Eyelink  stamp
        %----------------------------------------------------------------------
        if isEyelink
            %             Eyelink('Message','SYNCTIME');
            if currentframe==1
                if mod(trial,2) == 1
                    message = ['blindspot left trial ',num2str(trial),'started'];
                    Eyelink('Message',message);
                else
                    message = ['blindspot right trial ',num2str(trial),'started'];
                    Eyelink('Message','blindspot right trial');
                end
            end
        end
    end
    
    data.position(trial) = dot.position;
    data.position_dva(trial) = atand(screenHeight * dot.position/(rect(4)*eyeScreenDistence));
    data.fixdrifttrial(trial) = fixDriftFrame;
    WaitSecs (0.5);
    
end


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

% dir = sprintf(['../../../data/corticalBlindness/Eyelink_guiding/'  '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end
%
% savePath = dir;

% datadir = ' ../../../data/corticalBlindness/Eyelink_guiding/blindspottest/';
% datadir = 'C:\Users\Administrator\Desktop\hjh\flash-grab\data\corticalBlindness\Eyelink_guiding\blindspottest';
% fileName = fullfile(datadir, 'eyelinkDataFile.edf');

datadir =  '../../../data/corticalBlindness/eyelink_guiding/blindspottest/';
savePath = datadir;

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%        average blind spot width and distance
%----------------------------------------------------------------------

blindspot_from_fixation = round(mean(data.position_dva(1:2:(length(data.position_dva)))))
blindspot_width = round(mean(data.position_dva(2:2:(length(data.position_dva)))) - blindspot_from_fixation)

sca;
