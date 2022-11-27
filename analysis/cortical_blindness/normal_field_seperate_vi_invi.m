
clear all;

addpath '../../function';

sbjnames = { 'wutianjiang' } ; % 'mali'  'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials

folderNum = 3;   % choose which visual to analysis
folders = {'upper_field','lower_field','normal_field'};
path = '../../data/corticalBlindness/bar';
areaFolderName = fullfile(path, folders{folderNum});
cd(areaFolderName);


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
        
    Files = dir(s3);
    load (Files.name);
    
    illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
    illusionCWIndex = find(data.flashTiltDirection == 2);  % CW
    
    
    normal_CCW_each_trial_from_horizon = 90 - grab_effect_degree(illusionCCWIndex);
    normal_CW_each_trial_from_horizon = grab_effect_degree(illusionCWIndex) - 90;
    
    normal_CCW = mean(normal_CCW_each_trial_from_horizon)
    Nornal_CW = mean(normal_CW_each_trial_from_horizon)
    
end

normal_illusion_degree = (normal_CCW + Nornal_CW)/2