% test the right eye blind spot using an adjustable flashed red disk
% 'left arrow ' for red disk moving leftward  'right arrow' for red disk moving rightward
% 'up arrow ' for red disk moving upward  'down arrow' for red disk moving downward
% '1' for red disk enlarge  '2' for red disk shrink
% At the beginning of each trial the fixation should within
% "gaze_away_visual_degree"  then the trial could begin
% 20230117 Jiahan Hui


clear all;close all;

if 1
    sbjname = 'sry';
    isEyelink = 0;
else
    sbjname = input('>>>Please input the subject''s name:   ','s');
    isEyelink = input('>>>Use eye link? (1 for yes\0 for no):  ','d');
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
[wptr,rect]=Screen('OpenWindow',screenNumber,greycolor,[0 0 1024 768],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
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


trialNumber = 6;

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
% sectorRadius_out_visual_degree = 11; % sunnannan 9.17  mali 11.5
% sectorRadius_in_visual_degree = 11; % sunnannan 5.5   mali7.9
% sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
% sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
% centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

% eye gaze distance from center
fixRadius_dva = 2;
fixRadius = round(tand(fixRadius_dva) * eyeScreenDistence *  rect(4)/screenHeight);
fixateTimeDura = 600; %ms
driftDuation = 30; %  frame

%----------------------------------------------------------------------
%    flash dot parameter to map the blind spot postion
%----------------------------------------------------------------------
disk.color = [255 0 0];
disk.startRadius_dva = 1.5;
% disk.startRadius_pixel = dva2pix(disk.startRadius_dva,eyeScreenDistence,rect,screenHeight);
disk.moveStep_dva = 0.1; % dva
disk.moveStep_pixel =  dva2pix(disk.moveStep_dva,eyeScreenDistence,rect,screenHeight); % pixel
disk.startLoca_dva = 12.5;  % from center
disk.startLoca_pixel = dva2pix(disk.startLoca_dva,eyeScreenDistence,rect,screenHeight); % pixel
disk.flashFreq = 2; % Hz
disk.flashRepresentFrame = 8; % frame
disk.radiusStep_dva = 0.1;

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
trial = 1;
abandonBlockMat = [];
driftDuation_pre = 1; %  sec
driftDuation_dur = 2; % sec

while trial <= trialNumber
    
    TrialOnset = GetSecs;
    respToBeMade = true;
    currentframe = 0;
    fixDriftFrame = 0;
    isOutFixationWindowFrame = 0;
    isOutFixationWindowTimes = 0;
    abandonTrialFlag = 0;
    disk.NewestRadius_dva = disk.startRadius_dva ;
    disk.NewestLoc_x = disk.startLoca_pixel;
    disk.NewestLoc_y = 0;
    prekeyIsDown = 0;
    
    %     if trial == 1
    str = sprintf('This is the %dth of %d trial.\n\n Fix the cross to start the trial',trial,trialNumber);
%     str = 'Fix on the cross to start the trial';
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
                    Eyelink('Message','Fixed');
                    break;
                end
            end
        end
    end
    
    fixDriftFrame = 0;
    isOutFixationWindowFrame = 0;
    isOutFixationWindowTimesMat = [];
    
    %----------------------------------------------------------------------
    %%%                  parameters of red disk
    %----------------------------------------------------------------------
    
    while respToBeMade
        
        currentframe = currentframe + 1;
        
        if  mod(currentframe,60/disk.flashFreq) == 0
            Screen('FillOval', wptr, disk.color, diskRect);
            WaitSecs(disk.flashRepresentFrame/framerate);
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
                    Screen('FillOval', wptr, fixationcolour, gazeRect);
                    %                             Screen('Flip',wptr);
                elseif  isOutFixationWindowFrame <= driftDuation_dur * framerate
                    fixDriftFrame = fixDriftFrame + 1;
                    isOutFixationWindowFrame  = fixDriftFrame;
                elseif isOutFixationWindowFrame  > driftDuation_dur * framerate
                    isOutFixationWindowTimes = isOutFixationWindowTimes + 1;
                    isOutFixationWindowTimesMat = [isOutFixationWindowTimes;    isOutFixationWindowTimesMat];
                    sprintf('Gaze is outside fixation window during  trial  %d\n',  trial)
                    abandonTrialFlag = 1;  % the whole block was abandoned
                    trialNumber = trialNumber + 1;
                    abandonBlockMat(trial) = abandonTrialFlag;
                    break;
                end
            end
        end
        
        disk.NewestRadius_pixel = dva2pix(disk.NewestRadius_dva,eyeScreenDistence,rect,screenHeight);
        
        diskRect = [xCenter + disk.NewestLoc_x - disk.NewestRadius_pixel...
            yCenter + disk.NewestLoc_y - disk.NewestRadius_pixel ...
            xCenter + disk.NewestLoc_x + disk.NewestRadius_pixel...
            yCenter + disk.NewestLoc_y + disk.NewestRadius_pixel];
        if currentframe == 1
            
            if isEyelink
                Eyelink('Message','TRIALID %d',trial);
            end
        end
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
                disk.NewestRadius_dva = disk.NewestRadius_dva + disk.radiusStep_dva;
            elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                disk.NewestRadius_dva = disk.NewestRadius_dva - disk.radiusStep_dva;
            elseif keyCode(KbName('leftArrow'))
                disk.NewestLoc_x = disk.NewestLoc_x - disk.moveStep_pixel;
            elseif keyCode(KbName('rightArrow'))
                disk.NewestLoc_x = disk.NewestLoc_x + disk.moveStep_pixel;
            elseif keyCode(KbName('upArrow'))
                disk.NewestLoc_y = disk.NewestLoc_y - disk.moveStep_pixel;
            elseif keyCode(KbName('downArrow'))
                disk.NewestLoc_y = disk.NewestLoc_y + disk.moveStep_pixel;
            elseif keyCode(KbName('Space'))
                respToBeMade = false;
                break;
                prekeyIsDown = 1;
                WaitSecs(0.5);
            end
        end
        prekeyIsDown = keyIsDown;
        
        
    end
    
    data.Radius_dva(trial) = atand(disk.NewestRadius_pixel * screenHeight/(rect(4)*eyeScreenDistence));
    data.loc_x(trial) = disk.NewestLoc_x;
    data.loc_y(trial) = disk.NewestLoc_y;
    
    trial = trial + 1;
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
%      save the blindspot parameter for main exp
%----------------------------------------------------------------------
blindspot_from_fixation_x = round(mean(data.loc_x));
blindspot_from_fixation_y = round(mean(data.loc_y));

blindspot_loc_x_dva = atand(blindspot_from_fixation_x * screenHeight/(rect(4)*eyeScreenDistence))
blindspot_loc_y_dva = atand(blindspot_from_fixation_y * screenHeight/(rect(4)*eyeScreenDistence))
blindspot_width = round(mean(data.Radius_dva)*2)

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

datadir =  '../../../data/corticalBlindness/eyelink_guiding/blindspottest/';
savePath = datadir;

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

sca;
