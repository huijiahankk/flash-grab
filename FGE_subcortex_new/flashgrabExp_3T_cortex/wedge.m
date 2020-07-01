%% 
% time=32*8+4=260, TR=2s, 130TR, 130 measurements
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
BackColor=[64,64,64];
theta=10;
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
mask(:,:,1) = (m.^2+n.^2>=R^2)*BackColor(1);
mask(:,:,2) = (m.^2+n.^2>=R^2)*BackColor(2);
mask(:,:,3) = (m.^2+n.^2>=R^2)*BackColor(3);

checkerboard=MakeCheckerboard(R,R,25,10);
cbColor1(:,:,1)=(checkerboard+1)/2*(1)*255+mask(:,:,1);
cbColor1(:,:,2)=(checkerboard+1)/2*(1)*255+mask(:,:,2);
cbColor1(:,:,3)=(checkerboard+1)/2*(1)*255+mask(:,:,3);

cbColor2(:,:,1)=(checkerboard-1)/2*(-1)*255+mask(:,:,1);
cbColor2(:,:,2)=(checkerboard-1)/2*(-1)*255+mask(:,:,2);
cbColor2(:,:,3)=(checkerboard-1)/2*(-1)*255+mask(:,:,3);
% cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

cbColorMask1 = Screen('MakeTexture', wptr,cbColor1);
cbColorMask2 = Screen('MakeTexture', wptr,cbColor2);

% maskTex = Screen('MakeTexture', wptr,mask);
Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]); 
Screen('Flip',wptr);

%% scans

% paremeters
tf=Screen('GetFlipInterval', wptr); % time of flip interval
% T = 64; 
T = 48

s1=0;
k=0;
sp = 360;

frame = T / tf; % all frames
fa = sp/(frame); % deg per frame

randnum = 500;
frequency=5;
Duration=60/frequency;

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

while GetSecs-BlockOnset1< T*6

    BlockOnset2=GetSecs;
    while GetSecs-BlockOnset2<T
        k=k+1;
        if mod(k,6)==0
            weigh = -1*weigh;
        end
%         
%         cbColor1(:,:,1)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,1);
%         cbColor1(:,:,2)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,2);
%         cbColor1(:,:,3)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,3);

    %     cbColor2(:,:,1)=(checkerboard-1)/2*(-1)*255+mask(:,:,1);
    %     cbColor2(:,:,2)=(checkerboard-1)/2*(-1)*255+mask(:,:,2);
    %     cbColor2(:,:,3)=(checkerboard-1)/2*(-1)*255+mask(:,:,3);
        % cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

%         cbColorMask1 = Screen('MakeTexture', wptr,cbColor1);
    %     cbColorMask2 = Screen('MakeTexture', wptr,cbColor2);
        if weigh == 1
            Screen('DrawTexture',wptr,cbColorMask2,...
                Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y))
        elseif weigh == -1
            Screen('DrawTexture',wptr,cbColorMask1,...
                Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,y))
        end
        
        if s1 >= sp
            s1 = 0;
        end
        
        s1=s1+fa;
        Screen('FillArc',wptr,BackColor,[x-2*R,y-2*R,x+2*R,y+2*R],theta+s1,360-2*theta);
        
        i = randperm(randnum);
        if  i(1)==1
            Screen('FillOval',wptr,[255,0,0],[x-6,y-6,x+6,y+6]);
        elseif i(1)>1
            Screen('FillOval',wptr,[0,0,0],[x-5,y-5,x+5,y+5]);
        end
        
        Screen('Flip',wptr);

        KbName('UnifyKeyNames');
        [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
        if keyIsDown
           if keyCode(KbName('ESCAPE'))
              QuitFlag=1;
              sca;
              break;
           end
        end
    end
    display(GetSecs - ScanOnset);
    
end

sca;