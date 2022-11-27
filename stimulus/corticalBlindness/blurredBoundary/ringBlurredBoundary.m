
% generate a flash-grab checkerboard event-related for testing hemianopia
% patient
% report visible or invisible
% flash at reverse CCW :   data.flashTiltDirection(block,trial) == 2  &&r  back.FlagSpinDirecA ==  - 1
% reverse CW:   data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecB ==  1


clear all;close all;

if 1
    sbjname = 'k';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    barflash_flag = 1; % barflash_flag = 0  no red flash bar    barflash_flag = 1  with red flashed bar
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = 'n';
    %     debug = input('>>>Debug? (y/n):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../function;
addpath ../../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
bottomcolor = (whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[0 0 800 600],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
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
barMat(:,:,2) = repmat(0, barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

trialNumber = 4;


if strcmp(condition, 'normal')
    subtrialNumber = 1;
else
    subtrialNumber = 4;
end


back.CurrentAngle = 0;

back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;
back.alpha = 1; % background transparence

wedgeTiltStart = 0;

% wedgeTiltIncre = 0;
back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;

% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
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
        wedgeTiltNow = wedgeTiltStartUpperRight;
        multiplier = - 1;   % in vi2invi condition  off_sync degree  over than bar_only degree
    elseif barLocation == 'l'
        wedgeTiltNow = wedgeTiltStartLowerRight;
        multiplier = 1;
    elseif barLocation == 'n'
        wedgeTiltNow = wedgeTiltStartNormal;
    end
    
    
    
    wedgeTiltNow = wedgeTiltStart;
    
       for subtrial = 1:subtrialNumber 
    
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    respToBeMade = true;
    %     while respToBeMade
    flashPresentFlag = 0;
    prekeyIsDown = 0;
    data.flashTiltDirection = back.flashTiltDirectionMatShuff(trial);
    currentFrame = 0;
    
    % data.flashTiltDirection == 1  means CCW
    if data.flashTiltDirection == 1
        back.reverse_anlge_end = 0;
        back.reverse_anlge_start = - 180;
        back.SpinDirec = - 1; % 1 means clockwise     -1 means counter-clockwise
    elseif data.flashTiltDirection == 2
        back.reverse_anlge_end = 180;
        back.reverse_anlge_start = 0;
        back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
    end
    
    
    while respToBeMade
        
        currentFrame = currentFrame + 1;
        
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        barRectTiltDegree = wedgeTiltNow + 180;
        barDrawTiltDegree = back.CurrentAngle + 180;
        
        % tilt right  background first rotate clockwise until to the reverse angle
        if back.CurrentAngle >= back.reverse_anlge_end - wedgeTiltNow % back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = - 1;
            back.FlagSpinDirecA = back.SpinDirec;
            % tilt left
        elseif back.CurrentAngle <= back.reverse_anlge_start - wedgeTiltNow  % - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = 1;
            back.FlagSpinDirecB = back.SpinDirec;
        end
        
        ringBlurredBoundaryTiltDegree = back.CurrentAngle;
        %         ringBlurredBoundaryDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(ringBlurredBoundaryTiltDegree), yCenter - dotRadius2Center * cosd(ringBlurredBoundaryTiltDegree));
        Screen('DrawTexture',wptr,ringBlurredBoundaryTexture,ringBlurredBoundaryRect,ringBlurredBoundaryDestinationRect,back.CurrentAngle,[],back.alpha);
        
        if barflash_flag == 1
            % present flash tilt right  CCW
            if data.flashTiltDirection(trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash grab  CCW
                
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter + centerRingRadius2Center * cosd(barRectTiltDegree));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
            elseif data.flashTiltDirection(trial) == 2  && back.FlagSpinDirecB ==  1    % CW
                
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barRectTiltDegree), yCenter + centerRingRadius2Center * cosd(barRectTiltDegree));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
            end
        end
        
        back.FlagSpinDirecA = 0;
        back.FlagSpinDirecB = 0;
        
        fixcolor = 0;
        
        Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
        
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
                
                wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                
            elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                
                wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                
            elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                
                wedgeTiltNow = wedgeTiltNow + 2 * wedgeTiltStep;
                
            elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                
                wedgeTiltNow = wedgeTiltNow - 2 * wedgeTiltStep;
                
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
    
    data.flashTiltDirection
    
    if data.flashTiltDirection == 1
        grab_effect_degree_CCW_from_vertical(trial) = wedgeTiltNow;
    elseif   data.flashTiltDirection == 2
        grab_effect_degree_CW_from_vertical(trial) = wedgeTiltNow;
    end
    
    WaitSecs (0.5);
end



display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end

savePath = '../../data/corticalBlindness/ringBlurredBoundary/';


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
