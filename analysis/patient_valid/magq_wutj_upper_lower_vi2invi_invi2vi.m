% for hemianopia patient 5 maguangquan (left)  and patient 6 wutianjiang(left)
% notice it is contratory for injury in left visual field and right visual
% field
% this is for left visual field injury

% For data in maguangquan  up vertical is 0  move rightward -1
% from 0 move leftward is +1
% lower vertical is 0 move rightward(CCW) +1
% from 0 move leftward(CW)  -1

% in the upper visual field CCW is grab_in
% in the lower visual field CW is grab_in
% 20230921 By Jiahan Hui


clear all;

bar_only_mark = 2; % 1 means show bar_only  2 means no bar_only data  every data was normalized by bar_only
% pValue = input('>>>Calculate p Value? (y/n):  ','s');
% only could plot 1 subject
sbjnames = { 'maguangquan' } ; % 6'maguangquan' (left)  7 'wutianjiang' (left)

fieldNum = 1;   % choose which visual to analysis
fieldfolders = {'upper_field','lower_field'}; % ,'lower_field' ,'normal_field'
path = '../../data/corticalBlindness/bar';
areaFolderName = fullfile(path, fieldfolders{fieldNum});
cd(areaFolderName);

viInvifolders = {'vi2invi' 'invi2vi'};   %  'invi2vi'

for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);

    for viInvifolderNum = 1:length(viInvifolders)

        if viInvifolderNum == 1    % subfolders = {'vi2invi'};
            cd(viInvifolders{viInvifolderNum});
        else viInvifolderNum == 2    % subfolders = {'invi2vi'};
            cd (['../' viInvifolders{viInvifolderNum}]);
        end

        Files = dir(s3);
        load (Files.name);

        illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
        illusionCWIndex = find(data.flashTiltDirection == 2);  % CW

        % The first row is vi2invi and the second row is invi2vi
        bar_only_data(viInvifolderNum,:) = 90 + multiplier * bar_only;
        off_sync_data(viInvifolderNum,:) = 90 + multiplier * off_sync;

        if strcmp(fieldfolders{fieldNum} , 'upper_field')
            bar_only_data(viInvifolderNum,:) = 90 - bar_only;
            off_sync_data(viInvifolderNum,:) = 90 - off_sync;
            flash_grab_in_data(viInvifolderNum,:)  = 90 - flash_grab(illusionCCWIndex);
            flash_grab_out_data(viInvifolderNum,:)  = 90 - flash_grab(illusionCWIndex);

            if strcmp(condition, 'invi2vi')
                perceived_location_in(viInvifolderNum,:) = 90 - perceived_location(illusionCCWIndex);
                perceived_location_out(viInvifolderNum,:) = 90 - perceived_location(illusionCWIndex);
            end

        elseif strcmp(fieldfolders{fieldNum} , 'lower_field')
            bar_only_data(viInvifolderNum,:) = 90 + bar_only;
            off_sync_data(viInvifolderNum,:) = 90 + off_sync;
            flash_grab_in_data(viInvifolderNum,:)  = 90 + flash_grab(illusionCWIndex);
            flash_grab_out_data(viInvifolderNum,:)  = 90 + flash_grab(illusionCCWIndex);

            if strcmp(condition, 'invi2vi')
                perceived_location_in(viInvifolderNum,:) = 90 + perceived_location(illusionCWIndex);
                perceived_location_out(viInvifolderNum,:) = 90 +  perceived_location(illusionCCWIndex);
            end
        end
    end
end


%----------------------------------------------------------------------
%  average data
%----------------------------------------------------------------------

bar_only_ave = mean(bar_only_data,'all');
off_sync_ave = mean(off_sync_data,'all');
grab_in_ave = mean(flash_grab_in_data,'all');
perceived_in_ave = mean(perceived_location_in(2,:),'all');
grab_out_ave = mean(flash_grab_out_data,'all');
perceived_out_ave = mean(perceived_location_out(2,:),'all');

%----------------------------------------------------------------------
%  plot with bar_only (bar_only_mark == 1)
%----------------------------------------------------------------------

if bar_only_mark == 1

    y = [bar_only_ave off_sync_ave grab_in_ave perceived_in_ave  grab_out_ave  perceived_out_ave];
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
    XaxisMarker = {'bar-only' 'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out'} ;
    set(gca, 'XTick', 1:6, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold');
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
    hold on;
    %----------------------------------------------------------------------
    %  plot  each trial
    %----------------------------------------------------------------------

    for condition = 1: length(bar_only_data)
        plot(1 + randn/20,bar_only_data(1,condition),'r--o');
        plot(1 + randn/20,bar_only_data(2,condition),'b--o');
        plot(2 + randn/20,off_sync_data(1,condition),'r--o');
        plot(2 + randn/20,off_sync_data(2,condition),'b--o');
    end

    for condition = 1: length(flash_grab_in_data)
        plot(3 + randn/20,flash_grab_in_data(1,condition),'r--o');
        plot(3 + randn/20,flash_grab_in_data(2,condition),'b--o');
        plot(5 + randn/20,flash_grab_out_data(1,condition),'r--o');
        plot(5 + randn/20,flash_grab_out_data(2,condition),'b--o');
    end

    for condition = 1: length(perceived_location_in)
        plot(4 + randn/20,perceived_location_in(2,condition),'b--o');
        plot(6 + randn/20,perceived_location_out(2,condition),'b--o');
    end



    %----------------------------------------------------------------------
    %  plot without  bar_only (bar_only_mark == 1)
    %----------------------------------------------------------------------
elseif bar_only_mark == 2

    y = [off_sync_ave grab_in_ave perceived_in_ave  grab_out_ave  perceived_out_ave] - bar_only_ave;
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',5);
    XaxisMarker = {'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out'} ;
    set(gca, 'XTick', 1:5, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold')
    ylabel('Shift degree from blind border','FontName','Arial','FontSize',30);
    hold on;

    %----------------------------------------------------------------------
    %  plot  each trial
    %----------------------------------------------------------------------

    for condition = 1: length(off_sync_data)
        plot(1 + randn/20,off_sync_data(1,condition) - bar_only_ave,'r--o');
        plot(1 + randn/20,off_sync_data(2,condition) - bar_only_ave,'b--o');
    end

    for condition = 1: length(flash_grab_in_data)
        plot(2 + randn/20,flash_grab_in_data(1,condition) - bar_only_ave,'r--o');
        plot(2 + randn/20,flash_grab_in_data(2,condition) - bar_only_ave,'b--o');
        plot(4 + randn/20,flash_grab_out_data(1,condition) - bar_only_ave,'r--o');
        plot(4 + randn/20,flash_grab_out_data(2,condition) - bar_only_ave,'b--o');
    end

    for condition = 1: length(perceived_location_in)
        plot(3 + randn/20,perceived_location_in(2,condition) - bar_only_ave,'b--o');
        plot(5 + randn/20,perceived_location_out(2,condition) - bar_only_ave,'b--o');
    end

end


set(gca,'ylim',[-30 70],'FontName','Arial','FontSize',25);
set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);



cd ../../../../../analysis/patient_valid/
