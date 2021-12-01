% generate a flash-grab red wedge event-related for testing whether SC
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
% clear all;
clearvars;

if 1
   

    sbjname = 'huijiahan';
   
    debug = 'n';
    % have to be the mutiply of 3
    sbjIllusionSizeLeft = 0;  % 5
    sbjIllusionSizeRight = 0;
    run_no = '1';
    trialNumber = 30;
else
    run_no = input('>>>Please input the run number:   ','s');
    sbjname = input('>>>Please input the subject''s name:   ','s');
    debug = input('>>>Debug? (y/n):  ','s');
    
    %     illusion = input('>>>Illusion or no illusion? (y/n):  ','s');
    % input('>>>trialNumber? (30):  ');
    
end

illusion = 'y';
%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../function;
addpath ../FGE_subcortex_new/flashgrabExp_7T_layer;
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

fixsize = 5;
% coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
% coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink]; %[0 0 256 192];
% redSectorRect = [xCenter - xCenter*coverSectorShrink yCenter - xCenter*coverSectorShrink  xCenter  + xCenter*coverSectorShrink  yCenter + xCenter*coverSectorShrink];
sectorRect = [0  yCenter - xCenter  2*xCenter yCenter + xCenter];

% Create rotation matrix
% theta = 90; % to rotate 90 counterclockwise
% R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% % Rotate your point(s)
% point = coverSectorRect'; % arbitrarily selected
% rotpoint = R .* point;


%% set parameters
fixcolor = 200; % 0 255
framerate = FrameRate(wptr);
redcolor = [256 0 0];

% blackColor = BlackIndex(screenNumber);
% whiteColor = WhiteIndex(screenNumber);
[centerMoveHoriPix, centerMoveVertiPix, resp] = deal(0);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 10;
respSwitch = 0;


%----------------------------------------------------------------------
%                adjust screen rgb to map linear  ramp
%----------------------------------------------------------------------

% load ../function/Calibration-rog_sRGB-2020-10-28-20-35.mat;  % this is for 7T screen on the black mac pro
%
% dacsize = 10;  %How many bits per pixel#
% maxcol = 2.^dacsize-1;
% ncolors = 256; % see details in makebkg.m
% newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv);  %Make the gamma table we want#
% newclut(1:ncolors,:) = newcmap./maxcol;
% newclut(isnan(newclut)) = 0;


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

visualDegreeOrig = 10;
sectorRadius_in_out_magni = 1;
visualDegree = visualDegreeOrig * sectorRadius_in_out_magni;
visualHerghtIn7T_cm_perVisualDegree = tan(deg2rad(1)) * 75;
visualHerghtIn7T_pixel_perVisualDegree = visualHerghtIn7T_cm_perVisualDegree/28 * 768;
visualHerghtIn7T_pixel = visualHerghtIn7T_pixel_perVisualDegree * visualDegree;


%----------------------------------------------------------------------
%                      draw background sector
%----------------------------------------------------------------------

sectorNumber = 8;
%         annnulus outer radius
sectorRadius_out_pixel = floor((visualHerghtIn7T_pixel - 20)/2);%  + centerMovePix;   % outer radii of background annulus

sectorRadius_in_pixel = sectorRadius_out_pixel - 100 * sectorRadius_in_out_magni;    % inner diameter of background annulus


dotRadius2Center = (sectorRadius_in_pixel + sectorRadius_out_pixel)/2;
[sectorTex,sectorRect] = MakeSectorTexRect(sectorNumber, visualDegree, blackcolor, whitecolor,wptr,sectorRadius_in_pixel,sectorRadius_out_pixel);

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% VisualField = [1 1 1 1];


trialNumber = 4; %44;
block = 1;


back.CurrentAngle = 360/sectorNumber/2;
back.ground_alpha = 0.24;
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
% back.FlagSpinDirecA = 0;  % flash tilt right
% back.FlagSpinDirecB = 0;  % flash tilt left

wedgeTiltStart = 0;


back.SpinSpeed = 3;% 2.8125;   % 4 degree/frame    3.334 in Hinze's paper   22.5(sector angle)/4
back.velocity = back.SpinSpeed * framerate;
back.ReverseAngle = 90; % duration frame of checkerboard
% each experiment generate the same sequence for flash direction,
% different contrast same direction sequence
% back.flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
% data.flashTiltDirection = Shuffle(back.flashTiltDirectionMat);

% how many times does the flash present before it gradually dissappear
flashPresentTimesCeiling = 1;
flashRepresentFrame = 2.2; % 2.2 means 3 frame

%----------------------------------------------------------------------
%                       optseq parameters
%----------------------------------------------------------------------
cd '../optimal_seq'

% run_no = '1';
% TR = 2; % second
% the sector first rotate rightward 90 degree and then leftward 180 degree
% rightward 180 degree and so on
% sectorTimeRound = back.AngleRange/(back.SpinSpeed * framerate);% how many second does the background rotate rightward and then leftward cost
filePrefixName = 'FGI-00' ;

fileName = strcat(filePrefixName,run_no,'.par');
% [timepoint,stim_type,SOA,~,~] = read_optseq2_data([fileName]);
[stimonset,stimtype,stimlength,junk,stimname] =  textread(fileName,'%f%n%f%s%s','delimiter',' '); %textread

data.flashTiltDirection = stimtype;

% [timepoint,stim_type,SOA,~,~] = read_optseq2_data(['optimal_seq/' fileName '00' run_no '.par']);



%----------------------------------------------------------------------
%          adjust the fixation cross
%----------------------------------------------------------------------
respToBeMade = true;


% while respToBeMade
%     
%     resp = 0;
%     prekeyIsDown = 0;
%     [keyIsDown,secs,keyCode] = KbCheck(-1);
%     if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
%         if keyCode(KbName('ESCAPE'))
%             ShowCursor;
%             sca;
%             return
%             
%         elseif keyCode(KbName('1!'))||keyCode(KbName('1'))
%             resp = - 1;
%             
%         elseif keyCode(KbName('2')) ||keyCode(KbName('2@'))
%             resp = 1;
%             
%         elseif keyCode(KbName('3')) ||keyCode(KbName('3#'))
%             respSwitch = 1;
%             
%         elseif keyCode(KbName('4')) ||keyCode(KbName('4$'))
%             respToBeMade = false;
%         end
%         
%     end
%     prekeyIsDown = keyIsDown;
%     
%     
%     
%     if  respSwitch == 0
%         centerMoveHoriPix = centerMoveHoriPix + resp * 1;
%     elseif  respSwitch == 1
%         centerMoveVertiPix = centerMoveVertiPix + resp * 1;
%     end
%     
%     % Now we set the coordinates (these are all relative to zero we will let
%     % the drawing routine center the cross in the center of our monitor for us)
%     xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
%     yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
%     allCoords = [xCoords; yCoords];
%     
%     % Set the line width for our fixation cross
%     lineWidthPix = 4;
%     
%     sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);
%     Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
%     
%     % Draw the fixation cross in white, set it to the center of our screen and
%     % set good quality antialiasing
%     Screen('DrawLines', wptr, allCoords,lineWidthPix, whitecolor, [xCenter + centerMoveHoriPix yCenter + centerMoveVertiPix]);
%     Screen('Flip',wptr);
%     
% end


%----------------------------------------------------------------------
%                      draw red wedge
%----------------------------------------------------------------------

coverSectorShrink = 4; % 2 big cover sector 4 small cover sector

% coverSectorRect = [xCenter + centerMoveHoriPix - xCenter/coverSectorShrink yCenter + centerMoveVertiPix - xCenter/coverSectorShrink...
%     xCenter + centerMoveHoriPix  + xCenter/coverSectorShrink  yCenter + centerMoveVertiPix + xCenter/coverSectorShrink];

redSectorRect = [xCenter - sectorRadius_out_pixel yCenter - sectorRadius_out_pixel...
    xCenter  + sectorRadius_out_pixel  yCenter + sectorRadius_out_pixel];

redSectorRectAdjust = CenterRectOnPoint(redSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);

InnerSectorRect = [xCenter  - sectorRadius_in_pixel  yCenter - sectorRadius_in_pixel...
    xCenter + sectorRadius_in_pixel  yCenter + sectorRadius_in_pixel];

InnerSectorRectAdjust = CenterRectOnPoint(InnerSectorRect,xCenter + centerMoveHoriPix,yCenter + centerMoveVertiPix);

sectorArcAngle = 360/sectorNumber;

%----------------------------------------------------------------------
%       present a start screen and wait for a key-press
%----------------------------------------------------------------------

% formatSpec = 'This is the %dth of %d block. Click s To Begin';
%
% A1 = block;
% A2 = blockNumber;
% str = sprintf(formatSpec,A1,A2);
% DrawFormattedText(wptr, str, 'center', 'center', blackcolor);
DrawFormattedText(wptr, '\n\nPress s To Begin', 'center', 'center', blackcolor);
%         fprintf(1,'\tTrial number: %2.0f\n',trialNumber);

Screen('Flip', wptr);


%     KbStrokeWait;
%     KbWait;

checkflag = 1;

while checkflag
    [~, ~, keyCode, ~] = KbCheck(-1);
    if keyCode(KbName('s'))
        checkflag = 0;
    end
end


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
scanOnset = GetSecs;
response = - 1; % if the subject failed to press the key, record -1

% for block = 1 : blockNumber


for trial = 1:trialNumber
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    trailOnset = GetSecs;
    respToBeMade = true;
    prekeyIsDown = 0;
    wedgeTiltNow = wedgeTiltStart;
    trialOnset = GetSecs;
    
    adjustAngle = 360/2/sectorNumber;
    
    back.RotateTimes = 0;
    flashPresentTimes = 0;
    
    back.FlagSpinDirecA = 0;% flash tilt right
    back.FlagSpinDirecB = 0;% flash tilt left
    
    
    testDuration = stimlength(trial)
    
    trial
    %                 HideCursor;
    flashPresentFlag = 0;
    
    while GetSecs - trailOnset < testDuration  % back.RotateTimes < testDuration %  % &&  respToBeMade
        %             mouseclick_frame = mouseclick_frame + 1;
        %             HideCursor;
        flashPresentFlag = 0;
        % tilt right  background first rotate clockwise until to the reverse angle
        if back.CurrentAngle >= back.ReverseAngle + adjustAngle + wedgeTiltNow  % + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = - 1;
            back.FlagSpinDirecA = back.SpinDirec;
            back.RotateTimes = back.RotateTimes + 1;
            
            % tilt left
        elseif back.CurrentAngle <= - back.ReverseAngle + adjustAngle + wedgeTiltNow  %  + wedgeTiltNow - (360/sectorNumber/2 + 0.75 + adjustAngle)
            back.SpinDirec = 1;
            back.FlagSpinDirecB = back.SpinDirec;
            back.RotateTimes = back.RotateTimes + 1;
            
        end
        
        %    draw background each frame
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle,[],back.ground_alpha); %  + backGroundRota
        
        
        %----------------------------------------------------------------------
        %       flash at reverse onset
        %----------------------------------------------------------------------
        % illusion == y mean flash at the reverse moment
        if illusion == 'y'
            % present flash tilt right
            if data.flashTiltDirection(trial,block) == 1  && back.FlagSpinDirecA ==  - 1  && flashPresentTimes < (flashPresentTimesCeiling) % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                
                % draw red wedge
                Screen('FillArc',wptr,redcolor,redSectorRectAdjust,back.CurrentAngle + 90 - 2*adjustAngle,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
                Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,back.CurrentAngle + 90 - 2*adjustAngle,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
                
                flashTimePoint = GetSecs - scanOnset;
                flashOnset = GetSecs;
                if trial > 1
                    flashInterval = GetSecs - scanOnset - flashTimePointMat((trial+1)/2 - 1,block);
                elseif trial == 1
                    flashInterval = GetSecs - trialOnset;
                end
                display(flashTimePoint);
                display(flashInterval);
                
                % present flash tilt left
            elseif data.flashTiltDirection(trial,block) == 2  && back.FlagSpinDirecB ==  1  && flashPresentTimes < (flashPresentTimesCeiling)  % flash tilt left
                
                
                % draw red wedge
                Screen('FillArc',wptr,redcolor,redSectorRectAdjust,back.CurrentAngle - 90 - 2*adjustAngle,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                Screen('FillArc',wptr,bottomcolor,InnerSectorRectAdjust,back.CurrentAngle - 90 - 2*adjustAngle,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
                
                flashTimePoint = GetSecs - scanOnset;
                flashOnset = GetSecs;
                
                if trial > 1
                    flashInterval = GetSecs - scanOnset - flashTimePointMat((trial+1)/2 - 1,block);
                elseif trial == 1
                    flashInterval = GetSecs - trialOnset;
                end
                display(flashTimePoint);
                display(flashInterval);
                
                
            elseif data.flashTiltDirection(trial,block) == 0  || data.flashTiltDirection(trial,block) == 3
                flashPresentFlag = 0;
                flashTimePoint = GetSecs - scanOnset;
                flashOnset = GetSecs;
                
            end
            
            %--------------------------------------------
            %       flash at ongoing rotate
            %--------------------------------------------
            % illusion == n means flash not at the moment when background reversed
        elseif  illusion == 'n'
            %                 back.CurrentAngle = 0  right field horizontal
            
            
            if data.flashTiltDirection(block,trial) == 1  && back.CurrentAngle ==  sbjIllusionSizeRight + back.ReverseAngle + adjustAngle + 1.5  - sectorArcAngle && flashPresentTimes < (flashPresentTimesCeiling) % flash tilt right
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                %  the location of the red dot is present in the middle of annlus (between outer and inner radii)
                
                % draw red wedge
                Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle + 90 - 2*adjustAngle + sectorArcAngle ,sectorArcAngle);  %  wedgeTiltNow - 360/sectorNumber/2
                Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle + 90 - 2*adjustAngle + sectorArcAngle ,sectorArcAngle); %wedgeTiltNow  - 360/sectorNumber/2
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
                
                flashTimePoint = GetSecs - scanOnset;
                flashOnset = GetSecs;
                if trial > 1
                    flashInterval = GetSecs - scanOnset - flashTimePointMat((trial+1)/2 - 1,block);
                elseif trial == 1
                    flashInterval = GetSecs - trialOnset;
                end
                display(flashTimePoint);
                %                     display(flashInterval);
                
                % present flash tilt left
            elseif data.flashTiltDirection(block,trial) == 2  && back.CurrentAngle == sbjIllusionSizeLeft - back.ReverseAngle + adjustAngle + 1.5  - sectorArcAngle && flashPresentTimes < (flashPresentTimesCeiling)  % flash tilt left
                
                % draw red wedge
                Screen('FillArc',wptr,redcolor,redSectorRect,back.CurrentAngle - 90 - 2*adjustAngle + sectorArcAngle,sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                Screen('FillArc',wptr,bottomcolor,InnerSectorRect,back.CurrentAngle - 90 - 2*adjustAngle + sectorArcAngle, sectorArcAngle); % wedgeTiltNow - 360/sectorNumber/2
                flashPresentTimes = flashPresentTimes + 1;
                flashPresentFlag = 1;
                
                flashTimePoint = GetSecs - scanOnset;
                flashOnset = GetSecs;
                
                if trial > 1
                    flashInterval = GetSecs - scanOnset - flashTimePointMat((trial+1)/2 - 1,block);
                elseif trial == 1
                    flashInterval = GetSecs - trialOnset;
                end
                display(flashTimePoint);
                %                     display(flashInterval);
                
            else
                flashPresentFlag = 0;
            end
            
            
        end
        
        
        
        
        % the first run background rotate clockwise the second run
        % rotate counter-clockwise
        %             if mod(run_no,2) == 1
        %                 back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        %             elseif mod(run_no,2) == 0
        %                 back.CurrentAngle = back.CurrentAngle - back.SpinDirec * back.SpinSpeed;
        %             end
        
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        
        %             Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMoveHoriPix,xCenter+fixsize,yCenter+fixsize-centerMoveVertiPix]); % fixation
        Screen('DrawLines', wptr, allCoords,lineWidthPix, whitecolor, [xCenter+centerMoveHoriPix yCenter+centerMoveVertiPix]);
        Screen('Flip',wptr);
        
        % define the present frame of the flash
        if flashPresentFlag
            WaitSecs((1/framerate) * flashRepresentFrame);
            
        end
        
        
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
            elseif keyCode(KbName('LeftArrow'))
                response = 1;
                
            elseif keyCode(KbName('RightArrow'))
                response = 2;
                
            elseif keyCode(KbName('Space'))
                response = 0;
                respToBeMade = false;
                %                     prekeyIsDown = 1;
                %                 WaitSecs(0.5);
            end
            
            
            %             KbStrokeWait;
        end
        
        prekeyIsDown = keyIsDown;
        
        % for debug when flash present the simulus halt
        if debug== 'y' && flashPresentFlag
            KbWait;
        end
        
    end
    
    
    if mod(trial,2) == 1
        flashTimePointMat((trial+1)/2,block) = flashTimePoint;
        flashIntervalMat((trial+1)/2,block) = flashInterval;
    end
    
    responseMat(trial) = response;
    
    %         display(GetSecs - scanOnset);
    
    
end


% display(GetSecs - ScanOnset);

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


savePath = '../data/7T/';


time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'data','back');
save(filename2);

sca;
