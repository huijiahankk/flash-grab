


addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/sector/CB/zhuerliang/';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
cd(datapath);
dataFile = 'zhuerl_invi2vi_l_2023_09_13_12_03.asc';

% Load the ASCII Data
fid = fopen(dataFile, 'r');
data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

lines = data{1};


% Parse the Data
fixations = [];
for i = 1:length(lines)
    line = lines{i};
    if contains(line, 'EFIX')
        parts = strsplit(line);
        eye = parts{2};
        start_time = str2double(parts{3});
        end_time = str2double(parts{4});
        duration = str2double(parts{5});
        avg_x = str2double(parts{6});
        avg_y = str2double(parts{7});
        fixations = [fixations; start_time, end_time, duration, avg_x, avg_y];
    end
end

%----------------------------------------------------------------------
%  plot heatmap of gaze position
%----------------------------------------------------------------------

% Compute Average Fixation Duration

avg_fixation_duration = mean(fixations(:, 3));
disp(['Average Fixation Duration: ', num2str(avg_fixation_duration), ' ms']);

% Plot a Heatmap of Gaze Positions
x_positions = fixations(:, 4);
y_positions = fixations(:, 5);

% Assuming a screen resolution of 1920x1080, you can adjust bins accordingly
x_bins = 1:1920;
y_bins = 1:1080;

heatmap_counts = histcounts2(y_positions, x_positions, y_bins, x_bins);
% heatmap(heatmap_counts, 'Colormap', jet, 'GridVisible', 'off');

figure;
imagesc(heatmap_counts);
colormap(jet);
colorbar;
axis image; % This makes the x and y axes equal in scale
title('Heatmap of Gaze Positions');
xlabel('X Position');
ylabel('Y Position');
set(gca, 'YDir', 'normal'); % This ensures the Y-axis is not inverted


%----------------------------------------------------------------------
%  extract gaze positions specifically for "TRIALID 3" and "TRIALID 4"
%----------------------------------------------------------------------

% Find the start and end lines for TRIALID 3 and TRIALID 4
trial3_start_index = find(contains(lines, 'TRIALID 3'), 1, 'first');
trial4_start_index = find(contains(lines, 'TRIALID 4'), 1, 'first');
trial4_end_index = find(contains(lines, 'TRIALID 5'), 1, 'first') - 1; % Assuming TRIALID 5 comes after TRIALID 4

% If TRIALID 5 doesn't exist, set end index to length of lines
if isempty(trial4_end_index)
    trial4_end_index = length(lines);
end

% Parse gaze data for TRIALID 3 and 4
gaze_positions = [];
for i = trial3_start_index:trial4_end_index
    line = lines{i};
    if contains(line, 'EFIX')
        parts = strsplit(line);
        avg_x = str2double(parts{6});
        avg_y = str2double(parts{7});
        gaze_positions = [gaze_positions; avg_x, avg_y];
    end
end

% Plot the heatmap for TRIALID 3 and 4
x_positions = gaze_positions(:, 1);
y_positions = gaze_positions(:, 2);

x_bins = 1:1920;
y_bins = 1:1080;

heatmap_counts = histcounts2(y_positions, x_positions, y_bins, x_bins);

% Use imagesc for heatmap
figure;
imagesc(heatmap_counts);
colormap(jet);
colorbar;
axis image;
title('Heatmap of Gaze Positions for TRIALID 3 and 4');
xlabel('X Position');
ylabel('Y Position');
set(gca, 'YDir', 'normal');







