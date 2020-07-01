clear all;
%% set globle parameters
try
BackColor=[64,64,64];
theta=10;
weigh=1;
%% initialize screen
Screenid=max(Screen('Screens'));
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

small_fr = 0.3;
small_R = floor(small_fr*R);
[m n] =  meshgrid(-small_R:small_R,-small_R:small_R);
mask = zeros(size(m,1),size(m,2),3);
mask(:,:,1) = (m.^2+n.^2>=small_R^2)*BackColor(1);
mask(:,:,2) = (m.^2+n.^2>=small_R^2)*BackColor(2);
mask(:,:,3) = (m.^2+n.^2>=small_R^2)*BackColor(3);

checkerboard=MakeCheckerboard(small_R,small_R,25,10);
cbColor3(:,:,1)=(checkerboard+1)/2*(1)*255+mask(:,:,1);
cbColor3(:,:,2)=(checkerboard+1)/2*(1)*255+mask(:,:,2);
cbColor3(:,:,3)=(checkerboard+1)/2*(1)*255+mask(:,:,3);

cbColor4(:,:,1)=(checkerboard-1)/2*(-1)*255+mask(:,:,1);
cbColor4(:,:,2)=(checkerboard-1)/2*(-1)*255+mask(:,:,2);
cbColor4(:,:,3)=(checkerboard-1)/2*(-1)*255+mask(:,:,3);

cbColorMask3 = Screen('MakeTexture', wptr,cbColor3);
cbColorMask4 = Screen('MakeTexture', wptr,cbColor4);


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

while GetSecs-BlockOnset1<8*8
    
    BlockOnset2=GetSecs;
    while GetSecs-BlockOnset2<8
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
%         if weigh == 1
%             Screen('DrawTexture',wptr,cbColorMask2,...
%                 Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y))
%         elseif weigh == -1
%             Screen('DrawTexture',wptr,cbColorMask1,...
%                 Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,y))
%         end
        
        s1= floor(k/fa);
        if mod(s1,2) == 0
            Screen('Rect',cbColorMask2);
            CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y);
            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask2,...
                Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y));
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask1,...
                Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,y));
            end
            out_R = (1-small_fr)*R;
            Screen('FillArc',wptr,BackColor,[x-out_R,y-out_R,x+out_R,y+out_R],0,360);
            Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]);
        else
            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask3,...
                Screen('Rect',cbColorMask3),CenterRectOnPoint(Screen('Rect',cbColorMask3),x,y));
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask4,...
                Screen('Rect',cbColorMask4),CenterRectOnPoint(Screen('Rect',cbColorMask4),x,y));
            end
            Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]);
        end

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
    Screen('CloseAll');
end
