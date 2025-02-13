% generate a flash-grab checkerboard event-related for testing whether SC
% response to the illusion or physical position
% flash tilt right:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1
% flash perceived tilt left :   data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1

% duration = (12+12+12+12)*6+12+4=304,TR=2s,152TR
%% 7T fMRI parameter (6 scans 6 blocks)
% Bandawidth=1200(<1000);
% TE=30;
% Slice=30;
% thickness=2mm;
% patial_fourier_factor=7/8;
% FOV=128*128;
% Dim=64*64;
% grappa=off;
%%
clear all;close all;

if 1
    sbjname = 'k';
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../function;

commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
bottomcolor = 128; %(whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[0 0 800 600],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);

fixsize = 12;

HideCursor;

% Create rotation matrix
% theta = 90; % to rotate 90 counterclockwise
% R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% % Rotate your point(s)
% point = coverSectorRect'; % arbitrarily selected
% rotpoint = R .* point;

centerMovePix = 0;
%% set parameters
fixcolor = 200; % 0 255
framerate = FrameRate(wptr);
redcolor = [256 0 0];
bluecolor = [0 0 200];

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
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
barCenter2screenCenter = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

%----------------------------------------------------------------------
%%%                     parameters of red bar
%----------------------------------------------------------------------

barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barWidth/2  -barLength/2  barWidth/2   barLength/2];

% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barLength, barWidth);
barMat(:,:,2) = repmat(0, barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);

% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

bar1startAngle = 15;
bar2startAngle = 30;

data.directionMat = repmat([1;2],trialNumber/2,1);   %  data.direction = 1 CCW  data.direction = 2  CW 
data.directionMatShuff = Shuffle(data.directionMat)';

% barTiltStep = 1;
time.flashpresent = 5; % frame
time.fixpresent = 60; % frame
time.apinterval = 20; % frame 
trialNumber = 4;
blockNumber = 2;

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

for block = 1:blockNumber
    
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
    WaitSecs (1);
    
    for trial = 1:trialNumber
        
        respToBeMade = 1;
        
%         if data.directionMatShuff == 1 
        
        
        
        while respToBeMade
            
            % draw bar 1
            
            barDestinationRect = CenterRectOnPoint(barRect,xCenter + barCenter2screenCenter * sind(bar1startAngle), yCenter - barCenter2screenCenter * cosd(bar1startAngle));
            Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,bar1startAngle);
            Screen('DrawLine',wptr,blackcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
            Screen('DrawLine',wptr,blackcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
            Screen('Flip',wptr);
            
            WaitSecs(time.flashpresent/framerate);
            
            %    duration beetween apparent motion
            Screen('DrawLine',wptr,blackcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
            Screen('DrawLine',wptr,blackcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
            Screen('Flip',wptr);
            WaitSecs(time.apinterval/framerate);
            
            %         draw bar 2
            barDestinationRect = CenterRectOnPoint(barRect,xCenter + barCenter2screenCenter * sind(bar2startAngle), yCenter - barCenter2screenCenter * cosd(bar2startAngle));
            Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,bar2startAngle);
            Screen('DrawLine',wptr,blackcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
            Screen('DrawLine',wptr,blackcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
            Screen('Flip',wptr);
            
            WaitSecs(time.flashpresent/framerate);
            
            %         draw fixation while waiting for response
            
            Screen('DrawLine',wptr,blackcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
            Screen('DrawLine',wptr,blackcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
            Screen('Flip',wptr);
            
            WaitSecs(time.fixpresent/framerate);
            
            
            
            %----------------------------------------------------------------------
            %                      Response record
            %----------------------------------------------------------------------
            
           prekeyIsDown = - 1; 
            while respToBeMade
                [keyIsDown,secs,keyCode] = KbCheck(-1);
                if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        respToBeMade = false;
                        return
                    elseif keyCode(KbName('UpArrow'))
                        response = 1;
                        respToBeMade = false;
                    elseif keyCode(KbName('DownArrow'))
                        response = 2;
                        respToBeMade = false;
                    elseif keyCode(KbName('Space'))
                        response = 0;
                        respToBeMade = false;
                    end
                end
                prekeyIsDown = keyIsDown;
            end
            
            data.response(trial) = response;
            WaitSecs (1);
            respToBeMade = false;
        end
        
    end
end


%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../../data/corticalBlindness/bar/apparent_motion_off_sync/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);


sca;
