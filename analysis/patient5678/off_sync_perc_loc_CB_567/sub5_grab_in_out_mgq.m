% for hemianopia patient mali
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location

% notice it is contratory for injury in left visual field and right visual
% field
% this is for left visual field injury
% in the upper visual field CCW is grab_in
% in the lower visual field CW is grab_in



clear all;

addpath '../../../function';

bar_only_mark = 1; % 1 means show bar_only  2 means no bar_only data  every data was normalized by bar_only
% pValue = input('>>>Calculate p Value? (y/n):  ','s');
% only could plot 1 subject
sbjnames = { 'wutianjiang' } ; % 6'maguangquan' (left)    7'wutianjiang' (left)   5'mali'(right)  only could plot 1 subject

fieldNum = 1;   % choose which visual to analysis
fieldfolders = {'upper_field','lower_field'}; % ,'lower_field' ,'normal_field'
path = '../../../data/corticalBlindness/bar';
% areaFolderName = fullfile(path, folders{folderNum});
% cd(areaFolderName);


viInvifolders = {'vi2invi' 'invi2vi'};   %  'invi2vi'
viInvifolderNums = length(viInvifolders);  % analy each condition include {'invi2vi','vi2invi'};

for fieldNum = 1:length(fieldfolders)
    areaFolderName = fullfile(path, fieldfolders{fieldNum});
    if fieldNum == 1
        cd(areaFolderName);
    elseif fieldNum == 2
        cd(['../../' fieldfolders{fieldNum}]);
    end

    for sbjnum = 1:length(sbjnames)
        s1 = string(sbjnames(sbjnum));
        s2 = '*.mat';
        s3 = strcat(s1,s2);
        %     if sbjnum > 1
        %         cd '../../percLocaTest/added_gabor_location'
        %     end


        %     if strcmp(string(sbjnames(sbjnum)),'mali') == 1

        for viInvifolderNum = 1:viInvifolderNums

            if viInvifolderNum == 1    % subfolders = {'vi2invi'};
                cd(viInvifolders{viInvifolderNum});
            else viInvifolderNum == 2    % subfolders = {'invi2vi'};
                cd (['../' viInvifolders{viInvifolderNum}]);
            end

            Files = dir(s3);
            load (Files.name);
            %----------------------------------------------------------------------
            %          sbj 'mali'   CCW & CW add  perceived location test
            %----------------------------------------------------------------------

            if strcmp(sbjnames, 'mali')

                if strcmp(fieldfolders{fieldNum} , 'upper_field')
                    multiplier =  1 ;
                elseif strcmp(fieldfolders{fieldNum} , 'lower_field')
                    multiplier = - 1 ;
                end

                bar_CCW = 90 + multiplier * bar_only;
                bar_CW = 90 + multiplier * bar_only;

                %             illusionCCWIndex = find(data.flashTiltDirection_off_sync == 1);
                %             illusionCWIndex = find(data.flashTiltDirection_off_sync == 2);
                off_sync_Degree(viInvifolderNum,:) = 90 + multiplier * off_sync;
                %             off_sync_CWDegree(subfolderNum,:) =  90 + multiplier * off_sync;


                if strcmp(viInvifolders{fieldNum} , 'upper_field')

                    illusionCCWIndex = find(data.flashTiltDirection_grab_upper == 1);
                    illusionCWIndex = find(data.flashTiltDirection_grab_upper == 2);
                    flash_grab_CCW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
                    flash_grab_CW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);


                    if strcmp(condition, 'invi2vi')

                        illusionCCWIndex = find(data.flashTiltDirection_grab_upper == 1);
                        illusionCWIndex = find(data.flashTiltDirection_grab_upper == 2);
                        perceived_location_CCW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                        perceived_location_CW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
                    end

                elseif strcmp(viInvifolders{fieldNum} , 'lower_field')

                    illusionCCWIndex = find(data.flashTiltDirection_grab_lower == 1);
                    illusionCWIndex = find(data.flashTiltDirection_grab_lower == 2);
                    flash_grab_CCW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
                    flash_grab_CW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);


                    if strcmp(condition, 'invi2vi')

                        illusionCCWIndex = find(data.flashTiltDirection_grab_lower == 1);
                        illusionCWIndex = find(data.flashTiltDirection_grab_lower == 2);
                        perceived_location_CCW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                        perceived_location_CW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
                    end

                end

                %----------------------------------------------------------------------
                %    sbj not  'mali'   CCW & CW add  perceived location test
                %----------------------------------------------------------------------
            else   %  if not 'mali'

                if strcmp(fieldfolders{fieldNum} , 'upper_field')
                    multiplier = - 1 ;
                elseif strcmp(fieldfolders{fieldNum} , 'lower_field')
                    multiplier =  1 ;
                end

                illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
                illusionCWIndex = find(data.flashTiltDirection == 2);  % CW

                % The first row of bar_CCW is vi2invi and the second row is
                % invi2vi
                bar_CCW(viInvifolderNum,:) = 90 + multiplier * bar_only(illusionCCWIndex);
                bar_CW(viInvifolderNum,:) = 90 + multiplier * bar_only(illusionCWIndex);
                off_sync_CCW(viInvifolderNum,:) = 90 + multiplier * off_sync(illusionCCWIndex);
                off_sync_CW(viInvifolderNum,:) =  90 + multiplier * off_sync(illusionCWIndex);
                flash_grab_CCW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCCWIndex);
                flash_grab_CW(viInvifolderNum,:) =  90 + multiplier * flash_grab(illusionCWIndex);

                if strcmp(condition, 'invi2vi')
                    perceived_location_CCW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCCWIndex);
                    perceived_location_CW(viInvifolderNum,:) = 90 + multiplier * perceived_location(illusionCWIndex);
                end

            end
        end


        %----------------------------------------------------------------------
        %  physical location of  each trial
        %----------------------------------------------------------------------

        eachtrial_bar_only(fieldNum,:) = reshape([bar_CW bar_CCW]',1,8);   % the first 4 value is vi2invi   the rest is invi2vi
        if strcmp(sbjnames, 'mali')
            eachtrial_off_sync(fieldNum,:)  = off_sync_Degree;
        else
            eachtrial_off_sync(fieldNum,:)  = reshape([off_sync_CW off_sync_CCW]',1,8);
        end
        % the first row is upper visual
        eachtrial_flash_CCW(fieldNum,:)  = reshape(flash_grab_CCW,1,4);
        eachtrial_perc_CCW(fieldNum,:)  = nonzeros(perceived_location_CCW)';
        eachtrial_flash_CW(fieldNum,:)  = reshape(flash_grab_CW,1,4);
        eachtrial_perc_CW(fieldNum,:)  = nonzeros(perceived_location_CW)';


        %----------------------------------------------------------------------
        %  plot  average value of each trial
        %----------------------------------------------------------------------
        bar_only_field(fieldNum) = mean(reshape([bar_CW bar_CCW],1,8));
        if strcmp(sbjnames, 'mali')
            off_sync_field(fieldNum)  = mean(reshape(off_sync_Degree,1,8));
        else
            off_sync_field(fieldNum)  = mean(reshape([off_sync_CCW off_sync_CW],1,8));
        end
        flash_grab_CCW_field(fieldNum) = mean(reshape(flash_grab_CCW,1,4));
        flash_grab_CW_field(fieldNum)  = mean(reshape(flash_grab_CW,1,4));

        if strcmp(condition, 'invi2vi')
            perceived_location_CCWField(fieldNum)  = mean(perceived_location_CCW(2,:));
            perceived_location_CWField(fieldNum)  = mean(perceived_location_CW(2,:));
        end

    end
end



if bar_only_mark == 1


    %----------------------------------------------------------------------
    %  combind grab_in and grab_out
    %----------------------------------------------------------------------

    ave_bar_only = mean(bar_only_field);
    ave_off_sync = mean(off_sync_field);
    ave_grab_in = (flash_grab_CCW_field(1) + flash_grab_CW_field(2))/2;
    ave_perc_in = (perceived_location_CCWField(1) + perceived_location_CWField(2))/2;
    ave_grab_out = (flash_grab_CCW_field(2) + flash_grab_CW_field(1))/2;
    ave_perc_out = (perceived_location_CCWField(2) + perceived_location_CWField(1))/2;

    y = [ave_bar_only ave_off_sync ave_grab_in ave_perc_in  ave_grab_out  ave_perc_out];
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);


    XaxisMarker = {'bar-only' 'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out'} ;

    set(gca, 'XTick', 1:6, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold');

    % set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

    set(gcf,'color','w');
    set(gca,'box','off');
    xtickangle(45);

    %     if folders{fieldNum} == 'lower_field'
    %         % set the origin on the left top
    %         set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    %     end

    hold on;
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
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

    % eachtrial_grab_CCW(1,:)  is upper visual field CCW
    eachtrial_grab_in = [eachtrial_flash_CCW(1,:)  eachtrial_flash_CW(2,:)];
    eachtrial_perc_in = [eachtrial_perc_CCW(1,:)  eachtrial_perc_CW(2,:)];
    eachtrial_grab_out = [eachtrial_flash_CCW(2,:)   eachtrial_flash_CW(1,:)];
    eachtrial_perc_out = [eachtrial_perc_CCW(2,:)   eachtrial_perc_CW(1,:)];




    for condition = 1: length(eachtrial_bar_only)
        plot(1 + randn/20,eachtrial_bar_only(condition),'r--o');
        plot(2 + randn/20,eachtrial_off_sync(condition),'r--o');
    end

    for condition = 1: length(eachtrial_grab_in)
        plot(3 + randn/20,eachtrial_grab_in(condition),'r--o');
        plot(5 + randn/20,eachtrial_grab_out(condition),'r--o');
    end

    for condition = 1: length(eachtrial_perc_in)
        plot(4 + randn/20,eachtrial_perc_in(condition),'r--o');
        plot(6 + randn/20,eachtrial_perc_out(condition),'r--o');
    end


elseif bar_only_mark == 2
    %----------------------------------------------------------------------
    %  combind invisible2visible & visible2invisible
    %----------------------------------------------------------------------

    y = [off_sync_field flash_grab_CCW_field perceived_location_CCWField flash_grab_CW_field perceived_location_CWField] - bar_only_field;


    % y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
    h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    if strcmp(viInvifolders{fieldNum} , 'upper_field')
        XaxisMarker = {'off-sync' 'grab-out' 'perc-out' 'grab-in' 'perc-in'} ;
    elseif strcmp(viInvifolders{fieldNum} , 'lower_field')
        XaxisMarker = {'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out'} ;
    end
    set(gca, 'XTick', 1:5, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold');

    % set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

    set(gca,'ylim',[-50 90],'FontName','Arial','FontSize',25);
    set(gcf,'color','w');
    set(gca,'box','off');
    xtickangle(45);

    if viInvifolders{fieldNum} == 'lower_field'
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    hold on;
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
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
    eachtrial_bar_only = [reshape(bar_CCW,1,4) reshape(bar_CW,1,4)] - bar_only_field;
    % plot off_sync data
    eachtrial_off_sync = [reshape(off_sync_CCW,1,4) reshape(off_sync_CW,1,4)] - bar_only_field;
    % plot grab_CCW data
    eachtrial_flash_CCW = reshape(flash_grab_CCW,1,4) - bar_only_field;
    % plot perc_CCW data
    eachtrial_perc_CCW = nonzeros(perceived_location_CCW)' - bar_only_field;
    % plot grab_CW data
    eachtrial_flash_CW = reshape(flash_grab_CW,1,4) - bar_only_field;
    % plot perc_CW data
    eachtrial_perc_CW = nonzeros(perceived_location_CW)' - bar_only_field;


    for condition = 1: length(eachtrial_bar_only)
        %         plot(1,eachtrialdegree_bar_only(condition),'r--o');
        plot(1 + randn/20,eachtrial_off_sync(condition),'r--o');
    end

    for condition = 1: length(eachtrial_flash_CCW)
        plot(2 + randn/20,eachtrial_flash_CCW(condition),'r--o');
        plot(4 + randn/20,eachtrial_flash_CW(condition),'r--o');
    end

    for condition = 1: length(eachtrial_perc_CCW)
        plot(3 + randn/20,eachtrial_perc_CCW(condition),'r--o');
        plot(5 + randn/20,eachtrial_perc_CW(condition),'r--o');
    end

end

cd ../../../../../analysis/vi2invi_in2vi_perc_off_sync/off_sync_perc_loc_CB_567/
