% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block

clear all;
addpath '../../function';

annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'blindspot'; % blindspot   artificialScotoma

barOnlyDraw = 'n';   % draw bar_only

% sector blindspot : 'chr','hbb','hjh','hyx','hyy','jwj','lx','lxy','lyh','sry','xs','yyr','zcx','zsj','zy'
% sector artificial scotoma : 'chqy','hbb','hjh','hyy','jwj','lx','lxy','lyh','sry','xs','xyj','yyr','zsj','zy'
% blurredBoundary artificial scotoma:  'hbb','hjh','lxy','sry','xs'
% blurredBoundary blindspot: 'hbb','hjh','hyx','lxy','sry','sx','zcx'
sbjnames = {'chr','hbb','hjh','hyx','hyy','jwj','lx','lxy','lyh','sry','xs','yyr','zcx','zsj','zy'};
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

% datapath = sprintf([path  '%s/'],sbjnames{1});
% cd(datapath);

upperExp = { '_vi2invi_u','_invi2vi_u'}; % ,'_invi2vi_u'  'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
lowerExp = { '_vi2invi_l','_invi2vi_l'}; % ,'_invi2vi_l'


for sbjnum = 1:length(sbjnames)

    if sbjnum == 1
        datapath = sprintf([path  '%s/'],sbjnames{sbjnum});
        cd(datapath);
    else
        cd(strcat(sbjnames{sbjnum},'/'));
    end


    for expcondition = 1:length(upperExp)
        s1 = sbjnames(sbjnum);
        s2 = string(upperExp(expcondition));
        s3 = '*.mat';
        s4 = strcat(s1,s2,s3);

        Files = dir(s4);
        load (Files.name);

        validTrialIndex = find(perceived_location ~= 0);
        illusionCCWIndex = [];
        illusionCWIndex = [];

        for i = 1:length(validTrialIndex)

            if data.flashTiltDirectionMat(validTrialIndex(i)) == 1
                illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
            elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2
                illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
            end
        end

        if strcmp(annulusPattern,'blurredBoundary')
            boundary_out_u(expcondition,:) = 90 - boundary(illusionCCWIndex);
            boundary_in_u(expcondition,:) = 90 - boundary(illusionCWIndex);
        end


        bar_only_u(expcondition,:)  = 90 - bar_only(validTrialIndex);
        off_sync_u(expcondition,:) = 90 - off_sync(validTrialIndex);
        %         off_sync_out_u(expcondition,:) = 90 - off_sync_u(illusionCCWIndex);
        %         off_sync_in_u(expcondition,:) = 90 - off_sync_u(illusionCWIndex);
        flash_grab_out_u(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
        flash_grab_in_u(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
        perceived_location_out_u(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);
        perceived_location_in_u(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
    end


    for expcondition = 1:length(lowerExp)
        s1 = sbjnames(sbjnum);
        s2 = string(lowerExp(expcondition));
        s3 = '*.mat';
        s4 = strcat(s1,s2,s3);

        Files = dir(s4);
        load (Files.name);

        validTrialIndex = find(perceived_location ~= 0);
        illusionCCWIndex = [];
        illusionCWIndex = [];

        for i = 1:length(validTrialIndex)

            if data.flashTiltDirectionMat(validTrialIndex(i)) == 1
                illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
            elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2
                illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
            end
        end

        if strcmp(annulusPattern,'blurredBoundary')
            boundary_out_l(expcondition,:) = boundary(illusionCWIndex) - 90;
            boundary_in_l(expcondition,:) = boundary(illusionCCWIndex) - 90;
        end

        bar_only_l(expcondition,:)  = bar_only(validTrialIndex) - 90;
        off_sync_l(expcondition,:) = off_sync(validTrialIndex) - 90;

        flash_grab_in_l(expcondition,:)  = flash_grab(illusionCCWIndex) - 90;
        flash_grab_out_l(expcondition,:)  = flash_grab(illusionCWIndex) - 90;
        perceived_location_in_l(expcondition,:)  = perceived_location(illusionCCWIndex) - 90;
        perceived_location_out_l(expcondition,:)   = perceived_location(illusionCWIndex) - 90;
    end

    %------------------------------------------------------------------
    %  storage each subject's all data
    %------------------------------------------------------------------
    bar_only_ave = mean([bar_only_u bar_only_l],'all');

    if strcmp(barOnlyDraw,'n')
        bar_only_ave_temp = bar_only_ave;
    elseif strcmp(barOnlyDraw,'y')
        bar_only_l_ave_temp = 0;
    end

    % each trial degree in different condition such as vi2invi or invi2vi
    bar_only_data = [bar_only_u bar_only_l] - bar_only_ave_temp;
    off_sync_data = [off_sync_u  off_sync_l] - bar_only_ave_temp;

    if strcmp(annulusPattern,'blurredBoundary')
        boundary_out_data = [boundary_out_u boundary_out_l] -  bar_only_ave_temp;
        boundary_in_data = [boundary_in_u boundary_in_l] -  bar_only_ave_temp;
    end

    flash_grab_in_data = [flash_grab_in_u flash_grab_in_l] - bar_only_ave_temp;
    perceived_location_in_data = [perceived_location_in_u  perceived_location_in_l] - bar_only_ave_temp;
    flash_grab_out_data = [flash_grab_out_u  flash_grab_out_l] - bar_only_ave_temp;
    perceived_location_out_data = [perceived_location_out_u  perceived_location_out_l] - bar_only_ave_temp;


    %     off_sync_ave = mean([off_sync_u; off_sync_l],"all") - bar_only_ave_temp;

    %     % allign each trial response into one row
    %     eachtrial_flash_grab_out(sbjnum,:) = reshape(flash_grab_out_data,1,numel(flash_grab_out_data));
    %     eachtrial_perceived_location_out(sbjnum,:) = reshape(perceived_location_out_data,1,numel(perceived_location_out_data));
    %     eachtrial_flash_grab_in(sbjnum,:) = reshape(flash_grab_in_data,1,numel(flash_grab_in_data));
    %     eachtrial_perceived_location_in(sbjnum,:) = reshape(perceived_location_in_data,1,numel(perceived_location_in_data));


    % save ave data for each subj
    bar_only_sbj(sbjnum) = mean(bar_only_data,'all');
    off_sync_sbj(sbjnum) = mean(off_sync_data,'all');
    %     off_sync_out_sbj(sbjnum) = mean(mean([off_sync_out_u; off_sync_out_l]));
    %     off_sync_in_sbj(sbjnum) = mean(mean([off_sync_in_u; off_sync_in_l]));
    if strcmp(annulusPattern,'blurredBoundary')
        boundary_out_sbj(sbjnum) = mean(boundary_out_data,'all');
        boundary_in_sbj(sbjnum) = mean(boundary_in_data,'all');
    end

    flash_grab_in_sbj(sbjnum) = mean(flash_grab_in_data,'all');
    perceived_location_in_sbj(sbjnum) = mean(perceived_location_in_data,'all');
    flash_grab_out_sbj(sbjnum) = mean(flash_grab_out_data,'all');
    perceived_location_out_sbj(sbjnum) = mean(perceived_location_out_data,'all');

    cd ../
end



%-----------------------------------------------------------------------------
%    seperate off_sync_out and off_sync_in and add boundary_out  boundary_in
%-----------------------------------------------------------------------------
% if strcmp(annulusPattern,'blurredBoundary')
%     [ave{:}] = deal(mean(bar_only_sbj),mean(off_sync_out_sbj),mean(off_sync_in_sbj),mean(boundary_out_sbj),mean(boundary_in_sbj),...
%         mean(flash_grab_out_sbj),mean(perceived_location_out_sbj),mean(flash_grab_in_sbj),mean(perceived_location_in_sbj));
%     [ave_ste{:}] = deal(ste(bar_only_sbj,2),ste(off_sync_out_sbj,2),ste(off_sync_in_sbj,2),ste(boundary_out_sbj,2),ste(boundary_in_sbj,2),...
%         ste(flash_grab_out_sbj,2),ste(perceived_location_out_sbj,2),ste(flash_grab_in_sbj,2),ste(perceived_location_in_sbj,2));
%     XaxisMarker = {'bar-only' 'off-sync-out' 'off-sync-in' 'boundary-out' 'boundary-in' 'grab-out' 'perc-out' 'grab-in' 'perc-in'};
% else
%
%
%
% end

%---------------------------------------------------
%     combine off_sync_out and off_sync_in
%---------------------------------------------------
if strcmp(barOnlyDraw,'n')
    number_x_axis = 5;
    ave = cell(1, number_x_axis);
    ave_ste = cell(1, number_x_axis);
    [ave{:}] = deal(mean(off_sync_sbj), mean(flash_grab_in_sbj),mean(perceived_location_in_sbj),...
        mean(flash_grab_out_sbj),mean(perceived_location_out_sbj));
    [ave_ste{:}] = deal(ste(off_sync_sbj,2),ste(flash_grab_in_sbj,2),ste(perceived_location_in_sbj,2),...
        ste(flash_grab_out_sbj,2),ste(perceived_location_out_sbj,2));

    %     h = bar(1:2:number_x_axis * 2,cell2mat(ave),'FaceColor','red','EdgeColor',[0.7 0 0],'FaceAlpha', 0.2,'LineWidth',1,'barWidth',0.5);
%     h = bar([1 4:5 8:9],cell2mat(ave),'FaceColor','red','EdgeColor',[0.7 0 0],'FaceAlpha', 0.2,'LineWidth',1,'barWidth',0.5);
% Generate the bar plot
h = bar([1 4:5 8:9],cell2mat(ave),'FaceColor','red','EdgeColor','none','FaceAlpha', 0.2,'LineWidth',1,'barWidth',0.5);


    XaxisMarker = {'Control' 'Grab-in' 'Percived-in' 'Grab-out' 'Perceived-out' };
    ylabel('Shift degree from blindspot border','FontName','Arial','FontSize',30);


elseif strcmp(barOnlyDraw,'y')
    % number of x axis condition
    number_x_axis = 6;
    ave = cell(1, number_x_axis);
    ave_ste = cell(1, number_x_axis);
    [ave{:}] = deal(mean(bar_only_sbj),mean(off_sync_sbj), mean(flash_grab_in_sbj),mean(perceived_location_in_sbj),...
        mean(flash_grab_out_sbj),mean(perceived_location_out_sbj));
    [ave_ste{:}] = deal(ste(bar_only_sbj,2),ste(off_sync_sbj,2),ste(flash_grab_in_sbj,2),ste(perceived_location_in_sbj,2),...
        ste(flash_grab_out_sbj,2),ste(perceived_location_out_sbj,2));
    h = bar(1:number_x_axis,cell2mat(ave),'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
%     h = bar([1 4:5 8:9],cell2mat(ave),'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
    XaxisMarker = {'bar-only' 'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out' };
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
end


hold on;
% errorbar(1:2:number_x_axis * 2,cell2mat(ave),cell2mat(ave_ste),'k.','LineWidth',1);
% set(gca, 'XTick', 1:2:number_x_axis * 2, 'XTickLabels',XaxisMarker,'fontsize',30,'FontWeight','bold');
% change the location of the x tick 
errorbar([1 4:5 8:9],cell2mat(ave),cell2mat(ave_ste),'k.','LineWidth',1);
set(gca, 'XTick', [1 4:5 8:9], 'XTickLabels',XaxisMarker,'fontsize',30,'FontWeight','bold');


% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);
ylim([-30,40]);

hold on;

if strcmp(annulusWidth,'artificialScotoma')
    %     ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',30);
    ylabel('Shift degree from artificial scotoma border','FontName','Arial','FontSize',30);
%     line([0 number_x_axis + 1], [(blindfield_from_horizontal_degree - bar_only_ave_temp) (blindfield_from_horizontal_degree-bar_only_ave_temp)],'LineWidth',1.5,'LineStyle','--');
end

% %----------------------------------------------------------------------
% %  plot  each subject's average value
% %----------------------------------------------------------------------

if strcmp(barOnlyDraw,'n')
    drawEachLoca = 0;
elseif strcmp(barOnlyDraw,'y')
    drawEachLoca = 1;
    for condition = 1: length(bar_only_l)
        plot(drawEachLoca + randn/20,bar_only_l(condition),'Color', [1, 0.5, 0], 'LineStyle', '--', 'Marker', 'o'); % 'r--o'
    end
end
% for condition = 1: length(sbjnames)
%     plot(drawEachLoca + 1 + randn/20,off_sync_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
%     plot(drawEachLoca + 3 + randn/20,flash_grab_in_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
%     plot(drawEachLoca + 5 + randn/20,perceived_location_in_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
%     plot(drawEachLoca + 7 + randn/20,flash_grab_out_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
%     plot(drawEachLoca + 9 + randn/20,perceived_location_out_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
% end

for condition = 1: length(sbjnames)
    plot(drawEachLoca + 1 + randn/20,off_sync_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
    plot(drawEachLoca + 4 + randn/20,flash_grab_in_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
    plot(drawEachLoca + 5 + randn/20,perceived_location_in_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
    plot(drawEachLoca + 8 + randn/20,flash_grab_out_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
    plot(drawEachLoca + 9 + randn/20,perceived_location_out_sbj(condition),'Color', [0.6, 0, 0], 'LineStyle', '--', 'Marker', 'o');
end

cd ../../../../../analysis/eyeGuiding_behavior_data/

% % significant test
% data_all_subj = [off_sync_sbj;flash_grab_in_sbj;perceived_location_in_sbj;flash_grab_out_sbj;perceived_location_out_sbj]';
% [p, tbl, stats] = anova1(data_all_subj);
% [results,~,~,gnames] = multcompare(stats);
% boxplot(data_all_subj);

% Perform t-tests
[h_control, p_control,ci_control,stats_control] = ttest(off_sync_sbj(:));
% [h_control_1, p_grab_in,ci,stats] = ttest2(off_sync_sbj(:), flash_grab_in_sbj(:));
% [h_control_2, p_grab_out] = ttest2(off_sync_sbj(:), flash_grab_out_sbj(:));
[h_grab_in, p_perceive_in,ci_grab_in,stats_grab_in] = ttest(flash_grab_in_sbj(:), perceived_location_in_sbj(:));
[h_grab_out, p_perceive_out,ci_grab_out,stats_grab_out] = ttest(flash_grab_out_sbj(:), perceived_location_out_sbj(:));


% Display results
disp('t-test results:');
disp(['control: h = ', num2str(h_control), ', p = ', num2str(p_control)]);
% disp(['control vs grab-out: h = ', num2str(h_control_2), ', p = ', num2str(p_grab_in)]);
disp(['grab-in vs perceived_in: h = ', num2str(h_grab_in), ', p = ', num2str(p_perceive_in)]);
disp(['grab-out vs perceived_out: h = ', num2str(h_grab_out), ', p = ', num2str(p_perceive_out)]);


