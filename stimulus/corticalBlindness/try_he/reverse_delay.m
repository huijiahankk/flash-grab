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
    barLocation = 'u';  % u  upper visual field   l   lower visual field n  normal
    
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    barLocation = input('>>>Flash bar location? (u for upper\l for lower\n for normal):  ','s');
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
fixcolor = blackcolor;
greycolor = (blackcolor + whitecolor)/2;
[wptr,rect]=Screen('OpenWindow',screenNumber,greycolor,[],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);
fixsize = 12;

HideCursor;

centerMovePix = 0;
% fixcolor = [0:1:255  255:-1:0]; % 200
framerate = FrameRate(wptr);

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
%               Screen parameter
%----------------------------------------------------------------------

eyeScreenDistence = 78;  % cm  68  sunnannan
screenHeight = 26.8; % cm
sectorRadius_out_visual_degree = 9.17; % sunnannan 9.17  mali 11.5
sectorRadius_in_visual_degree = 5.5; % sunnannan 5.5   mali 7.9
sectorRadius_out_pixel = round(tand(sectorRadius_out_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);
sectorRadius_in_pixel = round(tand(sectorRadius_in_visual_degree) * eyeScreenDistence * rect(4)/screenHeight);

%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 4;

% sectorRadius_in_pixel = floor((visualHeightIn7T_pixel - 400)/2);    % inner diameter of background annulus
% sectorRadius_out_pixel = floor((visualHeightIn7T_pixel - 20)/2);%  %         annnulus outer radius
dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
[sector] = drawBackgroundSector(sectorNumber,sectorRadius_in_pixel,sectorRadius_out_pixel,blackcolor,whitecolor,xCenter,yCenter,centerMovePix);

sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%----------------------------------------------------------------------
%%%          parameters of red bar
%----------------------------------------------------------------------


barWidth = 20;
barLength = (sectorRadius_out_pixel - sectorRadius_in_pixel);
barRect = [-barLength/2  -barWidth/2  barLength/2  barWidth/2];


% Define a vertical red rectangle
barMat(:,:,1) = repmat(255, barWidth, barLength);
barMat(:,:,2) = repmat(0,  barWidth, barLength);
barMat(:,:,3) = barMat(:,:,2);

% % Define a horizontal red rectangle
% barMat(:,:,1) = repmat(255, barLength, barWidth);
% barMat(:,:,2) = repmat(0,  barLength, barWidth);
% barMat(:,:,3) = barMat(:,:,2);

% % % Make the rectangle into a texure
barTexture = Screen('MakeTexture', wptr, barMat);
barRect = Screen('Rect',barTexture);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------

trialNumber = 4;


randWedgeTiltNoiseMat = rand(trialNumber,1)*2;
back.CurrentAngle = 0;


% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;
back.alpha = 1; % background transparence

wedgeTiltNow = 0;

back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
% back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';

delayFrame = 11;  % actually delayFrame - 1 frame 
rotate_step = 180/(60-delayFrame + 1);
rotation_sequence = [zeros(1,delayFrame) rotate_step:rotate_step:180-rotate_step  ones(1,delayFrame)*180  180-rotate_step:-rotate_step:rotate_step];


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
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
    
%     KbStrokeWait;
    
%     KbWait;
    
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    respToBeMade = true;
    %     while respToBeMade
%     flashPresentFlag = 0;
    prekeyIsDown = 0;
    data.flashTiltDirection(trial) = back.flashTiltDirectionMatShuff(trial);
    
    frameCounter = 0;
    
    %----------------------------------------------------------------------
    %       write the sequence
    %----------------------------------------------------------------------
%     if data.flashTiltDirection(trial) == 1    % rotate leftward    22.5 means start when the wedge at the center
        % 22.5 22.5 at the first means
%         rotation_sequence = [0 0 0:-180/57:-180 -180 -180 -180:180/57:0];
%     else     data.flashTiltDirection(trial) == 2 % rotate rightward

    
    
    while respToBeMade
        flashPresentFlag = 0;
        
        frameCounter = frameCounter + 1;
        if frameCounter > 120
            frameCounter = frameCounter-120;
        end
        
        
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,rotation_sequence(frameCounter),[],back.alpha);
        
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        
        barRectTiltDegree = wedgeTiltNow;
        barDrawTiltDegree = 90;
        barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
        
        %----------------------------------------------------------------------
        %       flash at reverse onset
        %----------------------------------------------------------------------
        %         if data.flashTiltDirection(trial) > 0  % &&  flashframes_max_in_one_trial>0
        if data.flashTiltDirection(trial) ~= 0  % rotate leftward
            % illusion tilt left
            if frameCounter == 1 % frameCounter>59.5 && frameCounter<60.5 

%                 barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                flashPresentFlag = 1;
            end
%         else    %   stimtype(1) == 2 rotate rightward
%             % illusion tilt right
%             if frameCounter == 1  % frameCounter>0.5 && frameCounter< 1.5 
% %                 barRectTiltDegree = wedgeTiltNow;
% %                 barDrawTiltDegree = 90;
%                 
%                 Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
%                 flashPresentFlag = 1;
%             end
        end
        

        
        Screen('DrawLine',wptr,fixcolor,xCenter-fixsize,yCenter,xCenter+fixsize,yCenter,5);
        Screen('DrawLine',wptr,fixcolor,xCenter,yCenter-fixsize,xCenter,yCenter+fixsize,5);
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
         
%         if frameCounter == 60
%             KbWait;
%         end
        
    end
    
        responseDegree(trial) = wedgeTiltNow;

    
    WaitSecs (0.5);
    
end


display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../../data/corticalBlindness/bar/upper_field/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

%----------------------------------------------------------------------
%                    average illusion size
%----------------------------------------------------------------------



illusionCCWIndex = find(data.flashTiltDirection == 1);
illusionCWIndex = find(data.flashTiltDirection == 2);

visible2invisibleCCWDegree = mean(visible2invisible(illusionCCWIndex));
visible2invisibleCWDegree = mean(visible2invisible(illusionCWIndex));
invisible2visibleCCWDegree = mean(invisible2visible(illusionCCWIndex));
invisible2visibleCWDegree = mean(invisible2visible(illusionCWIndex));
perceived_locationDegree = mean(perceived_location);



y = [visible2invisibleCCWDegree visible2invisibleCWDegree perceived_locationDegree invisible2visibleCCWDegree invisible2visibleCWDegree];
h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(gca, 'XTick', 1:5, 'XTickLabels', {'vi2inviCCW' 'vi2inviCW' 'perc location'  'invi2viCCW' 'invi2viCW'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
% title('Illusion size','FontSize',25);

sca;
