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
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    dotOrWedgeOrBarFlag = 'b';  % dotOrWedgeOrBarFlag == 'b'
else
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
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
bottomcolor = 128; %(whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[0 0 800 600],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);

fixsize = 12;
HideCursor;
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

%----------------------------------------------------------------------
%               Screen parameter
%----------------------------------------------------------------------

eyeScreenDistence = 78;  % cm  68 sunnannan
screenHeight = 26.8; % cm
sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);

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
%%%                     parameters of  red bar
%----------------------------------------------------------------------


barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];

% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barLength, barWidth);
barMat(:,:,2) = repmat(0, barLength,  barWidth);
barMat(:,:,3) = barMat(:,:,2);


% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
trialNumber = 2;  % how many times

back.CurrentAngle = 0;

back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;
back.alpha = 1; % background transparence

wedgeTiltStartUpperRight = 15;
wedgeTiltStartLowerRight = -15;
% wedgeTiltIncre = 0;
back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
back.flashTiltDirectionMatShuff = [1 1 1 1];%Shuffle(back.flashTiltDirectionMat)';


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
ScanOnset = GetSecs;


for trial = 1 : trialNumber    % block 1  upper border of blind field ; block2 lower border
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
    
    
    
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    respToBeMade = true;
    %     while respToBeMade
    flashPresentFlag = 0;
    prekeyIsDown = 0;
    data.flashTiltDirection(trial) = back.flashTiltDirectionMatShuff(trial);
    
    wedgeTiltNow = wedgeTiltStartUpperRight;
    
    while respToBeMade
        
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        
        % tilt right  background first rotate clockwise until to the reverse angle
        if back.CurrentAngle >= back.ReverseAngle - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = - 1;
            back.FlagSpinDirecA = back.SpinDirec;
            % tilt left
        elseif back.CurrentAngle <= - back.ReverseAngle  - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = 1;
            back.FlagSpinDirecB = back.SpinDirec;
        end
        
        %    draw background each frame
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.alpha); %  + backGroundRota
        
        
        barRectTiltDegree = wedgeTiltNow + 22.5;
        barDrawTiltDegree = back.CurrentAngle - 22.5;
        
        % present flash tilt right   CCW
        if data.flashTiltDirection(trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right
            
            
            % background on the vertical meridian the left part is always
            % white and the right part is always black
            %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
            
            if barLocation == 'l' | barLocation == 'n'
                % vertical bar lower visual field
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter + dotRadius2Center * cosd(barRectTiltDegree));
                
            elseif  barLocation == 'u'
                % vertical bar upper visual field
                barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
                
            end
            
            Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
            
            flashPresentFlag = 1;
            % present flash tilt left  CW
        elseif data.flashTiltDirection(trial) == 2  && back.FlagSpinDirecB ==  1    % flash tilt left
            
            
            if barLocation == 'l' | barLocation == 'n'
                % vertical bar lower visual field
                barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter + dotRadius2Center * cosd(barRectTiltDegree));
            elseif barLocation == 'u'
                % vertical bar upper visual field
                barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
            end
            
            Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
            
            flashPresentFlag = 1;
        else
            flashPresentFlag = 0;
        end
        
        back.FlagSpinDirecA = 0;
        back.FlagSpinDirecB = 0;
        
        
        
        % draw fixation
        Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
        
        %             Screen('DrawLine',window,blackColor,xCenter-fixationSize,yCenter,xCenter+fixationSize,yCenter,5);
        %             Screen('DrawLine',window,blackColor,xCenter,yCenter-fixationSize,xCenter,yCenter+fixationSize,5);
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
                if barLocation == 'l'| barLocation == 'lowerleft'
                    wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                elseif barLocation == 'u'
                    wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                end
            elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                if barLocation == 'l'| barLocation == 'lowerleft'
                    wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                elseif barLocation == 'u'
                    wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                end
            elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                if barLocation == 'l'| barLocation == 'lowerleft'
                    wedgeTiltNow = wedgeTiltNow - 2 * wedgeTiltStep;
                elseif barLocation == 'u'
                    wedgeTiltNow = wedgeTiltNow + 2 * wedgeTiltStep;
                end
                
            elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                if barLocation == 'l'| barLocation == 'lowerleft'
                    wedgeTiltNow = wedgeTiltNow + 5 * wedgeTiltStep;
                elseif barLocation == 'u'
                    wedgeTiltNow = wedgeTiltNow - 5 * wedgeTiltStep;
                end
                
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
    
    if  subtrial == 1
        visible2invisible(trial) = wedgeTiltNow;
    elseif subtrial == 2
        invisible2visible(trial) = wedgeTiltNow;
    end
    
    %         data.wedgeTiltEachBlock(block,trial) = wedgeTiltNow;
    WaitSecs (1);
end





display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

if dotOrWedgeOrBarFlag == 'd'
    savePath = '../../data/corticalBlindness/dot/';
elseif dotOrWedgeOrBarFlag == 'b'
    savePath = '../../data/corticalBlindness/bar/blindField/withBackground/';
end

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------

% blindFieldUpper = mean(data.wedgeTiltEachBlock(1,:))
% blindFieldLower = mean(data.wedgeTiltEachBlock(2,:))
visible2invisibleDegree = mean(visible2invisible)
invisible2visibleDegree = mean(invisible2visible)

sca;
