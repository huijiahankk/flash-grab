
clear all;

addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/sector/blindspot/xs/';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
cd(datapath);
dataFile = 'xs_invi2vi_l_2023_03_29_20_26.edf';
edfStruct = edfmex(dataFile);
edfTable.FEVENT = struct2table(edfStruct.FEVENT);

xCenter = 1280;
yCenter = 720;


index_flash = find(strcmp(edfTable.FEVENT.message,'flash'));
index_trial_a = find(strcmp(edfTable.FEVENT.message,'TRIALID 2'));
index_trial_b = find(strcmp(edfTable.FEVENT.message,'TRIALID 3'));

for a = 1:length(index_trial_a)
 index_between_trial(a) = index_trial_b(a) - index_trial_a(a);
end


data.row = max(index_between_trial);
[trialOnset.x,trialOnset.y] = deal(zeros(data.row,length(index_between_trial)));


for i = 1:length(index_trial_a)
    trialOnset.x(1:index_between_trial(i),i) = edfTable.FEVENT.gstx(index_trial_a(i) : index_trial_a(i) + index_between_trial(i) - 1);
    trialOnset.y(1:index_between_trial(i),i) = edfTable.FEVENT.gsty(index_trial_a(i) : index_trial_a(i) + index_between_trial(i) - 1);
    plot(nonzeros(trialOnset.x(:,i)), nonzeros(trialOnset.y(:,i)));
    hold on;
end

hold on;
plot(xCenter,yCenter,'bo');
 
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



