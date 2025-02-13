% for normal participant blindspot/artificial scotoma experiment
% plot each trial data
% only plot one subject upper or lower field data
% only for blind field on the right visual field
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block

clear all;
addpath '../../function';


barOnlyDraw = 'n'; % 'n' means bar only measurements was subtracted from all conditions
annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'blindspot'; % blindspot   artificialScotoma


sbjnames = {'chr','hbb','hjh','hyx','hyy','jwj','lx','lxy','lyh','sry','xs','yyr','zcx','zsj','zy'};
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

visualField = 'u'; % u for upper l for lower

if visualField == 'u'
    visualFieldExp = {'_vi2invi_u','_invi2vi_u'}; %  '_vi2invi_u','_invi2vi_u'
elseif visualField == 'l'
    visualFieldExp = {'_vi2invi_l','_invi2vi_l',}; % '_vi2invi_l','_invi2vi_l',
end


for sbjnum = 1:length(sbjnames)

    if sbjnum == 1
        datapath = sprintf([path  '%s/'],sbjnames{sbjnum});
        cd(datapath);
    else
        cd(strcat(sbjnames{sbjnum},'/'));
    end


    %----------------------------------------------------------------------
    %        restore  upper/lower visual field data
    %----------------------------------------------------------------------
    for expcondition = 1:length(visualFieldExp)
        s1 = sbjnames(sbjnum);
        s2 = string(visualFieldExp(expcondition));
        s3 = '*.mat';
        s4 = strcat(s1,s2,s3);

        Files = dir(s4);
        load (Files.name);

        validTrialIndex = find(perceived_location ~= 0);
        illusionCCWIndex = [];
        illusionCWIndex = [];

        for i = 1:length(validTrialIndex)

            if data.flashTiltDirectionMat(validTrialIndex(i)) == 1    % CCW
                illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
            elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2   % CW
                illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
            end
        end

        if strcmp(annulusPattern,'blurredBoundary')
            boundary_out_data(expcondition,:) = 90 - boundary(illusionCCWIndex);
            boundary_in_data(expcondition,:) = 90 - boundary(illusionCWIndex);
        end

        bar_only_data(expcondition,:) = 90 - bar_only(validTrialIndex);
        off_sync_data(expcondition,:) = 90 - off_sync(validTrialIndex);
        grab_in_data(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
        perceived_in_data(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
        grab_out_data(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
        perceived_out_data(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);

    end

    %----------------------------------------------------------------------
    %   each subject's  average
    %----------------------------------------------------------------------
    bar_only_ave_each_subj(sbjnum) = mean(bar_only_data,'all');
    off_sync_ave_each_subj(sbjnum) = mean(off_sync_data,'all');
    grab_in_ave_each_subj(sbjnum) = mean(grab_in_data,'all');
    perceived_in_ave_each_subj(sbjnum) = mean(perceived_in_data,'all');
    grab_out_ave_each_subj(sbjnum) = mean(grab_out_data,'all');
    perceived_out_ave_each_subj(sbjnum) = mean(perceived_out_data,'all');

    %----------------------------------------------------------------------
    %   all  subject's  data
    %----------------------------------------------------------------------

    bar_only_data_subj(:,:,sbjnum) = bar_only_data;
    off_sync_data_subj(:,:,sbjnum) = off_sync_data;
    flash_grab_in_data_subj(:,:,sbjnum) = grab_in_data;
    perceived_location_in_data_subj(:,:,sbjnum) = perceived_in_data;
    flash_grab_out_data_subj(:,:,sbjnum) = grab_out_data;
    perceived_location_out_data_subj(:,:,sbjnum)  = perceived_out_data;
    cd ../
end



%----------------------------------------------------------------------
%    average all subjects'  data
%----------------------------------------------------------------------
bar_only_ave = mean(bar_only_data_subj,'all');
off_sync_ave = mean(off_sync_data_subj,'all'); % first row is vi2invi and second row is invi2vi
flash_grab_in_ave = mean(flash_grab_in_data_subj,'all');
perceived_in_ave = mean(perceived_location_in_data_subj,'all');
flash_grab_out_ave = mean(flash_grab_out_data_subj,'all');
perceived_out_ave = mean(perceived_location_out_data_subj,'all');

if strcmp(annulusPattern,'blurredBoundary')
    boundary_in_u_ave =  mean(boundary_in_u,'all');
    boundary_out_u_ave = mean(boundary_out_u,'all');
end



%----------------------------------------------------------------------
%     plot bar charts
%----------------------------------------------------------------------

if strcmp(barOnlyDraw,'y')
    if strcmp(annulusPattern,'blurredBoundary')
        y_u = [bar_only_ave off_sync_ave boundary_in_ave boundary_out_ave flash_grab_in_ave perceived_in_ave flash_grab_out_ave perceived_out_ave];
    else
        y_u = [bar_only_ave off_sync_ave flash_grab_in_ave perceived_in_ave flash_grab_out_ave perceived_out_ave];
    end
elseif strcmp(barOnlyDraw,'n')
    y_u = [off_sync_ave flash_grab_in_ave perceived_in_ave flash_grab_out_ave perceived_out_ave] - bar_only_ave;
end


h_u = bar(y_u,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
hold on;

%----------------------------------------------------------------------
%  plot  each subject's average value
%----------------------------------------------------------------------

if strcmp(barOnlyDraw,'n')
    drawEachLoca = 0;
elseif strcmp(barOnlyDraw,'y')
    drawEachLoca = 1;
    for condition = 1: length(bar_only_ave_each_subj)
        plot(drawEachLoca + randn/20,bar_only_ave_each_subj(condition),'r--o');
    end
end
for condition = 1: length(sbjnames)
    plot(drawEachLoca + 1 + randn/20,off_sync_ave_each_subj(condition)- bar_only_ave,'r--o');
    plot(drawEachLoca + 2 + randn/20,grab_in_ave_each_subj(condition)- bar_only_ave,'r--o');
    plot(drawEachLoca + 3 + randn/20,perceived_in_ave_each_subj(condition)- bar_only_ave,'r--o');
    plot(drawEachLoca + 4 + randn/20,grab_out_ave_each_subj(condition)- bar_only_ave,'r--o');
    plot(drawEachLoca + 5 + randn/20,perceived_out_ave_each_subj(condition)- bar_only_ave,'r--o');
end




%----------------------------------------------------------------------
%    xLable for draw and don't draw bar_only data   and yLable
%----------------------------------------------------------------------

if strcmp(barOnlyDraw,'n')
    drawBarNum = 5;
    %     ylim([-15,50]);
    xLable = {'off-sync' 'grab-in' 'perceived-in' 'grab-out' 'perceived-out'};
elseif strcmp(barOnlyDraw,'y')
    if strcmp(annulusPattern,'blurredBoundary')
        drawBarNum = 8;
        xLable = {'bar-only' 'off-sync'  'grab-in' 'perceived-in' 'grab-out' 'perceived-out' 'boundary-in' 'boundary-out'};
    else
        drawBarNum = 6;
        xLable = {'bar-only' 'off-sync' 'grab-in' 'perceived-in' 'grab-out' 'perceived-out'};
    end
end


set(gca, 'XTick', 1:drawBarNum, 'XTickLabels',xLable ,'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
% ylim([-15,50]);
ylim([-50,70]);
xtickangle(45);
hold on;
ylabel('     Away from blind border   -->','FontName','Arial','FontSize',25);

% if strcmp(annulusWidth,'artificialScotoma')
%     ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
%     %     line([0 drawBarNum + 1], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5,'LineStyle','--');
% end




% cd ../../../../../../analysis/eyeGuiding_behavior_data/



