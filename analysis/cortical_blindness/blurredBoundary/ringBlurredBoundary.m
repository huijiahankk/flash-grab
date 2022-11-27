% ringBlurredBoundary

clear all;

addpath '../../function';

sbjnames = {'redbar','withoutbar'};

path = '../../data/corticalBlindness/ringBlurredBoundary';

cd(path);

for sbjnum = 1:length(sbjnames)
    
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    
    Files = dir(s3);
    load (Files.name);
    
    
    CCW_mean(sbjnum) = mean(nonzeros(grab_effect_degree_CCW_from_vertical));
    CW_mean(sbjnum) = mean(nonzeros(grab_effect_degree_CW_from_vertical));
    
end


y = [CCW_mean(1) CCW_mean(2) CW_mean(1) CW_mean(2)];


% y = [bar_onlyDegreeMean flash_grab_CCWDegreeMean flash_grab_CWDegreeMean];
h = bar(y,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);
set(gca, 'XTick', 1:4, 'XTickLabels', {'redbar-CCW' 'noredbar-CCW' 'redbar-CW' 'noredbar-CW'},'fontsize',20,'FontWeight','bold');

ylabel('Shift degree from vertical meridian','FontName','Arial','FontSize',25);
% set(gca,'ylim',[-20 20],'FontName','Arial','FontSize',25);
set(gcf,'color','w');
set(gca,'box','off');
xtickangle(45);
