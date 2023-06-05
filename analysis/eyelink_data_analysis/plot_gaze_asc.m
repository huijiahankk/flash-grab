clear all;

addpath '/Users/huijiajia/Documents/matlab/preCompiled_edfmex';
datapath = '../../data/corticalBlindness/Eyelink_asc/blurredBoundary/blindspot/sry/';


% addpath('/Users/huijiajia/Documents/Psychtoolbox-3-3.0.17.9/Psychtoolbox/PsychHardware/EyelinkToolbox');
% Read the EyeLink ASCII data file
cd(datapath);
filename_eye = 'sry_invi2vi_l_2023_03_14_16_44.asc';

cfg = [];
cfg.dataset = filename_eye;
data_eye = ft_preprocessing(cfg);

disp(data_eye)