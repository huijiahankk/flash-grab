% for normal participant blindspot experiment


clear all;

addpath '../../../function';

% pValue = input('>>>Calculate p Value? (y/n):  ','s');
sbjnames = { 'k_vi2invi_u' } ; % 6'maguangquan'     7'wutianjiang'    5'mali'

path = '../../../data/corticalBlindness/Eyelink_guiding/k/';
% areaFolderName = fullfile(path, folders{folderNum});
cd(path);


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    
    
    Files = dir(s3);
    load (Files.name);
    
    
    if strcmp(condition, 'vi2invi')
        illusionCCWIndex = find(data.flashTiltDirection == 1);
        illusionCWIndex = find(data.flashTiltDirection == 2);
    end
    
    
    
    illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
    illusionCWIndex = find(data.flashTiltDirection == 2);  % CW
    
    
    off_sync_CCWDegree = 90 - off_sync(illusionCCWIndex);
    off_sync_CWDegree = 90 - off_sync(illusionCWIndex);
    flash_grab_CCWDegree = 90 - flash_grab(illusionCCWIndex);
    flash_grab_CWDegree = 90 - flash_grab(illusionCWIndex);
    perceived_location_CCWDegree = 90 -  perceived_location(illusionCCWIndex);
    perceived_location_CWDegree  = 90 -  perceived_location(illusionCWIndex);
    
end


bar_onlyDegreeMean = 90 - mean(bar_only);
off_synCCWDegreeMean = mean(off_sync_CCWDegree);
off_synCWDegreeMean = mean(off_sync_CWDegree);

flash_grab_CCWDegreeMean= mean(flash_grab_CCWDegree);
flash_grab_CWDegreeMean = mean(flash_grab_CWDegree);

perceived_location_CCWDegreeMean = mean(perceived_location_CCWDegree);
perceived_location_CWDegreeMean = mean(perceived_location_CWDegree);



y = [bar_onlyDegreeMean off_synCCWDegreeMean off_synCWDegreeMean flash_grab_CCWDegreeMean perceived_location_CCWDegreeMean flash_grab_CWDegreeMean perceived_location_CWDegreeMean];


% y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
set(gca, 'XTick', 1:7, 'XTickLabels', {'bar-only' 'off-sync-CCW' 'off-sync-CW' 'grab-CCW' 'perc-CCW' 'grab-CW' 'perc-CW'},'fontsize',20,'FontWeight','bold');

% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);


hold on;
ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);


%----------------------------------------------------------------------
%  plot  each trial
%----------------------------------------------------------------------
% plot bar_only value
eachtrialdegree_bar_only = 90 - bar_only;


for condition = 1: length(eachtrialdegree_bar_only)
    plot(1,eachtrialdegree_bar_only(condition),'r--o');
end

for condition = 1: length(off_sync_CCWDegree)
    plot(2,off_sync_CCWDegree(condition),'r--o');
    plot(3,off_sync_CWDegree(condition),'b--o');
    plot(4,flash_grab_CCWDegree(condition),'r--o');
    plot(5,perceived_location_CCWDegree(condition),'r--o');
    plot(6,flash_grab_CWDegree(condition),'b--o');
    plot(7,perceived_location_CWDegree(condition),'b--o');    
end

