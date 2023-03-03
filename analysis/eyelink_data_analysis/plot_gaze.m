
clear all;

addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/blurredBoundary/artificial_scotoma/normal/';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
dataFile = 'hjh_normal_n_2023_02_28_10_00.edf';

edfStruct = edfmex(dataFile);


index = find(strcmp(a.message,'TRIALID 1'));
x = a.gsty(index);

for i = 1:size(edfStruct.FEVENT.sttime , 2)
    
trial_indices = find(strcmp(edfStruct.FEVENT.message, 'TRIALID 1'));

trial_indices = find(edfStruct.FEVENT.message(:) == 'TRIALID 1');

gstxIndex = find(contains(edfStruct.FEVENT.message, 'GSTX:'));
gstxValue = str2double(split(edfStruct.FEVENT.message{gstxIndex}, ' ')[2]);


edfStruct.FEVENT.message == 'BLOCKID 1';
edfStruct.FEVENT.message.trial == 'TRIALID 1';

edfStruct.FEVENT.gstx
edfStruct.FEVENT.gsty

edfStruct.FEVENT.time 

fixEvents = [];
% Extract the fixation data from the EDF file
fixEvents = edfStruct.FEVENT.gstx(strcmp(edfStruct.FEVENT.message(:),'BLOCKID 1'));
fixationEvents = edfStruct.FEVENT(strcmp({edfStruct.FEVENT.type}, 'EFIX'));


Index = strcmp(edfStruct.FEVENT.message(:),'BLOCKID 1')

fieldnames(edfStruct.FEVENT)


% % Plot the gaze data
plot(edfStruct.FEVENT.gstx, edfStruct.FEVENT.gsty);
% 
% % Extract relevant data from the file
% gazeX = data.gx;     % gaze position x-coordinate
% gazeY = data.gy;     % gaze position y-coordinate
% pupilSize = data.pa; % pupil size
% timeStamp = data.time; % timestamp in ms
% 
% % Convert timestamp to seconds
% timeStamp = (timeStamp - timeStamp(1)) / 1000;
% 
% % Plot gaze position over time
% figure
% plot(timeStamp, gazeX, 'r')
% hold on
% plot(timeStamp, gazeY, 'b')
% xlabel('Time (s)')
% ylabel('Gaze Position (pixels)')
% legend('X Position', 'Y Position')
% 
% % Plot pupil size over time
% figure
% plot(timeStamp, pupilSize)
% xlabel('Time (s)')
% ylabel('Pupil Size (arbitrary units)')



