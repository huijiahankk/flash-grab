% 2019.3.12
% We adapt this script to run a 7T experiment
% 1) change 3D to 2D presentation, adjust distance, size, fixation size to 7t projector
% 2) keep fall point to 0.05 and 0, then add reciding condition (fall point = 10)
% 3) SOA: [10 12 14] --> [8 10 12 14] (here we use optimal sequence 2, read from pre-computed par)
% 4) only keep upper visual filed stimuli
% 5) time = 6(pre-dummy) + 240 + 4(post-blank)

% dummy scan before was prolonged to 6s; the last trial was fix to 14s
% so the total time is fixed to 15*12 + 14 + 6 = 200 s

% finally, we just use fixation color task, instead of RSVP
% similar to ckflicker_localizer

% 2017.11.24, reduce the difficulty of task
%   distractor_SOA 500 --> 2000; distractor_dur 150 --> 500

% To do the new exp., 
% 1. we change the data folder to fMRI_RSVP_new. 
% 2. remove the condition of ContraEyeHit, so the total time reduce to
%    12*4*4 + 4 + 2(because random problem) = [[ 198 ]] s; 
% 3. load runsequence_new, and change block numbers to 10. only keep low
%    load condition. 

% 2017.10.28

% ########################################################################

% remove fixation point during RSVP stimuli presenting
% use make_RSVP_scan_sequence to generate a series of RSVP sequence, and
% shuffle the order of task among runs, at last, we just load a RSVP task
% type and sequence here.

% using a RSVP task to attract attention from collision stimuli, separate
% the condition into low & high attentional load.
% 
% RSVP task
% modified from "Attentional Load Modulates Responses of Human Primary
% Visual Cortex to Invisible Stimuli"
% 
% Participants monitored for targets (low-load condition, "T" of either
% color; high-load condition, blue "Z" and white "N") within a stream
% of successive letters randomly chosen from T, N, Z, M, L, K, and W and
% randomly colored blue or white (Arial, font size = 25; visual angle: 1 )
% and responded by pressing a button
% 
% modified from looming_Collision_3Ddisp_HitMissTask_3_fMRI.m [2016.12.21]


% 242+4 second per run, totally 10 runs
% note: there is 4 seconds blank after the begin of scan (in fMRI condition)
% note: because 20 trials can't be totally divided by 3[10 12 14s trial
% time condition], so we set the run duration to max duration(242) other
% than average duration(240)

% ########################################################################
% condition: StartP(4)*EndP(5) * 10(trial/cond) * 12(secs/trial) / 60 = 40m
% 
% **** we now only have 'IpsiMiss' 'IpsiNearMiss' 'IpsiLoom' 'IpsiNose'
% 'ContraLoom' five End Position conditions
% ########################################################################


%%%%%% for 3D display use in MRI %%%%%%%%%%%%%%%%%%%%%%%%%%%
% view = 0 : eyefiled in moglStereoProjection function = +(right eye view) : select buffer = 0(I dont know why) : glasses pass = right eye;
% view = 1 : eyefiled in moglStereoProjection function = -(left eye view) : select buffer = 1(I dont know why) : glasses pass = left eye;
% 
% note: when LIED in MRI scanner, the position of image on screen is L/R
% reversed (because of the reflection of mirror), HOWEVER, the image
% projected to L/R eye will keep the same, I dont know why. [LE Img -> LE;
% RE Img -> RE] 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% modified based on 3 [2016.11.23]
% 
% 1: use a formula (1-0.998*abs(hitRadius)) to replase align_coef_table
% 2: add ~keyCode(KbName('s')) in response detect [2016.12.13]
% 
% modefied based on 2
% 
% 2016.11.21: add feature: use mass center of trace in each condition as
% alignment coefficiency in start position shift procedure, so that trace
% of each condition match the most. strictly, i use the average of both
% eyes' coefficiency as final number of each condition.
% 
% NEW FEATURE:
% 1: start diameter = 1.5 meters
% 2: end depth = -2 meters; align end position together (which means to
%   vary start position slightly in one set of start point condition) 
% 3: speed = 24 m/s
% 
% NEW FEATURE(2):
% 
% 1: we use shutter glasses now to present 3D images
% 2: change start point to 2(updown)x2(leftright); 
% 3: make ball smaller, and miss condition closer to center
% 4: change start position from 5 meters from screen to 10 meters
% 5: now, change fixation from zero plane to 5 meters to screen, then shape
%   more complex to help dichopticly fuse; also make tunnel to 5 meters to
%   screen, and larger (1.61*0.91*3.5[xyz])
% 6: use isfMRI to control the different porjection relationship of two
%   eyes between 3ddisplay in 3T MRI and shutter glasses (because the
%   3ddisplay in 3T MRI is left-right-eye reversed, which is unreasonable!
% 
% the task is to judge hit(1) or miss(2)
% change the presenting mode to self pace, just like
% "QUEST_looming_Collision_3Ddisp_HitMissTask" dose
% 
% collision with 3D display presenting
%
% by JINYOU ZOU

clear all
sca;

rng('shuffle');

KbName('UnifyKeyNames');
% HideCursor;
% function looming_Collision_3Ddisp(fileName,blockNum)
Screen('Preference', 'SkipSyncTests', 2);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screenid = 0;
isfMRI = 0;  % integrate 'is3Ddisp' parameter \\ isfMRI == is3Ddisp
isstim_in_upper = 1; % 0 for lower VF, 1 for upper VF

pathName = 'data/fMRI7t/';
fileName = 'Subject01';
% blockNum=3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%sssss%%%%%%%%%%%%%%%%%%%%%%%%%%%
distanceFromDisplay = 0.75;
sizeOfMonitor = 0.35;
global GL;
AssertOpenGL;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load('RunSequence_new.mat');
% k = find(strcmp(fileName, subjNameT));
% target_type = {'O[white] O[blue]','N[white] Z[blue]','O[white] O[blue]','Z[white] N[blue]',...
%     'O[white] O[blue]','N[white] Z[blue]','O[white] O[blue]','Z[white] N[blue]',...
%     'O[white] O[blue]','N[white] Z[blue]','O[white] O[blue]','Z[white] N[blue]'};
% target_type = {'O[white] O[blue]','O[white] O[blue]','O[white] O[blue]','O[white] O[blue]',...
%     'O[white] O[blue]','O[white] O[blue]','O[white] O[blue]','O[white] O[blue]',...
%     'O[white] O[blue]','O[white] O[blue]'};
% disp('PLEASE Choose a RUN');
% choice = menu(['Choose Target: ' fileName],['RUN 1 - Target: ' target_type{run_sequence(k,1)}],['RUN 2 - Target: ' target_type{run_sequence(k,2)}],['RUN 3 - Target: ' target_type{run_sequence(k,3)}],...
%     ['RUN 4 - Target: ' target_type{run_sequence(k,4)}],['RUN 5 - Target: ' target_type{run_sequence(k,5)}],['RUN 6 - Target: ' target_type{run_sequence(k,6)}],...
%     ['RUN 7 - Target: ' target_type{run_sequence(k,7)}],['RUN 8 - Target: ' target_type{run_sequence(k,8)}],['RUN 9 - Target: ' target_type{run_sequence(k,9)}],...
%     ['RUN 10 - Target: ' target_type{run_sequence(k,10)}]);
commandwindow;


% VisualSequence.letter = [ 'O', 'N', 'Z', 'M', 'L', 'K', 'W', 'O', 'N', 'Z', 'M', 'L', 'K', 'W' ];
% for i = 1:7
%     VisualSequence.colour{i} = [255 255 255].*[0.8 0.8 0.8];   % white
% end
% for i = 8:14
%     VisualSequence.colour{i} = [255 255 255].*[0.3 0.8 1];      % blue
% end

% Distractor_1 = [4:7 11:14];
% Target_LowLoad_1 = [1 8];    % O_white, O_blue
% Target_HighLoad_1 = [2 10];    % N_white, Z_blue
% Target_HighLoad_2 = [3 9];    % Z_white, N_bluea*

Trial_Dur_s = 240;
% dosen't include dummy scan (6s)
dummy_dur = 6;
post_blank = 4;

answer = inputdlg('RUN No.', 'RUN No.', 1);
run_no = answer{1};
% SOA_ms = 1500;  %
% dur_distractor_ms = 500;

% n = run_sequence(k,choice);
% task_target = RSVP(k,n).task_target;
% RSVP_sequence = RSVP(k,n).RSVP_sequece;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% screenid=max(Screen('Screens'));
% screenRect = Screen('Rect',screenid);
% presentRECT = CenterRect([0,0,1024,768],screenRect);
presentRECT = [0 0 1024 768];
InitializeMatlabOpenGL;
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
[win , winRect] = PsychImaging('OpenWindow', screenid, 0,presentRECT,[],[],[]);%
t_zht=GetSecs;
Screen('BlendFunction',win,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% [bufferTex, bufferRect] = Screen('OpenOffScreenWindow', win, 0, [winRect(1:3) winRect(4)*2]);
% SetAnaglyphStereoParameters('FullColorAnaglyphMode', win);
% SetCompressedStereoSideBySideParameters(win, [0, 0], [1, 0.5], [0, 0.5], [1, 1]);

% CompressedRect = CenterRect([winRect(1:3) winRect(4)], winRect);
% frameRate = round(FrameRate(win));
% if frameRate ~= 120
%     Screen('CloseAll');
%     ShowCursor;
%     disp('**** frame rate is not 120!! ****')
%     return
% end

[GrandCenter(1), GrandCenter(2)]=RectCenter(winRect);

% backTex = Screen('OpenOffScreenWindow',screenid,0,CenterRect([0,0,1200,1200],screenRect));
% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':
% Screen('FillOval',bufferTex,[255 255 255],CenterRectOnPoint([0 0 5 5],GrandCenter(1),GrandCenter(2)));
% Screen('Flip', bufferTex);

% Screen('BeginOpenGL', win);
%% RSVP
% textsize = 25;

% oldFontName = Screen('TextFont', win);

frameRate = round(FrameRate(win));
% SOA_fm = SOA_ms / 1000 * frameRate;
% dur_distractor_fm = dur_distractor_ms / 1000 * frameRate;


CenterX = GrandCenter(1);
CenterY = GrandCenter(2);

% response = cell(2,1);



%% 
ball_lum  = 255;

bv = zeros(8);
wv = ones(8);
myimg = double(repmat([bv wv; wv bv],7,4) > 0.5) * ball_lum;
myimg = repmat(myimg,[1 1 3]);
myimg(:,:,3) = 0;
mytex = Screen('MakeTexture', win, uint8(myimg), [], 1);

Screen('BeginOpenGL', win);

%% random pattern as the walls
scaleFac = 1;
margin = 0.25;

grid.LowerBound = -0.455/scaleFac;
grid.UpperBound = 0.455/scaleFac;
grid.LeftBound = -0.805/scaleFac;
grid.RightBound = 0.805/scaleFac;
grid.FrontBound = -3.25/scaleFac;
grid.BackBound = -6.75/scaleFac;
%
upleftgrid = grid; lowleftgrid = grid; uprightgrid = grid; lowrightgrid = grid;

upleftgrid.LowerBound = grid.UpperBound*(1-margin);
upleftgrid.RightBound = grid.LeftBound*(1-margin);

lowleftgrid.UpperBound = grid.LowerBound*(1-margin);
lowleftgrid.RightBound = grid.LeftBound*(1-margin);

uprightgrid.LowerBound = grid.UpperBound*(1-margin);
uprightgrid.LeftBound = grid.RightBound*(1-margin);

lowrightgrid.UpperBound = grid.LowerBound*(1-margin);
lowrightgrid.LeftBound = grid.RightBound*(1-margin);
%

wall_color = 150;

random_size_x = 32;
random_size_y = 4;
random_size_z = 128;
random_resample_time = 8;
Rx = random_size_x*random_resample_time;
Ry = random_size_y*random_resample_time;
Rz = random_size_z*random_resample_time;

% Enable 2D texture mapping, so the faces of the cube will show some nice
% images:
glEnable(GL.TEXTURE_2D);

% Generate 8 textures and store their handles in vecotr 'texname'
texname=glGenTextures(8);
for i=1:8   % upper;lower;right;left
    if i <= 4
        random_size_width = random_size_x;
        Rwidth = Rx;
    else
        random_size_width = random_size_y;
        Rwidth = Ry;
    end
    % Enable i'th texture by binding it:
    glBindTexture(GL.TEXTURE_2D,texname(i));
    % Compute random pattern in matlab matrix 'random_pattern_square'
    random_pattern_square = rand(random_size_z, random_size_width)*wall_color;
    random_pattern_square = resample(random_pattern_square,random_resample_time,1,0);
    random_pattern_square = resample(random_pattern_square',random_resample_time,1,0);
    
%     random_pattern_square(round(Rwidth*margin):round(Rwidth*(1-margin)),:) = 0;
%     random_pattern_square = repmat(random_pattern_square,[1 1 3]);
    random_pattern_square = uint8(random_pattern_square);
    % Assign image in matrix 'tx' to i'th texture:
    glTexImage2D(GL.TEXTURE_2D,0,GL.LUMINANCE,Rwidth,Rz,0,GL.LUMINANCE,GL.UNSIGNED_BYTE,random_pattern_square);
    % Setup texture wrapping behaviour:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);
    % Setup filtering for the textures:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.LINEAR);
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
    % Choose texture application function: It shall modulate the light
    % reflection properties of the the cubes face:
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    
end

%% get checkerboard textures;


% Retrieve OpenGL handles to the PTB texture. These are needed to use the texture
% from "normal" OpenGL code:
[gltex, gltextarget] = Screen('GetOpenGLTexture', win, mytex);


% Enable texture mapping for this type of textures...
glEnable(gltextarget);

% Bind our texture, so it gets applied to all following objects:
glBindTexture(gltextarget, gltex);

% Textures color texel values shall modulate the color computed by lighting model:
glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);

% Clamping behaviour shall be a cyclic repeat:
glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);

% Set up minification and magnification filters. This is crucial for the thing to work!
% Checkerboard pattern: This has high frequency edges, so we'll
% need trilinear filtering for a good look:
glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

% Need mipmapping for trilinear filtering --> Create mipmaps:
% if ~isempty(findstr(glGetString(GL.EXTENSIONS), 'GL_EXT_framebuffer_object'))
    % Ask the hardware to generate all depth levels automatically:
    glGenerateMipmapEXT(gltextarget);
% else
%     % No hardware support for auto-mipmap-generation. Do it "manually":
%     
%     % Use GLU to compute the image resolution mipmap pyramid and create
%     % OpenGL textures ouf of it: This is slow, compared to glGenerateMipmapEXT:
%     r = gluBuild2DMipmaps(gltextarget, GL.LUMINANCE, size(myimg,1), size(myimg,2), GL.LUMINANCE, GL.UNSIGNED_BYTE, uint8(myimg));
%     if r>0
%         error('gluBuild2DMipmaps failed for some reason.');
%     end
% end


% % Set basic "color" of object to white to get a nice interaction between the texture
% % and the objects lighting:
% glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 1 1 1 1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);
% 
% % Reset our virtual camera and all geometric transformations:
% glMatrixMode(GL.MODELVIEW);
% glLoadIdentity;
% Create the sphere as a quadric object. This is needed because the simple glutSolidSphere
% command does not automatically assign texture coordinates for texture mapping onto a sphere:
% mysphere is a handle that you need to pass to all quadric functions:
mysphere = gluNewQuadric;

% Enable automatic generation of texture coordinates for our quadric object:
gluQuadricTexture(mysphere, GL.TRUE);


%%

% Get the aspect ratio of the screen:
ar=winRect(4)*2/winRect(3);
glViewport(0, 0, RectWidth(winRect), RectHeight(winRect));

% % Turn on OpenGL local lighting model: The lighting model supported by
% % OpenGL is a local Phong model with Gouraud shading.
%  
glEnable(GL.LIGHTING);
% glColor3f(1,1,1);

% Enable the first local light source GL_LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources.
% glEnable(GL.LIGHT1);
% glEnable(GL.BLEND);
% glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

% Enable two-sided lighting - Back sides of polygons are lit as well.
% glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);

% Enable proper occlusion handling via depth tests:
glEnable(GL.DEPTH_TEST);

% Define the sphere light reflection properties by setting up reflection
% coefficients for ambient, diffuse and specular reflection:
glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT,  [ .9 .9 .9 1 ]);
glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE,  [ .9 .9 .9 1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.SPECULAR, [ 1 1 1 0.1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.SHININESS,64);


% % Set projection matrix: This defines a perspective projection,
% % corresponding to the model of a pin-hole camera - which is a good
% % approximation of the human eye and of standard real world cameras --
% % well, the best aproximation one can do with 3 lines of code ;-)
% glMatrixMode(GL.PROJECTION);
% glLoadIdentity;

% Field of view is +/- 25 degrees from line of sight. Objects close than
% 0.1 distance units or farther away than 100 distance units get clipped
% away, aspect ratio is adapted to the monitors aspect ratio:
% FOV = atand(sizeOfMonitor/2/distanceFromDisplay)*2;

% gluPerspective(FOV,1/ar,0.1,10000000);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;




% Cam is located at 3D position (0,0,10), points upright (0,1,0) and fixates
% at the origin (0,0,0) of the worlds coordinate system:
gluLookAt(0,0,0,0,0,-100,0,1,0);

% Setup position and emission properties of the light source:

% Set background color to 'black':
glClearColor(0,0,0,0);

% % Point lightsource at (1,2,3)...
% glLightfv(GL.LIGHT0,GL.POSITION,[ 0 0 1 0 ]);
%
% % Emits white (1,1,1,1) diffuse light:
glLightfv(GL.LIGHT0,GL.AMBIENT, [ .5 .5 .5 1 ]);
glLightfv(GL.LIGHT0,GL.DIFFUSE, [ .5 .5 .5 1 ]);
glEnable(GL.LIGHT0);

% Our point lightsource is at position (x,y,z) == (1,2,3)...
% glLightfv(GL.LIGHT0,GL.POSITION,[ 0 0 -100 0 ]);
% glLightfv(GL.LIGHT1,GL.POSITION,[ -1 0 -0.8 0]);


% glLightfv(GL.LIGHT1,GL.DIFFUSE, [ 1 1 1 1 ]);
% glLightfv(GL.LIGHT1,GL.POSITION,[ 1 2 3 0 ]);

% % Emits reddish (1,1,1,1) specular light:
% glLightfv(GL.LIGHT0,GL.SPECULAR, [ 1 0 0 1 ]);
%
% % There's also some blue, but weak (R,G,B) = (0.1, 0.1, 0.1)
% % ambient light present:
% glLightfv(GL.LIGHT0,GL.AMBIENT, [ .1 .1 .1 1 ]);

glClear;

% GetClicks;
% trialData = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4;0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1;1 1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 -1 -1]';
Screen('EndOpenGL', win);

%%

% drawGrid = 1;


% if blockNum==1
% else
%     load(fileName);
% end
% fixTargetTime = [2.5:5:237.5];
% fixTargetTime = fixTargetTime+2*(rand(size(fixTargetTime))-0.5)*2.5;
% targets = Shuffle(1:numel(fixTargetTime));
% targets = targets(1:end/2);
% fixK = 1;fixTarget = 0;

% fixTargeTime = 0;
% for i=1:100
%     fixTargeTime = [fixTargeTime fixTargeTime(end)+rand*4+2];
% end

% fixTargeFrame = floor(fixTargeTime(2:end)*60);
% if is3Ddisp
%     views = [0 1];
% else
%     views = 0;
% end

upfaceTexs = fliplr([ 1 2 6 5 ]);
lowfaceTexs = fliplr([ 3 4 8 7 ]);
rightfaceTexs = fliplr([ 2 3 7 6 ]);
leftfaceTexs = fliplr([ 4 1 5 8 ]);


for i=1:2
for view=[0 1]
    Screen('SelectStereoDrawBuffer', win, isfMRI+((-1)^isfMRI)*view);   %  see "for 3D display use in MRI"
    % if is not fMRI, then it is not 3D display
    if ~isfMRI
        view = 0;
    end
    
%     bufferTex(view+1) = Screen('MakeTexture', win, zeros(winRect(3),winRect(4)));
% rightviewTex = Screen('MakeTexture', win, zeros(winRect(3),winRect(4)));

    Screen('BeginOpenGL', win);
    % Setup camera for this eyes 'view':
    glClear;
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;
% 
    near = distanceFromDisplay-0.1;far = -10;
    zero_plane = 0;
    dist = distanceFromDisplay - zero_plane;
    win_x = sizeOfMonitor/2;
    win_y = ar*win_x;
    obser2fix = 5 + distanceFromDisplay;
    eyeeccen = 0;
    
    fixshift_pix = funFixationStereoShift(distanceFromDisplay, obser2fix, eyeeccen, winRect(3), sizeOfMonitor);
%     fixshift_pix = funFixationStereoShift(obser2screen, obser2fix, eyeeccen, pix_screen, screen_width);

    moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen*2*(view-0.5));
%     moglStereoProjection(left, right, top, bottom, near, far, zero_plane, dist, eye)

%     glFrustum(-0.351,  .351,  -0.351,  .351, 1,  20);
%     gluPerspective(FOV,1/ar,0.1,10000000);

%     glMatrixMode(GL.MODELVIEW);
%     glLoadIdentity;
%     gluLookAt(0,0,0,0,0,-5,0,1,0);

    glClear;
    
%     glScalef(1/15,1/15,1/15);
    epx = 0.15;
    epy = 0.28;

%     funTunnelWallGl(upfaceTexs,texname(1),upleftgrid, epx);
%     funTunnelWallGl(lowfaceTexs,texname(2),lowleftgrid, epx);
%     funTunnelWallGl(upfaceTexs,texname(3),uprightgrid, epx);
%     funTunnelWallGl(lowfaceTexs,texname(4),lowrightgrid, epx);
    funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
    funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);

    
    funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
    funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
    funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
    funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
%     glScalef(1/15,1/15,1/15);

%     glTranslatef(1, 1, 10);
%     glRotatef(90, 1, 0, 0);
%     glRotatef(3, 0, 0, 1);
%     gluSphere(mysphere, ballSize, slices, stacks);
    Screen('EndOpenGL', win);
    
    %fixation at zeroplane
    fixcolorfactor = 0.7;
    fixshrinkfactor = 0.6;
    
    width_fixTex = round(41*fixshrinkfactor);
    crossRadius = round(20*fixshrinkfactor);
    ovalDiameter = round(30*fixshrinkfactor);
    innerovalDiameter = round(20*fixshrinkfactor);
    newm = zeros(width_fixTex,width_fixTex,4);
    fixTex = Screen('MakeTexture', win, uint8(newm));
    fixRect = Screen('Rect',fixTex);
    [FixCenter(1), FixCenter(2)]=RectCenter(fixRect);
    Screen('FrameOval',fixTex,128*fixcolorfactor,CenterRect([0 0 ovalDiameter ovalDiameter],fixRect),5);
    Screen('FrameOval',fixTex,210*fixcolorfactor,CenterRect([0 0 crossRadius*2 crossRadius*2],fixRect),3);
    Screen('DrawLine',fixTex,[1 1 1]*210*fixcolorfactor,FixCenter(1)-crossRadius,FixCenter(2),FixCenter(1)+crossRadius,FixCenter(2),3);
    Screen('DrawLine',fixTex,[1 1 1]*210*fixcolorfactor,FixCenter(1),FixCenter(2)-crossRadius,FixCenter(1),FixCenter(2)+crossRadius,3);
    Screen('FillOval',fixTex,[255 0 0]*fixcolorfactor,CenterRect([0 0 innerovalDiameter innerovalDiameter],fixRect));

    fixRect_orig = CenterRect(fixRect./[1 1 1 2].*[1.25 1.25 1.25 1.25],winRect);
    fixRect_leftshift = OffsetRect(fixRect_orig,-fixshift_pix,0);
    fixRect_rightshift = OffsetRect(fixRect_orig,fixshift_pix,0);
    fixRect_leftUPshift = OffsetRect(fixRect_orig,-fixshift_pix-width_fixTex,-width_fixTex);
    fixRect_rightUPshift = OffsetRect(fixRect_orig,fixshift_pix-width_fixTex,-width_fixTex);
    fixRect_leftUPshift2 = OffsetRect(fixRect_orig,-fixshift_pix+width_fixTex,-width_fixTex);
    fixRect_rightUPshift2 = OffsetRect(fixRect_orig,fixshift_pix+width_fixTex,-width_fixTex);
    
%     for k = 1:numel(VisualSequence.letter)
%         fixTex_RSVP(k) = Screen('MakeTexture', win, uint8(newm));
% %         Screen('FrameOval',fixTex_RSVP(k),128*fixcolorfactor,CenterRect([0 0 ovalDiameter ovalDiameter],fixRect),5);
%         Screen('FrameOval',fixTex_RSVP(k),210*fixcolorfactor,CenterRect([0 0 crossRadius*2 crossRadius*2],fixRect),3);
% %         Screen('DrawLine',fixTex_RSVP(k),[1 1 1]*210*fixcolorfactor,FixCenter(1)-crossRadius,FixCenter(2),FixCenter(1)+crossRadius,FixCenter(2),3);
% %         Screen('DrawLine',fixTex_RSVP(k),[1 1 1]*210*fixcolorfactor,FixCenter(1),FixCenter(2)-crossRadius,FixCenter(1),FixCenter(2)+crossRadius,3);
% %         Screen('FillOval',fixTex_RSVP(k),[255 0 0]*fixcolorfactor,CenterRect([0 0 innerovalDiameter innerovalDiameter],fixRect));
%         
%         Screen('TextSize', fixTex_RSVP(k), textsize);
%         Screen('TextFont', fixTex_RSVP(k), 'Arial');
%         DrawFormattedText(fixTex_RSVP(k), VisualSequence.letter(k), 'center' , 'center' , VisualSequence.colour{k}, [],1, [], [], [], fixRect);
%     end
%     fixTex_blank = Screen('MakeTexture', win, uint8(newm));
%     Screen('FrameOval',fixTex_blank,210*fixcolorfactor,CenterRect([0 0 crossRadius*2 crossRadius*2],fixRect),3);
%     
%     fixTex_instruction = Screen('MakeTexture', win, uint8(newm));
%     Screen('TextSize', fixTex_instruction, textsize);
%     Screen('TextFont', fixTex_instruction, 'Arial');
%     DrawFormattedText(fixTex_instruction, VisualSequence.letter(task_target(1)), 'center' , 'center' , VisualSequence.colour{task_target(1)}, [],[], [], [], [], fixRect);

    if view
        Screen('DrawTexture',win,fixTex,[],fixRect_rightshift);
%         Screen('DrawTexture',win,fixTex_RSVP(task_target(1)),[],fixRect_rightUPshift);
%         Screen('DrawTexture',win,fixTex_RSVP(task_target(2)),[],fixRect_rightUPshift2);
    else
        Screen('DrawTexture',win,fixTex,[],fixRect_leftshift);
%         Screen('DrawTexture',win,fixTex_RSVP(task_target(1)),[],fixRect_leftUPshift);
%         Screen('DrawTexture',win,fixTex_RSVP(task_target(2)),[],fixRect_leftUPshift2);
    end
end
Screen('Flip', win);
% Screen('Close', bufferTex(1));
% Screen('Close', bufferTex(2));

end

fix_task_dur = 2;
fix_task_color = [0 255 0];
% might be fixation task or stimuli related task
n = 0;total_time = 0;task_response = [];task_response_time = [];
prekeyIsDown = 0;
while total_time <= Trial_Dur_s + dummy_dur + post_blank + 1
    n = n+1;
    total_time = total_time + randsample(8:4:32, 1) + fix_task_dur;
    task_start(n) = total_time - fix_task_dur;
    task_end(n) = total_time;
end
n=1;

imageArray=Screen('GetImage', fixTex);
fixTaskTex = Screen('MakeTexture', win, imageArray);
Screen('FillOval',fixTaskTex,fix_task_color.*fixcolorfactor,CenterRect([0 0 innerovalDiameter innerovalDiameter],fixRect));

%% start!
% the orientation described below is all normal view, not fMRI view
% in fMRI view, left right are all reversed!!(already confirmed)
% if isfMRI
paramatrix{1} = [1 5];        %start point/angle (unit circle) (0 is rightward, then rotate at ccw )
paramatrix{2} = [0];                   %end point/angle (0 is rightward, 6 is leftward )
% temp = fun_EndPTable(fileName);    %miss/hit in radius  (Ipsi(-) or Contra(+) to startP)
% paramatrix{3} = temp([1:4]);
paramatrix{3} = [-0.05 0 10];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% here the 10 just indicate the reciding condition ("fall point"=0) %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramatrix{4} = [24];                  % m/s speed of flying ball
paramatrix{5} = [8 10 12 14];            % trial time (SOA)

trial_number = 24;
isEndIpCont = 1;  % now we use 'Ipsi or Contra to start Posit' as EndP Input BUT still Output as 'Left or Right'
% else
%     paramatrix{1} = [1 5 7 11];        %start point/angle (unit circle) (0 is rightward, then rotate at ccw )
%     % paramatrix{1} = [5];        %start point/angle (unit circle) (0 is rightward, then rotate at ccw )
%     paramatrix{2} = [0];                   %end point/angle (0 is rightward, 6 is leftward )
%     paramatrix{3} = [-0.1 -0.06 -0.03 0 0.03 0.06 0.1];    %miss/hit in radius  (left(-) to right(+))
%     % paramatrix{3} = [-0.03 0.03];    %miss/hit in radius  (left(-) to right(+))
%     paramatrix{4} = [24];                  % m/s speed of flying ball   12
%     paramatrix{5} = [2 3];                 % trial time (SOA)
%     
%     trial_number = 112;
%     isEndIpCont = 0;
% end
    
% % % % % trialData = fun_datamk(trial_number, paramatrix);
% % % % % % now we change 'IpsiContraEndP' back to 'LeftRightEndP' [left(-) to right(+)]
% % % % % if isEndIpCont
% % % % %     leftJudge = [4 5 6 7 8];
% % % % %     for trialN = 1:trial_number
% % % % %         trialData(trialN,3) = trialData(trialN,3) * (ismember(trialData(trialN,1),leftJudge)-0.5) * 2;
% % % % %     end
% % % % % end
% % % % % 
% % % % % % fix the last trial to 14s
% % % % % trialData(trial_number,5) = paramatrix{5}(end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% here we load optseq2 par and construct the trialData mat %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[timepoint,stim_type,SOA,~,~] = read_optseq2_data(['optimal_seq/' fileName '/par-00' run_no '.par']);
trialData(:,5) = SOA(2:2:end)+2;
trialData(:,4) = 24;
trialData(:,2) = 0;
if isstim_in_upper
    stim_type_map_startangle = [5 5 5 1 1 1];
else
    stim_type_map_startangle = [7 7 7 11 11 11];
end
stim_type_map_hit_radius = [0 -0.05 10 0 0.05 10];
trialData(:,1) = stim_type_map_startangle(stim_type(1:2:end));
trialData(:,3) = stim_type_map_hit_radius(stim_type(1:2:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% here we load optseq2 par and construct the trialData mat %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

startPointZ = -10; %
hitPointZ = distanceFromDisplay; %
startDiscR = 0.75;

% according to every end position condition [-0.1 -0.03 0 0.03 0.1]
% align_coef_table = [ mean([0.885,0.775])  mean([0.885,0.775,1,0.91]) mean([1,0.91]) mean([1,1]) mean([1,0.91]) mean([0.885,0.775,1,0.91]) mean([0.885,0.775])];

ballSize = 0.03;%radius in meter
slices = 100;stacks = 100;
QuitFlag = 0;

response = zeros(trial_number,4);  % 1 is keypress; 2 is keypress time; 3 is looming start time; 4 is looming end time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frameRSVP = -1;
% task_response_time = cell(2,1);

while 1
    [ ~, ~, keyCode ] = KbCheck(-1);
    if keyCode(KbName('s'))
        break,
    end
end
blockOnset = GetSecs;
for view=[0 1]
    Screen('SelectStereoDrawBuffer', win, isfMRI+((-1)^isfMRI)*view);   %  see "for 3D display use in MRI"
    % if is not fMRI, then it is not 3D display
    if ~isfMRI
        view = 0;
    end

    Screen('BeginOpenGL', win);
    % Setup camera for this eyes 'view':
    glClear;
    glMatrixMode(GL.PROJECTION);
    glLoadIdentity;

    moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen*2*(view-0.5));
    glClear;

    funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
    funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);

    
    funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
    funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
    funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
    funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);

    Screen('EndOpenGL', win);
    
    if view
        Screen('DrawTexture',win,fixTex,[],fixRect_rightshift);
    else
        Screen('DrawTexture',win,fixTex,[],fixRect_leftshift);
    end
end
Screen('Flip', win);

while GetSecs - blockOnset <= dummy_dur
end
RestrictKeysForKbCheck([KbName('ESCAPE') KbName('1!') KbName('1')]);

% frameK = 0;


for Ntrial = 1:trial_number
    
    startAngle = trialData(Ntrial,1)/6*pi;
    hitAngle = trialData(Ntrial,2)/6*pi;
    hitRadius = trialData(Ntrial,3);
    BallSpeed = trialData(Ntrial,4);  % m/s
    trialFrames = frameRate*trialData(Ntrial,5);
    if hitRadius == 10
        hitRadius=0;
        reciding_flag = 1;
    else
        reciding_flag = 0;
    end
    rotDirection = randsample([-1 1], 1);
    %     movingDirection = 1;
    
    startX = startDiscR*cos(startAngle);
    startY = startDiscR*sin(startAngle);
    startZ = startPointZ;
    
    hitX = hitRadius*cos(hitAngle);
    hitY = hitRadius*sin(hitAngle);
    hitZ = hitPointZ;
    
    endZ = -2;%-1*distanceFromDisplay;

    
    % for produce the same projection to retina, we align end position
    % together
    standard_hitX = 0;
    align_endZ = (endZ - startZ)*(1-0.998*abs(hitRadius)) + startZ;
    startX = funAlignEndPosition(startX, startZ, hitX, hitZ, align_endZ, standard_hitX);

    DisStart2Hit = sqrt((hitX - startX)^2 + (hitY - startY)^2 + (hitZ - startZ)^2);
    VirtFlyFrames = DisStart2Hit/BallSpeed * frameRate;     % (from START to HIT (not END)
    
    dx = (hitX-startX)/VirtFlyFrames;
    dz = (hitZ-startZ)/VirtFlyFrames;
    traceY = funGravity(startY,hitY,VirtFlyFrames);
%     dy = (endY-startY)/VirtFlyFrames;

%     endX = startX-(startX-hitX)*(startZ-endZ)/(startZ-hitZ);
%     endY = startY-(startY-hitY)*(startZ-endZ)/(startZ-hitZ);
    PresentFlyFrames = round(VirtFlyFrames*(endZ-startZ)/(hitZ-startZ));  % the actually ball presenting duration (from START to END)    
    x1=startX;y1=startY;z1=startZ;

    trialendtime = sum(trialData(1:Ntrial,5))+dummy_dur;
%     frameK = -frameRate*0.8; % wait 800 ms after the end of last trial
    frameK = 0;
    while GetSecs - blockOnset < trialendtime
        frameK = frameK + 1;
%         frameRSVP = frameRSVP + 1;
%         letterN = floor(frameRSVP./SOA_fm) + 1;
%         letterID = RSVP_sequence(letterN);
        
time_now = GetSecs - blockOnset;

        for view=[0 1]
            Screen('SelectStereoDrawBuffer', win, isfMRI+((-1)^isfMRI)*view);
            % if is not fMRI, then it is not 3D display
            if ~isfMRI
                view = 0;
            end
            
            Screen('BeginOpenGL', win);
            % Setup camera for this eyes 'view':
            glClear;
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen*2*(view-0.5));
            
            % background walls
            glClear;
            glScalef(scaleFac,scaleFac,scaleFac);
            
            %     funTunnelWallGl(upfaceTexs,texname(1),upleftgrid, epx);
            %     funTunnelWallGl(lowfaceTexs,texname(2),lowleftgrid, epx);
            %     funTunnelWallGl(upfaceTexs,texname(3),uprightgrid, epx);
            %     funTunnelWallGl(lowfaceTexs,texname(4),lowrightgrid, epx);
            funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
            funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
            
            
            funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
            funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
            
            glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
            
            % flying balls
            if frameK<=PresentFlyFrames && frameK > 0
                glBindTexture(gltextarget, gltex);
                if reciding_flag == 1
                    fk_tmp = PresentFlyFrames - frameK + 1;
                    glTranslatef(x1+dx*fk_tmp, traceY(fk_tmp), z1+dz*fk_tmp);
                else
                    glTranslatef(x1+dx*frameK, traceY(frameK), z1+dz*frameK);
                end
                glRotatef(90, 1, 0, 0);
                glRotatef(4*frameK, 0, rotDirection, 0);
                gluSphere(mysphere, ballSize, slices, stacks);
            end
            
            Screen('EndOpenGL', win);
            
            if view
                Screen('DrawTexture',win,fixTex,[],fixRect_rightshift);
            else
                Screen('DrawTexture',win,fixTex,[],fixRect_leftshift);
            end
            if time_now > task_start(n) && time_now < task_end(n)
                fixtask_alpha = NormalPDF(time_now,(task_start(n)+task_end(n))/2,0.16);
                if view
                    Screen('DrawTexture',win,fixTaskTex,[],fixRect_rightshift, [],[],fixtask_alpha);
                else
                    Screen('DrawTexture',win,fixTaskTex,[],fixRect_leftshift,  [],[],fixtask_alpha);
                end
            else
                if time_now > task_end(n)
                    n = n+1;
                end
            end
        
            % fixation image
%             if frameRSVP - (letterN-1)*SOA_fm > dur_distractor_fm
%                 if view
%                     Screen('DrawTexture',win,fixTex_blank,[],fixRect_rightshift);
%                 else
%                     Screen('DrawTexture',win,fixTex_blank,[],fixRect_leftshift);
%                 end
%             else
%                 if view
%                     Screen('DrawTexture',win,fixTex_RSVP(letterID),[],fixRect_rightshift);
%                 else
%                     Screen('DrawTexture',win,fixTex_RSVP(letterID),[],fixRect_leftshift);
%                 end
%             end
        end
        %         [QuitFlag,response] = fixResponseCheck(response,fixK,fixTargetOffset,loomingOffset);

        if frameK == 1
            response(Ntrial,3) = time_now;
        elseif frameK == PresentFlyFrames+1
            response(Ntrial,4) = time_now;
        end
        [ keyIsDown, keysecs, keyCode ] = KbCheck(-1);
        if keyIsDown && ~prekeyIsDown
            if keyCode(KbName('ESCAPE'))
                QuitFlag=1;
            else
                task_response(end+1) = find(keyCode,1);
                task_response_time(end+1) = keysecs - blockOnset;
            end
        end
        prekeyIsDown = keyIsDown;
%         if ~mod(frameRSVP, 900)
%             fun_RSVP_response_check(RSVP_sequence, task_target, response_RSVP{2}, SOA_fm, frameRSVP, frameRate, Trial_Dur_s)
%         end
        Screen('Flip', win);
%         if GetSecs - blockOnset >= trialendtime;
%             break
%         end
        if QuitFlag, break, end
    end
    if QuitFlag, break, end
    
    if mod(Ntrial,2)
%         att_task_time_now = att_task_time(1:seqN);
        fun_CheckTaskPerformance(task_start(1:n),task_response_time,2+fix_task_dur/2)
    end
    
end
if ~QuitFlag
    WaitSecs(post_blank);
end
GetSecs - blockOnset
t_zht=GetSecs-t_zht;
disp(t_zht)
Screen('CloseAll');
% ShowCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fun_RSVP_response_check(RSVP_sequence, task_target, response_RSVP{2}, SOA_fm, frameRSVP, frameRate, Trial_Dur_s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~QuitFlag
    isExpUnderWin = IsWin;
    blockNum = numel(dir([pathName fileName '-*']))+1;
    save([pathName fileName '-' num2str(blockNum) '-run_' run_no]);
end



