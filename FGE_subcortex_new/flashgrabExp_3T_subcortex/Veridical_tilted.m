% time=(12+12+12+12)*6+12=300,TR=2s,152TR
%% fMRI parameter (6 scans 6 blocks)
% Bandawidth=1200(<1000);
% TE=30;
% Slice=30;
% thickness=2mm;
% patial_fourier_factor=7/8;
% FOV=128*128;
% Dim=64*64;
% grappa=off;

%% set parameters
clear all;close all;
rota = 180;
sp=120; % sweeping angle
v= 3; % sweeping speed
ds1=1;
s1=0;

fixcolor = [0,0,0];
backcolor=124;
contrastratio = 0.1;
sector1_color = backcolor + backcolor*contrastratio;
sector2_color = backcolor;
contrast = (sector1_color-sector2_color)/2;
sector_angle = 60; 
ps=4;
%%  initialize on Screen Window
% Screenid=max(Screen('Screens'));  
Screenid = 1;
[wptr,rect]=Screen('OpenWindow',Screenid,backcolor);
%set window to ,[0 0 1024 768] for single monitor display

% R=300;
R = rect(4)/2;
mov = R/2+R/4;
R_mov = R+mov;
[x,y]=WindowCenter(wptr);
tf=Screen('GetFlipInterval', wptr); % time of flip interval
t=20; %bar_width
fixsize = 10/2;

% stimulus size
% screensize = [ , ]; % unit: mm.
% resolusion = [rect(3) ,rect(4)];
% ppm = screensize/resolution % pixel per mm. In principle, ppm(1) == ppm(2).

% distance = 60*10; % unit: mm.
% fovea = 10 % unit: °.
% rLength = ppm(1) distance * atan(fovea);

SF = (1/40)*2; % spatial frequency
[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of bar
barMask = (m.^2+n.^2 >= (R/4).^2) & (m.^2+n.^2 <= (R_mov).^2) & ((m-t/2)<=0)&((m+t/2)>=0) & (n<0);
checkerboard=MakeCheckerboard(R_mov,R_mov,1/(SF/2),180);
bar1(:,:,1)=(checkerboard+1)/2*255;
bar1(:,:,2)=(checkerboard+1)/2*255;
bar1(:,:,3)=(checkerboard+1)/2*255;
bar1(:,:,4) = 255*barMask;

bar2(:,:,1)=(checkerboard-1)/2*(-1)*255;
bar2(:,:,2)=(checkerboard-1)/2*(-1)*255;
bar2(:,:,3)=(checkerboard-1)/2*(-1)*255;
bar2(:,:,4)=255*barMask;

bar1Tex = Screen('MakeTexture', wptr, bar1);
bar2Tex = Screen('MakeTexture', wptr, bar2);

[m2 n2] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of sector
mask2 = (m2.^2+n2.^2 <= (R_mov).^2);
% mask2 = 1;
sector(:,:,1) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,4) = mask2*255;
sectorTex = Screen('MakeTexture', wptr, sector);

fixdot(:,:,1) = (m.^2+n.^2 < fixsize.^2) * 0;
fixdot(:,:,2) = (m.^2+n.^2 < fixsize.^2) * 0;
fixdot(:,:,3) = (m.^2+n.^2 < fixsize.^2) * 0;
fixdot(:,:,4) =  (m.^2+n.^2 < fixsize.^2) * 255;
dotTex = Screen('MakeTexture', wptr, fixdot);

Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawTexture',wptr,dotTex,...
    Screen('Rect',dotTex),CenterRectOnPoint(Screen('Rect',dotTex),x,y-mov),[]);
Screen('Flip',wptr);
%% Scans % scan time = 4+6+(12+12+12+12)*5=316,TR=2s,158TR
VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2]; % 1: perceive right, 2: fixation, 3: perceive left
% random order
% VisualField = [1 3 1 3 1 3];
% VisualField = [3 3 3 3 3 3];
% a = size(VisualField,2);
% VisualField(randperm(a)) = VisualField(1:1:a);
while 1
    KbName('UnifyKeyNames');
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
    if keyIsDown
        if keyCode(KbName('s'))
            break,
        elseif keyCode(KbName('ESCAPE'))
            QuitFlag=1;
            sca;
            break,
        end
    end
end
%% Start Timing
WaitSecs(4); % dummy scan
ScanOnset = GetSecs;
for blocks=1:size(VisualField,2)
    BlockOnset=GetSecs;
    while GetSecs-BlockOnset < 12
        if s1>=sp
            ds1=(-1);
        elseif s1<=0
            ds1=1;
        end
        %% stimulus
%         Screen('DrawTexture',wptr,sectorTex,...
%             Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
        
%         if ((s1 ==sp/4)&& ds1==(-1) && (VisualField(blocks)==1)) || ((s1==(sp/4))&&ds1==1&&(VisualField(blocks)==3))
        if ((s1<=0) && (VisualField(blocks)==1))
            whichbar = randperm(10);
            if whichbar(1) == 1
                    %% bar 1
                    whichbar(1)
%                     Screen('DrawTexture',wptr,sectorTex,...
%                         Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota+15, []);
                    Screen('DrawTexture',wptr,bar2Tex,...
                        Screen('Rect',bar2Tex),CenterRectOnPoint(Screen('Rect',bar2Tex),x,y-mov),0+rota+15);
            else
                    %% bar 2
%                     Screen('DrawTexture',wptr,sectorTex,...
%                         Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota+15, []);
                    Screen('DrawTexture',wptr,bar1Tex,...
                        Screen('Rect',bar1Tex),CenterRectOnPoint(Screen('Rect',bar1Tex),x,y-mov),0+rota+15);
            end
%         elseif ((s1<=0) && (VisualField(blocks)==3)) || ((s1>=(sp))&&(VisualField(blocks)==1))
%             for fn = 1 : ps
%                 Screen('DrawTexture',wptr,sectorTex,...
%                     Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota, []);
%                 Screen('DrawTexture',wptr,dotTex,...
%                     Screen('Rect',dotTex),CenterRectOnPoint(Screen('Rect',dotTex),x,y-mov),[]);
%                 Screen('Flip',wptr);
%             end
        elseif ((s1>=(sp))&&(VisualField(blocks)==3)) 
            whichbar = randperm(10);
            if whichbar(1) == 1
                    %% bar 1
                    whichbar(1)
%                     Screen('DrawTexture',wptr,sectorTex,...
%                         Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota-15, []);
                    Screen('DrawTexture',wptr,bar2Tex,...
                        Screen('Rect',bar2Tex),CenterRectOnPoint(Screen('Rect',bar2Tex),x,y-mov),0+rota-15);
                end
            else
                for fn = 1 : ps
                    %% bar 2
%                     Screen('DrawTexture',wptr,sectorTex,...
%                         Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota-15, []);
                    Screen('DrawTexture',wptr,bar1Tex,...
                        Screen('Rect',bar1Tex),CenterRectOnPoint(Screen('Rect',bar1Tex),x,y-mov),0+rota-15);
                    Screen('DrawTexture',wptr,dotTex,...
                        Screen('Rect',dotTex),CenterRectOnPoint(Screen('Rect',dotTex),x,y-mov),[]);
                    Screen('Flip',wptr);
                end
            end
        end
        %% check input
        KbName('UnifyKeyNames');
        [ keyIsDown, timeSecs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                sca;
                break,
            end
        end
        %% fixation task
%         i = randperm(randnum);
%         if  i(1)==1
%             Screen('FillOval',wptr,[255,0,0],[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%         else
%             Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%         end
        %%
        s1=s1+v*ds1;
        Screen('DrawTexture',wptr,dotTex,...
            Screen('Rect',dotTex),CenterRectOnPoint(Screen('Rect',dotTex),x,y-mov),[]);
%         Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
        Screen('Flip',wptr);
    end
    display(GetSecs - ScanOnset);
end
sca;
