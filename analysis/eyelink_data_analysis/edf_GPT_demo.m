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

% % Determine the missing data value
% missing_data_value = -32768;
%
% % Create a logical index for missing data in the second row of FSAMPLE.gx
% missing_data_indices = edf.FSAMPLE.gx(2, :) == missing_data_value;
%
% % Extract the missing data
% missing_data = edf.FSAMPLE.gx(2, missing_data_indices);


trial_start_msg = 'TRIALID 1';
trial_start_msg_number = 0;
trial_end_msg = 'TRIALID 2';
trial_end_msg_number = 0;

start_time = -1;
end_time = -1;


for i = 1:length(edf.FEVENT)
    if strcmp(edf.FEVENT(i).message, trial_start_msg)
        trial_start_msg_number = trial_start_msg_number + 1;
        start_time(trial_start_msg_number) = edf.FEVENT(i).sttime;
    elseif strcmp(edf.FEVENT(i).message, trial_end_msg)
        trial_end_msg_number = trial_end_msg_number + 1;
        end_time(trial_end_msg_number) = edf.FEVENT(i).sttime;
    end
end

% Assuming you have start_time and end_time arrays from the previous script
num_events = length(start_time);

% Assuming you have start_time and end_time arrays from the previous script
figure;
smooth_window = 10;  % Choose an appropriate window size for smoothing

for i = 1:num_events
    % Get the start and end time for the current event
    event_start_time = start_time(i);
    event_end_time = end_time(i);
    
    % Find the indices corresponding to the start and end times in the FSAMPLE time data
    start_idx = find(edf.FSAMPLE.time == event_start_time, 1);
    end_idx = find(edf.FSAMPLE.time == event_end_time, 1);
    
    % Extract the x_positions and corresponding time data for the current event
    x_positions = edf.FSAMPLE.gx(2, start_idx:end_idx);
    time_data = edf.FSAMPLE.time(start_idx:end_idx);
    
    
    % Replace 0 values with NaN
    x_positions(x_positions == 0) = NaN;
    
    % Plot the x_positions with respect to time
%     figure;
    plot(time_data, x_positions);
    title('X Positions with 0 Values Replaced by NaN');
    xlabel('Time');
    ylabel('X Position');
    hold on;
end
