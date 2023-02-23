
clear all;
datapath = '../../data/corticalBlindness/Eyelink_asc/artificial_scotoma/';

% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
dataFile = 'hjh_invi2vi_l_2023_02_22_09_39.asc';

% Specify the path to the Eyelink asc file
asc_file_path = strcat(datapath,dataFile);

% Open the asc file
asc_file_id = fopen(asc_file_path, 'r');

% Read the data from the asc file
asc_data = textscan(asc_file_id, '%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%s%s%s%s%s', 'HeaderLines', 71);
% asc_data = textscan(asc_file_id, '%f%f%s', 'HeaderLines', 71);

% Close the asc file
fclose(asc_file_id);

% Extract the relevant data from the cell array
eye_data = [asc_data{1} asc_data{2} asc_data{3}];

% Plot the gaze data
plot(eye_data(:,1), eye_data(:,2));

% Extract relevant data from the file
gazeX = data.gx;     % gaze position x-coordinate
gazeY = data.gy;     % gaze position y-coordinate
pupilSize = data.pa; % pupil size
timeStamp = data.time; % timestamp in ms

% Convert timestamp to seconds
timeStamp = (timeStamp - timeStamp(1)) / 1000;

% Plot gaze position over time
figure
plot(timeStamp, gazeX, 'r')
hold on
plot(timeStamp, gazeY, 'b')
xlabel('Time (s)')
ylabel('Gaze Position (pixels)')
legend('X Position', 'Y Position')

% Plot pupil size over time
figure
plot(timeStamp, pupilSize)
xlabel('Time (s)')
ylabel('Pupil Size (arbitrary units)')