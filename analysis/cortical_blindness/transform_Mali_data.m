% load data of mali  and transforms it into invi2vi  format

clear all;

addpath '../../function'

%----------------------------------------------------------------------
%                   load bar_only data
%----------------------------------------------------------------------

path = '../../data/corticalBlindness/bar/blindField';
cd(path);

sbjnames = { 'mali' } ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials

s1 = string(sbjnames(1));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);

% upper visual field
% data.flashTiltDirection   it's only bar condition so there is no
% difference in different tilt direction 
% data.flashTiltDirection_bar_only = data.flashTiltDirection;
upper.bar_only = data.wedgeTiltEachBlock(1,:); %  data.wedgeTiltEachBlock(1,:) upper visual field 
lower.bar_only = data.wedgeTiltEachBlock(2,:); %  data.wedgeTiltEachBlock(2,:) lower visual field


%----------------------------------------------------------------------
%         load off_sync data   upper visual field
%----------------------------------------------------------------------

path = '../';
folderNum = 1;
folders = {'upper_field','lower_field', 'normal_field'};

thisFolderName = fullfile(path, folders{folderNum});
cd(thisFolderName);

s1 = string(sbjnames(1));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);


upper.off_sync_invi2vi = invisible2visible;
upper.off_sync_vi2invi = visible2invisible;

%----------------------------------------------------------------------
%         load off_sync data   lower visual field
%----------------------------------------------------------------------
path = '../';
folderNum = 2;
folders = {'upper_field','lower_field', 'normal_field'};

thisFolderName = fullfile(path, folders{folderNum});
cd(thisFolderName);

% sbjnames = { 'mali' } ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials

s1 = string(sbjnames(1));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);

% data.flashTiltDirection_off_sync_lower = data.flashTiltDirection;
lower.off_sync_invi2vi = invisible2visible;
lower.off_sync_vi2invi = visible2invisible;

%----------------------------------------------------------------------
%         load grab & perceived data in upper visual field
%----------------------------------------------------------------------
path = '../';
folderNum = 1;
folders = {'upper_field','lower_field', 'normal_field'};

thisFolderName = fullfile(path, folders{folderNum});
cd(thisFolderName);

% sbjnames = { 'mali' } ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials

s1 = string(sbjnames(1));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);

data.flashTiltDirection_grab_upper = data.flashTiltDirection;
upper.flash_grab_invi2vi = invisible2visible;
upper.flash_grab_vi2invi = visible2invisible;
upper.perceived_location = perceived_location; 

%----------------------------------------------------------------------
%         load grab & perceived data in lower visual field
%----------------------------------------------------------------------
path = '../';
folderNum = 2;
folders = {'upper_field','lower_field', 'normal_field'};

thisFolderName = fullfile(path, folders{folderNum});
cd(thisFolderName);

s1 = string(sbjnames(1));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);

data.flashTiltDirection_grab_lower = data.flashTiltDirection;
lower.flash_grab_invi2vi = invisible2visible;
lower.flash_grab_vi2invi = visible2invisible;
lower.perceived_location = perceived_location; 


%----------------------------------------------------------------------
%     save data format as in CB6/7   lower_field    invi2vi folder
%----------------------------------------------------------------------

data.flashTiltDirection = data.flashTiltDirection_grab_lower;
bar_only = lower.bar_only;
off_sync = lower.off_sync_invi2vi;
flash_grab = lower.flash_grab_invi2vi;
perceived_location = lower.perceived_location;
condition = 'invi2vi';

savePath = 'invi2vi/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'bar_only','off_sync','flash_grab','perceived_location','data','condition');


%----------------------------------------------------------------------
%     save data format as in CB6/7   lower_field    vi2invi folder
%----------------------------------------------------------------------

data.flashTiltDirection = data.flashTiltDirection_grab_lower;
bar_only = lower.bar_only;
off_sync = lower.off_sync_vi2invi;
flash_grab = lower.flash_grab_vi2invi;
condition = 'vi2invi';

savePath = 'vi2invi/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'bar_only','off_sync','flash_grab','data','condition');

%----------------------------------------------------------------------
%     save data format as in CB6/7   upper_field    invi2vi  folder
%----------------------------------------------------------------------

data.flashTiltDirection = data.flashTiltDirection_grab_upper;
bar_only = upper.bar_only;
off_sync = upper.off_sync_invi2vi;
flash_grab = upper.flash_grab_invi2vi;
perceived_location = upper.perceived_location;
condition = 'invi2vi';

savePath = '../upper_field/invi2vi/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'bar_only','off_sync','flash_grab','perceived_location','data','condition');


%----------------------------------------------------------------------
%     save data format as in CB6/7   upper_field    vi2invi  folder
%----------------------------------------------------------------------

data.flashTiltDirection = data.flashTiltDirection_grab_upper;
bar_only = upper.bar_only;
off_sync = upper.off_sync_vi2invi;
flash_grab = upper.flash_grab_vi2invi;
condition = 'vi2invi';


savePath = 'vi2invi/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'bar_only','off_sync','flash_grab','data','condition');

