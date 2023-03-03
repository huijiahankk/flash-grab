% for hemianopia patient mali
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location
% For the degree record for example: right visual field damaged, the blind visual field is
% blindFieldUpper =  -15   blindFieldLower =   15
% we present the degree with degree to the horizontal meridian

clear all;

addpath '../../../function';

bar_only_mark = 1; % 1 means show bar_only  2 means no bar_only data  every data was normalized by bar_only
% pValue = input('>>>Calculate p Value? (y/n):  ','s');
sbjnames = { 'wutianjiang' } ; % 6'maguangquan'     7'wutianjiang'    5'mali' 

folderNum = 1;   % choose which visual to analysis
folders = {'upper_field','lower_field','normal_field'};
path = '../../../data/corticalBlindness/bar';
areaFolderName = fullfile(path, folders{folderNum});
cd(areaFolderName);


subfolders = {'vi2invi' 'invi2vi'};   %  'invi2vi'
subfolderNums = length(subfolders);  % analy each condition include {'invi2vi','vi2invi'};

for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    
    
    %     if strcmp(string(sbjnames(sbjnum)),'mali') == 1
    
    for subfolderNum = 1:subfolderNums
        
        if subfolderNum == 1    % subfolders = {'vi2invi'};
            cd(subfolders{subfolderNum});
        else subfolderNum == 2    % subfolders = {'invi2vi'};
            cd (['../' subfolders{subfolderNum}]);
        end
        
        Files = dir(s3);
        load (Files.name);
        %----------------------------------------------------------------------
        %          sbj 'mali'   CCW & CW add  perceived location test
        %----------------------------------------------------------------------
        
        if strcmp(sbjnames, 'mali')
            
            if strcmp(folders{folderNum} , 'upper_field')
                multiplier =  1 ;
            elseif strcmp(folders{folderNum} , 'lower_field')
                multiplier = - 1 ;
            end
            
            bar_CCWDegree = 90 + multiplier * bar_only;
            bar_CWDegree = 90 + multiplier * bar_only;
            
            %             illusionCCWIndex = find(data.flashTiltDirection_off_sync == 1);
            %             illusionCWIndex = find(data.flashTiltDirection_off_sync == 2);
            off_sync_Degree(subfolderNum,:) = 90 + multiplier * off_sync;
            %             off_sync_CWDegree(subfolderNum,:) =  90 + multiplier * off_sync;
            
            
            if strcmp(folders{folderNum} , 'upper_field')
                
                illusionCCWIndex = find(data.flashTiltDirection_grab_upper == 1);
                illusionCWIndex = find(data.flashTiltDirection_grab_upper == 2);
                flash_grab_CCWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
                flash_grab_CWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);
                
                
                if strcmp(condition, 'invi2vi')
                    
                    illusionCCWIndex = find(data.flashTiltDirection_grab_upper == 1);
                    illusionCWIndex = find(data.flashTiltDirection_grab_upper == 2);
                    perceived_location_CCWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                    perceived_location_CWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
                end
                
            elseif strcmp(folders{folderNum} , 'lower_field')
                
                illusionCCWIndex = find(data.flashTiltDirection_grab_lower == 1);
                illusionCWIndex = find(data.flashTiltDirection_grab_lower == 2);
                flash_grab_CCWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
                flash_grab_CWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);
                
                
                if strcmp(condition, 'invi2vi')
                    
                    illusionCCWIndex = find(data.flashTiltDirection_grab_lower == 1);
                    illusionCWIndex = find(data.flashTiltDirection_grab_lower == 2);
                    perceived_location_CCWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                    perceived_location_CWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
                end
                
            end
            
            %----------------------------------------------------------------------
            %    sbj not  'mali'   CCW & CW add  perceived location test
            %----------------------------------------------------------------------
        else   %  if not 'mali'
            
            if strcmp(folders{folderNum} , 'upper_field')
                multiplier = - 1 ;
            elseif strcmp(folders{folderNum} , 'lower_field')
                multiplier =  1 ;
            end
            
            illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
            illusionCWIndex = find(data.flashTiltDirection == 2);  % CW
            
            
            bar_CCWDegree(subfolderNum,:) = 90 + multiplier * bar_only(illusionCCWIndex);
            bar_CWDegree(subfolderNum,:) = 90 + multiplier * bar_only(illusionCWIndex);
            off_sync_CCWDegree(subfolderNum,:) = 90 + multiplier * off_sync(illusionCCWIndex);
            off_sync_CWDegree(subfolderNum,:) =  90 + multiplier * off_sync(illusionCWIndex);
            flash_grab_CCWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
            flash_grab_CWDegree(subfolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);
            
            if strcmp(condition, 'invi2vi')
                perceived_location_CCWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                perceived_location_CWDegree(subfolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
            end
            
        end
    end
    
    bar_onlyDegreeMean = mean(reshape([bar_CWDegree bar_CCWDegree],1,8));
    if strcmp(sbjnames, 'mali')
        off_syncDegreeMean = mean(reshape(off_sync_Degree,1,8));
    else
        off_syncDegreeMean = mean(reshape([off_sync_CCWDegree off_sync_CWDegree],1,8));
    end
    flash_grab_CCWDegreeMean= mean(reshape(flash_grab_CCWDegree,1,4));
    flash_grab_CWDegreeMean = mean(reshape(flash_grab_CWDegree,1,4));
    
    if strcmp(condition, 'invi2vi')
        perceived_location_CCWDegreeMean = mean(perceived_location_CCWDegree(2,:));
        perceived_location_CWDegreeMean = mean(perceived_location_CWDegree(2,:));
    end
    
end

% %----------------------------------------------------------------------
% %  apart invisible2visible & visible2invisible
% %----------------------------------------------------------------------
%
% y = [mean(bar_CCWDegree(1,:)) mean(bar_CCWDegree(2,:))  mean(bar_CWDegree(1,:)) mean(bar_CWDegree(2,:))...
%     mean(off_sync_CCWDegree(1,:)) mean(off_sync_CCWDegree(2,:)) mean(off_sync_CWDegree(1,:)) mean(off_sync_CWDegree(2,:))...
%     mean(flash_grab_CCWDegree(1,:)) mean(flash_grab_CCWDegree(2,:)) perceived_location_CCWDegreeMean ...
%     mean(flash_grab_CWDegree(1,:)) mean(flash_grab_CWDegree(2,:)) perceived_location_CWDegreeMean ];
%
%
% % y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
% h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
% set(gca, 'XTick', 1:14, 'XTickLabels', {'bar-only-CCW-vi2invi' 'bar-only-CCW-invi2vi' 'bar-only-CW-vi2invi' 'bar-only-CW-invi2vi'...
%     'off-sync-CCW-vi2invi' 'off-sync-CCW-invi2vi' 'off-sync-CW-vi2invi' 'off-sync-CW-invi2vi' ...
%     'grab-CCW-vi2invi' 'grab-CCW-invi2vi' 'perc-CCW' 'grab-CW-vi2invi' 'grab-CW-invi2vi' 'perc-CW'},'fontsize',20,'FontWeight','bold');
%
% % set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
%
% set(gcf,'color','w');
% set(gca,'box','off');
% xtickangle(45);
%
% if barLocation == 'l'
%     % set the origin on the left top
%     set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
% end
%
% hold on;
% ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);
% % legend({'blind field border' 'reverse counter-clockwise','reverse clockwise'},'EdgeColor','w');
% if folderNum == 1
%     title('Motion reversal towards and outwards the scotoma---upper visual field ','FontName','Arial','FontSize',35);
%     set(gca,'ylim',[0 141],'FontName','Arial','FontSize',25);
% elseif folderNum == 2
%     title('Motion reversal towards and outwards the scotoma---lower visual field ','FontName','Arial','FontSize',35);
%     set(gca,'ylim',[0 141],'FontName','Arial','FontSize',25);% 'Position', [5, 0, 0],
% end
%
%
% %----------------------------------------------------------------------
% %  plot  each trial
% %----------------------------------------------------------------------
%
%
% % plot bar_only value
% eachtrialdegree_bar_only_CCW_vi2invi = bar_CCWDegree(1,:);
% eachtrialdegree_bar_only_CCW_invi2vi = bar_CCWDegree(2,:);
% eachtrialdegree_bar_only_CW_vi2invi = bar_CWDegree(1,:);
% eachtrialdegree_bar_only_CW_invi2vi = bar_CWDegree(2,:);
% % plot off_sync data
% eachtrialdegree_off_sync_CCW_vi2invi = off_sync_CCWDegree(1,:);
% eachtrialdegree_off_sync_CCW_invi2vi = off_sync_CCWDegree(2,:);
% eachtrialdegree_off_sync_CW_vi2invi = off_sync_CWDegree(1,:);
% eachtrialdegree_off_sync_CW_invi2vi = off_sync_CWDegree(2,:);
% % plot grab_CCW data
% eachtrialdegree_grab_CCW_vi2invi = flash_grab_CCWDegree(1,:);
% eachtrialdegree_grab_CCW_invi2vi = flash_grab_CCWDegree(2,:);
% % plot perc_CCW data
% eachtrialdegree_perc_CCW = nonzeros(perceived_location_CCWDegree)';
% % plot grab_CW data
% eachtrialdegree_grab_CW_vi2invi = flash_grab_CWDegree(1,:);
% eachtrialdegree_grab_CW_invi2vi = flash_grab_CWDegree(2,:);
% % plot perc_CW data
% eachtrialdegree_perc_CW = nonzeros(perceived_location_CWDegree)';
%
%
% for condition = 1: length(eachtrialdegree_bar_only_CCW_vi2invi)
%     plot(1,eachtrialdegree_bar_only_CCW_vi2invi(condition),'r--o');
%     plot(2,eachtrialdegree_bar_only_CCW_invi2vi(condition),'b--o');
%     plot(3,eachtrialdegree_bar_only_CW_vi2invi(condition),'r--o');
%     plot(4,eachtrialdegree_bar_only_CW_invi2vi(condition),'b--o');
%     plot(5,eachtrialdegree_off_sync_CCW_vi2invi(condition),'r--o');
%     plot(6,eachtrialdegree_off_sync_CCW_invi2vi(condition),'b--o');
%     plot(7,eachtrialdegree_off_sync_CW_vi2invi(condition),'r--o');
%     plot(8,eachtrialdegree_off_sync_CW_invi2vi(condition),'b--o');
% end
%
% for condition = 1: length(eachtrialdegree_bar_only_CCW_vi2invi)
%     plot(9,eachtrialdegree_grab_CCW_vi2invi(condition),'r--o');
%     plot(10,eachtrialdegree_grab_CCW_invi2vi(condition),'b--o');
%     plot(12,eachtrialdegree_grab_CW_vi2invi(condition),'r--o');
%     plot(13,eachtrialdegree_grab_CW_invi2vi(condition),'b--o');
% end
%
% for condition = 1: length(eachtrialdegree_perc_CCW)
%     plot(11,eachtrialdegree_perc_CCW(condition),'r--o');
%     plot(14,eachtrialdegree_perc_CW(condition),'r--o');
% end



if bar_only_mark == 1
    %----------------------------------------------------------------------
    %  combind invisible2visible & visible2invisible
    %----------------------------------------------------------------------
    
    y = [bar_onlyDegreeMean off_syncDegreeMean flash_grab_CCWDegreeMean perceived_location_CCWDegreeMean flash_grab_CWDegreeMean perceived_location_CWDegreeMean];
    
    
    % y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    set(gca, 'XTick', 1:6, 'XTickLabels', {'bar-only' 'off-sync' 'grab-CCW' 'perc-CCW' 'grab-CW' 'perc-CW'},'fontsize',20,'FontWeight','bold');
    
    % set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
    
    set(gcf,'color','w');
    set(gca,'box','off');
    xtickangle(45);
    
    if folders{folderNum} == 'lower_field'
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    
    hold on;
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);
    % legend({'blind field border' 'reverse counter-clockwise','reverse clockwise'},'EdgeColor','w');
%     if folderNum == 1
%         title('Motion reversal towards and outwards the scotoma---upper visual field ','FontName','Arial','FontSize',30);
%         %          set(gca,'ylim',[0 140],'FontName','Arial','FontSize',25);
%     elseif folderNum == 2
%         title('Motion reversal towards and outwards the scotoma---lower visual field ','FontName','Arial','FontSize',30);
%         %          set(gca,'ylim',[-90 0],'FontName','Arial','FontSize',25);% 'Position', [5, 0, 0],
%     end
    
    
    %----------------------------------------------------------------------
    %  plot  each trial
    %----------------------------------------------------------------------
    % plot bar_only value
    eachtrialdegree_bar_only = [reshape(bar_CCWDegree,1,4) reshape(bar_CWDegree,1,4)];
    if strcmp(sbjnames, 'mali')
        eachtrialdegree_off_sync = off_sync_Degree;
    else
        % plot off_sync data
        eachtrialdegree_off_sync = [reshape(off_sync_CCWDegree,1,4) reshape(off_sync_CWDegree,1,4)];
    end
    % plot grab_CCW data
    eachtrialdegree_grab_CCW = reshape(flash_grab_CCWDegree,1,4);
    % plot perc_CCW data
    eachtrialdegree_perc_CCW = nonzeros(perceived_location_CCWDegree)';
    % plot grab_CW data
    eachtrialdegree_grab_CW = reshape(flash_grab_CWDegree,1,4);
    % plot perc_CW data
    eachtrialdegree_perc_CW = nonzeros(perceived_location_CWDegree)';
    
    
    for condition = 1: length(eachtrialdegree_bar_only)
        plot(1,eachtrialdegree_bar_only(condition),'r--o');
        plot(2,eachtrialdegree_off_sync(condition),'r--o');
    end
    
    for condition = 1: length(eachtrialdegree_grab_CCW)
        plot(3,eachtrialdegree_grab_CCW(condition),'r--o');
        plot(5,eachtrialdegree_grab_CW(condition),'r--o');
    end
    
    for condition = 1: length(eachtrialdegree_perc_CCW)
        plot(4,eachtrialdegree_perc_CCW(condition),'r--o');
        plot(6,eachtrialdegree_perc_CW(condition),'r--o');
    end
    
    
elseif bar_only_mark == 2
    %----------------------------------------------------------------------
    %  combind invisible2visible & visible2invisible
    %----------------------------------------------------------------------
    
    y = [off_syncDegreeMean flash_grab_CCWDegreeMean perceived_location_CCWDegreeMean flash_grab_CWDegreeMean perceived_location_CWDegreeMean] - bar_onlyDegreeMean;
    
    
    % y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    set(gca, 'XTick', 1:5, 'XTickLabels', {'off-sync' 'grab-CCW' 'perc-CCW' 'grab-CW' 'perc-CW'},'fontsize',20,'FontWeight','bold');
    
    % set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
    
    set(gca,'ylim',[-50 90],'FontName','Arial','FontSize',25);
    set(gcf,'color','w');
    set(gca,'box','off');
    xtickangle(45);
    
    if folders{folderNum} == 'lower_field'
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    hold on;
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);
    % legend({'blind field border' 'reverse counter-clockwise','reverse clockwise'},'EdgeColor','w');
    %     if folderNum == 1
    %         title('Motion reversal towards and outwards the scotoma---upper visual field ','FontName','Arial','FontSize',35);
    %     elseif folderNum == 2
    %         title('Motion reversal towards and outwards the scotoma---lower visual field ','FontName','Arial','FontSize',35);    % 'Position', [5, 0, 0],
    %     end
    
    
    %----------------------------------------------------------------------
    %  plot  each trial
    %----------------------------------------------------------------------
    % plot bar_only value
    eachtrialdegree_bar_only = [reshape(bar_CCWDegree,1,4) reshape(bar_CWDegree,1,4)] - bar_onlyDegreeMean;
    % plot off_sync data
    eachtrialdegree_off_sync = [reshape(off_sync_CCWDegree,1,4) reshape(off_sync_CWDegree,1,4)] - bar_onlyDegreeMean;
    % plot grab_CCW data
    eachtrialdegree_grab_CCW = reshape(flash_grab_CCWDegree,1,4) - bar_onlyDegreeMean;
    % plot perc_CCW data
    eachtrialdegree_perc_CCW = nonzeros(perceived_location_CCWDegree)' - bar_onlyDegreeMean;
    % plot grab_CW data
    eachtrialdegree_grab_CW = reshape(flash_grab_CWDegree,1,4) - bar_onlyDegreeMean;
    % plot perc_CW data
    eachtrialdegree_perc_CW = nonzeros(perceived_location_CWDegree)' - bar_onlyDegreeMean;
    
    
    for condition = 1: length(eachtrialdegree_bar_only)
        %         plot(1,eachtrialdegree_bar_only(condition),'r--o');
        plot(1,eachtrialdegree_off_sync(condition),'r--o');
    end
    
    for condition = 1: length(eachtrialdegree_grab_CCW)
        plot(2,eachtrialdegree_grab_CCW(condition),'r--o');
        plot(4,eachtrialdegree_grab_CW(condition),'r--o');
    end
    
    for condition = 1: length(eachtrialdegree_perc_CCW)
        plot(3,eachtrialdegree_perc_CCW(condition),'r--o');
        plot(5,eachtrialdegree_perc_CW(condition),'r--o');
    end
    
end

cd ../../../../../analysis/cortical_blindness/
