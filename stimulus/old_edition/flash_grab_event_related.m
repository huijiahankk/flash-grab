% generate a flash-grab checkerboard event-related for testing whether SC
% response to the illusion or physical position
% Jiahan Hui 2020.6.4

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
tic;

% sbjname = input('Please input the subject''s name\n','s');
% BlockNum = input('Please input the Block No.\n','s');
% sbjname = input('>>>Please input the subject''s name:   ','s');
sbjname = 'k';
debug = input('>>>Debug? (y/n):','s');
expmark = input('>>>Which experiment? (1/2):');
% 1 background tilt，flash vertical  2 flash/background vertical  
% flash represent for 3 frames
flashRepresentFrame = input('>>>flash represent frames? (1/3):');

% 1 background tilt，flash vertical  2 flash/background vertical 
if expmark == 1  && flashRepresentFrame == 1
    savePath = '../data/illusionSize/backTilt_FlashVer/1frame';
elseif expmark == 1 && flashRepresentFrame == 3
    savePath = '../data/illusionSize/backTilt_FlashVer/3frame';
elseif expmark == 2 && flashRepresentFrame == 1 
    savePath = '../data/illusionSize/backFlash_Ver/1frame';
elseif expmark == 2
    savePath = '../data/illusionSize/backFlash_Ver/3frame';
end
% data.sectorRadiusIn = input('>>>> CheckerBoard wedge Inner Radius(degree) ? (e.g.: 0/300):  ');
data.sectorRadiusIn = 200;
%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------

addpath ../function;
addpath ../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
screenNumber = max(screens);
backcolor = 120;
[wptr,rect]=Screen('OpenWindow',screenNumber,backcolor,[0 0 1024 768]); %set window to ,[0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);
centerMovePix = 0;

%% set parameters
fixcolor = 0;
framerate = FrameRate(wptr);
% % Query the frame duration
% ifi = Screen('GetFlipInterval', window);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');

%----------------------------------------------------------------------
%                      background sector setup
%----------------------------------------------------------------------
sectorRadius_mov = xCenter + centerMovePix;
contrastratio = 0.12;
sector1_color = backcolor + backcolor * contrastratio;
sector2_color = backcolor;
contrast = (sector1_color - sector2_color)/2;
sectorNumber = 6;
sector_angle = 360/sectorNumber;
[m2 n2] = meshgrid(- sectorRadius_mov : sectorRadius_mov, - sectorRadius_mov : sectorRadius_mov); % coordinate of sector
mask = (m2.^2+n2.^2 <= (sectorRadius_mov).^2);

sector(:,:,1) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,4) = mask * 255;

sectorTex = Screen('MakeTexture', wptr, sector);

sectorRect = Screen('Rect',sectorTex);

sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);


%----------------------------------------------------------------------
%                      initialize on Screen Window
%----------------------------------------------------------------------
fixsize = 10/2;
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
% Screen('DrawTexture',wptr,crossTex,...
%     Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
Screen('Flip',wptr);

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

% 1 background tilt，flash vertical  2 flash/background vertical  
if expmark == 1
    % checkerboard tilt angle
    tiltAngle = sectorArcAngle/2;
elseif expmark == 2
    tiltAngle = 0;
end
% data.sectorRadiusIn = 300;
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

wedgeStripe_width = 25;
wedgeSector_width = 5;

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

%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% VisualField = [1 1 1 1];

blockNumber = 10;
% trialNumber = 3;

back.AngleRange = 120;
back.ReverseAngle = back.AngleRange/2; % duration frame of checkerboard
back.CurrentAngle = 0;  % back.ReverseAngle + tiltAngle + 0.5;
back.SpinSpeed = 4; % degree/frame
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
back.FlagSpinDirecA = 0;
back.FlagSpinDirecB = 0;


wedgeTilt = 0;



% responseKey = 1;



TR = 2; % second
% the sector first rotate rightward 90 degree and then leftward 180 degree
% rightward 180 degree and so on
back.ReversalSec = back.ReverseAngle/(back.SpinSpeed * framerate);% how many second does the background rotate rightward and then leftward cost


%----------------------------------------------------------------------
%  here we load optseq2 par and construct the trialData mat, optseq parameters
%----------------------------------------------------------------------

% prompt = {'Enter matrix size:','Enter colormap name:'};
% dlg_title = 'Input for peaks function';
% num_lines= 1;
% def     = {'20','hsv'};
% answer  = inputdlg(prompt,dlg_title,num_lines,def);

% answer  = inputdlg('Subject name');
% % run_no = '1';
% fileName = answer{1};


% [timepoint,event.TypeNumericIdMat,event.InterTimeMat,~,~] = read_optseq2_data(['../optseq2/' fileName '/exp1-00'  run_no  '.par']);


% [timepoint,stim_type,SOA,~,~] = read_optseq2_data(['optimal_seq/' fileName '/par-00' run_no '.par']);
% trialData(:,5) = SOA(2:2:end)+2;
% trialData(:,4) = 24;
% trialData(:,2) = 0;
% if isstim_in_upper
%     stim_type_map_startangle = [5 5 5 1 1 1];
% else
%     stim_type_map_startangle = [7 7 7 11 11 11];
% end
% stim_type_map_hit_radius = [0 -0.05 10 0 0.05 10];
% trialData(:,1) = stim_type_map_startangle(stim_type(1:2:end));
% trialData(:,3) = stim_type_map_hit_radius(stim_type(1:2:end));
event.TypeNumericIdAll = []; %  RespMat column 1
event.InterTimeAll = [];     %  RespMat column 2
flashTimePointAll = [];       %  RespMat column 3

event.TypeNumericIdMat = [0 1 2];  % 0 no sector checkerboard(scb) 1 checkerboard tilt left   2 checkerboard tilt right
event.InterTimeMat = [2 4 6];
% testDuration = 10;
back.ReversalTimesMat = [event.InterTimeMat]/back.ReversalSec;

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
    
    debugFlag = 0;
    back.ReversalTime = 0;
    event.TypeNumericId = event.TypeNumericIdMat(mod(block,3) + 1);
    %     event.InterRound = event.InterRoundMat(mod(block,3) + 1);
    event.InterTime = event.InterTimeMat(mod(block,3) + 1);
    %     ShowUpTimes = ShowUpTimesMat(mod(block,3) + 1);
    back.ReversalTimes = back.ReversalTimesMat(mod(block,3) + 1);
    respToBeMade = true;
    %     while respToBeMade
    
    prekeyIsDown = 0;
    % make sure during each block the checkerboard only flash once
    tiltRightFlag = 0;
    tiltLeftFlag = 0;
    %     frameCounter = 0;
    flashFreezeFrameFlag = 0;
    
    %----------------------------------------------------------------------
    %                      background rotate
    %----------------------------------------------------------------------
    
    
    % each block lasting seconds 10s
    while GetSecs - BlockOnset < event.InterTime  && back.ReversalTime <= back.ReversalTimes  %&& respToBeMade
        
        
        %         frameCounter = frameCounter + 1;
        %         % Time we want to wait before flash the checkerboard
        %         checkFlipTimeSecs = 2;
        %         checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
        %         frameCounter = 0;
        %
        %         if frameCounter == checkFlipTimeFrames
        %             textureCue = fliplr(textureCue);
        %             frameCounter = 0;
        %         end
        
        % background first rotate clockwise until to the reverse angle
        % 0.5 because  tiltAngle is
        if back.CurrentAngle > back.ReverseAngle  + wedgeTilt - tiltAngle %  + adjustSectorArcAngle
            back.SpinDirec = - 1;
            back.FlagSpinDirecA = back.SpinDirec;
            back.ReversalTime = back.ReversalTime + 1;
            % tilt right
        elseif back.CurrentAngle < - back.ReverseAngle - wedgeTilt  + tiltAngle % - adjustSectorArcAngle
            back.SpinDirec = 1;
            back.FlagSpinDirecB = back.SpinDirec;
            back.ReversalTime = back.ReversalTime + 1;
        end
        
        back.CurrentAngle = back.CurrentAngle + back.SpinDirec * back.SpinSpeed;
        %    draw background each frame
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle); %  + backGroundRota
        
        %         if GetSecs - BlockOnset >= event.InterTime  && respToBeMade && GetSecs - BlockOnset < event.InterTime
        
        
        %         1 checkerboard tilt right
        if event.TypeNumericId == 2 && tiltRightFlag == 0
            % checkerboard flash at the reverse time()
            % back.FlagSpinDirecA == - 1  flash tilt right
            if back.FlagSpinDirecA == - 1 %  && back.RotateTimes == ShowUpTimes
                Screen('DrawTexture',wptr,cbColorMask,cbColorMask1Rect,cbColorMask1DestinationRect,wedgeTilt);
                tiltRightFlag = 1;
                flashTimePoint = GetSecs - ScanOnset;
                display(GetSecs - ScanOnset);
                debugFlag = 1;
                flashFreezeFrameFlag = flashFreezeFrameFlag + 1;
                
            end
            
            %         1 checkerboard tilt left
        elseif event.TypeNumericId == 1 && tiltLeftFlag == 0
            % back.FlagSpinDirecB == 1  flash tilt left
            if back.FlagSpinDirecB == 1 %  && back.RotateTimes == ShowUpTimes
                Screen('DrawTexture',wptr,cbColorMask,cbColorMask1Rect,cbColorMask1DestinationRect,-wedgeTilt);
                tiltLeftFlag = 1;
                flashTimePoint = GetSecs - ScanOnset;
                display(GetSecs - ScanOnset);
                debugFlag = 1;
                flashFreezeFrameFlag = flashFreezeFrameFlag + 1;
                
            end
            %             end
            
        elseif event.TypeNumericId == 0
            flashTimePoint = 0;
        else
            debugFlag = 0;
        end
        %         end
        back.FlagSpinDirecA = 0;
        back.FlagSpinDirecB = 0;
        
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        
        [keyIsDown,secs,keyCode] = KbCheck(-1);
        if keyIsDown && ~prekeyIsDown
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                % the bar was on the left of the gabor
            elseif keyCode(KbName('LeftArrow'))
                response = 1;
                %                 response(2,responseKey) = GetSecs - BlockOnset;
                %                 responseKey = responseKey + 1;
                
            elseif keyCode(KbName('RightArrow'))
                response = 2;
            elseif keyCode(KbName('Space'))
                respToBeMade = false;
                %                 Wait(0.5);
            end
            
            
        end
        
        prekeyIsDown = keyIsDown;
        

        
        
        Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]); % fixation       
        Screen('Flip',wptr);
        
        if debugFlag && flashRepresentFrame == 'y'
        framesSinceLastWait = Screen('WaitBlanking', wptr, 3);
        end
        

        if debug== 'y' && debugFlag
            KbWait;
        end
        
        
       
            
        % seprate each illusion test for 0.5 sec
        %         if GetSecs - BlockOnset >= testDuration
        %             respToBeMade = false;
        %             WaitSecs (0.5);
    end
    
    
    
    %     WaitSecs(1);
    
    event.InterTimeAll = [event.InterTimeAll;event.InterTime];
    event.TypeNumericIdAll = [event.TypeNumericIdAll;event.TypeNumericId];
    flashTimePointAll = [flashTimePointAll; flashTimePoint];
end
%     display(GetSecs - BlockOnset);
%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------
time = clock;
RespMat = [event.TypeNumericIdAll  event.InterTimeAll  flashTimePointAll];


fileName = [savePath  sbjname '-' num2str(time(1)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5)) '.mat'];
% save(fileName,'RespMat','meanSubIlluDegree','time','all','gauss','cueVerDisDegree','gabor','viewingDistance','trialNumber','blockNumber');
save(fileName,'RespMat');
% end



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
%% save data
% sbjname = 'zhouhao';
% dir = sprintf('%s/',sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end
% time = clock;
% filename = sprintf('%s_record_%02g_%02g_%02g_%02g',BlockNum,time(2),time(3),time(4),time(5));
% filename2 = [dir,filename];
% save(filename2,'VF_key');
% %


%----------------------------------------------------------------------
%                       clear screen
%----------------------------------------------------------------------

ShowCursor;
Screen('close all');
sca;

fprintf(1,'\n\nThis part of the experiment took %.0f min.',(toc)/60);
fprintf(1,'\n\nOK!\n');