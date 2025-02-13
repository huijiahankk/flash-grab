% only could plot patient 9 zhuerliang(left)
% this is only for left visual field injury
% revise from the healthy participant's analysis script
% combine the upper visual field and lower visual field result together 
% red dot is upper visual field data and blue dot is lower visual field
% data
% each trial in the upper visual field minus the average data in the upper
% visual field

% 20230922 By Jiahan Hui


clear all;
addpath '../../function';

annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'CB'; % blindspot   artificialScotoma

sbjnames = {'lmy'};   % lili  zhuerliang
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

upperExp = { '_vi2invi_u'}; %  ,'_invi2vi_u'     'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
% lowerExp = { '_vi2invi_l','_invi2vi_l'};


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
    
    % calculate the degree in each condition to the horizontal meridian
    bar_only_u(viInvi,:) = 90 - bar_only(validTrialIndex);
    off_syn_u(viInvi,:) = 90 - off_sync(validTrialIndex);
    flash_grab_in_u(viInvi,:)  = 90 - flash_grab(illusionCCWIndex);
    perceived_location_in_u(viInvi,:)   = 90 - perceived_location(illusionCCWIndex);
    flash_grab_out_u(viInvi,:)  = 90 - flash_grab(illusionCWIndex);
    perceived_location_out_u(viInvi,:)  = 90 - perceived_location(illusionCWIndex);

end


% for viInvi = 1:length(lowerExp)
%     s1 = sbjnames;
%     s2 = string(lowerExp(viInvi));
%     s3 = '*.mat';
%     s4 = strcat(s1,s2,s3);
%     
%     Files = dir(s4);
%     load (Files.name);
%     
%     validTrialIndex = find(perceived_location ~= 0);
%     illusionCCWIndex = [];
%     illusionCWIndex = [];
%     
%     for i = 1:length(validTrialIndex)
%         
%         if data.flashTiltDirectionMat(validTrialIndex(i)) == 1
%             illusionCCWIndex = [illusionCCWIndex,validTrialIndex(i)];
%         elseif data.flashTiltDirectionMat(validTrialIndex(i)) == 2
%             illusionCWIndex = [illusionCWIndex,validTrialIndex(i)];
%         end
%     end 
%     
%     bar_only_l(viInvi,:)  = 270 - bar_only(validTrialIndex);
%     off_sync_l(viInvi,:) = 270 - off_sync(validTrialIndex);
%     flash_grab_in_l(viInvi,:)  = 270 - flash_grab(illusionCWIndex);
%     perceived_location_in_l(viInvi,:) = 270 - perceived_location(illusionCWIndex);
%     flash_grab_out_l(viInvi,:)  = 270 - flash_grab(illusionCCWIndex);
%     perceived_location_out_l(viInvi,:) = 270 - perceived_location(illusionCCWIndex);
% end

%----------------------------------------------------------------------
%  average  the upper and lower visual field data seperately 
%----------------------------------------------------------------------
bar_only_u_ave = mean(bar_only_u,'all');
bar_only_u_ave_temp = bar_only_u_ave;
off_sync_u_ave = mean(off_syn_u,'all');
flash_grab_in_u_ave = mean(flash_grab_in_u,'all');
perceived_location_in_u_ave = mean(perceived_location_in_u,'all');
flash_grab_out_u_ave = mean(flash_grab_out_u,'all');
perceived_location_out_u_ave = mean(perceived_location_out_u,'all');

% bar_only_l_ave = mean(bar_only_l,'all');
% bar_only_l_ave_temp = bar_only_l_ave;
% off_sync_l_ave = mean(off_sync_l,'all');
% flash_grab_in_l_ave = mean(flash_grab_in_l,'all');
% perceived_location_in_l_ave = mean(perceived_location_in_l,'all');
% flash_grab_out_l_ave = mean(flash_grab_out_l,'all');
% perceived_location_out_l_ave = mean(perceived_location_out_l,'all');

%----------------------------------------------------------------------
% average all the data in the upper and lower visual field together
%----------------------------------------------------------------------
bar_only_mat = [bar_only_u];
off_sync_mat = [off_syn_u];
flash_grab_in_mat = [flash_grab_in_u];
perceived_location_in_mat = [perceived_location_in_u];
flash_grab_out_mat = [flash_grab_out_u];
perceived_location_out_mat = [perceived_location_out_u];


bar_only_ave = mean(bar_only_mat,'all');
bar_only_ave_temp = bar_only_ave; 
off_sync_ave = mean(off_sync_mat,'all') - bar_only_ave_temp;
flash_grab_in_ave = mean(flash_grab_in_mat,'all') - bar_only_ave_temp;
perceived_location_in_ave = mean(perceived_location_in_mat,'all') - bar_only_ave_temp;
flash_grab_out_ave = mean(flash_grab_out_mat,'all') - bar_only_ave_temp;
perceived_location_out_ave = mean(perceived_location_out_mat,'all') - bar_only_ave_temp;

%----------------------------------------------------------------------
%  plot the grab in and grab out bar charts
%----------------------------------------------------------------------
ave_illusion = abs((flash_grab_out_ave - perceived_location_out_ave) + (perceived_location_in_ave - flash_grab_in_ave))/2;
y = [off_sync_ave flash_grab_in_ave perceived_location_in_ave flash_grab_out_ave perceived_location_out_ave ];

h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);
set(gca, 'XTick', 1:5, 'XTickLabels', {'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out' },'fontsize',20,'FontWeight','bold');


set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);

hold on;
ylabel('Shift degree from blind field border','FontName','Arial','FontSize',25);


%----------------------------------------------------------------------
% plot the upper visual field data in red and lower data in blue
%----------------------------------------------------------------------

for condition = 1: size(bar_only_mat,2)
%     plot(1 + randn/20,bar_only_mat(1:2,condition),'r--o');
%     plot(1 + randn/20,bar_only_mat(3:4,condition),'b--o');
    plot(1 + randn/20,off_sync_mat(1,condition) - bar_only_u_ave_temp,'r--o');
%     plot(1 + randn/20,off_sync_mat(3:4,condition) - bar_only_ave_temp,'b--o');
end


for condition = 1: size(flash_grab_in_mat,2)
    plot(2 + randn/20,flash_grab_in_mat(1,condition) - bar_only_u_ave_temp,'r--o');
%     plot(2 + randn/20,flash_grab_in_mat(3:4,condition) - bar_only_l_ave_temp,'b--o');
    plot(3 + randn/20,perceived_location_in_mat(1,condition) - bar_only_u_ave_temp,'r--o');
%     plot(3 + randn/20,perceived_location_in_mat(3:4,condition) - bar_only_l_ave_temp,'b--o');
    plot(4 + randn/20,flash_grab_out_mat(1,condition) - bar_only_u_ave_temp,'r--o');
%     plot(4 + randn/20,flash_grab_out_mat(3:4,condition) - bar_only_l_ave_temp,'b--o');
    plot(5 + randn/20,perceived_location_out_mat(1,condition) - bar_only_u_ave_temp,'r--o');
%     plot(5 + randn/20,perceived_location_out_mat(3:4,condition) - bar_only_l_ave_temp,'b--o');

end


% cd ../../../../../../analysis/patient_valid/

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