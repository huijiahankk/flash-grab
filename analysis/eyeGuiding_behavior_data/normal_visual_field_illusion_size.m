% illusion size in the visible field in normal subject
% in the left visual field

clear all;
addpath '../../function';

annulusPattern = 'blurredBoundary';  %  blurredBoundary   sector
annulusWidth = 'artificialScotoma'; % blindspot   artificialScotoma
condition = 'normal';
barLocation = 'n';

sbjnames = {'sry'};  % 'sry', 'hbb', 'lxy', 'hjh', 'xs'
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/',condition,'/');

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

s1 = sbjnames;
s2 = strcat('_',condition,'_',barLocation);
s3 = '*.mat';
s4 = string(strcat(s1,s2,s3));

Files = dir(s4);
load (Files.name);


validTrialIndex = find(abandonBlock == 0);
illusionMat = grab_effect_degree(validTrialIndex);
directionMat = data.flashTiltDirectionMat(validTrialIndex);

CCW = illusionMat(find(directionMat == 1)) - 270;
CW = illusionMat(find(directionMat == 2)) - 270;

ave_illu = (mean(CCW) - mean(CW))/2


