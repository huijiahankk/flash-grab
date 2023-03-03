% for hemianopia patient mali
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location 
% For the degree record for example: right visual field damaged, the blind visual field is
% blindFieldUpper =  -15   blindFieldLower =   15
% we present the degree with degree to the horizontal meridian

clear all;

addpath '../function'

% pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 3;  
folders = { 'normal_field', 'upper_field','lower_field'};
path = '../data/corticalBlindness/bar';

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
    
    if folderNum == 2   % 'upper_field'
        visible2invisibleCCW = 90 + visible2invisible(illusionCCWIndex);
        visible2invisibleCW = 90 + visible2invisible(illusionCWIndex);
        invisible2visibleCCW = 90 + invisible2visible(illusionCCWIndex);
        invisible2visibleCW = 90 + invisible2visible(illusionCWIndex);        
        perceived_locationCCW = 90 + perceived_location(illusionCCWIndex);
        perceived_locationCW = 90 + perceived_location(illusionCWIndex);
%         off_sync_edge_degree = off_sync_upper_edge_degree;
        
    elseif folderNum == 3  %  'lower_field'
        visible2invisibleCCW = 90 - visible2invisible(illusionCCWIndex);
        visible2invisibleCW = 90 - visible2invisible(illusionCWIndex);
        invisible2visibleCCW = 90 - invisible2visible(illusionCCWIndex);
        invisible2visibleCW = 90 - invisible2visible(illusionCWIndex);
        perceived_locationCCW = 90 - perceived_location(illusionCCWIndex);
        perceived_locationCW = 90 - perceived_location(illusionCWIndex);
%         off_sync_edge_degree = off_sync_lower_edge_degree;
    end
    
    visible2invisibleCCWmean = mean(visible2invisibleCCW);
    visible2invisibleCWmean = mean(visible2invisibleCW);
    invisible2visibleCCWmean = mean(invisible2visibleCCW);
    invisible2visibleCWmean = mean(invisible2visibleCW);
    perceived_locationCCWmean = mean(perceived_locationCCW);
    perceived_locationCWmean = mean(perceived_locationCW);
    
    CCWborder = [visible2invisibleCCW  invisible2visibleCCW];
    CWborder = [visible2invisibleCW invisible2visibleCW];
    CCWborderMean = mean(CCWborder);
    CWborderMean = mean(CWborder);
end


%----------------------------------------------------------------------
%  plot invisible2visible & visible2invisible & perceived location
%----------------------------------------------------------------------

% y = [visible2invisibleCCWmean visible2invisibleCWmean invisible2visibleCCWmean invisible2visibleCWmean perceived_locationmean];
%
% % h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar(1:5,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
% set(gca, 'XTick', 1:5, 'XTickLabels', {'vi2inviCCW' 'vi2inviCW' 'invi2viCCW' 'invi2viCW' 'perc'},'fontsize',20,'FontWeight','bold');
%
%
% hold on;
%
% eachtrialdegree = [visible2invisibleCCW; visible2invisibleCW;  invisible2visibleCCW; invisible2visibleCW];
%
% for condition = 1: size(eachtrialdegree,1)
%     for i = 1:size(eachtrialdegree(1,:),2)
%         plot(condition,eachtrialdegree(condition,:),'r--o');
%     end
% end

%----------------------------------------------------------------------
%  plot CCW & CW & perceived location  mean and each trial
%----------------------------------------------------------------------


% y = [visible2invisibleCCWmean invisible2visibleCCWmean perceived_locationCCWmean visible2invisibleCWmean invisible2visibleCWmean perceived_locationCWmean];
y = [CCWborderMean perceived_locationCCWmean CWborderMean perceived_locationCWmean];
h = bar(3:6,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
% set(gca, 'XTick', 1:8, 'XTickLabels', {'blind field' 'off-sync control' 'CCW-vi2invi'  'CCW-vi2invi' 'percCCW' 'CW-vi2invi' 'CW-vi2invi' 'percCW'},'fontsize',20,'FontWeight','bold');
set(gca, 'XTick', 1:6, 'XTickLabels', {'blind field' 'off-sync control' 'CCW' 'percCCW' 'CW' 'percCW'},'fontsize',20,'FontWeight','bold');
xtickangle(45);
set(gcf,'color','w');
set(gca,'box','off');
% title('Illusion size','FontSize',25);
set(gca,'ylim',[0 105],'FontName','Arial','FontSize',25);
if barLocation == 'l'
    %         set(gca, 'YDir', 'reverse');
    % set the origin on the left top
    set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
end
hold on;

% eachtrialdegree first row is CCW and second row is CW
% eachtrialdegree_CCW_CW_perc = [visible2invisibleCCW; invisible2visibleCCW; perceived_locationCCW;visible2invisibleCW; invisible2visibleCW;perceived_locationCW];
eachtrialdegree_CCW_CW = [CCWborder; CWborder];
eachtrialdegree_Perc = [perceived_locationCCW; perceived_locationCW];
% plot CCW value(first row of eachtrialdegree_CCW_CW) on first bar
for condition_CCW_CW = 1: size(eachtrialdegree_CCW_CW,1)
    plot(condition_CCW_CW*2 + 1,eachtrialdegree_CCW_CW(condition_CCW_CW,:),'r--o');
end

% for condition_CCW_CW = 1: size(eachtrialdegree_CCW_CW,1)
%     plot(3,eachtrialdegree_CCW_CW(2,condition_CCW_CW),'r--o');
% end

hold on;

for condition_perc = 1:size(eachtrialdegree_Perc,1)
    plot((condition_perc+1)*2,eachtrialdegree_Perc(condition_perc,:),'r--o');
end
% 
% for i = 1:size(eachtrialdegree_Perc_CCW_CW,2)
%     plot(4,eachtrialdegree_Perc_CCW_CW(2,i),'r--o');
% end

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


if folderNum == 2   % 'upper_field'
    visible2invisible = 90 + visible2invisible;
    invisible2visible = 90 + invisible2visible;
    visible2invisibleDegree = mean(visible2invisible);
    invisible2visibleDegree = mean(invisible2visible);
    off_sync_edge_degree = (visible2invisibleDegree + invisible2visibleDegree)/2;
elseif folderNum == 3   %  'lower_field'
    visible2invisible = 90 - visible2invisible;
    invisible2visible = 90 - invisible2visible;
    visible2invisibleDegree = mean(visible2invisible);
    invisible2visibleDegree = mean(invisible2visible);
    off_sync_edge_degree = (visible2invisibleDegree + invisible2visibleDegree)/2;
end

eachtrialdegree_off_sync = [visible2invisible  invisible2visible];
hold on;
y_barData = off_sync_edge_degree; 
h = bar(2,y_barData,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
hold on;
for off_sync = 1: size(eachtrialdegree_off_sync,2)
    plot(2,eachtrialdegree_off_sync(off_sync),'r--o');
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

if folderNum == 2   % 'upper_field'
    blindFieldUpper = 90 + data.wedgeTiltEachBlock(1,:);
    blindFieldUpperMean = mean(blindFieldUpper);
    y = blindFieldUpperMean;
    eachtrialdegree_blindfield = blindFieldUpper;
elseif folderNum == 3   % 'lower_field'
    blindFieldLower = 90 - data.wedgeTiltEachBlock(2,:);
    blindFieldLowerMean = mean(blindFieldLower);
    y = blindFieldLowerMean ;
    eachtrialdegree_blindfield = blindFieldLower;
end

hold on;
bar(1,y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
hold on;
for blindfield = 1: size(eachtrialdegree_blindfield,2)
    plot(1,eachtrialdegree_blindfield(blindfield),'r--o');
end

[h,p_blindfield_offsync,ci,stats] = ttest2(eachtrialdegree_blindfield,eachtrialdegree_off_sync);
p_blindfield_offsync
[h,p_CCW_perc,ci,stats] = ttest2(CCWborder,perceived_locationCCW);
p_CCW_perc
[h,p_CW_perc,ci,stats] = ttest2(CWborder,perceived_locationCW);
p_CW_perc
