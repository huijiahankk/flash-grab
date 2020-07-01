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
Screen('Preference', 'SkipSyncTests', 1);
fixcolor = 0;
backcolor=124;
contrastratio = 0.06;

% Screenid=max(Screen('Screens'));  
Screenid = 0;
[wptr,rect]=Screen('OpenWindow',Screenid,backcolor,[0 0 1024 768]);
%set window to ,[0 0 1024 768] for single monitor display

% R=300;
R = rect(4)/2;
mov = R/2+R/4;
R_mov = R+mov;
bar_center = (R_mov - R/4)/2;
bar_length = 50;

[x,y]=WindowCenter(wptr);
tf=Screen('GetFlipInterval', wptr); % time of flip interval
t=20; %bar_width
fixsize = 10/2;

% stimulus size
% screensize = [ , ]; % unit: mm.
% resolusion = [rect(3) ,rect(4)];
% ppm = screensize/resolution % pixel per mm. In principle, ppm(1) == ppm(2).

% distance = 60*10; % unit: mm.
% fovea = 10 % unit: ?.
% rLength = ppm(1) distance * atan(fovea);

%% flash line
SF = 40; % spatial frequency
SF2 = 30;
SF_probe = 20;

[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of bar
barMask = (m.^2+n.^2 >= (R/4).^2) & (m.^2+n.^2 <= (R_mov).^2) & ((m-t/2)<=0)&((m+t/2)>=0) & (n<0);
barMask2 = (m.^2+n.^2 >= (R/4).^2) & (m.^2+n.^2 <= (R_mov).^2) & ((m-t/2)<=0)&((m+t/2)>=0) & (n<-(bar_center-bar_length)) & (n>-(bar_center+bar_length));
checkerboard=MakeCheckerboard(R_mov,R_mov,SF,180);
bar1(:,:,1)=(checkerboard+1)/2*255;
bar1(:,:,2)=(checkerboard+1)/2*255;
bar1(:,:,3)=(checkerboard+1)/2*255;
bar1(:,:,4)=255*barMask;
bar1Tex = Screen('MakeTexture', wptr, bar1);

% bar1_rev(:,:,1)=(checkerboard+1)/2*(-1)*255;
% bar1_rev(:,:,2)=(checkerboard+1)/2*(-1)*255;
% bar1_rev(:,:,3)=(checkerboard+1)/2*(-1)*255;
% bar1_rev(:,:,4) = 255*barMask;

bar1_rev(:,:,1)=(checkerboard - 1)/2*(-1)*255;
bar1_rev(:,:,2)=(checkerboard - 1)/2*(-1)*255;
bar1_rev(:,:,3)=(checkerboard - 1)/2*(-1)*255;
bar1_rev(:,:,4) = 255*barMask;
bar1_revTex = Screen('MakeTexture', wptr, bar1_rev);

checkerboard2=MakeCheckerboard(R_mov,R_mov,SF2,180);
bar2(:,:,1)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,2)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,3)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,4)=255*barMask;
bar2Tex = Screen('MakeTexture', wptr, bar2);

bar2_rev(:,:,1)=(checkerboard2+1)/2*255;
bar2_rev(:,:,2)=(checkerboard2+1)/2*255;
bar2_rev(:,:,3)=(checkerboard2+1)/2*255;
bar2_rev(:,:,4)=255*barMask;
bar2_revTex = Screen('MakeTexture', wptr, bar2_rev);

checkerboard_probe=MakeCheckerboard(R_mov,R_mov,SF_probe,180);
bar_probe(:,:,1)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,2)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,3)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,4)=255*barMask2;
bar_probeTex = Screen('MakeTexture', wptr, bar_probe);

bar_white(:,:,1)=barMask*255;
bar_white(:,:,2)=barMask*255;
bar_white(:,:,3)=barMask*255;
bar_white(:,:,4)=255*barMask;
bar_whiteTex = Screen('MakeTexture', wptr, bar_white);

bar_black(:,:,1)=barMask*0;
bar_black(:,:,2)=barMask*0;
bar_black(:,:,3)=barMask*0;
bar_black(:,:,4)=255*barMask;
bar_blackTex = Screen('MakeTexture', wptr, bar_black);

bar_red(:,:,1)=barMask*255;
bar_red(:,:,2)=barMask*0;
bar_red(:,:,3)=barMask*0;
bar_red(:,:,4)=255*barMask;
bar_redTex = Screen('MakeTexture', wptr, bar_red);
%% background

sector1_color = backcolor + backcolor*contrastratio;
sector2_color = backcolor;
contrast = (sector1_color-sector2_color)/2;
sector_angle = 60; 
[m2 n2] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of sector
mask2 = (m2.^2+n2.^2 <= (R_mov).^2);
% mask2 = 1;
sector(:,:,1) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,4) = mask2*255;
sectorTex = Screen('MakeTexture', wptr, sector);
%% fixation
lineWidth = 2;
lineLength = 8;
[m3 n3] = meshgrid(-lineLength:lineLength,-lineLength:lineLength);
cross(:,:,1) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
cross(:,:,2) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,3) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,4) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
crossTex = Screen('MakeTexture', wptr, cross);
% fixdot(:,:,1) = (m.^2+n.^2 < fixsize.^2) * 0;
% fixdot(:,:,2) = (m.^2+n.^2 < fixsize.^2) * 0;
% fixdot(:,:,3) = (m.^2+n.^2 < fixsize.^2) * 0;
% fixdot(:,:,4) =  (m.^2+n.^2 < fixsize.^2) * 255;
% dotTex = Screen('MakeTexture', wptr, fixdot);
%%  initialize on Screen Window
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
% Screen('DrawTexture',wptr,crossTex,...
%     Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
Screen('Flip',wptr);
%% Scans % scan time = 4+12+(12+12+12+12)*6=304,TR=2s,152TR
VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2]; % 1: perceive right, 2: fixation, 3: perceive left
% VisualField = [1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3]; % 1: perceive right, 2: fixation, 3: perceive left
% VisualField = [1 3 1 3 1 3];

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
rota = 180;
sp=120; % sweeping angle
v= 5; % sweeping speed per frame
ds1=1;
s1=0;
ps=4;
key = 1;
p = 1;
q = 1;

flashNum = 12/(2*sp/v*1/60);
randFlash = 6;
LineStyle=[];
for i = 1:(2*12*flashNum/randFlash)
% for i = 1:(12*flashNum/randFlash)
    LineStyle = [LineStyle randperm(randFlash)];
end
flashTime = 1;
alpha_probe = 0.2;

ScanOnset = GetSecs;
timing = [];
for blocks=1:size(VisualField,2)
    BlockOnset=GetSecs;
    while (GetSecs-BlockOnset < 12 && ((VisualField(blocks)==1) || (VisualField(blocks)==3))) || (GetSecs-BlockOnset < 6 &&(VisualField(blocks)==2))
        if s1>=sp
            ds1=(-1);
        elseif s1<=0
            ds1=1;
        end
        %% background disc
        Screen('DrawTexture',wptr,sectorTex,...
            Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
        s1=s1+v*ds1;
        Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
        Screen('Flip',wptr);
        timing = [timing GetSecs];
        
        if ((s1<=0) ) || ((s1>=(sp))) 
            if LineStyle(flashTime) == 1
                %% bar 1
                LineStyle(flashTime)
                eventseq(1,q) = 1;
                eventseq(2,q)= GetSecs - ScanOnset;
                q=q+1;
                for i = 1:ps
                    %%
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
                    Screen('Flip',wptr);
%                     s1=s1+v*ds1;

                end
            else
                %% bar 2
                for i = 1:ps
                    %%
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
                    Screen('Flip',wptr);
%                     s1=s1+v*ds1;s
                    timing = [timing GetSecs];
                end
            end
        end

        %% flash line 
        if ((s1<=0) && (VisualField(blocks)==1)) || ((s1>=(sp))&&(VisualField(blocks)==3)) 
            if LineStyle(flashTime) == 1
                %% bar 1
                LineStyle(flashTime)
                eventseq(1,q) = 1;
                eventseq(2,q)= GetSecs - ScanOnset;
                q=q+1;
                for i = 1:ps
                    %%
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota);
                    Screen('DrawTexture',wptr,bar_probeTex,...
                        Screen('Rect',bar_probeTex),CenterRectOnPoint(Screen('Rect',bar_probeTex),x,y-mov),0+rota,[],alpha_probe);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
                    Screen('Flip',wptr);
%                     s1=s1+v*ds1;
                    timing = [timing GetSecs];
                end
            else
                %% bar 2
                for i = 1:ps
                    %%
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota);
%                     Screen('DrawTexture',wptr,bar_probeTex,...
%                         Screen('Rect',bar_probeTex),CenterRectOnPoint(Screen('Rect',bar_probeTex),x,y-mov),0+rota,[],0.1);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
                    Screen('Flip',wptr);
%                     s1=s1+v*ds1;s
                    timing = [timing GetSecs];
                end
            end
            flashTime = flashTime +1;
        end
        %% check input
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
        %%
%         WaitSecs(1)
    end
    display(GetSecs - ScanOnset);
end

eventseq
response

se = size(eventseq);
sr = size(response);
corr = 0;
z1 = 1;
numcorr = [];
for z2 = 1:se(2);
    z3 = 1;
    internumcorr{1} = [0;0];
    if  z2==se(2)
        eventseq(2,z2+1) = 300;
    end
    for z4 = 1:sr(2);
        if response(2,z4) < eventseq(2,z2+1) && response(2,z4) > eventseq(2,z2)
            internumcorr{z3} = response(:,z4);
            z3 = z3+1;
        end
    end
    if  internumcorr{1}(1) == eventseq(1,z2)
        corr = corr + 1;
        numcorr{z1} = internumcorr{1};
        z1 = z1+1;
    end
end

rcorr = corr/(se(2))
sca;
