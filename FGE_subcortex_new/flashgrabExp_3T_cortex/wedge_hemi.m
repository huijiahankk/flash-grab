clear all;
Screen('Preference', 'SkipSyncTests', 1);  

  %% set globle parameters
BackColor=[64,64,64];
theta=10;
weigh=1;

%% initialize screen
Screenid=max(Screen('Screens'));
[wptr,rect]=Screen('Openwindow',Screenid,BackColor,[0 0 1024 768]  );
% ,[0 0 1024 768]
[x, y]=RectCenter(Screen('Rect',wptr));
R=700;
r=100;
fc=10;
di=x-y;
fixation_down = [x-fc/2,2*y-r,x+fc/2,2*y-r+fc];
sectorcenter_down = [x-2*R,2*y-r+fc/2-2*R,x+2*R,2*y-r+fc/2+2*R];

fixation_left = [r-fc+di,y-fc/2,r+di,y+fc/2];
sectorcenter_left = [r-fc/2-2*R+di,y-2*R,r-fc/2+2*R+di,y+2*R];

fixation_top = [x-fc/2,r-fc,x+fc/2,r];
sectorcenter_top = [x-2*R,r-fc/2-2*R,x+2*R,r-fc/2+2*R];

fixation_right = [2*x-r-di,y-fc/2,2*x-r+fc-di,y+fc/2];
sectorcenter_right = [2*x-2*R-r+fc/2-di,y-2*R,2*x+2*R-r+fc/2-di,y+2*R];

% % [m n] = meshgrid(-R:R,-R:R);
[m n] = meshgrid(-R:R,-R:R);
mask(:,:,1) = (m.^2+n.^2>=R^2)*BackColor(1);
mask(:,:,2) = (m.^2+n.^2>=R^2)*BackColor(2);
mask(:,:,3) = (m.^2+n.^2>=R^2)*BackColor(3);

checkerboard=MakeCheckerboard(R,R,25,5);
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
Screen('FillOval',wptr,[255,0,0],fixation_down);
Screen('Flip',wptr);

%% scans

% paremeters
VisualField = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
tf=Screen('GetFlipInterval', wptr); % time of flip interval
va=30;
s1=0;
k=0;
fa=tf*va;

randnum=500;
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

for blocks=1:size(VisualField,2)
    
    BlockOnset2=GetSecs;
    if VisualField(blocks)==1
        Screen('FillOval',wptr,[255,0,0],fixation_down);
        Screen('Flip',wptr);
        WaitSecs(2);
        while GetSecs-ScanOnset<8*blocks
            k=k+1;
            if mod(k, 6)==0
                weigh = -1*weigh;
            end

            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask2,...
                    Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,2*y-r+fc/2))
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask1,...
                    Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,2*y-r+fc/2))
            end
            
            Screen('FillArc',wptr,BackColor,sectorcenter_down,theta+0,360-2*theta);
            i = randperm(randnum);
            if  i(1)>1
                Screen('FillOval',wptr,[255,0,0],fixation_down);
    %             Screen('Flip',wptr);
    %             WaitSecs(4*tf);
            elseif i(1)==1
                Screen('FillOval',wptr,[0,0,255],fixation_down);
            end
%             Screen('FillOval',wptr,[255,0,0],fixation_down);
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
    elseif VisualField(blocks)==2
        Screen('FillOval',wptr,[255,0,0],fixation_left);
        Screen('Flip',wptr);
        WaitSecs(2);
        while GetSecs-ScanOnset<8*blocks

            k=k+1;
            if mod(k, 6)==0
                weigh = -1*weigh;
            end

            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask2,...
                    Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),r-fc/2+di,y))
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask1,...
                    Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),r-fc/2+di,y))
            end
            
            Screen('FillArc',wptr,BackColor,sectorcenter_left,theta+90,360-2*theta);
            
            i = randperm(randnum);
            if  i(1)>1
                Screen('FillOval',wptr,[255,0,0],fixation_left);
            elseif i(1)==1
                Screen('FillOval',wptr,[0,0,255],fixation_left);
            end
            
%             Screen('FillOval',wptr,[255,0,0],fixation_left);
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
    elseif VisualField(blocks)==3
        Screen('FillOval',wptr,[255,0,0],fixation_top);
        Screen('Flip',wptr);
        WaitSecs(2);
        while GetSecs-ScanOnset<8*blocks
            k=k+1;
            if mod(k, 6)==0
                weigh = -1*weigh;
            end
%             cbColor1(:,:,1)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,1);
%             cbColor1(:,:,2)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,2);
%             cbColor1(:,:,3)=(checkerboard+weigh)/2*(weigh)*255+mask(:,:,3);

        %     cbColor2(:,:,1)=(checkerboard-1)/2*(-1)*255+mask(:,:,1);
        %     cbColor2(:,:,2)=(checkerboard-1)/2*(-1)*255+mask(:,:,2);
        %     cbColor2(:,:,3)=(checkerboard-1)/2*(-1)*255+mask(:,:,3);
            % cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

%             cbColorMask1 = Screen('MakeTexture', wptr,cbColor1);
        %     cbColorMask2 = Screen('MakeTexture', wptr,cbColor2);
            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask2,...
                    Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,r-fc/2))
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask1,...
                    Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,r-fc/2))
            end
            Screen('FillArc',wptr,BackColor,sectorcenter_top,theta+180,360-2*theta);
            
            i = randperm(randnum);
            if  i(1)>1
                Screen('FillOval',wptr,[255,0,0],fixation_top);
            elseif i(1)==1
                Screen('FillOval',wptr,[0,0,255],fixation_top);
            end
            
%             Screen('FillOval',wptr,[255,0,0],fixation_top);
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
    elseif VisualField(blocks)==4
        Screen('FillOval',wptr,[255,0,0],fixation_right);
        Screen('Flip',wptr);
        WaitSecs(2);
        while GetSecs-ScanOnset<8*blocks
            k=k+1;
            if mod(k, 6)==0
                weigh = -1*weigh;
            end
            
            if weigh == 1
                Screen('DrawTexture',wptr,cbColorMask2,...
                    Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),2*x-r+fc/2-di,y))
            elseif weigh == -1
                Screen('DrawTexture',wptr,cbColorMask1,...
                    Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),2*x-r+fc/2-di,y))
            end
            Screen('FillArc',wptr,BackColor,sectorcenter_right,theta+270,360-2*theta);
            i = randperm(randnum);
            if  i(1)>1
                Screen('FillOval',wptr,[255,0,0],fixation_right);
            elseif i(1)==1
                Screen('FillOval',wptr,[0,0,255],fixation_right);
            end
%             Screen('FillOval',wptr,[255,0,0],fixation_right);
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
end

sca;