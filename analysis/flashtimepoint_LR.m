% extract flash time point for illusion left and illusion right
% for main_exp & control 
% load ../data/7T/main_exp/calib-PC-03-Dec-2021_3t.mat;
stimtypevalidIndex = find(stimtype);
stimtypeIndexL = find(stimtype(stimtypevalidIndex) == 1);
stimtypeIndexR = find(stimtype(stimtypevalidIndex) == 2);
flashTimePointL = round(flashTimePoint(stimtypeIndexL)).'   
flashTimePointR = round(flashTimePoint(stimtypeIndexR)).'
% [stimonset,stimtype,stimlength,junk,stimname] 

% calculated stimTimePoint 
stimtypeIndex = find(contains(stimname,'left'));
calFlashTimePointL = stimonset(stimtypeIndex)';



% for localizer 
localizertype = localizerMat(1:20);
localizervalid = localizertype(find(localizertype~=3));
find(localizervalid==1);
localizerTimePointL = ((find(localizervalid==1)-1) * checkerboardFlickDura).'
localizerTimePointR = ((find(localizervalid==2)-1) * checkerboardFlickDura).'