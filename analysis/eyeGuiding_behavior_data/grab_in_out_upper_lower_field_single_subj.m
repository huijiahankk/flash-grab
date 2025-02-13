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
annulusWidth = 'artificialScotoma'; % blindspot   artificialScotoma


% sector blindspot : 'chr','hbb','hjh','hyx','hyy','jwj','lx','lxy','lyh','sry','xs','xyj','yyr','zcx','zsj','zy'
% sector artificial scotoma : 'chqy','hbb','hjh','hyy','jwj','lx','lxy','lyh','sry','xs','xyj','yyr','zsj','zy'
% blurredBoundary artificial scotoma:  'hbb','hjh','lxy','sry','xs'
% blurredBoundary blindspot: 'hbb','hjh','hyx','lxy','sry','sx','zcx'

sbjnames = {'zy'};
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');


visualField = 'l'; % u for upper l for lower


upperExp = {'_vi2invi_u','_invi2vi_u'}; %  '_vi2invi_u','_invi2vi_u'
lowerExp = {'_vi2invi_l','_invi2vi_l',}; % '_vi2invi_l','_invi2vi_l',


for sbjnum = 1:length(sbjnames)

    if sbjnum == 1
        datapath = sprintf([path  '%s/'],sbjnames{sbjnum});
        cd(datapath);
    else
        cd(strcat(sbjnames{sbjnum},'/'));
    end

    if strcmp(visualField,'u')
        %----------------------------------------------------------------------
        %        restor  upper visual field data
        %----------------------------------------------------------------------
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

                if data.flashTiltDirectionMat(validTrialIndex(i)) == 1    % CCW
                    illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
                elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2   % CW
                    illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
                end
            end

            if strcmp(annulusPattern,'blurredBoundary')
                boundary_out_u(expcondition,:) = 90 - boundary(illusionCCWIndex);
                boundary_in_u(expcondition,:) = 90 - boundary(illusionCWIndex);
            end

            bar_only_u(expcondition,:) = 90 - bar_only(validTrialIndex);
            off_sync_u(expcondition,:) = 90 - off_sync(validTrialIndex);
            flash_grab_in_u(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
            perceived_location_in_u(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
            flash_grab_out_u(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
            perceived_location_out_u(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);

        end
        %         off_sync_u = [off_sync_CW_u off_sync_CCW_u];

    elseif strcmp(visualField,'l')
        %----------------------------------------------------------------------
        %        restore  lower visual field data
        %----------------------------------------------------------------------
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
                boundary_in_l(expcondition,:) = boundary(illusionCCWIndex) - 90;
                boundary_out_l(expcondition,:) = boundary(illusionCWIndex) - 90;
            end

            bar_only_l(expcondition,:) = (bar_only(validTrialIndex) - 90);
            off_sync_l(expcondition,:) = (off_sync(validTrialIndex) - 90);
            flash_grab_in_l(expcondition,:)  = (flash_grab(illusionCCWIndex) - 90);
            perceived_location_in_l(expcondition,:)  = (perceived_location(illusionCCWIndex) - 90);
            flash_grab_out_l(expcondition,:)  = (flash_grab(illusionCWIndex) - 90);
            perceived_location_out_l(expcondition,:)  = (perceived_location(illusionCWIndex) - 90);
        end


        cd ../

    end
end


if strcmp(visualField,'u')
    %----------------------------------------------------------------------
    %  upper visual field  -----  average data
    %----------------------------------------------------------------------
    bar_only_u_ave = mean(bar_only_u,'all');
    off_sync_u_ave = mean(off_sync_u,'all'); % first row is vi2invi and second row is invi2vi
    flash_grab_in_u_ave = mean(flash_grab_in_u,'all');
    perceived_in_u_ave = mean(perceived_location_in_u,'all');
    flash_grab_out_u_ave = mean(flash_grab_out_u,'all');
    perceived_out_u_ave = mean(perceived_location_out_u,'all');

    if strcmp(annulusPattern,'blurredBoundary')
        boundary_in_u_ave =  mean(boundary_in_u,'all');
        boundary_out_u_ave = mean(boundary_out_u,'all');
    end



    %----------------------------------------------------------------------
    % upper visual field --- plot bar charts
    %----------------------------------------------------------------------

    if strcmp(barOnlyDraw,'y')
        if strcmp(annulusPattern,'blurredBoundary')
            y_u = [bar_only_u_ave off_sync_u_ave boundary_in_u_ave boundary_out_u_ave flash_grab_in_u_ave perceived_in_u_ave flash_grab_out_u_ave perceived_out_u_ave];
        else
            y_u = [bar_only_u_ave off_sync_u_ave flash_grab_in_u_ave perceived_in_u_ave flash_grab_out_u_ave perceived_out_u_ave];
        end
    elseif strcmp(barOnlyDraw,'n')
        y_u = [off_sync_u_ave flash_grab_in_u_ave perceived_in_u_ave flash_grab_out_u_ave perceived_out_u_ave] - bar_only_u_ave;
    end


    h_u = bar(y_u,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
    hold on;

    %----------------------------------------------------------------------
    %  upper visual field ---  draw each trial  red for vi2invi   blue for invi2vi
    %----------------------------------------------------------------------
    if strcmp(barOnlyDraw,'n')
        drawEachLoca = 0;
        bar_only_u_ave_temp = bar_only_u_ave;
    elseif strcmp(barOnlyDraw,'y')
        drawEachLoca = 1;
        bar_only_u_ave_temp = 0;
        for condition = 1: length(bar_only_u)
            plot(drawEachLoca + randn/20,bar_only_u(condition),'r--o');
        end
    end
    hold on;
    for condition = 1: size(off_sync_u,2)
        plot(drawEachLoca + 1 + randn/20,off_sync_u(1,condition)- bar_only_u_ave_temp,'r--o');
        plot(drawEachLoca + 1 + randn/20,off_sync_u(2,condition)- bar_only_u_ave_temp,'b--o');
    end
    for condition = 1:size(flash_grab_in_u,2)
        plot(drawEachLoca + 2 + randn/20,flash_grab_in_u(1,condition)- bar_only_u_ave_temp,'r--o');
        plot(drawEachLoca + 2 + randn/20,flash_grab_in_u(2,condition)- bar_only_u_ave_temp,'b--o');
        plot(drawEachLoca + 3 + randn/20,perceived_location_in_u(1,condition)- bar_only_u_ave_temp,'r--o');
        plot(drawEachLoca + 3 + randn/20,perceived_location_in_u(2,condition)- bar_only_u_ave_temp,'b--o');
        plot(drawEachLoca + 4 + randn/20,flash_grab_out_u(1,condition)- bar_only_u_ave_temp,'r--o');
        plot(drawEachLoca + 4 + randn/20,flash_grab_out_u(2,condition)- bar_only_u_ave_temp,'b--o');
        plot(drawEachLoca + 5 + randn/20,perceived_location_out_u(1,condition)- bar_only_u_ave_temp,'r--o');
        plot(drawEachLoca + 5 + randn/20,perceived_location_out_u(2,condition)- bar_only_u_ave_temp,'b--o');

        if strcmp(annulusPattern,'blurredBoundary')
            plot(drawEachLoca + 6 + randn/20,boundary_in_u(1,condition),'r--o');
            plot(drawEachLoca + 6 + randn/20,boundary_out_u(2,condition),'b--o');
        end
    end
    hold on;

elseif strcmp(visualField,'l')
    %----------------------------------------------------------------------
    %  lower visual field --- average  data
    %----------------------------------------------------------------------
    bar_only_l_ave = mean(bar_only_l,'all');
    off_sync_l_ave = mean(off_sync_l,'all'); % first row is vi2invi and second row is invi2vi
    flash_grab_in_l_ave = mean(flash_grab_in_l,'all');
    perceived_in_l_ave = mean(perceived_location_in_l,'all');
    flash_grab_out_l_ave = mean(flash_grab_out_l,'all');
    perceived_out_l_ave = mean(perceived_location_out_l,'all');

    if strcmp(annulusPattern,'blurredBoundary')
        boundary_in_l_ave =  mean(boundary_in_l,'all');
        boundary_out_l_ave = mean(boundary_out_l,'all');
    end


    %----------------------------------------------------------------------
    %  lower visual field --- plot bar charts
    %----------------------------------------------------------------------

    if strcmp(barOnlyDraw,'y')
        if strcmp(annulusPattern,'blurredBoundary')
            y_u = [bar_only_l_ave off_sync_l_ave boundary_in_l_ave boundary_out_l_ave flash_grab_in_l_ave perceived_in_l_ave flash_grab_out_l_ave perceived_out_l_ave];
        else
            y_l = [bar_only_l_ave off_sync_l_ave flash_grab_in_l_ave perceived_in_l_ave flash_grab_out_l_ave perceived_out_l_ave];
        end
    elseif strcmp(barOnlyDraw,'n')
        y_l = [off_sync_l_ave flash_grab_in_l_ave perceived_in_l_ave flash_grab_out_l_ave perceived_out_l_ave] - bar_only_l_ave;
    end


    h_l = bar(y_l,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
    hold on;

    %----------------------------------------------------------------------
    %  lower visual field ---  draw each trial  red for vi2invi   blue for invi2vi
    %----------------------------------------------------------------------
    if strcmp(barOnlyDraw,'n')
        drawEachLoca = 0;
        bar_only_l_ave_temp = bar_only_l_ave;
    elseif strcmp(barOnlyDraw,'y')
        drawEachLoca = 1;
        bar_only_l_ave_temp = 0;
        for condition = 1: length(bar_only_l)
            plot(drawEachLoca + randn/20,bar_only_l(condition),'r--o');
        end
    end
    hold on;
    for condition = 1: size(off_sync_l,2)
        plot(drawEachLoca + 1 + randn/20,off_sync_l(1,condition) - bar_only_l_ave_temp,'r--o','MarkerSize',5);
        plot(drawEachLoca + 1 + randn/20,off_sync_l(2,condition) - bar_only_l_ave_temp,'b--o');
    end

    for condition = 1:size(flash_grab_in_l,2)
        plot(drawEachLoca + 2 + randn/20,flash_grab_in_l(1,condition) - bar_only_l_ave_temp,'r--o');
        plot(drawEachLoca + 2 + randn/20,flash_grab_in_l(2,condition) - bar_only_l_ave_temp,'b--o');
        plot(drawEachLoca + 3 + randn/20,perceived_location_in_l(1,condition) - bar_only_l_ave_temp,'r--o');
        plot(drawEachLoca + 3 + randn/20,perceived_location_in_l(2,condition) - bar_only_l_ave_temp,'b--o');
        plot(drawEachLoca + 4 + randn/20,flash_grab_out_l(1,condition) - bar_only_l_ave_temp,'r--o');
        plot(drawEachLoca + 4 + randn/20,flash_grab_out_l(2,condition) - bar_only_l_ave_temp,'b--o');
        plot(drawEachLoca + 5 + randn/20,perceived_location_out_l(1,condition) - bar_only_l_ave_temp,'r--o');
        plot(drawEachLoca + 5 + randn/20,perceived_location_out_l(2,condition) - bar_only_l_ave_temp,'b--o');


        if strcmp(annulusPattern,'blurredBoundary')
            plot(drawEachLoca + 6 + randn/20,boundary_in_l(1,condition) - bar_only_l_ave_temp,'r--o');
            plot(drawEachLoca + 6 + randn/20,boundary_out_l(2,condition) - bar_only_l_ave_temp,'b--o');
        end


    end
    hold on;

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
ylabel('     Away from blindspot border   -->','FontName','Arial','FontSize',25);

if strcmp(annulusWidth,'artificialScotoma')
    if strcmp(visualField,'u')
        bar_only_ave = bar_only_u_ave;
    elseif strcmp(visualField,'l')
        bar_only_ave = bar_only_l_ave;
    end
    ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
    %     line([0 drawBarNum + 1], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5,'LineStyle','--');
end

% if strcmp(visualField, 'l')
%     % set the origin on the left top
%     set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
% end


% cd ../../../../../../analysis/eyeGuiding_behavior_data/



