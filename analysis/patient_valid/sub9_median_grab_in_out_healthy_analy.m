% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block 

clear all;
addpath '../../function';

annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'CB'; % blindspot   artificialScotoma

sbjnames = {'zhuerliang'};   % 'xs','sry', 'hbb','hjh', 'xs','lxy' 
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

upperExp = { '_vi2invi_u','_invi2vi_u'}; %       'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
lowerExp = { '_vi2invi_l','_invi2vi_l'};


for viInvi = 1:length(upperExp)
    s1 = sbjnames;
    s2 = string(upperExp(viInvi));
    s3 = '*.mat';
    s4 = strcat(s1,s2,s3);
    
    Files = dir(s4);
    load (Files.name);
     
    validTrialIndex = find(perceived_location ~= 0);
    illusionCCWIndex = [];
    illusionCWIndex = [];
    
    for i = 1:length(validTrialIndex)
          
        if data.flashTiltDirectionMat(validTrialIndex(i)) == 1   % CCW
            illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
        elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2  % CW
            illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
        end
    end   
    
    bar_only_u(viInvi,:) = 90 - bar_only(validTrialIndex) ;
    off_syn_u(viInvi,:) = 90 - off_sync((validTrialIndex));
    flash_grab_in_u(viInvi,:)  = 90 - flash_grab(illusionCCWIndex);
    perceived_location_in_u(viInvi,:)   = 90 -  perceived_location(illusionCCWIndex);
    flash_grab_out_u(viInvi,:)  = 90 - flash_grab(illusionCWIndex);
    perceived_location_out_u(viInvi,:)  = 90 -  perceived_location(illusionCWIndex);

end


for viInvi = 1:length(lowerExp)
    s1 = sbjnames;
    s2 = string(lowerExp(viInvi));
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
    
    bar_only_l(viInvi,:)  = bar_only(validTrialIndex) - 90;
    off_syn_l(viInvi,:) = off_sync(validTrialIndex) - 90;
    flash_grab_in_l(viInvi,:)  = flash_grab(illusionCWIndex) - 90;
    perceived_location_in_l(viInvi,:)  = perceived_location(illusionCWIndex) - 90;
    flash_grab_out_l(viInvi,:)  = flash_grab(illusionCCWIndex) - 90;
    perceived_location_out_l(viInvi,:)   = perceived_location(illusionCCWIndex) - 90;
end

%----------------------------------------------------------------------
%  calculate the median of the blind field and adjust each trail to the
%  median
%----------------------------------------------------------------------
median = (mean(bar_only_u,'All') - mean(bar_only_l,'All'))/2;

bar_only_ave_temp = 0;
bar_only_ave = mean([bar_only_u; bar_only_l],'All');
off_sync_ave = mean([off_syn_u; off_syn_l],'All') - bar_only_ave_temp;

bar_only_mat = [bar_only_u - median; bar_only_l + median] - bar_only_ave_temp;
off_sync_mat = [off_syn_u - median; off_syn_l + median] - bar_only_ave_temp;
flash_grab_in_mat = [flash_grab_in_u - median;flash_grab_in_l + median] - bar_only_ave_temp;
perceived_location_in_mat = [perceived_location_in_u - median;perceived_location_in_l + median] - bar_only_ave_temp;
flash_grab_out_mat = [flash_grab_out_u - median;flash_grab_out_l + median] - bar_only_ave_temp;
perceived_location_out_mat = [perceived_location_out_u - median; perceived_location_out_l + median] - bar_only_ave_temp;



flash_grab_out_ave = mean(flash_grab_out_mat,'All');
flash_grab_in_ave = mean(flash_grab_in_mat,'All');
perceived_location_out_ave = mean(perceived_location_out_mat,'All');
perceived_location_in_ave = mean(perceived_location_in_mat,'All');

ave_illusion = abs((flash_grab_out_ave - perceived_location_out_ave) + (perceived_location_in_ave - flash_grab_in_ave))/2;

y = [bar_only_ave off_sync_ave flash_grab_in_ave perceived_location_in_ave flash_grab_out_ave perceived_location_out_ave ];


% y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
set(gca, 'XTick', 1:6, 'XTickLabels', {'bar-only' 'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out' },'fontsize',20,'FontWeight','bold');

% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);
% line([0 7], [90 90],'Color', 'b', 'LineStyle', ':', 'LineWidth', 2);


hold on;
ylabel('Shift degree from blind field border','FontName','Arial','FontSize',25);
if strcmp(annulusWidth,'artificialScotoma')
    ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
    line([0 7], [(blindfield_from_horizontal_degree - bar_only_ave_temp) (blindfield_from_horizontal_degree-bar_only_ave_temp)],'LineWidth',1.5);
end


%----------------------------------------------------------------------
% % plot the upper visual field data in red and lower data in blue
%----------------------------------------------------------------------

for condition = 1: size(bar_only_mat,2)
    plot(1 + randn/20,bar_only_mat(1:2,condition),'r--o');
    plot(1 + randn/20,bar_only_mat(3:4,condition),'b--o');
    plot(2 + randn/20,off_sync_mat(1:2,condition),'r--o');
    plot(2 + randn/20,off_sync_mat(3:4,condition),'b--o');
end


for condition = 1: size(flash_grab_in_mat,2)
    plot(3 + randn/20,flash_grab_in_mat(1:2,condition),'r--o');
    plot(3 + randn/20,flash_grab_in_mat(3:4,condition),'b--o');
    plot(4 + randn/20,perceived_location_in_mat(1:2,condition),'r--o');
    plot(4 + randn/20,perceived_location_in_mat(3:4,condition),'b--o');
    plot(5 + randn/20,flash_grab_out_mat(1:2,condition),'r--o');
    plot(5 + randn/20,flash_grab_out_mat(3:4,condition),'b--o');
    plot(6 + randn/20,perceived_location_out_mat(1:2,condition),'r--o');
    plot(6 + randn/20,perceived_location_out_mat(3:4,condition),'b--o');

end


cd ../../../../../../analysis/patient_valid/

% % significant test
% [H1,P1,CI1] = ttest2(eachtrial_flash_grab_out,  eachtrial_perceived_location_out);
% [H2,P2,CI2] = ttest2(eachtrial_flash_grab_in,  eachtrial_perceived_location_in);
% P1
% P2

%     % bootstrap treats the original sample as a proxy for the real population and then draws random samples from it
%     bootstats = bootstrp(10000,@(x)[mean(x) ste(x)],[abs(illusionTiltLeftDegree),abs(illusionTiltRightDegree)]);
%
%     % cumulative distribution  from small to big
%     [f,x] = ecdf(bootstats(:,1) - bootstats(:,2));
%
%     % f(1) = 0  so assign the min in x to f(1)
%     pBootstrap = f(abs(x)==min(abs(x)))