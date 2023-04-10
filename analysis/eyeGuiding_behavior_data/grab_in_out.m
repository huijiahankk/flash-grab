% for normal participant blindspot/artificial scotoma experiment
% with random block number because if the subject gaze out of the fixation
% for more than 2 sec the whole block would abandoned and add a new block 

clear all;
addpath '../../function';

annulusPattern = 'blurredBoundary';  %  blurredBoundary   sector
annulusWidth = 'blindspot'; % blindspot   artificialScotoma

sbjnames = {'sry'};
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

upperExp = { '_vi2invi_u','_invi2vi_u'}; %  'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
lowerExp = { '_vi2invi_l','_invi2vi_l'};


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
    
    bar_only_u = 90 - bar_only(validTrialIndex);
    off_syn_u(expcondition,:) = 90 - off_sync((validTrialIndex));
    flash_grab_out_u(expcondition,:)  = 90 - flash_grab(illusionCCWIndex);
    flash_grab_in_u(expcondition,:)  = 90 - flash_grab(illusionCWIndex);
    perceived_location_out_u(expcondition,:)  = 90 -  perceived_location(illusionCCWIndex);
    perceived_location_in_u(expcondition,:)   = 90 -  perceived_location(illusionCWIndex);
end


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
    off_syn_l(expcondition,:) = off_sync(validTrialIndex) - 90;
    flash_grab_in_l(expcondition,:)  = flash_grab(illusionCCWIndex) - 90;
    flash_grab_out_l(expcondition,:)  = flash_grab(illusionCWIndex) - 90;
    perceived_location_in_l(expcondition,:)  = perceived_location(illusionCCWIndex) - 90;
    perceived_location_out_l(expcondition,:)   = perceived_location(illusionCWIndex) - 90;
end

bar_only_ave = 0;
bar_only_ave_temp = mean(mean([bar_only_u; bar_only_l]));
off_sync_ave = mean(mean([off_syn_u; off_syn_l])) - bar_only_ave;

bar_only_ana = [bar_only_u; bar_only_l] - bar_only_ave;
off_sync_ana = [off_syn_u; off_syn_l] - bar_only_ave;
flash_grab_out = [flash_grab_out_u;flash_grab_out_l] - bar_only_ave;
perceived_location_out = [perceived_location_out_u;perceived_location_out_l] - bar_only_ave;
flash_grab_in = [flash_grab_in_u;flash_grab_in_l] - bar_only_ave;
perceived_location_in = [perceived_location_in_u;perceived_location_in_l] - bar_only_ave;


flash_grab_out_ave= mean(mean(flash_grab_out));
flash_grab_in_ave = mean(mean(flash_grab_in));
perceived_location_out_ave = mean(mean(perceived_location_out));
perceived_location_in_ave = mean(mean(perceived_location_in));

ave_illusion = abs((flash_grab_out_ave - perceived_location_out_ave) + (perceived_location_in_ave - flash_grab_in_ave))/2

y = [bar_only_ave_temp off_sync_ave flash_grab_out_ave perceived_location_out_ave flash_grab_in_ave perceived_location_in_ave];


% y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
set(gca, 'XTick', 1:6, 'XTickLabels', {'bar-only' 'off-sync' 'grab-out' 'perc-out' 'grab-in' 'perc-in'},'fontsize',20,'FontWeight','bold');

% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);


hold on;
ylabel('Shift degree from blindspot border','FontName','Arial','FontSize',25);
if strcmp(annulusWidth,'artificialScotoma')
    ylabel('Shift degree from mapped blindfield border','FontName','Arial','FontSize',25);
    line([0 7], [(blindfield_from_horizontal_degree - bar_only_ave) (blindfield_from_horizontal_degree-bar_only_ave)],'LineWidth',1.5);
end
%----------------------------------------------------------------------
%  plot  each trial
%----------------------------------------------------------------------
% plot bar_only value
eachtrialdegree_bar_only = reshape(bar_only_ana,1,numel(bar_only_ana));
eachtrialdegree_off_sync = reshape(off_sync_ana,1,numel(off_sync_ana));

for condition = 1: length(eachtrialdegree_bar_only)
    plot(1,eachtrialdegree_bar_only(condition),'r--o');
    plot(2,eachtrialdegree_off_sync(condition),'r--o');
end

eachtrial_flash_grab_out = reshape(flash_grab_out,1,numel(flash_grab_out));
eachtrial_perceived_location_out = reshape(perceived_location_out,1,numel(perceived_location_out));
eachtrial_flash_grab_in = reshape(flash_grab_in,1,numel(flash_grab_in));
eachtrial_perceived_location_in= reshape(perceived_location_in,1,numel(perceived_location_in));

for condition = 1: numel([flash_grab_out_u;flash_grab_out_l])
    plot(3,eachtrial_flash_grab_out(condition),'r--o');
    plot(4,eachtrial_perceived_location_out(condition),'r--o');
    plot(5,eachtrial_flash_grab_in(condition),'b--o');
    plot(6,eachtrial_perceived_location_in(condition),'b--o');
end


% significant test
[H1,P1,CI1] = ttest2(eachtrial_flash_grab_out,  eachtrial_perceived_location_out);
[H2,P2,CI2] = ttest2(eachtrial_flash_grab_in,  eachtrial_perceived_location_in);
P1
P2

%     % bootstrap treats the original sample as a proxy for the real population and then draws random samples from it
%     bootstats = bootstrp(10000,@(x)[mean(x) ste(x)],[abs(illusionTiltLeftDegree),abs(illusionTiltRightDegree)]);
%
%     % cumulative distribution  from small to big
%     [f,x] = ecdf(bootstats(:,1) - bootstats(:,2));
%
%     % f(1) = 0  so assign the min in x to f(1)
%     pBootstrap = f(abs(x)==min(abs(x)))