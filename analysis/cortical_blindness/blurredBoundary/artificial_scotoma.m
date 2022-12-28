% ringBlurredBoundary

clear all;

addpath '../../function';

sbjnames = {'hjhnew_invi2vi_l'}; % 'hjhnew_invi2vi_l','hjhnew_invi2vi_u','hjhnew_vi2invi_l','hjhnew_vi2invi_u' 

path = '../../../data/corticalBlindness/artificial_scotoma/hjh/';

cd(path);

for sbjnum = 1:length(sbjnames)
    
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    
    Files = dir(s3);
    load (Files.name);
    
    
    if strcmp(barLocation , 'u')
        multiplier =  - 1 ;
        adjust_quadrant = 90;
    elseif strcmp(barLocation, 'l')
        multiplier =  1 ;
        adjust_quadrant = - 90;
    end
    
    illusionCCWIndex = find(data.flashTiltDirection == 1); % CCW
    illusionCWIndex = find(data.flashTiltDirection == 2);  % CW
    
    
    bar_CCWDegree = adjust_quadrant + multiplier * bar_only(illusionCCWIndex);
    bar_CWDegree = adjust_quadrant + multiplier * bar_only(illusionCWIndex);
    blurred_boundary_CCWDegree = adjust_quadrant + multiplier * blurred_boundary(illusionCCWIndex);
    blurred_boundary_CWDegree = adjust_quadrant + multiplier * blurred_boundary(illusionCWIndex);
    off_sync_CCWDegree = adjust_quadrant + multiplier * off_sync(illusionCCWIndex);
    off_sync_CWDegree =  adjust_quadrant + multiplier * off_sync(illusionCWIndex);
    flash_grab_CCWDegree =  adjust_quadrant + multiplier * flash_grab(illusionCCWIndex);
    flash_grab_CWDegree =  adjust_quadrant + multiplier * flash_grab(illusionCWIndex);
    perceived_location_CCWDegree = adjust_quadrant + multiplier * perceived_location(illusionCCWIndex);
    perceived_location_CWDegree = adjust_quadrant + multiplier * perceived_location(illusionCWIndex);
    
    
end

bar_onlyDegreeMean = mean([bar_CCWDegree bar_CWDegree]);

blurred_boundary_CCWDegreeMean= mean(blurred_boundary_CCWDegree);
blurred_boundary_CWDegreeMean = mean(blurred_boundary_CWDegree);

off_sync_CCWDegreeMean= mean(off_sync_CCWDegree);
off_sync_CWDegreeMean = mean(off_sync_CWDegree);

flash_grab_CCWDegreeMean= mean(flash_grab_CCWDegree);
flash_grab_CWDegreeMean = mean(flash_grab_CWDegree);

perceived_location_CCWDegreeMean = mean(perceived_location_CCWDegree);
perceived_location_CWDegreeMean = mean(perceived_location_CWDegree);


y = [bar_onlyDegreeMean blurred_boundary_CCWDegreeMean blurred_boundary_CWDegreeMean...
    off_sync_CCWDegreeMean off_sync_CWDegreeMean flash_grab_CCWDegreeMean ...
    perceived_location_CCWDegreeMean flash_grab_CWDegreeMean perceived_location_CWDegreeMean];


% y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
set(gca, 'XTick', 1:9, 'XTickLabels', {'bar-only' 'blurred-boundary-CCW' 'blurred-boundary-CW' 'off-sync-CCW' 'off-sync-CW'  'grab-CCW' 'perc-CCW' 'grab-CW' 'perc-CW'},'fontsize',20,'FontWeight','bold');
hold on;

line([0 10], [blindfieldDegree blindfieldDegree]);
% set(gca, 'XTick', 1:3, 'XTickLabels', {'bar-only' 'grab-CCW' 'grab-CW'},'fontsize',20,'FontWeight','bold');

set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);


% set the origin on the left top
if strcmp(barLocation, 'l')
    set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
end


hold on;
ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);

% %-----------------------------------------------------------
% %             plot  each trial
% %----------------------------------------------------------

% plot bar_only value
eachtrialdegree_bar_only = [bar_CCWDegree bar_CWDegree];


for condition = 1: length(eachtrialdegree_bar_only)
    plot(1,eachtrialdegree_bar_only(condition),'r--o');
end

for condition = 1: length(blurred_boundary_CCWDegree)
    plot(2,blurred_boundary_CCWDegree(condition),'r--o');
    plot(3,blurred_boundary_CWDegree(condition),'b--o');
    plot(4,off_sync_CCWDegree(condition),'r--o');
    plot(5,off_sync_CWDegree(condition),'b--o');
    plot(6,flash_grab_CCWDegree(condition),'r--o');
    plot(7,perceived_location_CCWDegree(condition),'r--o');
    plot(8,flash_grab_CWDegree(condition),'b--o');
    plot(9,perceived_location_CWDegree(condition),'b--o');
end



