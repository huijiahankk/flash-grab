function flashgrab(session)
%%
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
% rota = 0;
rota = 180;
sp=120; % sweeping angle
v=180; % sweeping speed
ds1=1;
s1=0;
% disc radius or bar_length
t=20; %bar_width
fixcolor = [0,0,0];
backcolor=64;
sector1_color=68;
sector2_color=60;
contrast = (sector1_color-sector2_color)/2;
sector_angle = 60; 
ps=5;
% randnum = 500;

% j = randperm(2);
% 
% if j(1) == 1
%     rota = rota + 180;
% end

%%  initialize on Screen Window
% Screenid=max(Screen('Screens'));  
Screenid = 0;
[wptr,rect]=Screen('OpenWindow',Screenid,backcolor,[0 0 1024 768] );
%set window to ,[0 0 1024 768] for single monitor display

% R=300;
R = rect(4)/2;
[m n] = meshgrid(-t/2:t/2,-R:R); % coordinate of bar
[m2 n2] = meshgrid(-R:R,-R:R); % coordinate of bar

[x,y]=WindowCenter(wptr);
tf=Screen('GetFlipInterval', wptr); % time of flip interval
% af = v*tf;
mask(:,:,1) = (m2.^2+n2.^2 <= R.^2);
mask(:,:,2) = (m2.^2+n2.^2 <= R.^2);
mask(:,:,3) = (m2.^2+n2.^2 <= R.^2);

bar(:,:,1) = ((m.^2+n.^2 <= R.^2)&((m-t/2)<=0)&((m+t/2)>=0)).*255;
bar(:,:,2) = ((m.^2+n.^2 <= R.^2)&((m-t/2)<=0)&((m+t/2)>=0)).*0;
bar(:,:,3) = ((m.^2+n.^2 <= R.^2)&((m-t/2)<=0)&((m+t/2)>=0)).*0;

sector(:,:,1) = (MakeSectorDisc(R,R,sector_angle).*mask(:,:,1))*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(R,R,sector_angle).*mask(:,:,2))*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(R,R,sector_angle).*mask(:,:,3))*contrast+backcolor;

barTex = Screen('MakeTexture', wptr, bar);
sectorTex = Screen('MakeTexture', wptr, sector);
Screen('FillOval',wptr,fixcolor,[x-5,y-5,x+5,y+5]);
Screen('Flip',wptr);

%% Scans
% scan time = 4+12+(12+12+12+12)*6+12=316,TR=2s,158TR
% 1: perceive right, % 2: fixation, % 3: perceive left
VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];

% % random order
% VisualField = [1 3 1 3 1 3];
% a = size(VisualField,2);
% VisualField(randperm(a)) = VisualField(1:1:a);

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

%%
ScanOnset = GetSecs;
for blocks=1:size(VisualField,2)
    BlockOnset=GetSecs;
    while GetSecs-BlockOnset<12
        if s1>=sp
            ds1=(-1);
        elseif s1<=0
            ds1=1;
        end

        Screen('DrawTexture',wptr,sectorTex,...
            Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y),s1+rota);

        if ((s1<=0) && (VisualField(blocks)==1))||((s1>=(sp))&&(VisualField(blocks)==3))

            Screen('DrawTexture',wptr,sectorTex,...
                Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y),s1+rota);
            Screen('DrawTexture',wptr,barTex,...
                Screen('Rect',barTex),CenterRectOnPoint(Screen('Rect',barTex),x,y),0+rota);
            Screen('FillOval',wptr,fixcolor,[x-5,y-5,x+5,y+5]);
            Screen('Flip',wptr);
%             WaitSecs(ps.*tf);
        end
        if ((s1<=0) && (VisualField(blocks)==1))||((s1>=(sp))&&(VisualField(blocks)==3))

            Screen('DrawTexture',wptr,sectorTex,...
                Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y),s1+rota);
            Screen('DrawTexture',wptr,barTex,...
                Screen('Rect',barTex),CenterRectOnPoint(Screen('Rect',barTex),x,y),0+rota);
            Screen('FillOval',wptr,fixcolor,[x-5,y-5,x+5,y+5]);
            Screen('Flip',wptr);
%             WaitSecs(ps.*tf);
        end
        
        KbName('UnifyKeyNames');
        [ keyIsDown, timeSecs, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                sca;
                break,
            end
        end
%         i = randperm(randnum);
%         if  i(1)==1
%             Screen('FillOval',wptr,[255,0,0],[x-6,y-6,x+6,y+6]);
%             %             Screen('Flip',wptr);
%             %             WaitSecs(4*tf);
%         elseif i(1)>1
%             Screen('FillOval',wptr,[0,0,0],[x-5,y-5,x+5,y+5]);
%         end
        s1=s1+v.*tf.*ds1;
        Screen('FillOval',wptr,fixcolor,[x-5,y-5,x+5,y+5]);
        Screen('Flip',wptr);
%         img = Screen('GetImage', wptr);
%         imwirte(img, 'tmp')
    end
    display(GetSecs - ScanOnset);
end
sca;
end
