function eyeAtt_spatial_localizer_VF_2condition(subject, run)
PsychDefaultSetup(0);
Screen('Preference', 'SkipSyncTests', 1);
% temporal paras for test
global  white black PPD frameRate
%% basic paras
% keyboard
KbName('UnifyKeyNames');
KeyS = KbName('S');
KeyEsc = KbName('ESCAPE');
KeyLeft = KbName('1!');
% KeyRight = KbName('2@');

% monitor
whichscreen=max(Screen('Screens'));
black=BlackIndex(whichscreen);
white=WhiteIndex(whichscreen);
gray=round((white-black)/2);
background = black;
% background=[128 128 0];
stereomode=4;
[wptr,  ~]  = Screen('OpenWindow',whichscreen,background,[], [], [],stereomode);
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[~, screenYpixels] = Screen('WindowSize', wptr);
frameRate = Screen('FrameRate',wptr);
disp(frameRate);

distance = 75;
projector_height = 35;
pixel_density = screenYpixels/projector_height;
PPD = 2 * distance * tand(1/2) * pixel_density;
PPD=39.4;
% PPD = 1.8*PPD;
% if In_7T
% % calibration for 7T
%     load Calibration-2016-9-30-22-29_7T_Backmonitor.mat;
%     dacsize=10;%How many bits per pixel#
%     maxcol=2.^dacsize-1;
%     ncolors=256;
%     %see details in makebkg.m
%     newcmap=rgb2cmapramp([0.5,0.5,0.5],[0.5,0.5,0.5],1,ncolors,gamInv,dacsize);%Make the gamma table we want#
%     newclut(1:ncolors,:)=newcmap./maxcol;
%     oldclut=Screen('ReadNormalizedGammaTable',0);
%     Screen('LoadNormalizedGammaTable',wptr,newclut);
% else
% % calibration for psych2
%     load Calibration-psych2-2013-6-9-14-31.mat;
%     dacsize = 10;  %How many bits per pixel#
%     maxcol = 2.^dacsize-1;
%     ncolors = 256; % see details in makebkg.m
%     newcmap = rgb2cmapramp([.5 .5 .5],[.5 .5 .5],1,ncolors,gamInv,dacsize);  %Make the gamma table we want#
%     newclut(1:ncolors,:) = newcmap./maxcol;
%     oldclut = Screen('ReadNormalizedGammaTable',whichscreen);
%     Screen('LoadNormalizedGammaTable', wptr, newclut);
% end


%% textures and locations
% fixation texture
fixation.size = round(0.5 * PPD);
fixationCross = DrawCrossFixation_background(20, 20, 2, gray/2, gray/2);
Crosstex_background = Screen('MakeTexture', wptr, fixationCross);
% fixation for task
fixationCross = DrawCrossFixation(20, 20, 2, white, gray);
Crosstex = Screen('MakeTexture', wptr, fixationCross);
% fixation mask
R_fixation = (fixation.size-1)/2;
center = (fixation.size+1)/2;
mask =  background*ones(fixation.size,fixation.size,4);
buffer=white * ones(fixation.size, fixation.size);
fade_start = 0.9;
fade_pixel = (1-fade_start)*R_fixation;
for i = 1:fixation.size
    for j = 1:fixation.size
        radius = ( (i-center)^2+(j-center)^2 )^(1/2);
        if radius^2>(fade_start*R_fixation)^2
            buffer(i,j) = white*sin( pi/2*(radius-fade_start*R_fixation)/fade_pixel );
        end
        if radius^2<(fade_start*R_fixation)^2
            buffer(i,j)=0;
        end
        if radius^2>(R_fixation)^2
            buffer(i,j)=0;
        end
    end
end
mask(:,:,4)=buffer;
Fmasktex = Screen('MakeTexture', wptr, mask);
% fixation location
% sbj.name = subject;
% load(['SUB/',sbj.name,'.mat']);
% L.x = screenXpixels/2;
% R.x = screenXpixels/2;
% L.y = screenYpixels/2;
% R.y = screenYpixels/2;
% vertical=-fix_pos(2);
%
% distance = 75.1;% 7T distance = 75.1
% display_height = 31.5; %7T 31.5
% pixel_density = screenYpixels/display_height; % use Ypixels, because the Xpixels are cut into 2 parts in stereomode 4.
% PPD = 2 * distance * tand(1/2) * pixel_density;
% deltaPPD = 6;
% PPD = PPD+deltaPPD;
%
% L.x = L.x + (offset+vergence)*PPD;
% R.x = R.x + (offset-vergence)*PPD;
% L.y = L.y + (vertical+tilt)*PPD;
% R.y = R.y + (vertical-tilt)*PPD;
%
% PPD = PPD-deltaPPD;
%
% visual_angle = 10;
% stim_rect = [0 0 visual_angle visual_angle]*PPD;
% L.pos = CenterRectOnPoint(stim_rect, L.x, L.y);
% R.pos = CenterRectOnPoint(stim_rect, R.x, R.y);
sbj.name = subject;
load(['SUB/',sbj.name,'_fix_location.mat']);
PPD=39.4;
[L.x,L.y] = RectCenter(L.pos);
[R.x,R.y] = RectCenter(R.pos);
destinationFixation.LE = CenterRect([0,0,fixation.size, fixation.size], L.pos);
destinationFixation.RE = CenterRect([0,0,fixation.size, fixation.size], R.pos);
% target texture
target.size = round(2*PPD);
target.sf = 1;
contrast = 0.99;
mean_luminance = gray;
luminance_1 = mean_luminance*(1+contrast); luminance_1 = luminance_1*ones(1,3);
luminance_2 = mean_luminance*(1-contrast); luminance_2 = luminance_2*ones(1,3);
chb_1 = DrawCheckerboard(target.size, target.sf, PPD, luminance_1, luminance_2);
chb_2 = DrawCheckerboard(target.size, target.sf, PPD, luminance_2, luminance_1);
chb_phase1 = Screen('MakeTexture', wptr, chb_1);
chb_phase2 = Screen('MakeTexture', wptr, chb_2);
% target mask
R_target=(target.size-1)/2;
center = (target.size+1)/2;
Tmask =  background*ones(target.size,target.size,4);
buffer=white * ones(target.size, target.size);
fade_start = 0.85;
fade_pixel = (1-fade_start)*R_target;
for i = 1:target.size
    for j = 1:target.size
        radius = ( (i-center)^2+(j-center)^2 )^(1/2);
        if radius^2>(fade_start*R_target)^2
            buffer(i,j) = white*sin( pi/2*(radius-fade_start*R_target)/fade_pixel );
        end     
        if radius^2>(R_target)^2
            buffer(i,j)=white;
        end
        if radius^2<(fade_start*R_target)^2
            buffer(i,j)=0;
        end
    end
end
Tmask(:,:,4)=buffer;
Tmasktex = Screen('MakeTexture', wptr, Tmask);
% target location
sourceRect = [0,0,target.size, target.size];
destinationTarget.LEorigin = CenterRect([0,0,target.size, target.size], L.pos);
destinationTarget.REorigin = CenterRect([0,0,target.size, target.size], R.pos);
target.offset = 0.5*PPD+target.size/2; target.offset = [target.offset, 0, target.offset, 0];
destinationTarget.LE.LF = destinationTarget.LEorigin-target.offset;
destinationTarget.LE.RF = destinationTarget.LEorigin+target.offset;
destinationTarget.RE.LF = destinationTarget.REorigin-target.offset;
destinationTarget.RE.RF = destinationTarget.REorigin+target.offset;

% surround texture
Surround.size = round(10*PPD);
Surround.sf = 1;
chb_1s = DrawCheckerboard(Surround.size, Surround.sf, PPD, luminance_1, luminance_2);
chb_2s = DrawCheckerboard(Surround.size, Surround.sf, PPD, luminance_2, luminance_1);
chb_phase1s = Screen('MakeTexture', wptr, chb_1s);
chb_phase2s = Screen('MakeTexture', wptr, chb_2s);
% surround mask
R_surround=(Surround.size-1)/2;
center=(Surround.size+1)/2;
mask =  background*ones(Surround.size,Surround.size,4);
buffer=white * ones(Surround.size,Surround.size);
fade_start = 0.9;
fade_pixel = (1-fade_start)*R_surround;
for i = 1:Surround.size
    for j = 1:Surround.size
        radius = ( (i-center)^2+(j-center)^2 )^(1/2);
        if radius^2>(fade_start*R_surround)^2
            buffer(i,j) = white*sin( pi/2*(radius-fade_start*R_surround)/fade_pixel );
        end
        if radius^2>(R_surround)^2
            buffer(i,j)=white;
        end
        if radius^2<(fade_start*R_surround)^2
            buffer(i,j)=0;
        end
    end
end
mask(:,:,4)=buffer;
Smasktex = Screen('MakeTexture', wptr, mask);
% surround location
destinationSurround.LE = CenterRect([0,0,Surround.size, Surround.size], L.pos);
destinationSurround.RE = CenterRect([0,0,Surround.size, Surround.size], R.pos);
% target mask for surround
target.sizeM = round(target.size*1.08);
R_targetM=(target.sizeM-1)/2;
center=(target.sizeM+1)/2;
mask =  background*ones(target.sizeM,target.sizeM,4);
buffer=white * ones(target.sizeM, target.sizeM);
fade_start = 0.92;
fade_pixel = (1-fade_start)*R_targetM;
for i = 1:target.sizeM
    for j = 1:target.sizeM
        radius = ( (i-center)^2+(j-center)^2 )^(1/2);
        if radius^2>(fade_start*R_targetM)^2
            buffer(i,j) = white*cos( pi/2*(radius-fade_start*R_targetM)/fade_pixel );
        end
        if radius^2>(R_targetM)^2
            buffer(i,j)=0;
        end
        if radius^2<(fade_start*R_targetM)^2
            buffer(i,j)=white;
        end
    end
end
mask(:,:,4)=buffer;
Tmasktex_s = Screen('MakeTexture', wptr, mask);
% target location for surround
destinationTarget_s.LE = CenterRect([0,0,target.sizeM, target.sizeM], L.pos);
destinationTarget_s.RE = CenterRect([0,0,target.sizeM, target.sizeM], R.pos);
target.offset = 0.5*PPD+target.size/2; target.offset = [target.offset, 0, target.offset, 0];
destinationTarget_s.LE = [(destinationTarget_s.LE-target.offset)' (destinationTarget_s.LE+target.offset)'];
destinationTarget_s.RE = [(destinationTarget_s.RE-target.offset)' (destinationTarget_s.RE+target.offset)'];
% fixation for task

% frames for fusion
ArcWid = PPD/14;
ArcColor_1 = gray;
ArcColor_2 = white;
arc_expend = 0*[-1 -1 1 1];
destinationArc.LE.LF = destinationTarget.LEorigin + arc_expend - target.offset;
destinationArc.LE.RF = destinationTarget.LEorigin + arc_expend + target.offset;
destinationArc.RE.LF = destinationTarget.REorigin + arc_expend - target.offset;
destinationArc.RE.RF = destinationTarget.REorigin + arc_expend + target.offset;
%% time course
% pipeline
TR = 2;
n_dummy = 2;
dummy_time = n_dummy * TR;
time.before = 12*TR;
time.after = 12*TR;
time.baseline = 0;
time.cue = 0.5*TR;
time.block = 12*TR;
blockNum = 12;
blockTimes.baseline = time.before + (1:blockNum)*time.baseline + ((1:blockNum)-1)*time.block;
blockTimes.stimuli = time.before + (1:blockNum)*(time.baseline+time.block);
% central or surround first
LEfirst = mod(run,2);
% flicker
time_freq = 7.5;
switch_phase = frameRate / (time_freq*2);
whichCHB = 1;
% task
task_duration = 1;
response_time = 1.5;
taskFreq = 0.2;
taskRamp = 1;
[taskWindow_1, responseWindow_1, ~, ~, ~, ~] = ...
    generatePairedTaskSeq(time.block,task_duration, response_time, taskFreq, taskRamp);
task_alpha = zeros(blockNum+1, length(taskWindow_1));
responseWindow = zeros(blockNum+1, length(responseWindow_1));
responseDeadlines = cell(1,blockNum+1);
for block = 1:(blockNum+1)
    [taskWindow_1, responseWindow_1, responseDeadlines_1, ~, ~, ~] = ...
        generatePairedTaskSeq(time.block,task_duration, response_time, taskFreq, taskRamp);
        task_alpha(block, :) =  taskWindow_1;
        responseWindow(block,:) = responseWindow_1;
        responseDeadlines{block} = responseDeadlines_1;
end
task_alpha=task_alpha*0.8; %task_alpha(task_alpha>0.6)=0.8;
task_alpha = 1 * (1 - task_alpha);
Kb_detectWait = 0.5;
Kb_lastDetect = GetSecs;
% record the task
totalTask=0;
Performance.eachCount = []; % 0 for correct, 1 for miss, 2 for false positive.
% fill value
cueVF = ones(1,100);
%% ready to show
while 1
    Screen('SelectStereoDrawBuffer', wptr, 0);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.LE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.LE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('SelectStereoDrawBuffer', wptr, 1);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.RE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.RE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('Flip',wptr);
    
    [~,secs,keyCode ]=KbCheck(-1);
    t_count = secs;
    if keyCode(KeyS)
        break;
    end
end
WaitSecs(dummy_time);
startTime = GetSecs;
%% time before
startbefore = GetSecs;
while GetSecs-startbefore < time.before
    Screen('SelectStereoDrawBuffer', wptr, 0);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.LE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.LE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('SelectStereoDrawBuffer', wptr, 1);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.RE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.RE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('Flip',wptr);
    
end
%% show stimuli
for block_counter = 1:blockNum
%     while GetSecs - startTime < blockTimes.baseline(block_counter)
%         Screen('SelectStereoDrawBuffer', wptr, 0);
%         Screen('DrawTexture', wptr, Crosstex_task, [],destinationFixation.LE, whichVFcue);
%         for i=1:2:7
%             Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE ,(i-1)*45, 45, ArcWid);
%             Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE ,i*45, 45, ArcWid);
%             
%             Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE ,(i-1)*45, 45, ArcWid);
%             Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE ,i*45, 45, ArcWid);
%         end
%         
%         Screen('SelectStereoDrawBuffer', wptr, 1);
%         Screen('DrawTexture', wptr, Crosstex_task, [],destinationFixation.RE, whichVFcue);
%         for i=1:2:7
%             Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE ,(i-1)*45, 45, ArcWid);
%             Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE ,i*45, 45, ArcWid);
%             
%             Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE ,(i-1)*45, 45, ArcWid);
%             Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE ,i*45, 45, ArcWid);
%         end
%         
%         Screen('Flip',wptr);
%     end
    
    if mod(block_counter, 2) == LEfirst
        frame_counter = 1;
        while GetSecs - startTime < blockTimes.stimuli(block_counter)
            % for flicker
            if mod(frame_counter, switch_phase) == (switch_phase-1)
                whichCHB = 3 - whichCHB;
            end
            if whichCHB == 1
                chb_tex = chb_phase1;
            else
                chb_tex = chb_phase2;
            end
            % for task
            
            Screen('SelectStereoDrawBuffer', wptr, 0);
            Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.LE);
            Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.LE,[],[],task_alpha(block_counter, frame_counter));
             Screen('DrawTextures', wptr, chb_tex, sourceRect,destinationTarget.LE.LF);
            Screen('DrawTextures', wptr, Tmasktex, [],destinationTarget.LE.LF);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.RF ,i*45, 45, ArcWid);
    end
            
            Screen('SelectStereoDrawBuffer', wptr, 1);
            Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.RE);
            Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.RE,[],[],task_alpha(block_counter, frame_counter));
            Screen('DrawTextures', wptr, chb_tex, sourceRect,destinationTarget.RE.LF);
            Screen('DrawTextures', wptr, Tmasktex, [],destinationTarget.RE.LF);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.RF ,i*45, 45, ArcWid);
    end
            
            Screen('Flip',wptr);
            
            
            if GetSecs - Kb_lastDetect > Kb_detectWait
                [~,secs,keyCode ]=KbCheck(-1);
                if keyCode(KeyEsc)
                    break;
                end
                % stair case and percent correct
                if keyCode(KeyLeft)
                    %             sca;
                    Kb_lastDetect = secs;
                    % if hit
                end
                
            end
            
            frame_counter = frame_counter + 1;
        end
    else
        frame_counter = 1;
        while GetSecs - startTime < blockTimes.stimuli(block_counter)
            % for flicker
            if mod(frame_counter, switch_phase) == (switch_phase-1)
                whichCHB = 3 - whichCHB;
            end
            if whichCHB == 1
                chb_tex = chb_phase1;
            else
                chb_tex = chb_phase2;
            end
            % for task
            
            Screen('SelectStereoDrawBuffer', wptr, 0);
            Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.LE);
            Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.LE,[],[],task_alpha(block_counter, frame_counter));
             Screen('DrawTextures', wptr, chb_tex, sourceRect,destinationTarget.LE.RF);
            Screen('DrawTextures', wptr, Tmasktex, [],destinationTarget.LE.RF);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.RF ,i*45, 45, ArcWid);
    end
            
            Screen('SelectStereoDrawBuffer', wptr, 1);
            Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.RE);
            Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.RE,[],[],task_alpha(block_counter, frame_counter));
             Screen('DrawTextures', wptr, chb_tex, sourceRect,destinationTarget.RE.RF);
            Screen('DrawTextures', wptr, Tmasktex, [],destinationTarget.RE.RF);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.RF ,i*45, 45, ArcWid);
    end
            
            Screen('Flip',wptr);
            
            
            if GetSecs - Kb_lastDetect > Kb_detectWait
                [~,secs,keyCode ]=KbCheck(-1);
                if keyCode(KeyEsc)
                    break;
                end
                % stair case and percent correct
                if keyCode(KeyLeft)
                    %             sca;
                    Kb_lastDetect = secs;
                    % if hit
                end
                
            end
            
            frame_counter = frame_counter + 1;
        end
    end
end

%% time before
startafter = GetSecs;
while GetSecs-startafter < time.after
    Screen('SelectStereoDrawBuffer', wptr, 0);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.LE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.LE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.LE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.LE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('SelectStereoDrawBuffer', wptr, 1);
    Screen('DrawTexture', wptr, Crosstex_background, [],destinationFixation.RE);
    Screen('DrawTexture', wptr, Crosstex, [],destinationFixation.RE);
    for i=1:2:7
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.LF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.LF ,i*45, 45, ArcWid);
        
        Screen('FrameArc', wptr, ArcColor_1, destinationArc.RE.RF ,(i-1)*45, 45, ArcWid);
        Screen('FrameArc', wptr, ArcColor_2, destinationArc.RE.RF ,i*45, 45, ArcWid);
    end
    
    Screen('Flip',wptr);
    
end
%% end


clear global
sca;








































































% Screen('LoadNormalizedGammaTable',wptr,oldclut);
end