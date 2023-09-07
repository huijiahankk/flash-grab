% for hemianopia patient mali
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location
% For the degree record for example: right visual field damaged, the blind visual field is
% blindFieldUpper =  -15   blindFieldLower =   15
% we present the degree with degree to the horizontal meridian

clear all;

addpath '../../function'
bar_only_mark = 1; % 1 means show bar_only data   2 means no bar_only data  every data was normalized by bar_only
% pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 1;
folders = {'upper_field','lower_field', 'normal_field'};
path = '../../../data/corticalBlindness/bar';

thisFolderName = fullfile(path, folders{folderNum});

cd(thisFolderName);

sbjnames = { 'mali' } ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials


% off_sync_upper_edge_degree = 37.8750;
% off_sync_lower_edge_degree = 84.7500;


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir(s3);
    load (Files.name);
    
    %     if strcmp(string(sbjnames(sbjnum)),'mali') == 1
    
    %----------------------------------------------------------------------
    %                CCW & CW add  perceived location test
    %----------------------------------------------------------------------
    
    
    illusionCCWIndex = find(data.flashTiltDirection == 1);
    illusionCWIndex = find(data.flashTiltDirection == 2);
    
    if folderNum == 1   % 'upper_field'
        visible2invisibleCCW = 90 + visible2invisible(illusionCCWIndex);
        visible2invisibleCW = 90 + visible2invisible(illusionCWIndex);
        invisible2visibleCCW = 90 + invisible2visible(illusionCCWIndex);
        invisible2visibleCW = 90 + invisible2visible(illusionCWIndex);
        perceived_location_CCWDegree = 90 + perceived_location(illusionCCWIndex);
        perceived_location_CWDegree = 90 + perceived_location(illusionCWIndex);
        %         off_sync_edge_degree = off_sync_upper_edge_degree;
        
    elseif folderNum == 2  %  'lower_field'
        visible2invisibleCCW = 90 - visible2invisible(illusionCCWIndex);
        visible2invisibleCW = 90 - visible2invisible(illusionCWIndex);
        invisible2visibleCCW = 90 - invisible2visible(illusionCCWIndex);
        invisible2visibleCW = 90 - invisible2visible(illusionCWIndex);
        perceived_location_CCWDegree = 90 - perceived_location(illusionCCWIndex);
        perceived_location_CWDegree = 90 - perceived_location(illusionCWIndex);
        %         off_sync_edge_degree = off_sync_lower_edge_degree;
    end
    
    visible2invisibleCCWmean = mean(visible2invisibleCCW);
    visible2invisibleCWmean = mean(visible2invisibleCW);
    invisible2visibleCCWmean = mean(invisible2visibleCCW);
    invisible2visibleCWmean = mean(invisible2visibleCW);
    perceived_locationCCWmean = mean(perceived_location_CCWDegree);
    perceived_locationCWmean = mean(perceived_location_CWDegree);
    
    flash_grab_CCWDegree = [visible2invisibleCCW  invisible2visibleCCW];
    flash_grab_CWDegree = [visible2invisibleCW invisible2visibleCW];
    flash_grab_CCWMean = mean(flash_grab_CCWDegree);
    flash_grab_CWMean = mean(flash_grab_CWDegree);
end


%----------------------------------------------------------------------
%  plot invisible2visible & visible2invisible & perceived location
%----------------------------------------------------------------------

% y = [visible2invisibleCCWmean invisible2visibleCCWmean perceived_locationCCWmean visible2invisibleCWmean invisible2visibleCWmean perceived_locationCWmean];
%
% % h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar(3:8,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
% set(gca, 'XTick', 1:8,'XTickLabels', {'bar-only'  'off-sync'  'vi2inviCCW' 'invi2viCCW' 'perc-CCW' 'vi2inviCW' 'invi2viCW' 'perc-CW'},'fontsize',20,'FontWeight','bold');
% xtickangle(45);
% set(gcf,'color','w');
% set(gca,'box','off');
% set(gca,'ylim',[0 100],'FontName','Arial','FontSize',25);
% hold on;
% ylabel('Shift degree from horizontal meridian','FontSize',20,'FontWeight','bold')
% eachtrialdegree = [visible2invisibleCCW; invisible2visibleCCW; perceived_location_CCWDegree;...
%     visible2invisibleCW; invisible2visibleCW; perceived_location_CWDegree];
%
% for condition = 1: size(eachtrialdegree,1)
%     for i = 1:size(eachtrialdegree(1,:),2)
%         plot(condition+2,eachtrialdegree(condition,:),'r--o');
%     end
% end


if bar_only_mark == 1 % 1 means show bar_only data   2 means no bar_only data  every data was normalized by bar_only
    %----------------------------------------------------------------------
    %  plot CCW & CW & perceived location  mean and each trial
    %----------------------------------------------------------------------
    
%     y = [visible2invisibleCCWmean invisible2visibleCCWmean perceived_locationCCWmean visible2invisibleCWmean invisible2visibleCWmean perceived_locationCWmean];
    y_flash_grab_perc = [flash_grab_CCWMean perceived_locationCCWmean flash_grab_CWMean perceived_locationCWmean];
    
    h = bar(3:6,y_flash_grab_perc,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    % set(gca, 'XTick', 1:8, 'XTickLabels', {'blind field' 'off-sync control' 'CCW-vi2invi'  'CCW-vi2invi' 'percCCW' 'CW-vi2invi' 'CW-vi2invi' 'percCW'},'fontsize',20,'FontWeight','bold');
    % y = [flash_grab_CCWMean flash_grab_CWMean];
    % h = bar(2:3,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    set(gca, 'XTick', 1:6, 'XTickLabels', {'blind field' 'off-sync control' 'grab-out'...
        'perc-out' 'grab-in' 'perc-in'},'fontsize',20,'FontWeight','bold');
    % set(gca, 'XTick', 1:3, 'XTickLabels', {'blind field' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
    xtickangle(45);
    set(gcf,'color','w');
    set(gca,'box','off');
    ylabel('Shift degree from horizontal meridian','FontSize',20,'FontWeight','bold')
    %     title('Shift degree from horizontal meridian','FontSize',25);
    %     set(gca,'ylim',[-10 70],'FontName','Arial','FontSize',25);
    if barLocation == 'l'
        %         set(gca, 'YDir', 'reverse');
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    hold on;
    
    % eachtrialdegree first row is CCW and second row is CW
    % eachtrialdegree_CCW_CW_perc = [visible2invisibleCCW; invisible2visibleCCW; perceived_locationCCW;visible2invisibleCW; invisible2visibleCW;perceived_locationCW];
    eachtrialdegree_CCW_CW = [flash_grab_CCWDegree; flash_grab_CWDegree];
    eachtrialdegree_Perc = [perceived_location_CCWDegree; perceived_location_CWDegree];
    % plot CCW value(first row of eachtrialdegree_CCW_CW) on first bar
    for condition_CCW_CW = 1: size(eachtrialdegree_CCW_CW,1)
        plot(condition_CCW_CW*2 + 1 + randn/20,eachtrialdegree_CCW_CW(condition_CCW_CW,:),'r--o');
    end
    
    
    hold on;
    
    for condition_perc = 1:size(eachtrialdegree_Perc,1)
        plot((condition_perc+1)*2 + randn/20,eachtrialdegree_Perc(condition_perc,:),'r--o');
    end
    
    %----------------------------------------------------------------------
    %               off sync control  border
    %----------------------------------------------------------------------
    
    path = '../blindField/withBackground';
    thisFolderName = fullfile(path, folders{folderNum});
    cd(thisFolderName);
    
    sbjnum = 1;
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(s3);
    load (Files.name);
    
    
    if folderNum == 1   % 'upper_field'
        visible2invisible = 90 + visible2invisible;
        invisible2visible = 90 + invisible2visible;
        visible2invisibleDegreeMean = mean(visible2invisible);
        invisible2visibleDegreeMean = mean(invisible2visible);
        off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
    elseif folderNum == 2   %  'lower_field'
        visible2invisible = 90 - visible2invisible;
        invisible2visible = 90 - invisible2visible;
        visible2invisibleDegreeMean = mean(visible2invisible);
        invisible2visibleDegreeMean = mean(invisible2visible);
        off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
    end
    
    eachtrialdegree_off_sync = [visible2invisible  invisible2visible];
    hold on;
    y_off_sync = off_sync_edge_degree;
    h = bar(2,y_off_sync,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    for off_sync = 1: size(eachtrialdegree_off_sync,2)
        plot(2 + randn/20,eachtrialdegree_off_sync(off_sync),'r--o');
    end
    
    
    %----------------------------------------------------------------------
    %             border without background
    %----------------------------------------------------------------------
    
    cd ../../
    
    sbjnum = 1;
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir(s3);
    load (Files.name);
    
    if folderNum == 1   % 'upper_field'
        blindFieldUpper = 90 + data.wedgeTiltEachBlock(1,:);
        bar_onlyDegreeMean = mean(blindFieldUpper);
        y_bar_only = bar_onlyDegreeMean;
        eachtrialdegree_blindfield = blindFieldUpper;
    elseif folderNum == 2   % 'lower_field'
        blindFieldLower = 90 - data.wedgeTiltEachBlock(2,:);
        bar_onlyDegreeMean = mean(blindFieldLower);
        y_bar_only = bar_onlyDegreeMean ;
        eachtrialdegree_blindfield = blindFieldLower;
    end
    
    hold on;
    bar(1 + randn/20,y_bar_only,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    for blindfield = 1: size(eachtrialdegree_blindfield,2)
        plot(1,eachtrialdegree_blindfield(blindfield),'r--o');
    end
    
    
elseif bar_only_mark == 2  % 1 means show bar_only data   2 means no bar_only data  every data was normalized by bar_only
    %----------------------------------------------------------------------
    %             border without background
    %----------------------------------------------------------------------
    
    cd ../blindField/
    
    sbjnum = 1;
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir(s3);
    load (Files.name);
    
    if folderNum == 1   % 'upper_field'
        blindFieldUpper = 90 + data.wedgeTiltEachBlock(1,:);
        bar_onlyDegreeMean = mean(blindFieldUpper);
        y = bar_onlyDegreeMean;
        eachtrialdegree_blindfield = blindFieldUpper;
    elseif folderNum == 2   % 'lower_field'
        blindFieldLower = 90 - data.wedgeTiltEachBlock(2,:);
        bar_onlyDegreeMean = mean(blindFieldLower);
        y = bar_onlyDegreeMean ;
        eachtrialdegree_blindfield = blindFieldLower;
    end
    
    %     hold on;
    %     bar(1,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    %     hold on;
    %     for blindfield = 1: size(eachtrialdegree_blindfield,2)
    %         plot(1,eachtrialdegree_blindfield(blindfield),'r--o');
    %     end
    
    %----------------------------------------------------------------------
    %               off sync control  border
    %----------------------------------------------------------------------
    
    path = '../blindField/withBackground';
    thisFolderName = fullfile(path, folders{folderNum});
    cd(thisFolderName);
    
    sbjnum = 1;
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(s3);
    load (Files.name);
    
    
    if folderNum == 1   % 'upper_field'
        visible2invisible = 90 + visible2invisible;
        invisible2visible = 90 + invisible2visible;
        visible2invisibleDegreeMean = mean(visible2invisible);
        invisible2visibleDegreeMean = mean(invisible2visible);
        off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
    elseif folderNum == 2   %  'lower_field'
        visible2invisible = 90 - visible2invisible;
        invisible2visible = 90 - invisible2visible;
        visible2invisibleDegreeMean = mean(visible2invisible);
        invisible2visibleDegreeMean = mean(invisible2visible);
        off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
    end
    
    eachtrialdegree_off_sync = [visible2invisible  invisible2visible] - bar_onlyDegreeMean;
    
    
    y_barData = off_sync_edge_degree  - bar_onlyDegreeMean;
    h = bar(1,y_barData,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;

    %     y = [visible2invisibleCCWmean invisible2visibleCCWmean perceived_locationCCWmean visible2invisibleCWmean invisible2visibleCWmean perceived_locationCWmean];
    y = [flash_grab_CCWMean perceived_locationCCWmean flash_grab_CWMean perceived_locationCWmean] - bar_onlyDegreeMean;
    
    h = bar(2:5,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    % set(gca, 'XTick', 1:8, 'XTickLabels', {'blind field' 'off-sync control' 'CCW-vi2invi'  'CCW-vi2invi' 'percCCW' 'CW-vi2invi' 'CW-vi2invi' 'percCW'},'fontsize',20,'FontWeight','bold');
    % y = [flash_grab_CCWMean flash_grab_CWMean];
    % h = bar(2:3,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    set(gca, 'XTick', 1:5, 'XTickLabels', {'off-sync control' 'grab-CCW' 'percCCW' 'grab-CW' 'percCW'},'fontsize',20,'FontWeight','bold');
    % set(gca, 'XTick', 1:3, 'XTickLabels', {'blind field' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
    xtickangle(45);
    set(gcf,'color','w');
    set(gca,'box','off');
    % title('Illusion size','FontSize',25);
    set(gca,'ylim',[-15 70],'FontName','Arial','FontSize',25);
    if barLocation == 'l'
        %         set(gca, 'YDir', 'reverse');
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    hold on;
    
    %----------------------------------------------------------------------
    %  plot CCW & CW & perceived location  mean and each trial
    %----------------------------------------------------------------------
    for off_sync = 1: size(eachtrialdegree_off_sync,2)
        plot(1 + randn,eachtrialdegree_off_sync(off_sync),'r--o');
    end
    
    
    % plot grab_CCW data
    eachtrialdegree_grab_CCW = flash_grab_CCWDegree - bar_onlyDegreeMean;
    % plot perc_CCW data
    eachtrialdegree_perc_CCW = perceived_location_CCWDegree - bar_onlyDegreeMean;
    % plot grab_CW data
    eachtrialdegree_grab_CW = flash_grab_CWDegree - bar_onlyDegreeMean;
    % plot perc_CW data
    eachtrialdegree_perc_CW = perceived_location_CWDegree - bar_onlyDegreeMean;
    
    
    
    for condition = 1: length(eachtrialdegree_grab_CCW)
        plot(2 + randn,eachtrialdegree_grab_CCW(condition),'r--o');
        plot(4 + randn,eachtrialdegree_grab_CW(condition),'r--o');
    end
    
    for condition = 1: length(eachtrialdegree_perc_CCW)
        plot(3 + randn,eachtrialdegree_perc_CCW(condition),'r--o');
        plot(5 + randn,eachtrialdegree_perc_CW(condition),'r--o');
    end
    
end


% cd ../../../../../analysis/vi2invi_in2vi_perc_off_sync/

% [h,p_blindfield_offsync,ci,stats] = ttest2(eachtrialdegree_blindfield,eachtrialdegree_off_sync);
% p_blindfield_offsync
% [h,p_CCW_perc,ci,stats] = ttest2(flash_grab_CCWDegree,perceived_locationCCW);
% p_CCW_perc
% [h,p_CW_perc,ci,stats] = ttest2(flash_grab_CWDegree,perceived_locationCW);
% p_CW_perc
