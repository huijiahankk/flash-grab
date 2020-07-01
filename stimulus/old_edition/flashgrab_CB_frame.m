
%----------------------------------------------------------------------
%    2020.1.2  We adapt this script to run a 7T experiment
%----------------------------------------------------------------------
% generate a flash-grab checkerboard event-related for testing whether SC
% response to the pereceived or physical position 
% Jiahan Hui
% 2020.1.2


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


% sbjname = input('Please input the subject''s name\n','s');
% BlockNum = input('Please input the Block No.\n','s');

%----------------------------------------------------------------------
%                      set up Psychtoolbox and skip  sync
%----------------------------------------------------------------------
clear all;
close all;
Screen('Preference', 'SkipSyncTests', 1);
addpath ../function;
addpath ../FGE_subcortex_new/flashgrabExp_7T_layer;
commandwindow;
screens = Screen('Screens');
screenNumber = max(screens);
backcolor = 120;
[wptr,rect]=Screen('OpenWindow',screenNumber,backcolor,[0 0 1024 768]); %set window to ,[0 0 1024 768] for single monitor display
ScreenRect = Screen('Rect',wptr);
[xCenter,yCenter] = WindowCenter(wptr);
centerMovePix = 0;
sectorRadius_mov = xCenter + centerMovePix;
framerate = FrameRate(wptr);

%----------------------------------------------------------------------
%                      initialize on Screen Window
%----------------------------------------------------------------------
fixsize = 10/2;
fixcolor = 0;
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
% Screen('DrawTexture',wptr,crossTex,...
%     Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
Screen('Flip',wptr);

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
spaceKey = KbName('space');

%----------------------------------------------------------------------
%                      background sector setup
%----------------------------------------------------------------------
contrastratio = 0.12;
sector1_color = backcolor + backcolor*contrastratio;
sector2_color = backcolor;
contrast = (sector1_color - sector2_color)/2;
sectorNumber = 8;
sector_angle = 360/sectorNumber;
[m2 n2] = meshgrid(- sectorRadius_mov : sectorRadius_mov, - sectorRadius_mov : sectorRadius_mov); % coordinate of sector
mask = (m2.^2+n2.^2 <= (sectorRadius_mov).^2);

sector(:,:,1) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(sectorRadius_mov,sectorRadius_mov,sector_angle).*mask-1)*contrast+backcolor;
% make part of the sector transparency
sector(:,:,4) = mask * 255;
sectorTex = Screen('MakeTexture', wptr, sector);

sectorRect = Screen('Rect',sectorTex);

sectorDestinationRect = CenterRectOnPoint(sectorRect,xCenter,yCenter-centerMovePix);



%----------------------------------------------------------------------
%%%                     generate  sector alpha channel matrix
%----------------------------------------------------------------------

% alphaSectorRect = zeros(xCenter,xCenter);
% sectorStartAngle = 170; % wedgeAngleTheta+0;
x = linspace(-yCenter,yCenter,yCenter * 2 + 1);
y = fliplr(linspace(-yCenter,yCenter,yCenter * 2 + 1));
[X,Y] = meshgrid(x,y);
% Parameters for sector
sectorArcAngle = 10; % abs(sectorStartAngle * 2);
sectorRadiusIn = 0;
sectorRadiusOut = xCenter;
% Coordinates to polarcoordinates
[phi, rho] = cart2pol(X,Y);
phi = rad2deg(phi);
% phi(phi > 0) = - phi(phi > 0);
% Generate mask
% alphaSectorMask = 255 * (rho > sectorRadiusIn & rho < sectorRadiusOut & phi > (90 - sectorArcAngle/2) & phi< (90 + sectorArcAngle/2));
alphaSectorMask = 255 * (rho > sectorRadiusIn & rho < sectorRadiusOut & phi > (- 90 - sectorArcAngle/2) & phi< (-90 + sectorArcAngle/2));
% size(alphaSectorMask)
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
r = 250;
fc = 50;

% [xCenter, yCenter]= RectCenter(ScreenRect);
[wedgeMat_m wedgeMat_n] = meshgrid(-yCenter:yCenter,-yCenter:yCenter);
mask_wedge(:,:,1) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(1);
mask_wedge(:,:,2) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(2);
mask_wedge(:,:,3) = (wedgeMat_m.^2 + wedgeMat_n.^2 >= yCenter^2) * wedgeBackColor(3);


checkerboard = MakeCheckerboard(yCenter,yCenter,wedgeStripe_width,wedgeSector_width);
cbColor1(:,:,1) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,1);
cbColor1(:,:,2) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,2);
cbColor1(:,:,3) = (checkerboard+1)/2 * (1) * 255 + mask_wedge(:,:,3);
cbColor1(:,:,4) = alphaSectorMask;
% cbColor2(:,:,1) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,1);
% cbColor2(:,:,2) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,2);
% cbColor2(:,:,3) = (checkerboard-1)/2 * (-1) * 255 + mask_wedge(:,:,3);
% cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

cbColorMask1 = Screen('MakeTexture', wptr,cbColor1);
% cbColorMask2 = Screen('MakeTexture', wptr,cbColor2);

% sectorcenter_down = [xCenter-2*ScreenXlengthHalf,2*yCenter-r+fc/2-2*ScreenXlengthHalf,xCenter+2*ScreenXlengthHalf,2*yCenter-r+fc/2+2*ScreenXlengthHalf];
% wedgeRect = [xCenter - yCenter,yCenter - xCenter, xCenter + yCenter,xCenter * 2];
% Screen('DrawTexture',wptr,cbColorMask2,...
%                     Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y));

cbColorMask1Rect = Screen('Rect',cbColorMask1);
cbColorMask1DestinationRect = CenterRectOnPoint(cbColorMask1Rect,xCenter,yCenter);
% cbColorMask2Rect = Screen('Rect',cbColorMask2);
% cbColorMask2DestinationRect = CenterRectOnPoint(cbColorMask2Rect,xCenter,yCenter);


%----------------------------------------------------------------------
%%%                     parameters of rotate background
%----------------------------------------------------------------------
blockNumber = 10;
% backGroundRota = 90;
back.CurrentAngle = 0;
back.AngleRange = 180;% back ground rotate angle
back.reverseAngle = back.AngleRange/2;
back.SpinSpeed = 4; % degree/frame
back.SpinDirec = 1; % 1 means clockwise     -1 means counter-clockwise
responseKey = 1;
% flashAngle = 0;  % initial flash frame
% stimulusSec = 3;

%----------------------------------------------------------------------
%                       optseq parameters
%----------------------------------------------------------------------
% stimulusOnset;
TR = 2; % second
eventTypeNumericIdMat = [0 1 2];  % 0 no sector checkerboard(scb) 1 back ground rotate closewise scb flash   2 back rotate counter closewise scb flash
% eventDuration = [2 4];  % second
eventTypeLabelMat = [5*TR 6*TR 7.5*TR];% second flash presented


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
WaitSecs(0); % dummy scan
ScanOnset = GetSecs;
for block = 1:blockNumber
    BlockOnset = GetSecs;
    
    %     eventTypeNumericId = exp1-001(3);
    eventTypeNumericId = eventTypeNumericIdMat(mod(block,3) + 1);
%     eventTypeLabel = eventTypeNumericIdMat(mod(block,3) + 1);
    eventTypeLabel = eventTypeLabelMat(mod(block,3) + 1);
    
%     while GetSecs - ScanOnset < eventTypeLabel 
      
    
    for frame = 1: (eventTypeLabel * framerate)
        if  back.CurrentAngle <= - back.reverseAngle
            back.SpinDirec = 1;
        end
        if  back.CurrentAngle > back.reverseAngle
            back.SpinDirec = -1;
        end
        Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
        back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
        
        if frame == ceil((eventTypeLabel * framerate) - 1)
            
%             switch  eventTypeNumericId
%                 
%                 % no flash
%                 case 0
%                     if  back.CurrentAngle <= - back.reverseAngle
%                         back.SpinDirec = 1;
%                     end
%                     if  back.CurrentAngle > back.reverseAngle
%                         back.SpinDirec = -1;
%                     end
%                     Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
%                     back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
%                     
%                     % back ground rotate clockwise
%                 case 1
%                     Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
%                     back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
%                     if  back.CurrentAngle <= - back.reverseAngle
%                         %                 Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
%                         back.SpinDirec = 1;
%                     end
%                     if  back.CurrentAngle >= back.reverseAngle
%                         back.SpinDirec = - 1;
%                         Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
%                     end
%                     
%                     % back ground rotate counter-clockwise
%                 case 2
%                     Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
%                     back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
%                     if  back.CurrentAngle <= - back.reverseAngle
%                         Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
%                         back.SpinDirec = 1;
%                     end
%                     if  back.CurrentAngle >= back.reverseAngle
%                         back.SpinDirec = - 1;
%                     end
%                     
%             end
            switch  eventTypeNumericId
                
                % no flash
                case 0
%                     if  back.CurrentAngle <= - back.reverseAngle
%                         back.SpinDirec = 1;
%                     end
%                     if  back.CurrentAngle > back.reverseAngle
%                         back.SpinDirec = -1;
%                     end
                    Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
                    back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
                    
                    % back ground rotate clockwise
                case 1
                    Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
                    back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
                    if  back.CurrentAngle <= - back.reverseAngle
                        %                 Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
                        back.SpinDirec = 1;
                    end
                    if  back.CurrentAngle >= back.reverseAngle
                        back.SpinDirec = - 1;
                        Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
                    end
                    
                    % back ground rotate counter-clockwise
                case 2
                    Screen('DrawTexture',wptr,sectorTex,sectorRect,sectorDestinationRect,back.CurrentAngle);
                    back.CurrentAngle = back.CurrentAngle + back.SpinSpeed * back.SpinDirec;
                    if  back.CurrentAngle <= - back.reverseAngle
                        Screen('DrawTexture',wptr,cbColorMask1,cbColorMask1Rect,cbColorMask1DestinationRect);
                        back.SpinDirec = 1;
                    end
                    if  back.CurrentAngle >= back.reverseAngle
                        back.SpinDirec = - 1;
                    end
                    
            end




        end
        
        Screen('FillOval',wptr,fixcolor,[xCenter-fixsize,yCenter-fixsize-centerMovePix,xCenter+fixsize,yCenter+fixsize-centerMovePix]);
        Screen('Flip',wptr);
        
        %----------------------------------------------------------------------
        %                      Response record
        %----------------------------------------------------------------------
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
            % the bar was on the left of the gabor
        elseif keyCode(leftKey)
            response(1,responseKey) = 1;
            response(2,responseKey) = GetSecs - ScanOnset;
            responseKey = responseKey + 1;
        end
    end
    stimulusOnset = GetSecs - ScanOnset;
    %     display(stimulusOnset);
end
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
% %
% time = clock;
% filename = sprintf('%s_record_%02g_%02g_%02g_%02g',BlockNum,time(2),time(3),time(4),time(5));
% filename2 = [dir,filename];
% save(filename2,'VF_key');
sca;
