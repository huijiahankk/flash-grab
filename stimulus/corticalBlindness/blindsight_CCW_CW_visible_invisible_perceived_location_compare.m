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
    barLocation = 'l';  % u  upper visual field   l   lower visual field n  normal
    
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
%     mask for change contrast
bottomcolor = 128; %(whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomcolor,[],[],[],0); %set window to ,[0 0 1000 800]  [0 0 1024 768] for single monitor display
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

eyeScreenDistence = 78;  % cm  68sunnannan
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
subtrialNumber = 3;   % 3 conditions  visible2invisible  invisible2visible    perceived location

% randWedgeTiltNoiseMat = rand(trialNumber,1)*2;
back.CurrentAngle = 0;


% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
% wedgeTiltStart = 0;
wedgeTiltStep = 1; %2.8125   1.40625;
back.alpha = 1; % background transparence

wedgeTiltStartUpperRight = 0;
wedgeTiltStartLowerRight = 0;
wedgeTiltStartNormal = - 90;  
% wedgeTiltIncre = 0;
back.SpinSpeed = 3;%  3  2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
back.flashTiltDirectionMatShuff = Shuffle(back.flashTiltDirectionMat)';


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
    
    KbStrokeWait;
    
    
    if barLocation == 'u'
        wedgeTiltNow = wedgeTiltStartUpperRight;
    elseif barLocation == 'l'
        wedgeTiltNow = wedgeTiltStartLowerRight;
    elseif barLocation == 'n'
        wedgeTiltNow = wedgeTiltStartNormal;
    end
    
    
    
    for subtrial = 1:subtrialNumber
        
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        data.flashTiltDirection(trial) = back.flashTiltDirectionMatShuff(trial);
        back.alpha = 1;
        currentFrame = 0;
        
        if subtrial == 1    % visible2invisible
            str_subtrial = '\n Adjust the bar until invisible   \n\n Press Any Key To Begin';
            wedgeTiltNow = wedgeTiltNow;
        elseif subtrial == 2   % invisible2visible
            str_subtrial = '\n Adjust the bar until visible and remember the location  \n\n Press Any Key To Begin';
            wedgeTiltNow = visible2invisible(trial);
        elseif subtrial == 3   % perceived_location
            str_subtrial = '\n Adjust the bar to the perceived location   \n\n Press Any Key To Begin';
            wedgeTiltNow = invisible2visible(trial);
            back.alpha = 0;
            %         elseif subtrial == 4  % off_timing
            %             str_subtrial = '\n Adjust the bar until visible   \n\n Press Any Key To Begin'
            %             wedgeTiltNow = wedgeTiltNow;
        end
        
        
        %----------------------------------------------------------------------
        %     task instruction  adjust the bar
        %----------------------------------------------------------------------
        
        DrawFormattedText(wptr, str_subtrial, 'center', 'center', blackcolor);
        Screen('Flip', wptr);
        KbStrokeWait;
        
        
        while respToBeMade
            
%             if currentFrame > 512
%                 currentFrame = currentFrame - 512;
%             end
            currentFrame = currentFrame + 1;
            
            
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
            
            %             if subtrial == 4
            %                 barRectTiltDegree = wedgeTiltNow + 22.5;
            %                 barDrawTiltDegree = back.CurrentAngle - 22.5;
            %             else
            
            
            barDrawTiltDegree = back.CurrentAngle;
            %             end
            
            % present flash tilt right  CCW
            if data.flashTiltDirection(trial) == 1  && back.FlagSpinDirecA ==  - 1   % flash tilt right  CCW
                %                 wedgeTiltNow
                barRectTiltDegree = wedgeTiltNow - 360/sectorNumber;    % - 360/sectorNumber
                barDrawTiltDegree = back.CurrentAngle + 360/sectorNumber;  % + 360/sectorNumber
%                 barRectTiltDegree = wedgeTiltNow;
%                 barDrawTiltDegree = back.CurrentAngle;
                
                
                if barLocation == 'l' | barLocation == 'n'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter + dotRadius2Center * cosd(barRectTiltDegree));
                    
                elseif  barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
                    
                end
                
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
                %                 end
                flashPresentFlag = 1;
                % present flash tilt left  CW
            elseif data.flashTiltDirection(trial) == 2  && back.FlagSpinDirecB ==  1    % CW
                
                barRectTiltDegree = wedgeTiltNow;
                barDrawTiltDegree = back.CurrentAngle;
                
                if barLocation == 'l' | barLocation == 'n'
                    % vertical bar lower visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter + dotRadius2Center * sind(barRectTiltDegree), yCenter + dotRadius2Center * cosd(barRectTiltDegree));
                elseif barLocation == 'u'
                    % vertical bar upper visual field
                    barDestinationRect = CenterRectOnPoint(barRect,xCenter - dotRadius2Center * sind(barRectTiltDegree), yCenter - dotRadius2Center * cosd(barRectTiltDegree));
                end
                
                Screen('DrawTexture',wptr,barTexture,barRect,barDestinationRect,barDrawTiltDegree);
                
                %                 end
                
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
            end
            
            back.FlagSpinDirecA = 0;
            back.FlagSpinDirecB = 0;
            
            
            
            % draw fixation
            %             Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
            
%             if mod(currentFrame,5) == 0
%                 fixcolor = 0;
%             else
%                 fixcolor = 128;
%             end
            fixcolor = 0;
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
            
        end
        
        if  subtrial == 1
            visible2invisible(trial) = wedgeTiltNow;
        elseif subtrial == 2
            invisible2visible(trial) = wedgeTiltNow;
        elseif subtrial == 3
            perceived_location(trial) = wedgeTiltNow;
        elseif subtrial == 4
            off_timing(trial) = wedgeTiltNow;
        end
        
        WaitSecs (0.5);
        
    end
    
    %     display(GetSecs - ScanOnset);
    
end




display(GetSecs - ScanOnset);



%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end


if  barLocation == 'u'
    savePath = '../../data/corticalBlindness/bar/upper_field/';
elseif  barLocation == 'l'
    savePath = '../../data/corticalBlindness/bar/lower_field/';
elseif  barLocation == 'n'
    savePath = '../../data/corticalBlindness/bar/normal/';
end


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
