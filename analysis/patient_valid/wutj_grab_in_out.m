% for hemianopia patient  7'wutianjiang' (left)
% this script is only for left visual field injury
% notice it is contratory for injury in left visual field and right visual
% CCW & CW add  perceived location test   off sync experiment
% from visible to invisible
% from invisible to visible
% perceived location
% in the upper visual field CCW is grab_in
% in the lower visual field CW is grab_in

% 20230921 By Jiahan Hui
% 20231101 Revised by Jiahan Hui  from seperate upper and lower field
% results into combine the grab-in and grab-out

clear all;

addpath '../../../function';

% bar_only_mark = 2; % 1 means show bar_only  2 means no bar_only data  every data was normalized by bar_only

sbjname = { 'wutianjiang' } ; % 'wutianjiang'    '6'maguangquan' (left)    7'wutianjiang' (left)   5'mali'(right)  only could plot 1 subject


fieldfolders = {'upper_field','lower_field'}; % ,'lower_field' ,'normal_field'
path = '../../data/corticalBlindness/bar';

% areaFolderName = fullfile(path, folders{folderNum});
% cd(areaFolderName);


viInvifolders = {'vi2invi','invi2vi'};   %  'invi2vi'
viInvifolderNums = length(viInvifolders);  % analy each condition include {'invi2vi','vi2invi'};



for fieldNum = 1:length(fieldfolders)
    areaFolderName = fullfile(path, fieldfolders{fieldNum});
    if fieldNum == 1
        cd(areaFolderName);
    elseif fieldNum == 2
        cd(['../../' fieldfolders{fieldNum}]);
    end


    s1 = string(sbjname);
    s2 = '*.mat';
    s3 = strcat(s1,s2);


    for viInvifolderNum = 1:viInvifolderNums

        if viInvifolderNum == 1    % subfolders = {'vi2invi'};
            cd(viInvifolders{viInvifolderNum});
        else viInvifolderNum == 2    % subfolders = {'invi2vi'};
            cd (['../' viInvifolders{viInvifolderNum}]);
        end

        Files = dir(s3);
        load (Files.name)

        illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
        illusionCWIndex = find(data.flashTiltDirection == 2);  % CW


        if strcmp(fieldfolders{fieldNum} , 'upper_field')

            % The first row of bar_CCW is vi2invi and the second row is
            % invi2vi
            bar_only_u(viInvifolderNum,:) = 90 - bar_only;
            off_sync_u(viInvifolderNum,:) = 90 - off_sync;
            grab_in_u(viInvifolderNum,:) =  90 - flash_grab(illusionCCWIndex);
            grab_out_u(viInvifolderNum,:) =  90 - flash_grab(illusionCWIndex);

            if strcmp(condition, 'invi2vi')
                perceived_in_u(viInvifolderNum,:) = 90 - perceived_location(illusionCCWIndex);
                perceived_out_u(viInvifolderNum,:) = 90 - perceived_location(illusionCWIndex);
            end

        elseif strcmp(fieldfolders{fieldNum} , 'lower_field')
            % The first row of bar_CCW is vi2invi and the second row is
            % invi2vi
            bar_only_l(viInvifolderNum,:) = abs(90 +  bar_only);
            off_sync_l(viInvifolderNum,:) = abs(90 + off_sync);
            grab_in_l(viInvifolderNum,:) =  abs(90 + flash_grab(illusionCWIndex));
            grab_out_l(viInvifolderNum,:) =  abs(90 + flash_grab(illusionCCWIndex));

            if strcmp(condition, 'invi2vi')
                perceived_in_l(viInvifolderNum,:) = abs(90 + perceived_location(illusionCWIndex));
                perceived_out_l(viInvifolderNum,:) = abs(90 + perceived_location(illusionCCWIndex));
            end
        end

    end
    
end

%----------------------------------------------------------------------
%  median of the blind field
%----------------------------------------------------------------------

bar_only_u_ave = mean(bar_only_u,'all');
bar_only_l_ave = mean(bar_only_l,'all');
% median2horizontal = (bar_only_u_ave + bar_only_l_ave)/2;

off_sync_data = [(off_sync_u - bar_only_u_ave)  (bar_only_l_ave - off_sync_l)];
grab_in_data = [(grab_in_u - bar_only_u_ave)   (bar_only_l_ave - grab_in_l)];
perceived_in_data = [(perceived_in_u(2,:) - bar_only_u_ave)   (bar_only_l_ave - perceived_in_l(2,:))];
grab_out_data = [(grab_out_u - bar_only_u_ave)   (bar_only_l_ave - grab_out_l)];
perceived_out_data = [(perceived_out_u(2,:) - bar_only_u_ave)   (bar_only_l_ave - perceived_out_l(2,:))];

%----------------------------------------------------------------------
%  delete bar_only, positive means outside the blind field vise versa
%----------------------------------------------------------------------

all_data = {off_sync_data, grab_in_data, perceived_in_data, grab_out_data, perceived_out_data};
mean_values = cellfun(@(x) mean(x, 'all'), all_data, 'UniformOutput', true);

y = mean_values;
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',3);


XaxisMarker = {'off-sync' 'grab-in' 'perc-in' 'grab-out' 'perc-out'} ;

set(gca, 'XTick', 1:5, 'XTickLabels', XaxisMarker,'fontsize',30,'FontWeight','bold');
ylabel('Away from blind field  --> ','FontName','Arial','FontSize',30);
hold on;
set(gca,'ylim',[-45 70],'FontName','Arial','FontSize',25);
set(gcf,'color','w');


for condition = 1: length(off_sync_data)
    plot(1 + randn/20,off_sync_data(1,condition),'r--o');
    plot(1 + randn/20,off_sync_data(2,condition),'b--o');
end

for condition = 1:length(grab_in_data)
    plot(2 + randn/20,grab_in_data(1,condition),'r--o');
    plot(2 + randn/20,grab_in_data(2,condition),'b--o');
    plot(4 + randn/20,grab_out_data(1,condition),'r--o');
    plot(4 + randn/20,grab_out_data(2,condition),'b--o');

end

for condition = 1: length(perceived_in_data)
    plot(3 + randn/20,perceived_in_data(condition),'b--o');
    plot(5 + randn/20,perceived_out_data(condition),'b--o');
end


cd ../../../../../analysis/patient_valid/

% % significant test
[H1,P1,CI1] = ttest2(reshape(off_sync_data,1,16),zeros(1,16));
[H1,P1,CI1] = ttest2(reshape(grab_in_data,1,8),zeros(1,8));
[H1,P1,CI1] = ttest2(perceived_in_data,zeros(1,4));

