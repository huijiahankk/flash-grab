
clear all;
datapath = '../../data/corticalBlindness/Eyelink_asc/blurredBoundary/artificial_scotoma/';

% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
dataFile = 'hjh_invi2vi_l_2023_02_23_09_25.asc';

% Specify the path to the Eyelink asc file
asc_file_path = strcat(datapath,dataFile);

% Open the asc file
asc_file_id = fopen(asc_file_path, 'r');
% read the file line by line
line = fgetl(asc_file_id);

while ischar(line)
    % check if the line contains eye data
    if strncmp(line, 'E', 1) == 1
        % extract the relevant information from the line
        fields = strsplit(line, '\t');
        time = str2double(fields{2});
        x = str2double(fields{3});
        y = str2double(fields{4});
        
        % do something with the eye data
        disp([time, x, y]);
    end
    
    % read the next line
    line = fgetl(asc_file_id);
end

% close the file
fclose(fid);
This script reads the Eyelink data file line by line and checks if each line contains eye data (identified by the 'E' at the beginning of the line). If a line contains eye data, it extracts the relevant information (time, x position, and y position) using the strsplit function and converts the strings to doubles using the str2double function. Finally, the script displays the eye data using the disp function, but you can modify this part to process the data as needed. Note that the script assumes that the Eyelink data is tab-separated and contains no header information. If your data is different, you may need to modify the script accordingly.






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