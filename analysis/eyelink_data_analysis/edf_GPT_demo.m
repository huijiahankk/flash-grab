clear all;

addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/sector/blindspot/lxy/';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
cd(datapath);
dataFile = 'lxy_invi2vi_l_2023_03_23_11_14.edf';
% Read EDF data into MATLAB
edf = edfmex(dataFile);

% Extract event and sample data
events = edf.FEVENT;
samples = edf.FSAMPLE;

% Extract x and y coordinates and sample times
x = [samples.gx];
y = [samples.gy];
sample_time = [samples.time]; % Extract time data and rename to 'sample_time' to avoid conflict

% Identify blinks (represented as -32768 in x)
blink_idx = (x(2,:) == -32768);

% % Create a logical index to exclude blinks
no_blinks_idx = ~blink_idx;


% Extract x and sample_time data for non-blink periods
x_no_blinks = x(2, no_blinks_idx);
sample_time_no_blinks = sample_time(no_blinks_idx);

% Plot x gaze position over time
figure;
plot(sample_time, x_no_blinks);
title('X Gaze Position Over Time');
xlabel('Time (ms)');
ylabel('X Position');

% Detect "flash" messages
flash_events = events(strcmp({events.message}, 'flash'));

% If there are "flash" events, mark them on the plot
if ~isempty(flash_events)
    hold on;
    flash_times = [flash_events.sttime];
    for i = 1:length(flash_times)
        % Find the samples after each flash
        post_flash_samples = sample_time_no_blinks > flash_times(i);
        % Plot these samples with a different color
        plot(sample_time_no_blinks(post_flash_samples), x_no_blinks(post_flash_samples), 'r');
    end
    hold off;
end




% trial_start_msg = 'TRIALID 1';
% trial_start_msg_number = 0;
% trial_end_msg = 'TRIALID 2';
% trial_end_msg_number = 0;
% 
% 
% start_time = -1;
% end_time = -1;
% 
% 
% for i = 1:length(edf.FEVENT)
%     if strcmp(edf.FEVENT(i).message, trial_start_msg)
%         trial_start_msg_number = trial_start_msg_number + 1;
%         start_time(trial_start_msg_number) = edf.FEVENT(i).sttime;
%     elseif strcmp(edf.FEVENT(i).message, trial_end_msg)
%         trial_end_msg_number = trial_end_msg_number + 1;
%         end_time(trial_end_msg_number) = edf.FEVENT(i).sttime;
%     end
% end
% 
% % Assuming you have start_time and end_time arrays from the previous script
% num_events = length(start_time);
% 
% % Assuming you have start_time and end_time arrays from the previous script
% figure;
% smooth_window = 10;  % Choose an appropriate window size for smoothing
% 
% for i = 1:num_events
%     % Get the start and end time for the current event
%     event_start_time = start_time(i);
%     event_end_time = end_time(i);
%     
%     % Find the indices corresponding to the start and end times in the FSAMPLE time data
%     start_idx = find(edf.FSAMPLE.time == event_start_time, 1);
%     end_idx = find(edf.FSAMPLE.time == event_end_time, 1);
%     
%     % Extract the x_positions and corresponding time data for the current event
%     x_positions = edf.FSAMPLE.gx(2, start_idx:end_idx);
%     time_data = edf.FSAMPLE.time(start_idx:end_idx);
%     
%     
%     % Replace 0 values with NaN
%     x_positions(x_positions == 0) = NaN;
%     
%     % Plot the x_positions with respect to time
% %     figure;
%     plot(time_data, x_positions);
%     title('X Positions with 0 Values Replaced by NaN');
%     xlabel('Time');
%     ylabel('X Position');
%     hold on;
% end
