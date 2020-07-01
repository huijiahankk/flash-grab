% time= 12 + (12+12+12+12)*6=300,TR=2s,150TR
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
fixcolor = [0,0,0];
backcolor=124;
contrastratio = 0.06;
sector1_color = backcolor + backcolor*contrastratio;
sector2_color = backcolor;
contrast = (sector1_color-sector2_color)/2;
sector_angle = 60; 
%%  initialize on Screen Window
% Screenid=max(Screen('Screens'));  
Screenid = 0;
[wptr,rect]=Screen('OpenWindow',Screenid,backcolor,[0 0 1024 768]);
%set window to ,[0 0 1024 768] for single monitor display

R = rect(4)/2;
mov = R/2+R/4;
R_mov = R+mov;
bar_center = (R_mov - R/4)/2;
bar_length = 50;

[x,y]=WindowCenter(wptr);
tf=Screen('GetFlipInterval', wptr); % time of flip interval
t=20; %bar_width
fixsize = 10/2;

SF = 40; % spatial frequency
SF2 = 20;
SF_probe = 20;

[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of bar
barMask = (m.^2+n.^2 >= (R/4).^2) & (m.^2+n.^2 <= (R_mov).^2) & ((m-t/2)<=0)&((m+t/2)>=0) & (n<0);
barMask2 = (m.^2+n.^2 >= (R/4).^2) & (m.^2+n.^2 <= (R_mov).^2) & ((m-t/2)<=0)&((m+t/2)>=0) & (n<-(bar_center-bar_length)) & (n>-(bar_center+bar_length));
checkerboard=MakeCheckerboard(R_mov,R_mov,SF,180);
bar1(:,:,1)=(checkerboard+1)/2*255;
bar1(:,:,2)=(checkerboard+1)/2*255;
bar1(:,:,3)=(checkerboard+1)/2*255;
bar1(:,:,4) = 255*barMask;
bar1Tex = Screen('MakeTexture', wptr, bar1);

checkerboard2=MakeCheckerboard(R_mov,R_mov,SF2,180);
bar2(:,:,1)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,2)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,3)=(checkerboard2-1)/2*(-1)*255;
bar2(:,:,4)=255*barMask;
bar2Tex = Screen('MakeTexture', wptr, bar2);

checkerboard_probe=MakeCheckerboard(R_mov,R_mov,SF_probe,180);
bar_probe(:,:,1)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,2)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,3)=(checkerboard_probe+1)/2*255;
bar_probe(:,:,4)=255*barMask2;
bar_probeTex = Screen('MakeTexture', wptr, bar_probe);


bar_red(:,:,1)=barMask*255;
bar_red(:,:,2)=barMask*0;
bar_red(:,:,3)=barMask*0;
bar_red(:,:,4)=255*barMask;
bar_redTex = Screen('MakeTexture', wptr, bar_red);


[m2 n2] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of sector
mask2 = (m2.^2+n2.^2 <= (R_mov).^2);
% mask2 = 1;
sector(:,:,1) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask2-1)*contrast+backcolor;
sector(:,:,4) = mask2*255;
sectorTex = Screen('MakeTexture', wptr, sector);

lineWidth = 2;
lineLength = 8;
[m3 n3] = meshgrid(-lineLength:lineLength,-lineLength:lineLength);
cross(:,:,1) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
cross(:,:,2) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,3) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 0;
cross(:,:,4) = ((m3>=-lineWidth & m3 <=lineWidth) | (n3>=-lineWidth & n3 <=lineWidth))* 255;
crossTex = Screen('MakeTexture', wptr, cross);

Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
% Screen('DrawTexture',wptr,crossTex,...
%     Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
Screen('Flip',wptr);
%% Scans 
VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2]; % 1: physical right, 2: fixation, 3: physical left
% VisualField = [1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3]; % 1: perceive right, 2: fixation, 3: perceive left

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
%% Start
v= 5; % sweeping speed per frame
sp=120; % sweeping angle
ds1=1;
s1=0;
key = 1;
p = 1;
q = 1;
ps=4;

left_tilted = 10; right_tilted = 10; % mod(var,3) == 0
rota1 = 180 + left_tilted; flashAngle_L = 60+left_tilted;
rota2 = 180 - right_tilted; flashAngle_R = 60-right_tilted;
rota = 90; % set initial position

flashNum = 12*60/(2*sp/v); % flash number per block
blockNum = 2*12;
randFlash = 6;
LineStyle=[];
for i = 1:(blockNum*flashNum/randFlash)
% for i = 1:(12*flashNum/randFlash)
    LineStyle = [LineStyle randperm(randFlash)];
end
flashTime = 1;
alpha_probe = 0.2;

WaitSecs(2); % dummy scan
ScanOnset = GetSecs;
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
%         Screen('DrawTexture',wptr,crossTex,...
%             Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
        Screen('Flip',wptr);
        
        %% flash line
        if (s1==flashAngle_R && ds1==1 && VisualField(blocks)==1)
            %% right tilted
            if LineStyle(flashTime) == 1
                %% bar low freq
                LineStyle(flashTime)
                eventseq(1,q) = 1;
                eventseq(2,q)= GetSecs - ScanOnset;
                q=q+1;
                
                for i = 1:ps
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota2);
                    Screen('DrawTexture',wptr,bar_probeTex,...
                        Screen('Rect',bar_probeTex),CenterRectOnPoint(Screen('Rect',bar_probeTex),x,y-mov),0+rota2,[], alpha_probe);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%                     Screen('DrawTexture',wptr,crossTex,...
%                         Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
                    Screen('Flip',wptr);
                    s1=s1+v*ds1;
                end
            else
                %% bar high freq
                for i = 1:ps
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota2);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%                     Screen('DrawTexture',wptr,crossTex,...
%                         Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
                    Screen('Flip',wptr);
                    s1=s1+v*ds1;
                end
            end
            flashTime = flashTime +1;
        elseif (s1==flashAngle_L && ds1 == -1 && VisualField(blocks)==3)
            %% left tilted
            if LineStyle(flashTime) == 1
                %% bar low freq
                LineStyle(flashTime)
                eventseq(1,q) = 1;
                eventseq(2,q)= GetSecs - ScanOnset;
                q=q+1;
                
                for i = 1:ps
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota1);
                    Screen('DrawTexture',wptr,bar_probeTex,...
                        Screen('Rect',bar_probeTex),CenterRectOnPoint(Screen('Rect',bar_probeTex),x,y-mov),0+rota1,[], alpha_probe);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%                     Screen('DrawTexture',wptr,crossTex,...
%                         Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
                    Screen('Flip',wptr);
                    s1=s1+v*ds1;
                end
            else
                %% bar high freq
                for i = 1:ps
                    Screen('DrawTexture',wptr,sectorTex,...
                        Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
                    Screen('DrawTexture',wptr,bar_redTex,...
                        Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota1);
                    Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
%                     Screen('DrawTexture',wptr,crossTex,...
%                         Screen('Rect',crossTex),CenterRectOnPoint(Screen('Rect',crossTex),x,y-mov),[]);
                    Screen('Flip',wptr);
                    s1=s1+v*ds1;
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
