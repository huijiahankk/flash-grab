% for normal participant blindspot experiment


clear all;

addpath '../../../function';

% pValue = input('>>>Calculate p Value? (y/n):  ','s');
sbjnames = {'k'};
expconNames = { '_invi2vi_u' '_vi2invi_u'} ; %  'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'

path = sprintf(['../../../data/corticalBlindness/Eyelink_guiding/blindspot/'  '%s/'],sbjnames{1});

% areaFolderName = fullfile(path, folders{folderNum});
cd(path);


for expcondition = 1:length(expconNames)
    %     s1 = string(expconNames(expcondition));
    s1 = num2str(cell2mat(strcat(sbjnames,expconNames(expcondition))));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    
    
    Files = dir(s3);
    load (Files.name);
    
    
%     if strcmp(condition, 'vi2invi')
%         illusionCCWIndex = find(back.flashTiltDirectionMat == 1);
%         illusionCWIndex = find(back.flashTiltDirectionMat == 2);
%     end
    
    
    
    illusionCCWIndex = find(back.flashTiltDirectionMat == 1); % CCW
    illusionCWIndex = find(back.flashTiltDirectionMat == 2);  % CW
    
    bar_only_degree(expcondition,:) = 90 - bar_only;
    off_sync_CCWDegree(expcondition,:) = 90 - off_sync(illusionCCWIndex);
    off_sync_CWDegree(expcondition,:)  = 90 - off_sync(illusionCWIndex);
    flash_grab_CCWDegree(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
    flash_grab_CWDegree(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
    perceived_location_CCWDegree(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);
    perceived_location_CWDegree(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
    
end


bar_onlyDegreeMean = mean(mean(bar_only_degree));
off_synCCWDegreeMean = mean(mean(off_sync_CCWDegree));
off_synCWDegreeMean = mean(mean(off_sync_CWDegree));

flash_grab_CCWDegreeMean= mean(mean(flash_grab_CCWDegree));
flash_grab_CWDegreeMean = mean(mean(flash_grab_CWDegree));

perceived_location_CCWDegreeMean = mean(mean(perceived_location_CCWDegree));
perceived_location_CWDegreeMean = mean(mean(perceived_location_CWDegree));


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
eachtrialdegree_bar_only = reshape(bar_only_degree,1,numel(bar_only_degree));


for condition = 1: length(eachtrialdegree_bar_only)
    plot(1,eachtrialdegree_bar_only(condition),'r--o');
end

eachtrialdegree_off_sync_CCW = reshape(off_sync_CCWDegree,1,numel(off_sync_CCWDegree));
eachtrialdegree_off_sync_CW = reshape(off_sync_CWDegree,1,numel(off_sync_CWDegree));
eachtrialdegree_flash_grab_CCW = reshape(flash_grab_CCWDegree,1,numel(flash_grab_CCWDegree));
eachtrialdegree_perceived_location_CCW= reshape(perceived_location_CCWDegree,1,numel(perceived_location_CCWDegree));
eachtrialdegree_flash_grab_CW = reshape(flash_grab_CWDegree,1,numel(flash_grab_CWDegree));
eachtrialdegree_perceived_location_CW= reshape(perceived_location_CWDegree,1,numel(perceived_location_CWDegree));

for condition = 1: numel(off_sync_CCWDegree)
    plot(2,eachtrialdegree_off_sync_CCW(condition),'r--o');
    plot(3,eachtrialdegree_off_sync_CW(condition),'b--o');
    plot(4,eachtrialdegree_flash_grab_CCW(condition),'r--o');
    plot(5,eachtrialdegree_perceived_location_CCW(condition),'r--o');
    plot(6,eachtrialdegree_flash_grab_CW(condition),'b--o');
    plot(7,eachtrialdegree_perceived_location_CW(condition),'b--o');    
end

