% use mouse click data to analysis the illusion size of the wedge
% flash-grab illusion
% noted: mouse is not at the vertical location under the fixation it could
% be at any location of the screen



clear all;

sbjnames = {'guofanhua','huangsiyuan','huijiahan2','songyunjie','wangye','zhangpeng','zhaona'}; % 'guofanhua','huijiahan1'  half trail 
addpath '../function';

% s = what('flash-grab');
% uigetdir(s.path)

cd '../data/illusionSize/mousePress/Wedge'


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir([s3]);
    load (Files.name);
    
    illusionSizeL = [];
    illusionSizeR = [];
    %----------------------------------------------------------------------
    %                    average illusion size
    %----------------------------------------------------------------------
    
    for n = 1:size(data.mouseMoveDegreeMat,1)
        
        tiltRightIndex = find( data.flashTiltDirection(n,:) == 1 );
        tiltLeftIndex = find( data.flashTiltDirection(n,:) == 2 );
        
        for  m = 1:size(data.mouseMoveDegreeMat,2)/2
            illusionSizeR(n,m) = data.mouseMoveDegreeMat(n,tiltRightIndex(m));
            illusionSizeL(n,m) = data.mouseMoveDegreeMat(n,tiltLeftIndex(m));
        end
    end
    
    
    aveIllusionSizeL(:,sbjnum)= mean(illusionSizeL,2);
    aveIllusionSizeR(:,sbjnum) = abs(mean(illusionSizeR,2));
    
    
    if back.contrastTrend == '1'
        aveIllusionSize(:,sbjnum) = (aveIllusionSizeL(:,sbjnum) + aveIllusionSizeR(:,sbjnum))/2;
    elseif back.contrastTrend == '2'  % 1 low - high   2  high - low
        aveIllusionSize(:,sbjnum) = flip((aveIllusionSizeL(:,sbjnum) + aveIllusionSizeR(:,sbjnum))/2);
    end
    
   
        
end

% real average date
aveSub = mean(aveIllusionSize,2)
bar(aveSub,0.4);


% normalized data 
normAveIllusionSize = normalize(aveIllusionSize,'norm');
aveNorm = mean(normAveIllusionSize,2);


aveNorm_ste = ste(normAveIllusionSize,2);
bar(aveNorm,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
hold on;
errorbar(aveNorm,aveNorm_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');



% legend('Dot','Wedge');

% bar([mean(aveIllusionSize,2)],'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar([aveIllusionSizeL aveIllusionSizeR aveIllusionSize],30,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% ylim([0 50]);
set(gca, 'XTick', 1:5, 'XTickLabels', {'0.06' '0.12' '0.24' '0.48' '0.96'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Flash shift at different background contrast','FontSize',25);
X = categorical({'Background contrast'});

