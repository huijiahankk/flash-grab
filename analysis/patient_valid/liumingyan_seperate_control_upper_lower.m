% could plot patient 10 liumingyan (right) and only tested one side of the
% scotoma and from vi2invi
% this is only for right visual field injury
% revise from the healthy participant's analysis script
% seperate upper and lower visual field result
% mark vi2invi data in red/invi2vi data in blue

% 20230921 By Jiahan Hui



clear all;

% addpath '../../../function';

% bar_only_mark = 2; % 1 means show bar_only  2 means no bar_only data  every data was normalized by bar_only
annulusPattern = 'sector';  %  blurredBoundary   sector
annulusWidth = 'CB'; % blindspot   artificialScotoma

sbjnames = {'lmy'};   % 
path = strcat('../../data/corticalBlindness/Eyelink_guiding/',annulusPattern,'/',annulusWidth,'/');

folderNum = 1;
folders = {'upper_field','lower_field'};

datapath = sprintf([path  '%s/'],sbjnames{1});
cd(datapath);

if string(folders(folderNum)) == 'upper_field'
    viinviExp = { '_vi2invi_u'}; %       'k_invi2vi_l','k_vi2invi_l' 'k_invi2vi_u' 'k_vi2invi_u'
elseif string(folders(folderNum) )== 'lower_field'
    viinviExp = { '_vi2invi_l','_invi2vi_l'};
end


for viInvi = 1:length(viinviExp)
    s1 = sbjnames;
    s2 = string(viinviExp(viInvi));
    s3 = '*.mat';
    s4 = strcat(s1,s2,s3);

    Files = dir(s4);
    load (Files.name);


    illusionCCWIndex = find(data.flashTiltDirectionMat == 1);
    illusionCWIndex = find(data.flashTiltDirectionMat == 2);



    if  string(folders(folderNum)) == 'upper_field'
        bar_only_data(viInvi,:) = 90 - bar_only;
%         off_sync_data(viInvi,:) = off_sync - 270;
        control_in(viInvi,:) = 90 - off_sync(illusionCWIndex);
        control_out(viInvi,:) = 90 - off_sync(illusionCCWIndex);

        flash_grab_in(viInvi,:)  = 90 - flash_grab(illusionCWIndex);
        perceived_location_in(viInvi,:)   = 90 - perceived_location(illusionCWIndex);
        flash_grab_out(viInvi,:)  = 90 - flash_grab(illusionCCWIndex);
        perceived_location_out(viInvi,:)  = 90 - perceived_location(illusionCCWIndex);
    elseif string(folders(folderNum) )== 'lower_field'
        bar_only_data(viInvi,:) = 270 - bar_only;
%         off_sync_data(viInvi,:) = 270 - off_sync ;
        control_in(viInvi,:) = 270 - off_sync(illusionCCWIndex);
        control_out(viInvi,:) = 270 - off_sync(illusionCWIndex);

        flash_grab_in(viInvi,:)  = 270 - flash_grab(illusionCCWIndex);
        perceived_location_in(viInvi,:)  = 270 - perceived_location(illusionCCWIndex);
        flash_grab_out(viInvi,:)  = 270 - flash_grab(illusionCWIndex) ;
        perceived_location_out(viInvi,:)  = 270 - perceived_location(illusionCWIndex);
    end

end


%----------------------------------------------------------------------
%  average blind border data in the left visual field
%----------------------------------------------------------------------

bar_only_ave = mean(bar_only_data,'all');
bar_only_ave_temp = bar_only_ave;


all_data = {control_in,flash_grab_in, perceived_location_in, control_out, flash_grab_out, perceived_location_out};
mean_values = cellfun(@(x) mean(x, 'all'), all_data, 'UniformOutput', true);

%----------------------------------------------------------------------
%  average lower blind border data in the left visual field
%----------------------------------------------------------------------

y = mean_values - bar_only_ave_temp;
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);

XaxisMarker = {'control-in' 'grab-in' 'perc-in' 'control-out'  'grab-out' 'perc-out'} ;
hold on;

%----------------------------------------------------------------------
%  spotted each trial data vi2invi mark red    invi2vi mark blue
%----------------------------------------------------------------------


% for condition = 1: length(off_sync_data)
%     plot(1 + randn/20,off_sync_data(1,condition) - bar_only_ave_temp,'r--o');
%     plot(1 + randn/20,off_sync_data(2,condition) - bar_only_ave_temp,'b--o');
% end

for condition = 1:length(flash_grab_in)
    plot(1 + randn/20,control_in(1,condition) - bar_only_ave_temp,'r--o');
    plot(2 + randn/20,flash_grab_in(1,condition)- bar_only_ave,'r--o');
%     plot(2 + randn/20,flash_grab_in(2,condition)- bar_only_ave,'b--o');
    plot(3 + randn/20,perceived_location_in(1,condition)- bar_only_ave,'r--o');
%     plot(3 + randn/20,perceived_location_in(2,condition)- bar_only_ave,'b--o');

    plot(4 + randn/20,control_out(1,condition) - bar_only_ave_temp,'b--o');
    plot(5 + randn/20,flash_grab_out(1,condition)- bar_only_ave,'r--o');
%     plot(5 + randn/20,flash_grab_out(2,condition)- bar_only_ave,'b--o');
    plot(6 + randn/20,perceived_location_out(1,condition)- bar_only_ave,'r--o');
%     plot(6 + randn/20,perceived_location_out(2,condition)- bar_only_ave,'b--o');
end


set(gca, 'XTick', 1:6, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold');
ylabel('          Away from blind field  --> ','FontName','Arial','FontSize',30);
hold on;

xtickangle(45);
set(gcf,'color','w');
set(gca,'box','off');
% ylabel('Shift degree from blind field border','FontSize',20,'FontWeight','bold')
% title('Shift degree from horizontal meridian','FontSize',25);
set(gca,'ylim',[-35 70],'FontName','Arial','FontSize',25);

% two separate groups and compare their means
[h, p, ci, stats] = ttest2(reshape(control_in,1,3), reshape(perceived_location_in,1,3));
% Display results
disp(['p-value = ', num2str(p)])
if h == 0
    disp('Fail to reject the null hypothesis: No significant difference between groups')
else
    disp('Reject the null hypothesis: Significant difference between groups')
end

cd ../../../../../../analysis/patient_valid/
