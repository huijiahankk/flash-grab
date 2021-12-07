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
clear all;
close all;

if 1
    sbjname = 'k';
    debug = 'n';
    flashRepresentFrame = 2.2;  % 2.2 means 3 frame
    dotOrWedgeFlag = 'b';   % b  means bar
    barLocation = 'u'; % n for normal vision field   
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    dotOrWedgeFlag = 'b';
    %     dotOrWedgeFlag = input('>>>Use dot flash Or wedge flash or bar flash? (d/w/b):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
end


%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../../function;
% addpath ../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
% HideCursor;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
blackcolor = BlackIndex(screenNumber);
whitecolor = WhiteIndex(screenNumber);
grey = (blackcolor + whitecolor)/2;

% Prepare setup of imaging pipeline for onscreen window.
% This is the first step in the sequence of configuration steps.
PsychImaging('PrepareConfiguration');
% 'AllViews' applies  the action to both, left- and right eye view channels of a stereo
% configuration or to the single monoscopic channel of a mono display
% configuration.Set this to 'General' if the
% command doesn't apply to a specific view, but is a general requirement.
PsychImaging('AddTask','AllViews','SideBySideCompressedStereo');

stereoMode = 1; %102;  %goggle
[wptr, winRect] = PsychImaging('OpenWindow',screenNumber,grey,[],[],[],stereoMode);

% [wptr,winRect]=Screen('OpenWindow',screenNumber,grey,[],[],[],stereoMode);
%     gammaTable = [0.5 0.5 0.5];
%     Screen('LoadNormalizedGammaTable', window, gammaTable);
AssertOpenGL;

oldVisualDebugLevel   = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

[xCenter, yCenter] = RectCenter(winRect);
[screenXpixels, screenYpixels] = Screen('WindowSize', wptr);
[displaywidth, ~] = Screen('DisplaySize', screenNumber);  %
Screen('TextSize', wptr, 40);
framerate = FrameRate(wptr);
viewingDistance = 60; % subject distance to the screen



fixsize = 8;
% centerMovePix = 0;

% set parameters
fixcolor = 200; % 0 255
redcolor = [256 0 0];

%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------


% load ../../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;   %????????????????????????????????????????????????
% % load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro
%
% dacsize = 10;  %How many bits per pixel#
% maxcol = 2.^dacsize-1;
% ncolors = 256; % see details in makebkg.m
% newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
% newclut(1:ncolors,:) = newcmap./maxcol;
% newclut(isnan(newclut)) = 0;
%
% [Origgammatable, ~, ~] = Screen('ReadNormalizedGammaTable', wptr);
% Screen('LoadNormalizedGammaTable', wptr, newclut);



%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
% spaceKey = KbName('space');

%----------------------------------------------------------------------
%               7T Screen parameter
%----------------------------------------------------------------------
% for 7T scanner the resolution of the screen is 1024*768   the height and
% width of the screen is 35*28cm  the distance from the subject to screen is 75cm    the visual degree for the subject is 10
% degree totally

% visualHeightIn7T_cm = tan(deg2rad(10/2)) * 75 * 2;
% visualHerghtIn7T_pixel = visualHeightIn7T_cm * 768/28;

visualDegree = 10;
visualHeightIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75 * 2;
visualHeightIn7T_pixel_perVisualDegree = visualHeightIn7T_cm_perVisualDegree/28 * 768;
visualHeightIn7T_pixel = visualHeightIn7T_pixel_perVisualDegree * visualDegree;


%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 8;
centerMovePix = 0;
sectorRadius_in_pixel = floor((visualHeightIn7T_pixel - 400)/2);    % inner diameter of background annulus
sectorRadius_out_pixel = floor((visualHeightIn7T_pixel - 20)/2);%  %         annnulus outer radius
dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
[sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% if mask for Gaussian border CFS it needs  alpha blendfunction
% Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Screen('DrawTexture',window,CFSTex(w),[],CFSloca); % CFSloca_R
% Screen('BlendFunction', window, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);



%----------------------------------------------------------------------
%                      draw red wedge
%----------------------------------------------------------------------

adjustAngleL = 0;
adjustAngleR = 0;

coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink];
redSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel  xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];
InnerSectorRect = [xCenter - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel  xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];
sectorArcAngle = 360/sectorNumber;

%----------------------------------------------------------------------
%%%                     generate  CFS
%----------------------------------------------------------------------
load /Users/jia/Documents/matlab/DD_illusion/myGabor/function/CFS/CFSMatMovie1.mat
% CFSFrequency= 8;
CFSMatMovie=Shuffle(CFSMatMovie);
CFSFrames = 100;
CFSwidth = 80; %30;
% make sure the gabor was all covered by CFS,CFS started y axis lower than
% center of gabor start point
% CFScoverGabor = gabor.DimPix/2;
% CFScoverGabor = 25;
CFScont = 0.1;
CFSoffFrame = 15;  % 176ms

% CFS.outSecCirMat = ones(sectorRadius_out_pixel,sectorRadius_out_pixel) * 2;
% CFS.innerSecCirMat = ones(sectorRadius_in_pixel,sectorRadius_in_pixel);

% We create a Alpha matrix for use as transparency mask
ms=128;
[x,y]=meshgrid((-ms+1):ms, (-ms+1):ms);

% mask for sharp border CFS
maskblob= (x.^2+y.^2) <= 128^2; 
% Have a look at the mask
% spy(maskblob);


for i=1:CFSFrames
    CFSMatMovie{i} =CFScont*(CFSMatMovie{i}-128)+128;
    CFSImage=CFSMatMovie{i};%.*mask+ContraN;
    %     CFSImage(:,:,4)=mask2*255;
     CFSImage(:,:,4) = maskblob * 255; 
    %     CFSImage = CFSImage((256/2-128*CFSsize_scale):(256/2+128*CFSsize_scale),(256/2-128*CFSsize_scale):(256/2+128*CFSsize_scale),:);
    CFSTex(i)=Screen('MakeTexture',wptr,CFSImage);
end

eyeCFS = [0 1];  %0 mean left eye
w = randi(100,1);



%----------------------------------------------------------------------
%%%                     parameters of red dot  and red bar
%----------------------------------------------------------------------

% dotRadiusPix = floor((sectorRadius_out_pixel - sectorRadius_in_pixel)*0.8)/2;
% dotColor = [255 0 0];
barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];
% radius of the red dot to the annulus center
% dotCenter2ScreenCenter =  ((sectorRadius_out_pixel + sectorRadius_in_pixel)/2)/2;
% dotRadius =(dotCenter2ScreenCenter - sectorRadius_in_pixel/2)*2*0.9;
% dotRect = [xCenter - dotRadius, yCenter + dotCenter2ScreenCenter - dotRadius,xCenter + dotRadius,yCenter + dotCenter2ScreenCenter + dotRadius];
% dotRect = CenterRectOnPoint([-dotRadius,-dotRadius,dotRadius,dotRadius],xCenter,yCenter + dotCenter2ScreenCenter * 2);  %  + dotCenter2ScreenCenter


% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barWidth, barLength);
barMat(:,:,2) = zeros(barWidth, barLength);  % repmat(0,  barWidth, barLength);
barMat(:,:,3) = barMat(:,:,2);

% % Define a horizontal red rectangle
% barMat(:,:,1) = repmat(255, barLength, barWidth);
% barMat(:,:,2) = repmat(0,  barLength, barWidth);
% barMat(:,:,3) = barMat(:,:,2);

% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
bartRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
trialNumber = 4;
blockNumber = 2;
% back.contrastratio = 1;

randWedgeTiltNoiseMat = rand(trialNumber,1)*2;
back.CurrentAngle = 0;
% back.AngleRange = 180;

% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;
back.alpha = 1; % background transparence

wedgeTiltStartUpperRight = - 23;
wedgeTiltStartLowerRight = 12.5;
wedgeTiltStartNormal = - 90;
% wedgeTiltIncre = 0;
back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);


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
    
    Screen('Flip', wptr);

    KbStrokeWait;
    
    back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';
    
    for trial = 1:trialNumber
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        data.flashTiltDirection(block,trial) = back.flashTiltDirectionMatShuff(trial);
        
        
        if barLocation == 'u'
            if trial == 1
                wedgeTiltNow = wedgeTiltStartUpperRight;
            else
                wedgeTiltNow = data.wedgeTiltEachBlock(block,trial - 1) + randWedgeTiltNoiseMat(trial);
            end
            
        elseif barLocation == 'l'
            if trial == 1
                wedgeTiltNow = wedgeTiltStartLowerRight;
            else
                wedgeTiltNow = data.wedgeTiltEachBlock(block,trial - 1) + randWedgeTiltNoiseMat(trial);
            end
        elseif barLocation == 'n'
            if trial == 1
                wedgeTiltNow = wedgeTiltStartNormal;
            else
                wedgeTiltNow = data.wedgeTiltEachBlock(block,trial - 1) + randWedgeTiltNoiseMat(trial);
            end
        end
        
        
        while respToBeMade
            
            back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
            
            % tilt right  background first rotate clockwise until to the reverse angle
            if back.CurrentAngle >= back.ReverseAngle + adjustAngleL - wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = - 1;
                back.FlagSpinDirecA = back.SpinDirec;
                % tilt left
            elseif back.CurrentAngle <= - back.ReverseAngle + adjustAngleR - wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
                back.SpinDirec = 1;
                back.FlagSpinDirecB = back.SpinDirec;
            end
            
            
           %----------------------------------------------------------------------
           %%%      draw rotation background on one eye 
           %----------------------------------------------------------------------            
            
            Screen('SelectStereoDrawBuffer', wptr, eyeCFS(1));
            
            %    draw background each frame
            Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.alpha); %  + backGroundRota
            
            
            
            % present flash tilt right
            if data.flashTiltDirection(block,trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                if dotOrWedgeFlag == 'd'
                    dotCentercoord = [xCenter + dotRadius2Center * cosd(back.CurrentAngle)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    dotRect = [dotCentercoord(1) - dotRadiusPix  dotCentercoord(2) - dotRadiusPix   dotCentercoord(1) + dotRadiusPix  dotCentercoord(2) + dotRadiusPix];
                    Screen('FillOval', wptr,dotColor,dotRect);
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle + 90 - 2*adjustAngleR,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
                elseif dotOrWedgeFlag == 'b'
                    if barLocation == 'l' || barLocation == 'n'
                        % vertical bar lower visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter + dotRadius2Center * sind(wedgeTiltNow), yCenter + dotRadius2Center * cosd(wedgeTiltNow));
                    elseif  barLocation == 'u'
                        % vertical bar upper visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter - dotRadius2Center * sind(wedgeTiltNow), yCenter - dotRadius2Center * cosd(wedgeTiltNow));
                        
                    end
                    Screen('DrawTexture',wptr,barTexture,bartRect,barDestinationRect,back.CurrentAngle);
                end
                flashPresentFlag = 1;
                % present flash tilt left
            elseif data.flashTiltDirection(block,trial) == 2  && back.FlagSpinDirecB ==  1    % flash tilt left
                
                if dotOrWedgeFlag == 'd'
                    dotCentercoord = [xCenter - dotRadius2Center * cosd(back.CurrentAngle)    yCenter + dotRadius2Center * (1 - tand(wedgeTiltNow/2)*cosd(90-wedgeTiltNow))];
                    % draw dots
                    %  Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    %  Screen('DrawDots', wptr, rotcoord, dotSizePix, dotColor,[],2);
                    dotRect = [dotCentercoord(1) - dotRadiusPix  dotCentercoord(2) - dotRadiusPix   dotCentercoord(1) + dotRadiusPix  dotCentercoord(2) + dotRadiusPix];
                    Screen('FillOval', wptr,dotColor,dotRect);
                    
                elseif dotOrWedgeFlag == 'w'
                    % draw red wedge
                    Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL ,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle - 90 - 2*adjustAngleL,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                    
                elseif dotOrWedgeFlag == 'b'
                    if barLocation == 'l' | barLocation == 'n'
                        % vertical bar lower visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter + dotRadius2Center * sind(wedgeTiltNow), yCenter + dotRadius2Center * cosd(wedgeTiltNow));
                    elseif barLocation == 'u'
                        % vertical bar upper visual field
                        barDestinationRect = CenterRectOnPoint(bartRect,xCenter - dotRadius2Center * sind(wedgeTiltNow), yCenter - dotRadius2Center * cosd(wedgeTiltNow));
                        
                    end
                    Screen('DrawTexture',wptr,barTexture,bartRect,barDestinationRect,back.CurrentAngle);
                end
                
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
            
           %----------------------------------------------------------------------
           %%%      draw CFS on the other eye 
           %----------------------------------------------------------------------              
            
            Screen('SelectStereoDrawBuffer', wptr, eyeCFS(2));
            Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
            maskSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel...
                         xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];
%             maskSectorRect = CenterRectOnPoint(maskSectorRect,xCenter,yCenter);
            maskSectorArcAngle = 315;
            maskInnerSectorArcAngle = 45;
            maskInnerSectorRect = [xCenter  - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel...
                         xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];
            InnerSectorRect = CenterRectOnPoint(InnerSectorRect,xCenter,yCenter);
            
            w = randi(100,1);
%             Screen('BlendFunction', window, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);
            Screen('DrawTexture',wptr,CFSTex(w),[],redSectorRect); 
            Screen('FillArc',wptr,grey,maskSectorRect,135,275);
            Screen('FillArc',wptr,grey,InnerSectorRect,45,90);
            
%             Screen('FillArc',wptr,grey,maskSectorRectAdjust,180-45, maskSectorArcAngle);
%             Screen('FillArc',wptr,grey,maskInnerSectorRectAdjust,45, maskInnerSectorArcAngle);
            
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
                    if barLocation == 'l'| barLocation == 'n'
                        wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                    end
                elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
                    if barLocation == 'l'| barLocation == 'n'
                        wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                    end
                elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                    if barLocation == 'l'| barLocation == 'n'
                        wedgeTiltNow = wedgeTiltNow - 2 * wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow + 2 * wedgeTiltStep;
                    end
                    
                elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
                    if barLocation == 'l'| barLocation == 'n'
                        wedgeTiltNow = wedgeTiltNow + 2 * wedgeTiltStep;
                    elseif barLocation == 'u'
                        wedgeTiltNow = wedgeTiltNow - 2 * wedgeTiltStep;
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
        
        
        data.wedgeTiltEachBlock(block,trial) = wedgeTiltNow;
        WaitSecs (0.5);
        
    end
    
    %     display(GetSecs - ScanOnset);
    
end




display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% time = clock;
% RespMat = [event.TypeNumericIdAll  event.InterTimeAll  flashTimePointAll];
% fileName = ['../data/' sbjname '-' num2str(time(1)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5)) '.mat'];
% % save(fileName,'RespMat','meanSubIlluDegree','time','all','gauss','cueVerDisDegree','gabor','viewingDistance','trialNumber','blockNumber');
% save(fileName,'RespMat');



% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end

if dotOrWedgeFlag == 'd'
    savePath = '../data/illusionSize/blindsight/dot/';
elseif dotOrWedgeFlag == 'b'
    %     savePath = '../data/illusionSize/blindsight/bar/';
    if  barLocation == 'u';
        savePath = '../data/illusionSize/corticalBlindness/bar/upper_field/';
    elseif  barLocation == 'l';
        savePath = '../data/illusionSize/corticalBlindness/bar/lower_field/';
    elseif  barLocation == 'n';
        savePath = '../data/illusionSize/corticalBlindness/bar/normal/';
    end
end

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------

% tilt right
illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 1);
illusionTiltRightDegree = data.wedgeTiltEachBlock(illusionTiltIndexRight);
illusionAveTiltRight = mean(illusionTiltRightDegree);

% tilt left
illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 2);
illusionTiltLeftDegree = data.wedgeTiltEachBlock(illusionTiltIndexLeft);
illusionAveTiltLeft = mean(illusionTiltLeftDegree);

illusionAve = (abs(illusionAveTiltRight) + abs(illusionAveTiltLeft))/2;




y = [illusionAve illusionAveTiltLeft illusionAveTiltRight];
h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(gca, 'XTick', 1:3, 'XTickLabels', {'average'  'tilt left'  'tilt right' },'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Illusion size','FontSize',25);

sca;
