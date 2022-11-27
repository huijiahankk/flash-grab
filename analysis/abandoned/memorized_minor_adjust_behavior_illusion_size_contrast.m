% use mouse click data to analysis the illusion size of the wedge
% flash-grab illusion
% noted: mouse is not at the vertical location under the fixation it could
% be at any location of the screen



clear all;

sbjnames = {'huijiahan','liuchen','zhaona','houwenhao','wangyue'}; %'huijiahan','liuchen','zhaona','houwenhao','wangyue'
addpath '../function';

cd '../data/illusionSize/ContrastHierarchy/memorized_minor_adjust_contrast/';



for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
%         if sbjnum > 1
%             cd '../../percLocaTest/added_gabor_location'
%         end
    Files = dir([s3]);
    load (Files.name);
    
    %         illusionSizeL = [];
    %         illusionSizeR = [];
    
   for block = 1:blockNumber
       
       leftCounter = 0;
       rightCounter = 0;
       
       for trial = 1:trialNumber 
           
           if data.flashTiltDirection(block,trial) == 2
               leftCounter = leftCounter + 1;
               tiltLeft(block,leftCounter) = data.wedgeMoveDegreeMat(block,trial);
           elseif data.flashTiltDirection(block,trial) == 1
              rightCounter = rightCounter + 1;
               tiltRight(block,rightCounter) = data.wedgeMoveDegreeMat(block,trial);
           end
       end
   end
       
    aveIlluSizeLeft(:,sbjnum) = abs(mean(tiltLeft,2));
    aveIlluSizeRight(:,sbjnum) = abs(mean(tiltRight,2));
    
    aveIlluSizeAll = (aveIlluSizeLeft+aveIlluSizeRight)/2;
    
    
    [out(:,sbjnum),index(:,sbjnum)] = sort([back.contrastratioRand]);
    
    aveIlluSizeAscendContra(:,sbjnum) = aveIlluSizeAll(index(:,sbjnum));
        
end


aveIlluSizeAscendContraAve = mean(aveIlluSizeAscendContra,2);

bar(aveIlluSizeAscendContraAve); %
text(1:length(aveIlluSizeAscendContraAve),aveIlluSizeAscendContraAve',split(num2str(aveIlluSizeAscendContraAve')),'vert','bottom','horiz','center','FontSize', 20); %num2str(aveIlluSizeAll)
set(gca, 'XTick', 1:length(aveIlluSizeAscendContraAve) , 'XTickLabels', {'0.1' '0.24' '0.48' '0.96' '1'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
% title('Illusion size','FontSize',25);
X = categorical({'Degree'});
xlim([0 length(aveIlluSizeAll)+1]);
% ylim([0 30]);






% % normalized data
% normAveIllusionSize = normalize(aveIllusionSize,'norm');
% aveNorm = mean(normAveIllusionSize,2);
% aveNorm_ste = ste(normAveIllusionSize,2);
%
% aveIllusionSize_ste = ste(aveIllusionSize,2);



% bar(aveNorm,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% hold on;
% errorbar(aveNorm,aveNorm_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
%
% bar(aveSub,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% hold on;
% errorbar(aveSub,aveIllusionSize_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');

% legend('Dot','Wedge');

% bar([mean(aveIllusionSize,2)],'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar([aveIllusionSizeL aveIllusionSizeR aveIllusionSize],30,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% ylim([0 50]);

