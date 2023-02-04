
% for normal participant artificial scotoma 
% generate the flash grab illusion with 2 sector.  one boundary was blurred
% and the other with sharp boundary so this stimulus could generate flash grab illusion
% without integrated red bar flash.
% Test this blurred boundary pattern as control with bar only condition.
% If this moving boundary the same as off_sync condition

% barTiltNow means the degree from bar to vertical meridian 

%  5 condition :(all from vi2invi  and then invi2vi)
% bar_only
% blurred boundary
% off_sync
% grab
% perceived



clear all;close all;

if 1
    sbjname = 'hjh';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    redbarflash_flag = 1; % barflash_flag = 0  no red flash bar    barflash_flag = 1  with red flashed bar
    barLocation = 'u';  % u  upper visual field   l   lower visual field n  normal
    condition = 'vi2invi';   % 'vi2invi'  'invi2vi'   'normal'
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = 'n';
    %     debug = input('>>>Debug? (y/n):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
    condition = input('>>>visible2invisible or invisible2visible? (vi2invi  invi2vi normal):  ','s');
    
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../../function;
addpath ../../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
%     mask for change contrast
greycolor = (whitecolor + blackcolor) / 2; % 128
blindfieldColor = 110;

[wptr,rect]=Screen('OpenWindow',screenNumber,greycolor,[0 0 1024 768],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
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

eyeScreenDistence = 78;  % cm  68 sunnannan
screenHeight = 26.8; % cm
sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali 7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
centerRingRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;

%----------------------------------------------------------------------
%             Blind field parameter
%----------------------------------------------------------------------
blindfield_deviate_center_visual_degree = 7;  % degree from horizontal meridian
blindfield_deviate_center_pixel = round(tand(blindfield_deviate_center_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);
blindfieldRadius_visual_degree = 4;
blindfieldRadius_pixel = round(tand(blindfieldRadius_visual_degree) * eyeScreenDistence *  rect(4)/screenHeight);


blindfieldDegree = radi2ang(asin(blindfieldRadius_pixel/centerRingRadius2Center));

% blindfieldDegree = 40;  % degree from horizontal meridian
% blindfieldRadius = centerRingRadius2Center * sind(blindfieldDegree);  %pixel
% blindfield_shift = centerRingRadius2Center + 65;

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
barMat(:,:,2) = zeros(barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

blockNumber = 8;

if strcmp(condition, 'normal')
    trialNumber = 1;
else
    trialNumber = 5;
end


barTiltStartUpper = 90 - blindfieldDegree;% - 90 + blindfieldDegree - 10;   % -10 from invi2vi
barTiltStartLower = 90 + blindfieldDegree;
barTiltStartNormal = 90;

currentframe = 0;
back.CurrentAngle = 0;

back.SpinDirec = 0; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;
back.FlagSpinDirecB = 0;
barTiltStep = 1;
% back.alpha = 1; % background transparence

back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;

% back.flashTiltDirection = 1 means sharp border grab CCW
back.flashTiltDirectionMat = repmat([1;2],blockNumber/2,1);
back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

ScanOnset = GetSecs;


for block = 1:blockNumber
    
    BlockOnset = GetSecs;
    back.CurrentAngle = 0;
    
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
    
    
    if barLocation == 'u'
%         barTiltNow = barTiltStartUpper;   % barTiltNow  the bar tilt degree from upright
        if strcmp(condition, 'vi2invi')
            multiplier =  - 1;   % in vi2invi condition  off_sync degree  over than bar_only degree
            barTiltNow = barTiltStartUpper;
        elseif strcmp(condition, 'invi2vi')
            multiplier = 1;
            barTiltNow = barTiltStartUpper + 10;
        end
    elseif barLocation == 'l'
%         barTiltNow = barTiltStartLower;
        if strcmp(condition, 'vi2invi')
            multiplier =  1;   % in vi2invi condition  off_sync degree  over than bar_only degree
            barTiltNow = barTiltStartLower;
        elseif strcmp(condition, 'invi2vi')
            multiplier = - 1;
            barTiltNow = barTiltStartLower - 10;
        end
    elseif barLocation == 'n'
        barTiltNow = barTiltStartNormal;
    end
    

    
    for trial = 1:trialNumber
        
        %-----------------------------------------------------------------
        %              task instruction  adjust the bar
        %-----------------------------------------------------------------
        respToBeMade = true;
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        data.flashTiltDirection(block) = back.flashTiltDirectionMatShuff(block);
        back.CurrentAngle = 0;
        currentframe = 0;
        flashtimes = 0;
        barTiltStep = 1;
        
        if barLocation ~= 'n'
            switch trial
                case 1    % flash bar only
                    back.alpha = 0;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 1  Adjust the bar from visible to invisible   \n\n Press Any Key To Begin';
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 1  Adjust the bar from invisible to visible   \n\n Press Any Key To Begin';
                    end
                case 2   % blurred boundary
                    back.alpha = 1;
                    redbarflash_flag = 0;
                    if strcmp(condition, 'vi2invi')
                        barTiltNow = bar_only(block) + multiplier * 10;
                        str_subtrial = '\n 2  Adjust the sharp bondary from visible to invisible   \n\n Press Any Key To Begin';
                    elseif strcmp(condition,'invi2vi')
                        barTiltNow = bar_only(block);
                        str_subtrial = '\n 2  Adjust the sharp bondary from invisible to visible   \n\n Press Any Key To Begin';
                    end
                    
                case 3   % off-sync
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 3  Adjust the bar from visible to invisible   \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(block) + multiplier * 10;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 3  Adjust the bar from invisible to visible and  \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(block);
                    end
                    
                case 4   % flash grab
                    back.alpha = 1;
                    redbarflash_flag = 1;
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 4  Adjust the bar from visible to invisible and \n\n remember the last location you have seen \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(block) - multiplier * 0;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 4  Adjust the bar from invisible to visible and \n\n  remember the location  \n\n Press Any Key To Begin';
                        barTiltNow = bar_only(block);
                    end
                    
                case 5  % perceived location
                    
                    if strcmp(condition, 'vi2invi')
                        str_subtrial = '\n 5  Adjust the bar to the perceived location where you last saw  \n\n Press Any Key To Begin' ;
                        barTiltNow = barTiltNow;
                    elseif strcmp(condition,'invi2vi')
                        str_subtrial = '\n 5  Adjust the bar to the perceived location   \n\n Press Any Key To Begin';
                    end
            end
            
        elseif  barLocation == 'n'   % normal visual field
            barTiltNow = barTiltStartNormal;
            str_subtrial = '\n Adjust the bar until horizon   \n\n Press Any Key To Begin';
        end
        
        DrawFormattedText(wptr, str_subtrial, 'center', 'center', blackcolor);
        Screen('Flip', wptr);
        KbStrokeWait;
        
        
        %----------------------------------------------------------------------
        %               background rotate   subtrial 1 - 4
        %----------------------------------------------------------------------
        
        if trial ~= 5  % subtrial 1 - 4
            
            
            while respToBeMade
                
                currentframe = currentframe + 1;
                
                %  back.SpinDirec    1 means clockwise     -1 means counter-clockwise
                back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
                
                % make sure the red bar didn't show up at the beginning of
                % the rotation
                if currentframe == 1
                    back.CurrentAngle = barTiltNow - 1;  % back.reverse_anlge_end
                    %                     back.CurrentAngle = back.reverse_anlge_start - barTiltNow ;
                end
                
                if data.flashTiltDirection(block) == 1    % CCW
                    % when larger than certain degree reverse  CCW
                    if back.CurrentAngle >= 0 + barTiltNow %   back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = - 1;
                        back.FlagSpinDirecA = back.SpinDirec;
                        %  when lower than certain degree reverse  CW
                    elseif back.CurrentAngle <= - 180 + barTiltNow %  - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                        back.SpinDirec = 1;
                        back.FlagSpinDirecB = back.SpinDirec;
                    end
                elseif data.flashTiltDirection(block) == 2   % CW
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
                
                
                if trial ~= 1 && trial ~= 3 % rotating background didn't presented in bar_only condition    DrawTexture 0 deg. = upright
                    Screen('DrawTexture',wptr,ringBlurredBoundaryTexture,ringBlurredBoundaryRect,ringBlurredBoundaryDestinationRect,back.CurrentAngle,[],back.alpha);
                elseif trial == 3
                    Screen('DrawTexture',wptr,ringBlurredBoundaryTexture,ringBlurredBoundaryRect,ringBlurredBoundaryDestinationRect,back.CurrentAngle + 90,[],back.alpha);
                end
                
                
                
                if redbarflash_flag == 1
                    % present flash tilt right  CCW
                    if data.flashTiltDirection(block) == 1  && back.FlagSpinDirecA ==  - 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barTiltNow);  % DrawTexture 0 deg. = upright
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        
                    elseif data.flashTiltDirection(block) == 2  && back.FlagSpinDirecB == 1
                        
                        barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                        Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barTiltNow);
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        
                        flashPresentFlag = 1;
                    else
                        flashPresentFlag = 0;
                    end
                    
                else 
                   if data.flashTiltDirection(block) == 1  && back.FlagSpinDirecA ==  - 1
                        
                        flashtimes = flashtimes + 1;
                        barTiltNowMat(trial,flashtimes,block) = barTiltNow;
                        back_currentAngleMat(trial,flashtimes,block) = back.CurrentAngle;
                        
                    elseif data.flashTiltDirection(block) == 2  && back.FlagSpinDirecB == 1
                        
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
                
                fixcolor = 0;
                
                Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                Screen('FillOval',wptr,blindfieldColor,[xCenter + blindfield_deviate_center_pixel - blindfieldRadius_pixel, yCenter - blindfieldRadius,...
                    xCenter + blindfield_deviate_center_pixel + blindfieldRadius_pixel, yCenter + blindfieldRadius_pixel]);
                Screen('Flip',wptr);
                
                %----------------------------------------------------------------------
                %                      Response
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
            
            %----------------------------------------------------------------------
            %         adjustable  smoothly moving red  bar
            %----------------------------------------------------------------------
            
        elseif trial == 5
            
            barTiltStep = 0.1;
            
            while respToBeMade
                
                %                 barRectPositionDegree =  barTiltNow;
                %                 barDrawTiltDegree = - barTiltNow - 180;
                
                if barLocation == 'l' | barLocation == 'n'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                elseif barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + centerRingRadius2Center * sind(barTiltNow), yCenter - centerRingRadius2Center * cosd(barTiltNow));
                end
                
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barTiltNow);
                
                
                % draw fixation
                
                fixcolor = 0;
                
                Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
                %             Screen('DrawLine',wptr,fixcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
                %             Screen('DrawLine',wptr,fixcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
                
                Screen('Flip',wptr);
                
                
                %----------------------------------------------------------------------
                %                      Response
                %----------------------------------------------------------------------
                
                [keyIsDown,secs,keyCode] = KbCheck(-1);
                %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
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
                %                 end
                %                 prekeyIsDown = keyIsDown;
            end
        end
        
        %-----------------------------------------------------------------
        %           Response  record
        %-----------------------------------------------------------------
        
        
        if barLocation ~= 'n'
            if  trial == 1      % flash bar only
                bar_only(block) = barTiltNow;
            elseif trial == 2   % blurred boundary
                blurred_boundary(block) = barTiltNow;
            elseif trial == 3     % off fync
                off_sync(block) = barTiltNow;
            elseif trial == 4  % flash grab
                flash_grab(block) = barTiltNow;
            elseif trial == 5  % perceived location
                perceived_location(block) = barTiltNow;
            end
            
        else
            if data.flashTiltDirection == 1
                grab_effect_degree_CCW_from_vertical(block) = barTiltNow;
            elseif   data.flashTiltDirection == 2
                grab_effect_degree_CW_from_vertical(block) = barTiltNow;
            end
        end
        
        WaitSecs (0.5);
    end
    
end

display(GetSecs - ScanOnset);

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
dir = sprintf(['../../../data/corticalBlindness/artificial_scotoma/' '%s/'],sbjname);
if ~isdir(dir)
    mkdir(dir)
end

savePath = dir;

time = clock;

filename = sprintf('%s_%s_%s_%02g_%02g_%02g_%02g_%02g',sbjname,condition,barLocation,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------


sca;
