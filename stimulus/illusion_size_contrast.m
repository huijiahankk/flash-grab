% generate a flash-grab checkerboard event-related for testing whether SC
% response to the illusion or physical position


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
    debug = 'y';
    expmark = 2;
    flashRepresentFrame = 2.2;
    data.sectorRadiusIn = 100;
    flashRedDiskFlag = 'y';
    InnerRadii = 0;
    %     contrastratio = 0.06;
    %     whiteBlackContrast = 'n';
    back.contrastTrend == 'higher';
else
    
    sbjname = input('>>>Please input the subject''s name:   ','s');
    % session = input('>>>Please input the session:  ','s');
    % session 1
    % 1  annulus segment condition
    % sectorNumber = input('>>>> How many background segment ? (e.g.: 8/12):  ');
    % savePath = '../data/'
    % InnerRadii = input('>>>> Inner radii of the annulus? (e.g.: 200/400):  ');
    % back.SpinSpeed = input('>>>> Background spin velocity(deg/frame)? (e.g.: 2.3/4):  ');
    debug = input('>>>Debug? (y/n):  ','s');
    
    expmark = 2; % input('>>>Which experiment? (1 background tilt，flash vertical/2 flash/background vertical):  ');
    % 1 background tilt，flash vertical  2 flash/background vertical
    % flash represent for 3 frames
    flashRepresentFrame = 2.2; %input('>>>flash represent frames? (0.8/2.2):  ');
    flashRedDiskFlag =  'y'; %input('>>>> Flash with red disk ? (e.g.: y/n):  ','s');
    InnerRadii = 0; % input('>>>> Inner Radius of annulus ? (e.g.: 0/200):  ');
    if  flashRedDiskFlag == 'n'
        data.sectorRadiusIn = input('>>>> CheckerBoard wedge Inner Radius(degree) ? (e.g.: 0/300):  ');
    else
        data.sectorRadiusIn = 300;
    end
%     whiteBlackContrast = input('>>>> background white and black ? (e.g.: y/n):  ','s');
    %     contrastratio = input('>>>background contrast ratio? (0.06/0.12/0.24/0.48/0.96):  ');
    back.contrastTrend = input('>>>> background contrast trend ? (e.g.: higher/lower):  ','s');
    
end

% 1 background tilt，flash vertical  2 flash/background vertical
% if expmark == 1  && flashRepresentFrame == 0.8
%     savePath = '../data/illusionSize/backTilt_FlashVer/1frame/';
% elseif expmark == 1 && flashRepresentFrame == 2.2
%     savePath = '../data/illusionSize/backTilt_FlashVer/3frame/';
% elseif expmark == 2 && flashRepresentFrame == 0.8
%     savePath = '../data/illusionSize/backFlash_Ver/1frame/';
% elseif expmark == 2 && flashRepresentFrame == 2.2
%     savePath = '../data/illusionSize/backFlash_Ver/3frame/';
% end

% if flashRepresentFrame == 0.8  && InnerRadii == 0
%     savePath = '../data/illusionSize/highContrast/1frame/0InnerRadii/';   % highContrast
% elseif flashRepresentFrame == 0.8  && InnerRadii == 200
%     savePath = '../data/illusionSize/highContrast/1frame/200InnerRadii/';
% elseif flashRepresentFrame == 2.2  && InnerRadii == 0
%     savePath = '../data/illusionSize/highContrast/3frame/0InnerRadii/';
% elseif flashRepresentFrame == 2.2  && InnerRadii == 200
%     savePath = '../data/illusionSize/highContrast/3frame/200InnerRadii/';
% end

% if contrastratio == 0.06
%     savePath = '../data/illusionSize/ContrastHierarchy/0.06/';
% elseif contrastratio == 0.12
%     savePath = '../data/illusionSize/ContrastHierarchy/0.12/';
% elseif contrastratio == 0.24
%     savePath = '../data/illusionSize/ContrastHierarchy/0.24/';
% elseif contrastratio == 0.48
%     savePath = '../data/illusionSize/ContrastHierarchy/0.48/';
% elseif contrastratio == 0.96
%     savePath = '../data/illusionSize/ContrastHierarchy/0.96/';
% end

savePath = '../data/illusionSize/ContrastHierarchy/';



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
back.maskcolor = (whitecolor + blackcolor) / 2;
backcolor = (whitecolor + blackcolor) / 2;  % high contrast 255
bottomColor = (whitecolor + blackcolor) / 2; % 128
[wptr,rect]=Screen('OpenWindow',screenNumber,bottomColor,[]); %set window to ,[0 0 1600 900]  [0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);

coverSectorShrink = 4; % 2 big cover sector 4 small cover sector
coverSectorRect = [xCenter - xCenter/coverSectorShrink yCenter - xCenter/coverSectorShrink  xCenter  + xCenter/coverSectorShrink  yCenter + xCenter/coverSectorShrink]; %[0 0 256 192];
redSectorRect = [xCenter - xCenter*coverSectorShrink yCenter - xCenter*coverSectorShrink  xCenter  + xCenter*coverSectorShrink  yCenter + xCenter*coverSectorShrink];

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


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
% spaceKey = KbName('space');

% %----------------------------------------------------------------------
% %                      background sector setup
% %----------------------------------------------------------------------
%
% sectorNumber = 6;
% [sector,InnerSectorRect]= MakeSector(xCenter,yCenter,centerMovePix,contrastratio,backcolor,sectorNumber,InnerRadii);
% sectorTex = Screen('MakeTexture', wptr, sector);
% sectorRect = Screen('Rect',sectorTex);
% sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
if back.contrastTrend == 'higher'
    back.contrastMat = [0.06 0.12 0.24 0.48 0.96]; % [0.96 0.48 0.24 0.12 0.06]
elseif back.contrastTrend == 'lower'
    back.contrastMat = [0.96 0.48 0.24 0.12 0.06];
end

sectorNumber = 6;
contrastratio = 1;
% for annulus background  draw the inner sector the same as background
[sector,InnerSectorRect]= MakeSector(xCenter,yCenter,centerMovePix,contrastratio,whitecolor,sectorNumber,InnerRadii);
sectorTex = Screen('MakeTexture', wptr, sector);
sectorRect = Screen('Rect',sectorTex);
sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);
% Screen('FillRect', wptr,bttomcolor, rect);

%----------------------------------------------------------------------
%                      initialize on Screen Window
%----------------------------------------------------------------------
fixsize = 5;
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
% % Screen('DrawTexture',wptr,crossTex,...
% %     Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
% Screen('Flip',wptr);

%----------------------------------------------------------------------
%%%                     generate  sector alpha channel matrix
%----------------------------------------------------------------------
% alphaSectorRect = zeros(xCenter,xCenter);
% sectorStartAngle = 0; % wedgeAngleTheta+0;
x = linspace(-yCenter,yCenter,yCenter * 2 + 1);
y = fliplr(linspace(-yCenter,yCenter,yCenter * 2 + 1));
[X,Y] = meshgrid(x,y);
% Parameters for sector
sectorArcAngle = 15; % abs(sectorStartAngle * 2);
adjustSectorArcAngle = mod(sectorArcAngle,2)/2;
% checkerboard tilt angle
tiltAngle = sectorArcAngle/2;
% sectorRadiusIn = 0; % 300;
data.sectorRadiusOut = xCenter;
% Coordinates to polarcoordinates
[phi, rho] = cart2pol(X,Y);
phi = rad2deg(phi);
% phi(phi<0)= - phi(phi<0);
% Generate mask
% alphaSectorMask = 255*(rho > sectorRadiusIn & rho < sectorRadiusOut & phi > (90 - sectorArcAngle/2) & phi< (90 + sectorArcAngle/2));
% location of checkerboard
% alphaSectorMask_left = 255 * (rho > sectorRadiusIn & rho < sectorRadiusOut & phi > (- 90 - sectorArcAngle/2 - tiltAngle) & phi< (-90 + sectorArcAngle/2 - tiltAngle));
% alphaSectorMask_right = 255 * (rho > sectorRadiusIn & rho < sectorRadiusOut & phi > (- 90 - sectorArcAngle/2 + tiltAngle) & phi< (-90 + sectorArcAngle/2 + tiltAngle));
alphaSectorMask = 255 * (rho > data.sectorRadiusIn & rho < data.sectorRadiusOut & phi > (- 90 - sectorArcAngle/2) & phi< (-90 + sectorArcAngle/2));
% size(alphaSectorMask);
% Have a look at the mask
% spy(alphaSectorMask);

%----------------------------------------------------------------------
%%%                     generate  wedge checkerboard
%----------------------------------------------------------------------
wedgeBackColor = [64,64,64];
% ScreenXlengthHalf=700;
% wedgeAngleTheta = -15;


wedgeSector_width = 10;
wedgeStripe_width = wedgeSector_width * 5;
% cbColorLeft = wedgeCheckerboard(alphaSectorMask_left,yCenter,wedgeBackColor,wedgeStripe_width,wedgeSector_width);
% cbColorRight = wedgeCheckerboard(alphaSectorMask_right,yCenter,wedgeBackColor,wedgeStripe_width,wedgeSector_width);
cbColor = wedgeCheckerboard(alphaSectorMask,yCenter,wedgeBackColor,wedgeStripe_width,wedgeSector_width);


% cbColor2(:,:,1) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,1);
% cbColor2(:,:,2) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,2);
% cbColor2(:,:,3) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,3);
% cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

cbColorMask = Screen('MakeTexture', wptr,cbColor);
cbColorMask1Rect = Screen('Rect',cbColorMask);
cbColorMask1DestinationRect = CenterRectOnPoint(cbColorMask1Rect,xCenter,yCenter);
% imshow(cbColor);


%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% VisualField = [1 1 1 1];

trialNumber = 20; % trial number should be even
blockNumber = length(back.contrastMat);
% trialNumber = 3;
back.CurrentAngle = 0;
back.AngleRange = 120;
back.ReverseAngle = back.AngleRange/2; % duration frame of checkerboard
% back.SpinSpeed = 4; % degree/frame     138  degree/sec    max 270
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;  % flash tilt right
back.FlagSpinDirecB = 0;  % flash tilt left
wedgeTiltStart = 0;
wedgeTiltStep = 0.5;
% wedgeTiltIncre = 0;
back.SpinSpeed = 4;
flashTiltDirectionMat = repmat([1;2],trialNumber/2,1);
data.flashTiltDirection = Shuffle(flashTiltDirectionMat);
% flashTiltDirectionMat = ['l','r'];
% flashTiltDirectionShu = Shuffle(1:length(flashTiltDirection));
% responseKey = 1;
% flashCurrentFrame = 0;  % initial flash frame
% data.wedgeTiltTotal = [];
% tiltFlag = 0;
TR = 2; % second
% the sector first rotate rightward 90 degree and then leftward 180 degree
% rightward 180 degree and so on
sectorTimeRound = back.AngleRange/(back.SpinSpeed * framerate);% how many second does the background rotate rightward and then leftward cost

% expmark 1 represent the checkerboard bar tilt for left and right
% condition and expmark 1 represent the checkerboard bar vertical whatever
% left and right condition
% finally we accept the expmark 2 condition
if  expmark == 1
    adjustAngle = tiltAngle + adjustSectorArcAngle;
elseif expmark == 2
    adjustAngle =   adjustSectorArcAngle;
end



%----------------------------------------------------------------------
%                       optseq parameters
%----------------------------------------------------------------------
% [timepoint,stim_type,SOA,~,~] = read_optseq2_data(['optimal_seq/' fileName '/par-00' run_no '.par']);

% event.TypeNumericIdMat = [0 1 2];  % 0 no sector checkerboard(scb) 1 checkerboard tilt left and perceived right  2 checkerboard tilt right and perceived left
% event.InterTimeMat = [4 4 4];
testDuration = 300;


% for k = 1:length(event.InterTimeMat)
%     % each block time contain how many round of background
%     ShowUpTimesMat(k) = floor(event.InterTimeMat(k)/sectorTimeRound);
% end

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
ScanOnset = GetSecs;




for block = 1 : blockNumber
    BlockOnset = GetSecs;
    
    back.RotateTimes = 0;
    %     event.TypeNumericId = event.TypeNumericIdMat(mod(block,3) + 1);
    %     event.InterRound = event.InterRoundMat(mod(block,3) + 1);
    %     event.InterTime = event.InterTimeMat(mod(block,3) + 1);
    %     ShowUpTimes = ShowUpTimesMat(mod(block,3) + 1);
    wedgeTiltNow = wedgeTiltStart;
    
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
    
    
    back.contrast = back.contrastMat(block);
    %     back.contrast = 1;
    
    for trial = 1:trialNumber
        %----------------------------------------------------------------------
        %                      background rotate
        %----------------------------------------------------------------------
        respToBeMade = true;
        %     while respToBeMade
        flashPresentFlag = 0;
        prekeyIsDown = 0;
        prekeyIsDowna = 0;
        %     flashTiltDirection = Shuffle(flashTiltDirectionMat);
        responseFlag = 0;
        frameFlag = 0;
        
        % each block lasting seconds 10s
        while GetSecs - BlockOnset < testDuration  && respToBeMade
            
            %         if event.TypeNumericId == 1
            %         while RoundFlag <  event.InterRound
            % background first rotate clockwise until to the reverse angle
            if back.CurrentAngle > back.ReverseAngle  + adjustAngle + wedgeTiltNow
                back.SpinDirec = - 1;
                back.FlagSpinDirecA = back.SpinDirec;
                back.RotateTimes = back.RotateTimes + 1;
                
            elseif back.CurrentAngle < - back.ReverseAngle  - adjustAngle  + wedgeTiltNow
                back.SpinDirec = 1;
                back.FlagSpinDirecB = back.SpinDirec;
                back.RotateTimes = back.RotateTimes + 1;
                
            end
            
            back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
            %    draw background each frame
            Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle); %  + backGroundRota
            Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], sectorDestinationRect);
            
            
            % present flash
            if data.flashTiltDirection(trial) == 1  && back.FlagSpinDirecA ==  - 1  % flash tilt right
                responseFlag = responseFlag + 1;
                
                % background on the vertical meridian the left part is always
                % white and the right part is always black
                if flashRedDiskFlag == 'y'
                    Screen('FillArc',wptr,redcolor,redSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                    Screen('FillArc',wptr,whitecolor,coverSectorRect,180 + wedgeTiltNow,sectorArcAngle/2); % backcolor * (1 - back.contrast)
                    Screen('FillArc',wptr,blackcolor,coverSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle/2);
                    Screen('FillArc', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], coverSectorRect, 180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                    %                     Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], coverSectorRect);
                    %                     Screen('FillArc',wptr,bottomColor,InnerSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                else
                    Screen('DrawTexture',wptr,cbColorMask,cbColorMask1Rect,cbColorMask1DestinationRect,wedgeTiltNow);
                end
                flashPresentFlag = 1;
            elseif data.flashTiltDirection(trial) == 2  && back.FlagSpinDirecB ==  1  % flash tilt left
                responseFlag = responseFlag + 1;
                
                if flashRedDiskFlag == 'y'
                    Screen('FillArc',wptr,redcolor,redSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                    Screen('FillArc',wptr,whitecolor,coverSectorRect,180 + wedgeTiltNow,sectorArcAngle/2); % backcolor * (1 - back.contrast)
                    Screen('FillArc',wptr,blackcolor,coverSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle/2);
                    Screen('FillArc', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], coverSectorRect, 180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                    %                     Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], sectorDestinationRect); % back.contrast * 255
                    %                     Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], coverSectorRect);
                    %                     Screen('FillArc',wptr,backcolor,coverSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                    %                     Screen('FillArc',wptr,bottomColor,InnerSectorRect,180 + wedgeTiltNow - sectorArcAngle/2,sectorArcAngle);
                else
                    Screen('DrawTexture',wptr,cbColorMask,cbColorMask1Rect,cbColorMask1DestinationRect,wedgeTiltNow);
                end
                flashPresentFlag = 1;
            else
                flashPresentFlag = 0;
                %                 %             display(GetSecs - ScanOnset);
            end
            
            %         Screen('FillOval', wptr,redcolor,sectorRect); %   [yCenter - xCenter  0  xCenter*2  xCenter + yCenter]
            
            %             Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], sectorDestinationRect); % back.contrast * 255
            back.FlagSpinDirecA = 0;
            back.FlagSpinDirecB = 0;
            %             Screen('FillRect', wptr, [back.maskcolor back.maskcolor back.maskcolor back.contrast * 255], sectorDestinationRect); % back.contrast * 255
            
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
                    wedgeTiltNow = wedgeTiltNow - wedgeTiltStep;
                    
                elseif keyCode(KbName('3')) || keyCode(KbName('3#'))
                    wedgeTiltNow = wedgeTiltNow + wedgeTiltStep;
                    
                elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
                    wedgeTiltNow = wedgeTiltNow - 4 * wedgeTiltStep;
                    
                elseif keyCode(KbName('6')) || keyCode(KbName('6^'))
                    wedgeTiltNow = wedgeTiltNow + 4 * wedgeTiltStep;
                    
                elseif keyCode(KbName('Space'))
                    respToBeMade = false;
                    
                    %                 WaitSecs(0.5);
                end
                
                %             data.wedgeTiltEachRes(block,trial) = wedgeTiltNow;
                %             KbStrokeWait;
            end
            
            prekeyIsDown = keyIsDown;
            
            Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]); % fixation
            Screen('Flip',wptr);
            
            if flashPresentFlag
                WaitSecs((1/framerate) * flashRepresentFrame);
                %             WaitSecs(1);
            end
            %         vbl = Screen('Flip', window, flashRepresentFrame);
            %       vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            %         if debugFlag && flashRepresentFrame == 'y'
            %             framesSinceLastWait = Screen('WaitBlanking', wptr, flashRepresentFrame);
            %         end
            
            if debug== 'y' && flashPresentFlag
                KbWait;
                %              KbPressWait(1);
            end
            
            
            
            %        framesSinceLastWait = Screen('WaitBlanking', wptr,60);
            
            %         [keyIsDowna,secs,keyCode] = KbCheck(-1);
            %         if keyIsDowna && ~prekeyIsDowna
            %             if keyCode(KbName('s'))
            %                 frameFlag = 1;
            %             end
            %             if frameFlag == 1
            %                 KbWait;
            %             end
            %         end
            %         prekeyIsDowna = keyIsDowna;
        end
        data.wedgeTiltEachBlock(block,trial) = wedgeTiltNow;
        WaitSecs (0.5);
        
        %     debug
        %     display(GetSecs - ScanOnset);
    end
end

display(GetSecs - ScanOnset);

% end
% eventseq;
% response;
%
% se = size(eventseq);
% sr = size(response);
% corr = 0;
% z1 = 1;
% numcorr = [];
% for z2 = 1:se(2);
%     z3 = 1;
%     internumcorr{1} = [0;0];
%     if  z2==se(2)
%         eventseq(2,z2+1) = 300;
%     end
%     for z4 = 1:sr(2);
%         if response(2,z4) < eventseq(2,z2+1) && response(2,z4) > eventseq(2,z2)
%             internumcorr{z3} = response(:,z4);
%             z3 = z3+1;
%         end
%     end
%     if  internumcorr{1}(1) == eventseq(1,z2)
%         corr = corr + 1;
%         numcorr{z1} = internumcorr{1};
%         z1 = z1+1;
%     end
% end
%
% rcorr = corr/(se(2));
% VF_key(1)

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


time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'data','back');

tiltRightIndex = find( data.flashTiltDirection == 1 );
tiltLeftIndex = find( data.flashTiltDirection == 2 );


plot(1:size(tiltRightIndex,1),data.wedgeTiltEachBlock(tiltRightIndex),'r');
hold on;
plot(1:size(tiltLeftIndex,1),abs(data.wedgeTiltEachBlock(tiltLeftIndex)),'b');
legend({'tilt right','tilt left'},'FontSize',14);
xlim([1 6]);
ylim([0 15]);



sca;
