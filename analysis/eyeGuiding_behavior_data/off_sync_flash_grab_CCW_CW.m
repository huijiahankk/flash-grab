% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block

clear all;
addpath '../../function';

annulusPattern = 'blurredBoundary';  %  blurredBoundary   sector
annulusWidth = 'artificialScotoma'; % blindspot   artificialScotoma

sbjnames = {'hjh'};
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

visualField = 'u'; % u for upper l for lower

upperExp = { '_vi2invi_u','_invi2vi_u'}; %  'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
lowerExp = { '_vi2invi_l','_invi2vi_l'};

if strcmp(visualField,'u')
    %----------------------------------------------------------------------
    %              data in upper visual field
    %----------------------------------------------------------------------
    for expcondition = 1:length(upperExp)
        s1 = sbjnames;
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
        
        bar_only_u(expcondition,:) = 90 - bar_only(validTrialIndex);
        off_sync_CCW_u(expcondition,:)  = 90 - off_sync(illusionCCWIndex);
        off_sync_CW_u(expcondition,:)  = 90 - off_sync(illusionCWIndex);
        flash_grab_CCW_u(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
        flash_grab_CW_u(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
        perceived_location_CCW_u(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);
        perceived_location_CW_u(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
    end
    
    bar_only_u_ave = 0;
    bar_only_u_ave_temp = mean(mean(bar_only_u));
    off_sync_CCW_u_ave = mean(mean(off_sync_CCW_u)) - bar_only_u_ave;
    off_sync_CW_u_ave = mean(mean(off_sync_CW_u)) - bar_only_u_ave;
    flash_grab_CCW_u_ave = mean(mean(flash_grab_CCW_u)) - bar_only_u_ave;
    perceived_location_CCW_u_ave = mean(mean(perceived_location_CCW_u)) - bar_only_u_ave;
    flash_grab_CW_u_ave = mean(mean(flash_grab_CW_u)) - bar_only_u_ave;
    perceived_location_CW_u_ave = mean(mean(perceived_location_CW_u)) - bar_only_u_ave;
    
    eachtrial_bar_only_u = reshape(bar_only_u,1,numel(bar_only_u)) - bar_only_u_ave;
    eachtrial_off_sync_CCW_u = reshape(off_sync_CCW_u,1,numel(off_sync_CCW_u)) - bar_only_u_ave;
    eachtrial_off_sync_CW_u = reshape(off_sync_CW_u,1,numel(off_sync_CW_u)) - bar_only_u_ave;
    eachtrial_flash_grab_CCW_u= reshape(flash_grab_CCW_u,1,numel(flash_grab_CCW_u)) - bar_only_u_ave;
    eachtrial_perceived_location_CCW_u = reshape(perceived_location_CCW_u,1,numel(perceived_location_CCW_u)) - bar_only_u_ave;
    eachtrial_flash_grab_CW_u = reshape(flash_grab_CW_u,1,numel(flash_grab_CW_u)) - bar_only_u_ave;
    eachtrial_perceived_location_CW_u = reshape(perceived_location_CW_u,1,numel(perceived_location_CW_u)) - bar_only_u_ave;
    
    y_u = [bar_only_u_ave_temp off_sync_CCW_u_ave off_sync_CW_u_ave flash_grab_CCW_u_ave perceived_location_CCW_u_ave flash_grab_CW_u_ave perceived_location_CW_u_ave];
    h_u = bar(y_u,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    
    for condition = 1: length(eachtrial_bar_only_u)
        plot(1,eachtrial_bar_only_u(condition),'r--o');
    end
    
    for condition = 1: numel(off_sync_CCW_u)
        plot(2,eachtrial_off_sync_CCW_u(condition),'r--o');
        plot(3,eachtrial_off_sync_CW_u(condition),'b--o');
        plot(4,eachtrial_flash_grab_CCW_u(condition),'r--o');
        plot(5,eachtrial_perceived_location_CCW_u(condition),'r--o');
        plot(6,eachtrial_flash_grab_CW_u(condition),'b--o');
        plot(7,eachtrial_perceived_location_CW_u(condition),'b--o');
    end
    
elseif strcmp(visualField,'l')
    %----------------------------------------------------------------------
    %             lower visual field data
    %----------------------------------------------------------------------
    for expcondition = 1:length(lowerExp)
        s1 = sbjnames;
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
        
        bar_only_l = bar_only(validTrialIndex) - 90;
        off_sync_CCW_l(expcondition,:)  = off_sync(illusionCCWIndex) - 90;
        off_sync_CW_l(expcondition,:)  = off_sync(illusionCWIndex) - 90;
        flash_grab_CCW_l(expcondition,:)  = flash_grab(illusionCCWIndex) - 90;
        flash_grab_CW_l(expcondition,:)  = flash_grab(illusionCWIndex) - 90;
        perceived_location_CCW_l(expcondition,:)  = perceived_location(illusionCCWIndex) - 90;
        perceived_location_CW_l(expcondition,:)   = perceived_location(illusionCWIndex) - 90;
    end
    
    bar_only_l_ave = 0; %mean(mean(bar_only_l));
    bar_only_l_ave_temp = mean(mean(bar_only_l));
    off_sync_CCW_l_ave = mean(mean(off_sync_CCW_l)) - bar_only_l_ave;
    off_sync_CW_l_ave = mean(mean(off_sync_CW_l)) - bar_only_l_ave;
    flash_grab_CCW_l_ave = mean(mean(flash_grab_CCW_l)) - bar_only_l_ave;
    perceived_location_CCW_l_ave = mean(mean(perceived_location_CCW_l)) - bar_only_l_ave;
    flash_grab_CW_l_ave = mean(mean(flash_grab_CW_l)) - bar_only_l_ave;
    perceived_location_CW_l_ave = mean(mean(perceived_location_CW_l)) - bar_only_l_ave;
    
    eachtrial_bar_only_l = reshape(bar_only_l,1,numel(bar_only_l)) - bar_only_l_ave;
    eachtrial_off_sync_CCW_l = reshape(off_sync_CCW_l,1,numel(off_sync_CCW_l)) - bar_only_l_ave;
    eachtrial_off_sync_CW_l = reshape(off_sync_CW_l,1,numel(off_sync_CW_l)) - bar_only_l_ave;
    eachtrial_flash_grab_CCW_l= reshape(flash_grab_CCW_l,1,numel(flash_grab_CCW_l)) - bar_only_l_ave;
    eachtrial_perceived_location_CCW_l = reshape(perceived_location_CCW_l,1,numel(perceived_location_CCW_l)) - bar_only_l_ave;
    eachtrial_flash_grab_CW_l = reshape(flash_grab_CW_l,1,numel(flash_grab_CW_l)) - bar_only_l_ave;
    eachtrial_perceived_location_CW_l = reshape(perceived_location_CW_l,1,numel(perceived_location_CW_l)) - bar_only_l_ave;
    
    
    
    
    
    y_l = [bar_only_l_ave_temp off_sync_CCW_l_ave off_sync_CW_l_ave flash_grab_CCW_l_ave perceived_location_CCW_l_ave flash_grab_CW_l_ave perceived_location_CW_l_ave];
    h_l = bar(y_l,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
    hold on;
    
    for condition = 1: length(eachtrial_bar_only_l)
        plot(1,eachtrial_bar_only_l(condition),'r--o');
        %     plot(2,eachtrialdegree_off_sync(condition),'r--o');
    end
    
    for condition = 1: numel(off_sync_CCW_l)
        plot(2,eachtrial_off_sync_CCW_l(condition),'r--o');
        plot(3,eachtrial_off_sync_CW_l(condition),'b--o');
        plot(4,eachtrial_flash_grab_CCW_l(condition),'r--o');
        plot(5,eachtrial_perceived_location_CCW_l(condition),'r--o');
        plot(6,eachtrial_flash_grab_CW_l(condition),'b--o');
        plot(7,eachtrial_perceived_location_CW_l(condition),'b--o');
    end
end
set(gca, 'XTick', 1:7, 'XTickLabels', {'bar-only' 'off-sync-CCW' 'off-sync-CW' 'flash-grab-CCW' 'perceived-location-CCW' 'flash-grab-CW' 'perceived-location-CW'},'fontsize',20,'FontWeight','bold');
% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);
hold on;
ylabel('Shift degree from blindspot border','FontName','Arial','FontSize',25);

if strcmp(artificialScotomaExp,'y')
    if strcmp(visualField,'u')
        bar_only_ave = bar_only_u_ave;
    elseif strcmp(visualField,'l')
        bar_only_ave = bar_only_l_ave;
    end
    ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
    line([0 8], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5,'LineStyle','--');
end


