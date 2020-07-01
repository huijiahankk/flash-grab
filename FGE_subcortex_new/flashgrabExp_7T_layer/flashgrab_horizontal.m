% duration = (12+12+12+12)*6+12+4=304,TR=2s,152TR
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
clear all;close all;
% Screen('Preference', 'SkipSyncTests', 1);
% sbjname = input('Please input the subject''s name\n','s');
% BlockNum = input('Please input the Block No.\n','s');
addpath support_program;
commandwindow;
%% change parameters
center=2; % center=1;

%% set parameters
fixcolor = 0;
backcolor = 120;
contrastratio = 0.12;
%% Setup Screen
% Screenid=max(Screen('Screens'));
Screenid = 0;
[wptr,rect]=Screen('OpenWindow',Screenid,backcolor,[0 0 1024 768]); %set window to ,[0 0 1024 768] for single monitor display
R = rect(3)/2;
mov = 0;
R_mov = R + mov;

if center==1
    load('Location_Of_Fixation.ini');
    x=Location_Of_Fixation(1);
    y=Location_Of_Fixation(2);
elseif center==2
    [x,y]=WindowCenter(wptr);
end

% tf=Screen('GetFlipInterval', wptr); % time of flip interval
bar_width = 20; %bar_width
fixsize = 10/2;
%% flash bar
[m n] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of bar
%% background
sector1_color = backcolor + backcolor*contrastratio;
sector2_color = backcolor;
contrast = (sector1_color-sector2_color)/2;
sector_angle = 45;
[m2 n2] = meshgrid(-R_mov:R_mov,-R_mov:R_mov); % coordinate of sector
mask = (m2.^2+n2.^2 <= (R_mov).^2);

sector(:,:,1) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,2) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,3) = (MakeSectorDisc(R_mov,R_mov,sector_angle).*mask-1)*contrast+backcolor;
sector(:,:,4) = mask*255;
sectorTex = Screen('MakeTexture', wptr, sector);
%% corss fixation
 %% dot fixation
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
%% Scans % duration = 4+12+(12+12+12+12)*6 = 304 s,TR=2s,152TR
% VF_key=randperm(2,1);
% if VF_key==1
%     VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
% else
%     VisualField = [2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2];
% end
VisualField = [2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2 1 2 3 2];
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

rota = 90;
s1=0;
sp=120;
v= 4;
ds1=1;
ps=4;
key = 1;
p = 1;
q = 1;
flashflag=0;
moveflag=1;
%% Start Timing
WaitSecs(4); % dummy scan
ScanOnset = GetSecs;
for blocks=1:size(VisualField,2)
    BlockOnset=GetSecs;
    while GetSecs-BlockOnset < 12
        if s1>=sp
            ds1=(-1);
        elseif s1<=0
            ds1=1;
        end
        %%
        Screen('DrawTexture',wptr,sectorTex,...
            Screen('Rect',sectorTex),CenterRectOnPoint(Screen('Rect',sectorTex),x,y-mov),s1+rota);
        %% 
        if s1<=0 && flashflag<ps
            if VisualField(blocks)==1
                %% flash
                Screen('DrawTexture',wptr,bar_redTex,...
                    Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota);
                flashflag=flashflag+1;
                moveflag=0;
            else
                %% stop
                flashflag=flashflag+1;
                moveflag=0;
            end
        elseif s1>=sp && flashflag<ps
            if VisualField(blocks)==3
                %% flash
                Screen('DrawTexture',wptr,bar_redTex,...
                    Screen('Rect',bar_redTex),CenterRectOnPoint(Screen('Rect',bar_redTex),x,y-mov),0+rota);
                flashflag=flashflag+1;
                moveflag=0;
            else
                %% stop
                flashflag=flashflag+1;
                moveflag=0;
            end
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
        Screen('FillOval',wptr,fixcolor,[x-fixsize,y-fixsize-mov,x+fixsize,y+fixsize-mov]);
        Screen('Flip',wptr);
        if flashflag>=ps
            moveflag=1;
            flashflag=0;
        end
        
        if moveflag==1
            s1=s1+v*ds1;
        end
    end
    display(GetSecs - ScanOnset);
end
% eventseq;
% response;
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
% rcorr = corr/(se(2));
% VF_key(1)
%% save data
% sbjname = 'zhouhao';
% dir = sprintf('%s/',sbjname);
% if ~isdir(dir)
%     mkdir(dir)
% end
% %
% time = clock;
% filename = sprintf('%s_record_%02g_%02g_%02g_%02g',BlockNum,time(2),time(3),time(4),time(5));
% filename2 = [dir,filename];
% save(filename2,'VF_key');
sca;
