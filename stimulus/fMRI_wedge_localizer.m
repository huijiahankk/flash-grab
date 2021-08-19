
% localizer for SC
% fixation baseline for 20sec before the stimulus
% checkerboard wedge  alternate present left and right visual
% field


% Clear the workspace
close all;
clearvars;
sca;

Screen('Preference', 'SkipSyncTests', 1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% swith curser to the commandwindow
commandwindow;

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
    grey, [0 0 1024 768], 32, 2, [], [], kPsychNeed32BPCFloat);    % [0 0 1024 768]

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Screen resolution in Y
screenYpix = windowRect(4);
[xCenter,yCenter] = WindowCenter(window);
[centerMoveHoriPix,centerMoveVertiPix] = deal(0);



%  7T Screen parameter
visualDegree = 10;
visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75;
visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;

% sector size
sectorRadius_in_pixel = floor((visualHerghtIn7T_pixel - 200)/2);    % inner diameter of background annulus
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%   % outer radii of background annulus




trialNumber = 20;

% 2 localizer  left and right
localizerMat = repmat([1; 2],trialNumber/2,1);
localizerMatRand = localizerMat(Shuffle(1:length(localizerMat)));


% Number of white/black circle pairs
rcycles = 2 ;

% Number of white/black angular segment pairs (integer)
tcycles = 12;

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (sectorRadius_out_pixel*2 - 1): xylim,...
    -xylim: 2 * xylim / (sectorRadius_out_pixel*2  - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;
checks = circle .* checks + grey * ~circle;

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/7;
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% Sync us to the vertical retrace
vbl = Screen('Flip', window);


% the duration of checkerboard flickering in seconds
checkerboardFlickDura = 12; % seconds
colorSwitchTimesMain = 2;  % during the checkerboard flickering the color of fixation switch twice

% fixation
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 10;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;


%----------------------------------------------------------------------
%          adjust the fixation cross
%----------------------------------------------------------------------
if 1
    % Here we set the size of the arms of our fixation cross
    %     fixCrossDimPix = 10;
    respSwitch = 0;
    
    respToBeMade = true;
    
    while respToBeMade
        
        resp = 0;
        prekeyIsDown = 0;
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                
            elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
                resp = - 1;
                
            elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
                resp = 1;
                
            elseif keyCode(KbName('3')) ||keyCode(KbName('3#'))
                respSwitch = 1;
                
            elseif keyCode(KbName('4')) ||keyCode(KbName('4$'))
                respToBeMade = false;
            end
            
        end
        prekeyIsDown = keyIsDown;
        
        
        
        if  respSwitch == 0
            centerMoveHoriPix = centerMoveHoriPix + resp * 1;
        elseif  respSwitch == 1
            centerMoveVertiPix = centerMoveVertiPix + resp * 1;
        end
        
        
        
        checkerboardRect = [0  0  sectorRadius_out_pixel * 2   sectorRadius_out_pixel * 2];
        sectorDestinationRect = CenterRectOnPoint(checkerboardRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
        %     Screen('DrawTexture',window,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
        Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)),[],sectorDestinationRect);
        % Draw the fixation cross in white, set it to the center of our screen and
        % set good quality antialiasing
        %         Screen('DrawLines', window, allCoords,lineWidthPix, white, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        Screen('Flip',window);
        
    end
    
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    DrawFormattedText(window, '\n\nPress s To Begin', 'center', 'center', black);
    Screen('Flip', window);
    
    checkflag = 1;
    
    while checkflag
        [~, ~, keyCode, ~] = KbCheck(-1);
        if keyCode(KbName('s'))
            checkflag = 0;
        end
    end
    
end

% mask the part of checkerboard
maskSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel...
    xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];
maskSectorRectAdjust = CenterRectOnPoint(maskSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
maskSectorArcAngle = 315;
% mask the sector to a wedge
maskInnerSectorRect = [xCenter  - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel...
    xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];
maskInnerSectorRectAdjust = CenterRectOnPoint(maskInnerSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
maskInnerSectorArcAngle = 45;



%----------------------------------------------------------------------
%      fixation baseline test before the localizer
%----------------------------------------------------------------------
% if the subject forget to press the keyboard, treat the response as -1
responseFixbaselineFront = - 1;
baselineOnset = GetSecs;
fixBaselineDura = 20;
keyPressTimes = 0;
prekeyIsDown = 0;
colorSwitchTimesBaselineFront = 4;

colorSwitchTimeBaselineMat = sort(randperm(fixBaselineDura,colorSwitchTimesBaselineFront));


while GetSecs - baselineOnset <= fixBaselineDura   
    
    if GetSecs - baselineOnset < colorSwitchTimeBaselineMat(1)
        fixationColor = white;
    elseif (colorSwitchTimeBaselineMat(1) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < colorSwitchTimeBaselineMat(2))
        fixationColor = black;
    elseif (colorSwitchTimeBaselineMat(2) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < colorSwitchTimeBaselineMat(3))
        fixationColor = white;
    elseif (colorSwitchTimeBaselineMat(3) < GetSecs - baselineOnset) && (GetSecs - baselineOnset< colorSwitchTimeBaselineMat(4))
        fixationColor = black;
    elseif( colorSwitchTimeBaselineMat(4) < GetSecs - baselineOnset) && (GetSecs - baselineOnset < fixBaselineDura)
        fixationColor = white;
    end
    
        
    Screen('DrawLines', window, allCoords,lineWidthPix, fixationColor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
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
        elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
            responseFixbaselineFront = 1;
            
        elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
            responseFixbaselineFront = 2;
            
        elseif keyCode(KbName('Space'))
            responseFixbaselineFront = 0;
            respToBeMade = false;
        end
    end
    
    
    if keyIsDown && ~prekeyIsDown
        keyPressTimes = keyPressTimes + 1;
        responseFixbaselineMat(keyPressTimes) = responseFixbaselineFront;
    end
     prekeyIsDown = keyIsDown;
    
end


stimulusOnset = GetSecs;


for trial  = 1:trialNumber
    
    
    trialOnset(trial) = GetSecs;
    localizerType = localizerMatRand(trial);
    
    %----------------------------------------------------------------------
    %             fixation color setting
    %----------------------------------------------------------------------
    %     colorMat = randi([0 checkerboardFlickDura],trialNumber,colorSwitchTimes);
    % sorts the elements of A in ascending order
    colorSwitchTimeMat = sort(randperm(checkerboardFlickDura,colorSwitchTimesMain));
    %     color = colorMat(trial,:);
    
    
    while GetSecs - trialOnset(trial) <= checkerboardFlickDura
        
        % Increment the counter
        frameCounter = frameCounter + 1;
        
        % Draw our texture to the screen
        Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)),[],sectorDestinationRect);
        
        if localizerType == 1
            
            % checkerboard left    mask right     angle start from right above
            Screen('FillArc',window,grey,maskSectorRectAdjust,180 + 45, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180,maskInnerSectorArcAngle);
            
        elseif localizerType == 2
            % checkerboard right    mask left     angle start from right above
            Screen('FillArc',window,grey,maskSectorRectAdjust,180, maskSectorArcAngle);
            Screen('FillArc',window,grey,maskInnerSectorRectAdjust,180 - 45, maskInnerSectorArcAngle);
        end
        
        
        colorSwitchOnset = GetSecs;
        
        if colorSwitchTimeMat(1) < colorSwitchOnset - trialOnset(trial) && colorSwitchOnset - trialOnset(trial) < colorSwitchTimeMat(2)
            fixationColor = white;
            %          GetSecs - trialOnset(trial) < colorSwitchTimeMat(1) |  GetSecs - trialOnset(trial) > colorSwitchTimeMat(1)
            %             fixationColor = black;
        else
            fixationColor = black;
        end
        
        Screen('DrawLines', window, allCoords,lineWidthPix, fixationColor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Reverse the texture cue to show the other polarity if the time is up
        if frameCounter == checkFlipTimeFrames
            textureCue = fliplr(textureCue);
            frameCounter = 0;
        end
        
        
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        prekeyIsDown = 0;
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                % the bar was on the left of the gabor
            elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
                response = 1;
                
            elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
                response = 2;
                
            elseif keyCode(KbName('Space'))
                response = 0;
                respToBeMade = false;
            end
        end
        
        prekeyIsDown = keyIsDown;
    end
    WaitSecs(1);
    responseMat(trial) = response;
    
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
% dir = sprintf(['../data/' '%s/'],sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end


savePath = '../data/7T/localizer/';

time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename1 = [savePath,filename];
% save(filename2,'data','back');
save(filename1);


% Clear up and leave the building
sca;
close all;
