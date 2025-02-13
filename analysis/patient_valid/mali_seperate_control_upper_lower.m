% for hemianopia patient mali   the blind field is in the right visual
% field
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location
% For the degree record for example: right visual field damaged, the blind visual field is
% blindFieldUpper =  -15(from vertical meridian)   blindFieldLower =   15(from vertical meridian)
% we present the degree with degree from the horizontal meridian
% data.flashTiltDirection == 1  CCW
% data.flashTiltDirection == 1  CW

% clear all;
clearvars;

addpath '../../function'
bar_only_mark = 2; % 1 means show bar_only data   2 means no bar_only data  every data was normalized by bar_only
% pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 2;
folders = {'upper_field','lower_field', 'normal_field'};
path = '../../data/corticalBlindness/bar';

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

    if folderNum == 1    % 'upper_field'
        grab_vi2invi_CCW = 90 + visible2invisible(illusionCCWIndex);
        grab_vi2invi_CW = 90 + visible2invisible(illusionCWIndex);
        grab_invi2vi_CCW = 90 + invisible2visible(illusionCCWIndex);
        grab_invi2vi_CW = 90 + invisible2visible(illusionCWIndex);

        grab_in_data = [grab_vi2invi_CW; grab_invi2vi_CW];
        perceived_location_in_data = 90 + perceived_location(illusionCWIndex);
        grab_out_data = [grab_vi2invi_CCW; grab_invi2vi_CCW];
        perceived_location_out_data = 90 + perceived_location(illusionCCWIndex);

    elseif folderNum == 2  %  'lower_field'
        grab_vi2invi_CCW = 90 - visible2invisible(illusionCCWIndex);
        grab_vi2invi_CW = 90 - visible2invisible(illusionCWIndex);
        grab_invi2vi_CCW = 90 - invisible2visible(illusionCCWIndex);
        grab_invi2vi_CW = 90 - invisible2visible(illusionCWIndex);

        grab_in_data = [grab_vi2invi_CCW; grab_invi2vi_CCW];  % first row vi2invi, second row invi2vi
        perceived_location_in_data = 90 - perceived_location(illusionCCWIndex);
        grab_out_data = [grab_vi2invi_CW; grab_invi2vi_CW];
        perceived_location_out_data = 90 - perceived_location(illusionCWIndex);
    end

end



%----------------------------------------------------------------------
%      bar_only       border without background
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
    bar_only_u = 90 + data.wedgeTiltEachBlock(1,:);
    bar_only_ave = mean(bar_only_u);
    eachtrial_bar_only = bar_only_u;
elseif folderNum == 2   % 'lower_field'
    bar_only_l = 90 - data.wedgeTiltEachBlock(2,:);
    bar_only_ave = mean(bar_only_l);
    eachtrial_bar_only = bar_only_l;
end

bar_only_ave_temp = bar_only_ave;
hold on;

if bar_only_mark == 1
    bar_only_ave_temp = 0;
    bar(1 + randn/20,bar_only_ave,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
    for blindfield = 1: size(eachtrial_bar_only,2)
        plot(1,eachtrial_bar_only(blindfield),'r--o');
    end
elseif bar_only_mark == 2
    bar_only_ave_temp = bar_only_ave;
end
hold on;

%----------------------------------------------------------------------
%               off sync control  border
%----------------------------------------------------------------------

path = 'withBackground_off_sync/';

if folder == 1
    thisFolderName = fullfile(path, folders{folder});
else
    thisFolderName = fullfile('../', folders{folder});
end
cd(thisFolderName);

sbjnum = 1;
s1 = string(sbjnames(sbjnum));
s2 = '*.mat';
s3 = strcat(s1,s2);
Files = dir(s3);
load (Files.name);


illusionCCWIndex = find(data.flashTiltDirection == 1);  % CCW
illusionCWIndex = find(data.flashTiltDirection == 2);  %CW

if folderNum == 1   % 'upper_field'
    %     off_sync_vi2invi = 90 + visible2invisible;
    %     off_sync_invi2vi = 90 + invisible2visible;
    control_in_u = (90 + visible2invisible(illusionCWIndex) + 90 + invisible2visible(illusionCWIndex))/2;
    control_out_u = (90 + visible2invisible(illusionCCWIndex) + 90 + invisible2visible(illusionCCWIndex))/2;

    %     visible2invisibleDegreeMean = mean(off_sync_vi2invi);
    %     invisible2visibleDegreeMean = mean(off_sync_invi2vi);
    %     off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
elseif folderNum == 2   %  'lower_field'
    %     off_sync_vi2invi = 90 - visible2invisible;
    %     off_sync_invi2vi = 90 - invisible2visible;
    control_in_l = (90 - visible2invisible(illusionCCWIndex) + 90 - invisible2visible(illusionCCWIndex))/2;
    control_out_l = (90 - visible2invisible(illusionCWIndex) + 90 - invisible2visible(illusionCWIndex))/2;
    %     visible2invisibleDegreeMean = mean(off_sync_vi2invi);
    %     invisible2visibleDegreeMean = mean(off_sync_invi2vi);
    %     off_sync_edge_degree = (visible2invisibleDegreeMean + invisible2visibleDegreeMean)/2;
end

control_in_data = [control_in_u; control_in_l] - bar_only_ave_temp;   % first row upper  second row lower
control_out_data = [control_out_u; control_out_l] - bar_only_ave_temp;

if bar_only_mark == 1   % no bar_only
    off_sync_bar_num = 2;
elseif bar_only_mark == 2
    off_sync_bar_num = [1 2];
end

h = bar(off_sync_bar_num,[mean(control_in_data,'all') mean(control_out_data,'all')],'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
hold on;
for off_sync = 1: size(control_in_data,2)
    plot(1 + randn/20,control_in_data(1,off_sync),'r--o');
    plot(2 + randn/20,control_out_data(2,off_sync),'b--o');
end





%----------------------------------------------------------------------
%       plot grab_in  and grab_out
%----------------------------------------------------------------------
if bar_only_mark == 1   % no bar_only
    flash_grab_bar_num = 3;
elseif bar_only_mark == 2  % draw bar only
    flash_grab_bar_num = 3;
end


y_grab = [mean(grab_in_data,'all')  mean(perceived_location_in_data,'all') ...
    mean(grab_out_data,'all')  mean(perceived_location_out_data,'all')] - bar_only_ave_temp;
h = bar(flash_grab_bar_num:flash_grab_bar_num+3,y_grab,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
hold on;

for flash_grab_condition = 1: size(grab_in_data,2)
    plot(flash_grab_bar_num + randn/20,grab_in_data(1,flash_grab_condition) - bar_only_ave_temp,'r--o');
    plot(flash_grab_bar_num + randn/20,grab_in_data(2,flash_grab_condition) - bar_only_ave_temp,'b--o');
    plot(flash_grab_bar_num + 2 + randn/20,grab_out_data(1,flash_grab_condition) - bar_only_ave_temp,'r--o');
    plot(flash_grab_bar_num + 2  + randn/20,grab_out_data(2,flash_grab_condition) - bar_only_ave_temp,'b--o');

end


plot(flash_grab_bar_num + 1 + randn/20,perceived_location_in_data(1) - bar_only_ave_temp,'r--o');
plot(flash_grab_bar_num + 1 + randn/20,perceived_location_in_data(2) - bar_only_ave_temp,'b--o');
plot(flash_grab_bar_num + 3 + randn/20,perceived_location_out_data(1) - bar_only_ave_temp,'r--o');
plot(flash_grab_bar_num + 3 + randn/20,perceived_location_out_data(2) - bar_only_ave_temp,'b--o');


if bar_only_mark == 1
    set(gca, 'XTick', 1:6, 'XTickLabels', {'bar-only' 'off-sync control' 'grab-in'  'perceived-in' ...
        'grab-out' 'perceived-out'},'fontsize',20,'FontWeight','bold');
elseif bar_only_mark == 2
    set(gca, 'XTick', 1:5, 'XTickLabels', {'off-sync control' 'grab-in'  'perceived-in' ...
        'grab-out' 'perceived-out'},'fontsize',20,'FontWeight','bold');
end


xtickangle(45);
set(gcf,'color','w');
set(gca,'box','off');
ylabel('Shift degree from blind field border','FontSize',20,'FontWeight','bold')
% title('Shift degree from horizontal meridian','FontSize',25);
set(gca,'ylim',[-35 70],'FontName','Arial','FontSize',25);
% if barLocation == 'l'
%     %         set(gca, 'YDir', 'reverse');
%     % set the origin on the left top
%     set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
% end

cd ../../../../../../analysis/patient_valid/


% % [h,p_blindfield_offsync,ci,stats] = ttest2(eachtrialdegree_blindfield,eachtrialdegree_off_sync);
% % p_blindfield_offsync
% % [h,p_CCW_perc,ci,stats] = ttest2(flash_grab_CCWDegree,perceived_locationCCW);
% % p_CCW_perc
% % [h,p_CW_perc,ci,stats] = ttest2(flash_grab_CWDegree,perceived_locationCW);
% % p_CW_perc
