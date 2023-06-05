% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block

clear all;
addpath '../../function';

annulusPattern = 'blurredBoundary';  %  blurredBoundary   sector
annulusWidth = 'artificialScotoma'; % blindspot   artificialScotoma

sbjnames = {'xs','sry', 'hbb','hjh', 'xs','lxy'}; % 'hbb','hjh','lxy','sry','xs'
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

% datapath = sprintf([path  '%s/'],sbjnames{1});
% cd(datapath);

upperExp = { '_vi2invi_u','_invi2vi_u'}; %  'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
lowerExp = { '_vi2invi_l','_invi2vi_l'};


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
            
        
        bar_only_u = 90 - bar_only(validTrialIndex);
        off_sync_u(expcondition,:) = 90 - off_sync(validTrialIndex);
        off_sync_out_u(expcondition,:) = 90 - off_sync(illusionCCWIndex);
        off_sync_in_u(expcondition,:) = 90 - off_sync(illusionCWIndex);
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
        
        bar_only_l = bar_only(validTrialIndex) - 90;
        off_sync_l(expcondition,:) = off_sync(validTrialIndex) - 90;
        off_sync_in_l(expcondition,:) = off_sync(illusionCCWIndex) - 90;
        off_sync_out_l(expcondition,:) = off_sync(illusionCWIndex) - 90;
        flash_grab_in_l(expcondition,:)  = flash_grab(illusionCCWIndex) - 90;
        flash_grab_out_l(expcondition,:)  = flash_grab(illusionCWIndex) - 90;
        perceived_location_in_l(expcondition,:)  = perceived_location(illusionCCWIndex) - 90;
        perceived_location_out_l(expcondition,:)   = perceived_location(illusionCWIndex) - 90;
    end
    
    bar_only_ave = 0;
    bar_only_ave_temp = mean(mean([bar_only_u; bar_only_l]));
    off_sync_ave = mean(mean([off_sync_u; off_sync_l])) - bar_only_ave;
    
    % each trial degree in different condition such as vi2invi or invi2vi
    bar_only_data = [bar_only_u bar_only_l] - bar_only_ave;
    off_sync_data = [off_sync_u  off_sync_l] - bar_only_ave;
    off_sync_out_data = [off_sync_out_u off_sync_out_l] - bar_only_ave;
    off_sync_in_data = [off_sync_in_u off_sync_in_l] - bar_only_ave;
    boundary_out_data = [boundary_out_u boundary_out_l] -  bar_only_ave;
    boundary_in_data = [boundary_in_u boundary_in_l] -  bar_only_ave;
    
    flash_grab_out = [flash_grab_out_u;flash_grab_out_l] - bar_only_ave;
    perceived_location_out = [perceived_location_out_u;perceived_location_out_l] - bar_only_ave;
    flash_grab_in = [flash_grab_in_u;flash_grab_in_l] - bar_only_ave;
    perceived_location_in = [perceived_location_in_u;perceived_location_in_l] - bar_only_ave;
    
    % allign each trial response into one row 
    eachtrial_flash_grab_out(sbjnum,:) = reshape(flash_grab_out,1,numel(flash_grab_out));
    eachtrial_perceived_location_out(sbjnum,:) = reshape(perceived_location_out,1,numel(perceived_location_out));
    eachtrial_flash_grab_in(sbjnum,:) = reshape(flash_grab_in,1,numel(flash_grab_in));
    eachtrial_perceived_location_in(sbjnum,:) = reshape(perceived_location_in,1,numel(perceived_location_in));
    
    
    % save ave data for each subj 
    bar_only_sbj(sbjnum) = mean(mean([bar_only_u; bar_only_l]));
    off_sync_sbj(sbjnum) = mean(mean([off_sync_u; off_sync_l]));
    off_sync_out_sbj(sbjnum) = mean(mean([off_sync_out_u; off_sync_out_l]));
    off_sync_in_sbj(sbjnum) = mean(mean([off_sync_in_u; off_sync_in_l]));
    boundary_out_sbj(sbjnum) = mean(mean([boundary_out_u; boundary_out_l]));
    boundary_in_sbj(sbjnum) = mean(mean([boundary_in_u; boundary_in_l]));
    
    flash_grab_out_sbj(sbjnum) = mean(mean(flash_grab_out));
    perceived_location_out_sbj(sbjnum) = mean(mean(perceived_location_out));
    flash_grab_in_sbj(sbjnum) = mean(mean(flash_grab_in));
    perceived_location_in_sbj(sbjnum) = mean(mean(perceived_location_in));
 
     cd ../
end


% number of x axis condition
number_x_axis = 9;
ave = cell(1, number_x_axis);
ave_ste = cell(1, number_x_axis);

%---------------------------------------------------
%     combine off_sync_out and off_sync_in
%---------------------------------------------------




%-----------------------------------------------------------------------------
%    seperate off_sync_out and off_sync_in and add boundary_out  boundary_in
%-----------------------------------------------------------------------------
 
[ave{:}] = deal(mean(bar_only_sbj),mean(off_sync_out_sbj),mean(off_sync_in_sbj),mean(boundary_out_sbj),mean(boundary_in_sbj),...
    mean(flash_grab_out_sbj),mean(perceived_location_out_sbj),mean(flash_grab_in_sbj),mean(perceived_location_in_sbj));
[ave_ste{:}] = deal(ste(bar_only_sbj,2),ste(off_sync_out_sbj,2),ste(off_sync_in_sbj,2),ste(boundary_out_sbj,2),ste(boundary_in_sbj,2),...
    ste(flash_grab_out_sbj,2),ste(perceived_location_out_sbj,2),ste(flash_grab_in_sbj,2),ste(perceived_location_in_sbj,2));
XaxisMarker = {'bar-only' 'off-sync-out' 'off-sync-in' 'boundary-out' 'boundary-in' 'grab-out' 'perc-out' 'grab-in' 'perc-in'};

%---------------------------------------------------
%     combine off_sync_out and off_sync_in
%---------------------------------------------------
% [ave{:}] = deal(mean(bar_only_sbj),mean(off_sync_sbj),mean(flash_grab_out_sbj),mean(perceived_location_out_sbj),...
%     mean(flash_grab_in_sbj),mean(perceived_location_in_sbj));
% [ave_ste{:}] = deal(ste(bar_only_sbj,2),ste(off_sync_sbj,2),ste(flash_grab_out_sbj,2),...
%     ste(perceived_location_out_sbj,2),ste(flash_grab_in_sbj,2),ste(perceived_location_in_sbj,2));
% XaxisMarker = {'bar-only' 'off-sync' 'grab-out' 'perc-out' 'grab-in' 'perc-in'};

h = bar(1:number_x_axis,cell2mat(ave),'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
hold on;
errorbar(1:number_x_axis,cell2mat(ave),cell2mat(ave_ste),'b.');
set(gca, 'XTick', 1:number_x_axis, 'XTickLabels',XaxisMarker,'fontsize',30,'FontWeight','bold');


% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);


hold on;
ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
if strcmp(annulusWidth,'artificialScotoma')
%     ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',30);
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',30);
    line([0 number_x_axis + 1], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5,'LineStyle','--');
end

% %----------------------------------------------------------------------
% %  plot  each subject's average value
% %----------------------------------------------------------------------
% for condition = 1: length(sbjnames)
%     plot(1 + randn/20,bar_only_sbj(condition),'r--o');
%     plot(2 + randn/20,off_sync_sbj(condition),'r--o');
%     plot(3 + randn/20,flash_grab_out_sbj(condition),'r--o');
%     plot(4 + randn/20,perceived_location_out_sbj(condition),'r--o');
%     plot(5 + randn/20,flash_grab_in_sbj(condition),'r--o');
%     plot(6 + randn/20,perceived_location_in_sbj(condition),'r--o');
% end



% %----------------------------------------------------------------------
% %  plot  each trial
% %----------------------------------------------------------------------
% % plot bar_only value
% eachtrial_bar_only = bar_only_data;
% eachtrial_off_sync = off_sync_data;
% 
% for condition = 1: length(eachtrial_bar_only)
%     plot(1 + randn/20,eachtrial_bar_only(condition),'r--o');
%     plot(2 + randn/20,eachtrial_off_sync(condition),'r--o');
% end
% 
% eachtrial_flash_grab_out = reshape(flash_grab_out,1,numel(flash_grab_out));
% eachtrial_perceived_location_out = reshape(perceived_location_out,1,numel(perceived_location_out));
% eachtrial_flash_grab_in = reshape(flash_grab_in,1,numel(flash_grab_in));
% eachtrial_perceived_location_in= reshape(perceived_location_in,1,numel(perceived_location_in));
% 
% for condition = 1: numel([flash_grab_out_u;flash_grab_out_l])
%     plot(3 + randn/20,eachtrial_flash_grab_out(condition),'r--o');
%     plot(4 + randn/20,eachtrial_perceived_location_out(condition),'r--o');
%     plot(5 + randn/20,eachtrial_flash_grab_in(condition),'b--o');
%     plot(6 + randn/20,eachtrial_perceived_location_in(condition),'b--o');
% end
% 
% 
% % significant test
% [H1,P1,CI1] = ttest2(eachtrial_flash_grab_out,  eachtrial_perceived_location_out);
% [H2,P2,CI2] = ttest2(eachtrial_flash_grab_in,  eachtrial_perceived_location_in);
% P1
% P2
