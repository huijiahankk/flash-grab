%% LGN localizer
% time=48*6+=288, TR=2s, 147TR
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
Screen('Preference', 'SkipSyncTests', 1);
%% set globle parameters
BackColor=[60,60,60];
fixcolor = 0;
fixsize = 4;
theta=10;
weigh=1;
%% initialize screen
% Screenid=max(Screen('Screens'));
Screenid = 0;
[wptr,rect]=Screen('Openwindow',Screenid,BackColor,[0 0 1024 768]);
% ,[0 0 1024 768]
[x, y]=RectCenter(Screen('Rect',wptr));
R=rect(4)/2;
mov = R/2+R/4;
R_mov = R+mov;
% % [m n] = meshgrid(-R:R,-R:R);
[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov);
mask(:,:,1) = (m.^2+n.^2>=R_mov^2)*BackColor(1);
mask(:,:,2) = (m.^2+n.^2>=R_mov^2)*BackColor(2);
mask(:,:,3) = (m.^2+n.^2>=R_mov^2)*BackColor(3);

checkerboard=MakeCheckerboard(R_mov,R_mov,25,5);
cbColor1(:,:,1)=(checkerboard+1)/2*(1)*255+mask(:,:,1);
cbColor1(:,:,2)=(checkerboard+1)/2*(1)*255+mask(:,:,2);
cbColor1(:,:,3)=(checkerboard+1)/2*(1)*255+mask(:,:,3);

cbColor2(:,:,1)=(checkerboard-1)/2*(-1)*255+mask(:,:,1);
cbColor2(:,:,2)=(checkerboard-1)/2*(-1)*255+mask(:,:,2);
cbColor2(:,:,3)=(checkerboard-1)/2*(-1)*255+mask(:,:,3);
% cbColor(:,:,4)=(m.^2+n.^2>=R^2)*64;

cbColorMask1 = Screen('MakeTexture', wptr,cbColor1);
cbColorMask2 = Screen('MakeTexture', wptr,cbColor2);

lineWidth = 2;
lineLength = 8;
[m3 n3] = meshgrid(-lineLength:lineLength,-lineLength:lineLength);
cross(:,:,1) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,2) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
cross(:,:,3) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,4) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
crossTex = Screen('MakeTexture', wptr, cross);

cross2(:,:,1) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
cross2(:,:,2) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross2(:,:,3) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross2(:,:,4) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
cross2Tex = Screen('MakeTexture', wptr, cross2);

Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,fixcolor,[   sca
    x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
% Screen('DrawTexture',wptr,cross2Tex,...
%     Screen('Rect',cross2Tex),CenterRectOnPoint(Screen('Rect',cross2Tex),x,y-mov),[]);
Screen('Flip',wptr);
%% scans

% paremeters
tf=Screen('GetFlipInterval', wptr); % time of flip interval
% T = 64; 
T = 12;

blockNum = 24;
flashNum = 3; % 3 times per 12s
randFlash = 60*flashNum;
crossColor=[];
for i = 1:(12*60*blockNum/randFlash)
    crossColor = [crossColor randperm(randFlash)];
end
flashTime = 1;

s1=0;
k=0;
sp = 360;

randnum = 500;
frequency=5;
Duration=60/frequency;

key = 1;
p = 1;
q = 1;
acum = 1;
colorMark = 1;
Angle_sector = 15;
%% angular parameter
Angle_right = 15 - Angle_sector/2;
Angle_left = 20 + Angle_sector/2;

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

WaitSecs(6); % dummy scan
ScanOnset = GetSecs;
BlockOnset1=GetSecs;

while GetSecs-BlockOnset1< T*blockNum
    BlockOnset2=GetSecs;
    while GetSecs-BlockOnset2<T
        %% checkerboard
        k=k+1;
        if mod(k,6)==0
            weigh = -1*weigh;
        end

        if weigh == 1
            Screen('DrawTexture',wptr,cbColorMask2,...
                Screen('Rect',cbColorMask2),CenterRectOnPoint(Screen('Rect',cbColorMask2),x,y-mov))
        elseif weigh == -1
            Screen('DrawTexture',wptr,cbColorMask1,...
                Screen('Rect',cbColorMask1),CenterRectOnPoint(Screen('Rect',cbColorMask1),x,y-mov))
        end
        if mod(acum, 2) ==0
            Screen('FillArc',wptr,BackColor,[x-2*R,y-2*R-mov,x+2*R,y+2*R-mov],180-Angle_right,360-Angle_sector);
        else
            Screen('FillArc',wptr,BackColor,[x-2*R,y-2*R-mov,x+2*R,y+2*R-mov],180+Angle_left,360-Angle_sector);
        end
        %% trigger for color change
        if crossColor(flashTime) == 1
            colorMark = -colorMark;
            eventseq(1,q) = 1;
            eventseq(2,q)= GetSecs - ScanOnset;
            q=q+1;
        end
        
        if  colorMark == -1
            Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%             Screen('DrawTexture',wptr,crossTex,...
%                 Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
        elseif colorMark == 1
            Screen('FillOval',wptr,[255,0,0],[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%             Screen('DrawTexture',wptr,cross2Tex,...
%                 Screen('Rect',cross2Tex),CenterRectOnPoint(Screen('Rect',cross2Tex),x,y-mov),[]);
        end
%         Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%         Screen('DrawTexture',wptr,cross2Tex,...
%             Screen('Rect',cross2Tex),CenterRectOnPoint(Screen('Rect',cross2Tex),x,y-mov),[]);
        Screen('Flip',wptr);
        flashTime = flashTime +1;
        %% check keyboard input
        KbName('UnifyKeyNames');
        [ keyIsDown, timeSecs, keyCode] = KbCheck(-1);
        if keyIsDown*key == 1
            if keyCode(KbName('ESCAPE'))
                sca;
                break,
            elseif keyCode(KbName('1!'))
                response(1,p) = 1;
                response(2,p) = GetSecs - ScanOnset;
                p = p+1;
            end
        end
        if keyIsDown == 1
            key = 0;
        elseif keyIsDown == 0
            key = 1;
        end
    end
    acum = acum+1;
    display(GetSecs - ScanOnset);
    
end

% eventseq
% response
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
% rcorr = corr/(se(2))

sca;