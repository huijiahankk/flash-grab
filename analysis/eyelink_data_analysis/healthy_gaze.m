


% addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/sector/blindspot/chr';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
cd(datapath);
dataFile = 'chr_invi2vi_l_2023_10_18_16_48.asc';

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


% Coordinates for the fixation point
xCenter = 1280;    % 1280  lili 1680
yCenter = 720;    % 720   lili 320

%----------------------------------------------------------------------
%  plot heatmap of gaze position
%----------------------------------------------------------------------

% Compute Average Fixation Duration

% avg_fixation_duration = mean(fixations(:, 3));
% disp(['Average Fixation Duration: ', num2str(avg_fixation_duration), ' ms']);

% Plot a Heatmap of Gaze Positions
x_positions = fixations(:, 4);
y_positions = fixations(:, 5);

% Assuming a screen resolution of 1920x1080, you can adjust bins accordingly
% Adjust the bins for larger gaze position dots
bin_size = 10;  % Adjust this value for desired dot size
x_bins = 1:bin_size:1920;
y_bins = 1:bin_size:1080;

heatmap_counts = histcounts2(y_positions, x_positions, y_bins, x_bins);
% heatmap(heatmap_counts, 'Colormap', jet, 'GridVisible', 'off');

% Calculate the bin index for the center
center_bin_x = length(x_bins) / 2;
center_bin_y = length(y_bins) / 2;

figure;
imagesc(heatmap_counts);
colormap(jet);
set(gcf,'color','w');
colorbar;
axis image; % This makes the x and y axes equal in scale
title('Heatmap of Gaze Positions');
xlabel('X Position');
ylabel('Y Position');
set(gca, 'YDir', 'normal'); % This ensures the Y-axis is not inverted

% Mark the fixation point on the heatmap
hold on;
plot(xCenter/bin_size, yCenter/bin_size, 'wo', 'MarkerSize', 10, 'MarkerFaceColor', 'w');  % Adjusted for bin size
hold off;

% %----------------------------------------------------------------------
% %  extract gaze positions specifically for "TRIALID 3" and "TRIALID 4"
% %----------------------------------------------------------------------
% 
% % Find the start and end lines for TRIALID 3 and TRIALID 4
% trial3_start_index = find(contains(lines, 'TRIALID 3'), 1, 'first');
% trial4_start_index = find(contains(lines, 'TRIALID 4'), 1, 'first');
% trial4_end_index = find(contains(lines, 'TRIALID 5'), 1, 'first') - 1; % Assuming TRIALID 5 comes after TRIALID 4
% 
% % If TRIALID 5 doesn't exist, set end index to length of lines
% if isempty(trial4_end_index)
%     trial4_end_index = length(lines);
% end
% 
% % Assuming a screen resolution of 1920x1080, you can adjust bins accordingly
% % Adjust the bins for larger gaze position dots
% bin_size = 10;  % Adjust this value for desired dot size
% x_bins = 1:bin_size:1920;
% y_bins = 1:bin_size:1080;
% 
% 
% % Parse gaze data for TRIALID 3 and 4
% gaze_positions = [];
% for i = trial3_start_index:trial4_end_index
%     line = lines{i};
%     if contains(line, 'EFIX')
%         parts = strsplit(line);
%         avg_x = str2double(parts{6});
%         avg_y = str2double(parts{7});
%         gaze_positions = [gaze_positions; avg_x, avg_y];
%     end
% end
% 
% % Plot the heatmap for TRIALID 3 and 4
% x_positions = gaze_positions(:, 1);
% y_positions = gaze_positions(:, 2);
% 
% 
% heatmap_counts = histcounts2(y_positions, x_positions, y_bins, x_bins);
% 
% % Use imagesc for heatmap
% figure;
% imagesc(heatmap_counts);
% colormap(jet);
% colorbar;
% axis image;
% title('Heatmap of Gaze Positions for TRIALID 3 and 4');
% xlabel('X Position');
% ylabel('Y Position');
% set(gca, 'YDir', 'normal');
% 
% % Mark the fixation point on the heatmap
% hold on;
% plot(xCenter/bin_size, yCenter/bin_size, 'wo', 'MarkerSize', 10, 'MarkerFaceColor', 'w');  % Adjusted for bin size
% hold off;


% %----------------------------------------------------------------------
% %  extract gaze positions related to the "MSG flash" event
% %----------------------------------------------------------------------
% % ... [Previous code for loading the file]
% 
% % Find all indices for lines containing both "MSG" and "flash"
% flash_indices = find(cellfun(@(x) contains(x, 'MSG') && contains(x, 'flash'), lines));
% 
% % % Display the line numbers and content for verification
% % disp('Lines containing "MSG" and "flash":');
% % for idx = 1:length(flash_indices)
% %     disp(['Line number: ', num2str(flash_indices(idx)), ' - Content: ', lines{flash_indices(idx)}]);
% % end
% 
% 
% % Initialize an empty matrix to store gaze data
% gaze_data = [];
% 
% % Loop through each "MSG flash" event
% for idx = 1:length(flash_indices)
%     i = flash_indices(idx) + 1;
%     while i <= length(lines) && ~contains(lines{i}, 'MSG')
%         line = lines{i};
%         if contains(line, 'EFIX')  % Assuming you want fixation data; adjust if necessary
%             parts = strsplit(line);
%             avg_x = str2double(parts{6});
%             avg_y = str2double(parts{7});
%             gaze_data = [gaze_data; avg_x, avg_y];  % Append the data to the gaze_data matrix
%         end
%         i = i + 1;
%     end
% end
% 
% 
% % Extract the x and y positions of gaze data
% x_positions = gaze_data(:, 1);
% y_positions = gaze_data(:, 2);
% 
% % Assuming a screen resolution of 1920x1080 and using the bin_size
% bin_size = 10;  % Adjust this value for desired dot size
% x_bins = 1:bin_size:1920;
% y_bins = 1:bin_size:1080;
% 
% heatmap_counts = histcounts2(y_positions, x_positions, y_bins, x_bins);
% 
% % Use imagesc for heatmap
% figure;
% imagesc(heatmap_counts);
% colormap(jet);
% colorbar;
% axis image; % This makes the x and y axes equal in scale
% title('Heatmap of Gaze Positions after "MSG" and "flash"');
% xlabel('X Position');
% ylabel('Y Position');
% set(gca, 'YDir', 'normal'); % This ensures the Y-axis is not inverted
% 
% % Mark the fixation point on the heatmap
% hold on;
% plot(xCenter/bin_size, yCenter/bin_size, 'wo', 'MarkerSize', 10, 'MarkerFaceColor', 'w');  % Adjusted for bin size
% hold off;









