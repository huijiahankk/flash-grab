%% 
% time=24*8+4=196, TR=1s, 196TR
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
clear all;
Screen('Preference', 'SkipSyncTests', 1);
%% set globle parameters
center=2;

%
T = 32;
sp = 32;
angle_res=1;
blockNum=8;

%
BackColor=60;
weigh=1;
%% initialize screen
% Screenid=max(Screen('Screens'));
Screenid = 1;
[wptr,rect]=Screen('Openwindow',Screenid,BackColor,[0 0 1024 768]);
% ,[0 0 1024 768]

if center==1
    load('Location_Of_Fixation.ini');
    x=Location_Of_Fixation(1);
    y=Location_Of_Fixation(2);
elseif center==2
    [x,y]=WindowCenter(wptr);
end

R=rect(3)/2;
mov = 0;
R_mov = R+mov;
%% bar
t=20;
StimSize = 50;
[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov);
barMask =  ((m-t/2+2)<0)&((m+t/2+2)>=0)& (n<R_mov-4);
Square_size = t/2;
StimSize=size(m,1)/Square_size;
checkerboard = MakeCheckerboard_sq(StimSize, StimSize, Square_size);
bar1(:,:,1) = barMask.*(checkerboard+1)/2*255;
bar1(:,:,2) = barMask.*(checkerboard+1)/2*255;
bar1(:,:,3) = barMask.*(checkerboard+1)/2*255;
bar1(:,:,4) = barMask*255;
barTex1 = Screen('MakeTexture', wptr,bar1);

bar2(:,:,1) = barMask.*(checkerboard-1)/2*(-1)*255;
bar2(:,:,2) = barMask.*(checkerboard-1)/2*(-1)*255;
bar2(:,:,3) = barMask.*(checkerboard-1)/2*(-1)*255;
bar2(:,:,4) = barMask*255;
barTex2 = Screen('MakeTexture', wptr,bar2);
%%
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,[255,0,0],[x-5,y-5,x+5,y+5]); 
Screen('Flip',wptr);
%% scans
tf=Screen('GetFlipInterval', wptr); % time of flip interval

k=0;
frame = T / tf; % all frames
fa = sp/(frame); % deg per frame

randnum = 500;
frequency=5;
Duration=60/frequency;

key = 1;
p = 1;
q = 1;
% trigger
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
for block = 1 : blockNum
    s1=16;
    acc=1;
    BlockOnset=GetSecs;
    while GetSecs-BlockOnset<T
        if fix(GetSecs-BlockOnset)==acc
            s1=s1-angle_res;
            acc=acc+1;
        end
        
        k=k+1;
        if mod(k,6)==0
            weigh = -1*weigh;
        end
        if weigh == 1
            Screen('DrawTexture',wptr,barTex1,...
                Screen('Rect',barTex1),CenterRectOnPoint(Screen('Rect',barTex1),x-2,y+2),s1+90)
        elseif weigh == -1
            Screen('DrawTexture',wptr,barTex2,...
                Screen('Rect',barTex2),CenterRectOnPoint(Screen('Rect',barTex2),x-2,y+2),s1+90)
        end
        
        i = randperm(randnum);
        if  i(1)==1
            Screen('FillOval',wptr,[255,0,0],[x-6,y-6,x+6,y+6]);
            eventseq(1,q) = 1;
            eventseq(2,q)= GetSecs - ScanOnset;
            q=q+1;
        elseif i(1)>1
            Screen('FillOval',wptr,[255,0,0],[x-5,y-5,x+5,y+5]);
        end
        Screen('Flip',wptr);
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
