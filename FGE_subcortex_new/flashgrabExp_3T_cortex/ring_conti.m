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
BackColor=[128,128,128];
theta=10;
weigh=1;
%% initialize screen
% Screenid=max(Screen('Screens'));
Screenid = 0;
[wptr,rect]=Screen('Openwindow',Screenid,BackColor,[0 0 1024 768]);
% ,[0 0 1024 768]
[x, y]=RectCenter(Screen('Rect',wptr));
R=rect(4)/2;
R1 = 0;
R2 = 0;

% % [m n] = meshgrid(-R:R,-R:R);
[m n] = meshgrid(-R:R,-R:R);
mask(:,:,1) = (m.^2+n.^2<=R.^2);
mask(:,:,2) = (m.^2+n.^2<=R.^2);
mask(:,:,3) = (m.^2+n.^2<=R.^2);
mask2(:,:,1) = (m.^2+n.^2>=R.^2);
mask2(:,:,2) = (m.^2+n.^2>=R.^2);
mask2(:,:,3) = (m.^2+n.^2>=R.^2);


% checkerboard=MakeCheckerboard(R,R,25,10);
% cbColor1(:,:,1)=(checkerboard).*mask(:,:,1).*mask_ring(:,:,1).*mask_ring2(:,:,1)*(1).*127+BackColor(1);
% cbColor1(:,:,2)=(checkerboard).*mask(:,:,2).*mask_ring(:,:,2).*mask_ring2(:,:,2)*(1).*127+BackColor(2);
% cbColor1(:,:,3)=(checkerboard).*mask(:,:,3).*mask_ring(:,:,3).*mask_ring2(:,:,3)*(1).*127+BackColor(3);
% 
% cbColor2(:,:,1)=(checkerboard).*mask(:,:,1).*mask_ring(:,:,1).*mask_ring2(:,:,1)*(-1).*127+BackColor(1);
% cbColor2(:,:,2)=(checkerboard).*mask(:,:,2).*mask_ring(:,:,2).*mask_ring2(:,:,2)*(-1).*127+BackColor(2);
% cbColor2(:,:,3)=(checkerboard).*mask(:,:,3).*mask_ring(:,:,3).*mask_ring2(:,:,3)*(-1).*127+BackColor(3);

checkerboard=MakeCheckerboard(R,R,25,10);
cbColor1(:,:,1)=(checkerboard+1)/2*(1).*mask(:,:,1).*255+mask2(:,:,1)*BackColor(1);
cbColor1(:,:,2)=(checkerboard+1)/2*(1).*mask(:,:,2).*255+mask2(:,:,2)*BackColor(2);
cbColor1(:,:,3)=(checkerboard+1)/2*(1).*mask(:,:,3).*255+mask2(:,:,3)*BackColor(3);

cbColor2(:,:,1)=(checkerboard-1)/2*(-1).*mask(:,:,1).*255+mask2(:,:,1)*BackColor(1);
cbColor2(:,:,2)=(checkerboard-1)/2*(-1).*mask(:,:,2).*255+mask2(:,:,2)*BackColor(2);
cbColor2(:,:,3)=(checkerboard-1)/2*(-1).*mask(:,:,3).*255+mask2(:,:,3)*BackColor(3);

cbColorMask1 = Screen('MakeTexture', wptr, cbColor1);
cbColorMask2 = Screen('MakeTexture', wptr, cbColor2);

% mask_ringTex = Screen('MakeTexture', wptr, mask_ring);
% mask_ring2Tex = Screen('MakeTexture', wptr, mask_ring2);

% maskTex = Screen('MakeTexture', wptr,mask);
Screen('FillOval',wptr,0,[x-5,y-5,x+5,y+5]); 
Screen('Flip',wptr);
%% scans

% paremeters
tf=Screen('GetFlipInterval', wptr); % time of flip interval
% va=11.25;
T = 32;
ringWidth = 50;
k=0;
frame = T/tf;
fa=(R-ringWidth)/frame;

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

while GetSecs-BlockOnset1<T*8

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
        
%         mask_ring(:,:,1) = (m.^2+n.^2<=R2.^2);
%         mask_ring(:,:,2) = (m.^2+n.^2<=R2.^2);
%         mask_ring(:,:,3) = (m.^2+n.^2<=R2.^2);
%         mask_ring(:,:,4) = (m.^2+n.^2<=R2.^2);
% 
%         mask_ring2(:,:,1) = ((m.^2+n.^2>=R1.^2).*mask_ring(:,:,1)-1)*(-1)*64;
%         mask_ring2(:,:,2) = ((m.^2+n.^2>=R1.^2).*mask_ring(:,:,2)-1)*(-1)*64;
%         mask_ring2(:,:,3) = ((m.^2+n.^2>=R1.^2).*mask_ring(:,:,3)-1)*(-1)*64;
%         mask_ring2(:,:,4) = ((m.^2+n.^2>=R1.^2).*mask_ring(:,:,4)-1)*(-1);
% 
%         mask_ring2Tex = Screen('MakeTexture', wptr, mask_ring2);
%         Screen(wptr, 'BlendFunction', GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%         
%         Screen('DrawTexture',wptr,mask_ring2Tex,...
%             Screen('Rect',mask_ring2Tex),CenterRectOnPoint(Screen('Rect',mask_ring2Tex), x, y))
%         
        if weigh == 1
            Screen('DrawTexture',wptr,cbColorMask2,...
                Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2), x, y))
        elseif weigh == -1
            Screen('DrawTexture',wptr,cbColorMask1,...
                Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1), x, y))
        end
        
%         if weigh == 1
%             Screen('DrawTexture',wptr,cbColorMask2,...
%                 Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y))
%         elseif weigh == -1
%             Screen('DrawTexture',wptr,cbColorMask1,...
%                 Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,y))
%         end
        
%         s1=s1+fa;
%         Screen('FillArc',wptr,BackColor,[x-2*R,y-2*R,x+2*R,y+2*R],s1+theta,360-2*theta);
%         Screen('DrawTexture',wptr,mask_ringTex,...
%             Screen('Rect',mask_ringTex),CenterRectOnPoint(Screen('Rect',mask_ringTex),x,y))
%         Screen('DrawTexture',wptr,mask_ring2Tex,...
%             Screen('Rect',mask_ring2Tex),CenterRectOnPoint(Screen('Rect',mask_ring2Tex),x,y))
        Screen('FrameOval',wptr,BackColor,[x-R-1,y-R-1,x+R+1,y+R+1], R-R2);
        Screen('FillOval',wptr,BackColor,[x-R1,y-R1,x+R1,y+R1]);

%         Screen('FrameOval',wptr,BackColor,[x-R1,y-R1,x+R1,y+R1], R2);

        i = randperm(randnum);
        if  i(1)==1
            Screen('FillOval',wptr,[255,0,0],[x-6,y-6,x+6,y+6]);
%             Screen('Flip',wptr);
%             WaitSecs(4*tf);
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