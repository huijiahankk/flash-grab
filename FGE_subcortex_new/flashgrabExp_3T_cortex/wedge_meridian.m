 12sclear all;
%% set globle parameters
try
BackColor=[64,64,64];
theta=10;
weigh=1;
%% initialize screen
Screenid=0;
Screen('Preference', 'SkipSyncTests', 1);
[wptr,rect]=Screen('Openwindow',Screenid,BackColor);
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
va=22.5;
s1=0;
k=0;
fa=1/tf*4;

randnum=100;
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

while GetSecs-BlockOnset1<16*16
    
    BlockOnset2=GetSecs;
    while GetSecs-BlockOnset2<16
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
        
        s1=0+floor(k/fa)*90;
        Screen('FillArc',wptr,BackColor,[x-2*R,y-2*R,x+2*R,y+2*R],s1+theta,360-2*theta);
        Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]);

%         i=randperm(randnum);
%         if i(1)==1
%             Screen('FillOval',wptr,255,[x-5,y-5,x+5,y+5]);
%         end
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
catch ME
end