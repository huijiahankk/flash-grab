 %% 
% time=48*6+4=292, TR=2s, 146TR
%% fMRI parameter (6 scans 6 blocks)
%
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

%% set globle parameters
BackColor=[128,128,128];
% theta=10;
weigh=1;
%% initialize screen
% Screenid=max(Screen('Screens'));
Screenid = 0;
[wptr,rect]=Screen('Openwindow',Screenid,BackColor,[0 0 1024 768],[],[],[],1000);
% ,[0 0 1024 768]
[x, y]=RectCenter(Screen('Rect',wptr));
R=rect(4)/2;

% % [m n] = meshgrid(-R:R,-R:R);
[m n] = meshgrid(-R:R,-R:R);
mask(:,:,1) = (m.^2+n.^2<=R.^2);
mask(:,:,2) = (m.^2+n.^2<=R.^2);
mask(:,:,3) = (m.^2+n.^2<=R.^2);
mask2(:,:,1) = (m.^2+n.^2>=R.^2);
mask2(:,:,2) = (m.^2+n.^2>=R.^2);
mask2(:,:,3) = (m.^2+n.^2>=R.^2);

checkerboard=MakeCheckerboard(R,R,25,10);
cbColor1(:,:,1)=(checkerboard+1)/2*(1).*mask(:,:,1).*255+mask2(:,:,1)*BackColor(1);
cbColor1(:,:,2)=(checkerboard+1)/2*(1).*mask(:,:,2).*255+mask2(:,:,2)*BackColor(2);
cbColor1(:,:,3)=(checkerboard+1)/2*(1).*mask(:,:,3).*255+mask2(:,:,3)*BackColor(3); 

cbColor2(:,:,1)=(checkerboard-1)/2*(-1).*mask(:,:,1).*255+mask2(:,:,1)*BackColor(1);
cbColor2(:,:,2)=(checkerboard-1)/2*(-1).*mask(:,:,2).*255+mask2(:,:,2)*BackColor(2);
cbColor2(:,:,3)=(checkerboard-1)/2*(-1).*mask(:,:,3).*255+mask2(:,:,3)*BackColor(3);

cbColorMask1 = Screen('MakeTexture', wptr, cbColor1);
cbColorMask2 = Screen('MakeTexture', wptr, cbColor2);

Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]); 
Screen('Flip',wptr);
%% scans
tf=Screen('GetFlipInterval', wptr); % time of flip interval
T = 48;
ringWidth = 50;
k=0;
frame = T/tf;
fa=(R-ringWidth)/frame;
randnum = 500;
frequency=5;
Duration=60/frequency;
R1 = 0;
R2 = 0;

% triger
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

WaitSecs(4); % dummy scan
ScanOnset = GetSecs;
BlockOnset1=GetSecs;

while GetSecs-BlockOnset1<T*6
    BlockOnset2=GetSecs;
    while GetSecs-BlockOnset2<T
        k=k+1;
        if mod(k,6)==0
            weigh = -1*weigh;
        end
        
        if R2 >= R
            R1 = 0;
        end
        
        R1 = R1+fa;
        R2 = R1+ringWidth;
        %% checkboard
        if weigh == 1
            Screen('DrawTexture',wptr,cbColorMask2,...
                Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2), x, y))
        elseif weigh == -1
            Screen('DrawTexture',wptr,cbColorMask1,...
                Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1), x, y))
        end
        %% ringMask
        Screen('FrameOval',wptr,BackColor,[x-R-10,y-R-10,x+R+10,y+R+10], R-R2);
        Screen('FillOval',wptr,BackColor,[x-R1,y-R1,x+R1,y+R1]);
        %% fixation task
        i = randperm(randnum);
        if  i(1)==1
            Screen('FillOval',wptr,[255,0,0],[x-6,y-6,x+6,y+6]);
        elseif i(1)>1
            Screen('FillOval',wptr,[0,0,0],[x-5,y-5,x+5,y+5]);
        end
        %% keyboard detection
        KbName('UnifyKeyNames');
        [ keyIsDown, timeSecs, keyCode] = KbCheck(-1);
        if keyIsDown
           if keyCode(KbName('ESCAPE'))
              QuitFlag=1;
              sca;
              break;
           end
        end
        %% flip
        Screen('Flip',wptr);
    end
    display(GetSecs - ScanOnset);
end
sca;