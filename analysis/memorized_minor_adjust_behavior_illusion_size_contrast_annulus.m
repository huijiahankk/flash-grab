% use mouse click data to analysis the illusion size of the wedge
% flash-grab illusion
% noted: mouse is not at the vertical location under the fixation it could
% be at any location of the screen



clear all;

sbjnames = {'chenchen'}; % 'dingyingshi','huijiahan','wangzeyu','tangkunyi','niulei','mojiayi','chenchen'
addpath '../function';

cd '../data/illusionSize/ContrastHierarchy/memorized_minor_adjust_behavior_illusion_size_contrast_annulus/';



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
    %     blockNumber = 2;
    [leftCounterSmall,rightCounterSmall,leftCounterLarge,rightCounterLarge] = deal(0);
    
    % 20 blocks odd blocks are small annulus even blocks are large annulus
    % first 2 blocks are contrast 0.06 the next 2 blocks are contrast 0.12
    % and so on  until 2 blocks are contrast 0.96 and then the contrast
    for block = 1:blockNumber
        if mod(block,2) == 1  % small annulus
            [leftCounterSmall,rightCounterSmall,leftCounterLarge,rightCounterLarge] = deal(0);
            for trial = 1:trialNumber
                
                % on each block the odd trial number means
                % sectorRadius_in_out_magni = 1   small annulus
                
                if data.flashTiltDirection(block,trial) == 2
                    leftCounterSmall = leftCounterSmall + 1;
                    tiltLeftSmall((block+1)/2,leftCounterSmall) = data.wedgeMoveDegreeMat(block,trial);
                elseif data.flashTiltDirection(block,trial) == 1
                    rightCounterSmall = rightCounterSmall + 1;
                    tiltRightSmall((block+1)/2,rightCounterSmall) = data.wedgeMoveDegreeMat(block,trial);
                end
            end
            
            
            
        elseif mod(block,2) == 0   % large annulus
            
            [leftCounterSmall,rightCounterSmall,leftCounterLarge,rightCounterLarge] = deal(0);
            for trial = 1:trialNumber
                % the even trial number means sectorRadius_in_out_magni = 2 big
                % annulus
                if data.flashTiltDirection(block,trial) == 2
                    leftCounterLarge = leftCounterLarge + 1;
                    tiltLeftLarge(block/2,leftCounterLarge) = data.wedgeMoveDegreeMat(block,trial);
                elseif data.flashTiltDirection(block,trial) == 1
                    rightCounterLarge = rightCounterLarge + 1;
                    tiltRightLarge(block/2,rightCounterLarge) = data.wedgeMoveDegreeMat(block,trial);
                end
                
            end
            
        end
    end        
    
    
        aveIlluSizeLeftSmall(:,sbjnum) = abs(mean(tiltLeftSmall,2));
        aveIlluSizeRightSmall(:,sbjnum) = abs(mean(tiltRightSmall,2));
        aveIlluSizeAllSmall = (aveIlluSizeLeftSmall+aveIlluSizeRightSmall)/2;
        
        aveIlluSizeLeftLarge(:,sbjnum) = abs(mean(tiltLeftLarge,2));
        aveIlluSizeRightLarge(:,sbjnum) = abs(mean(tiltRightLarge,2));
        aveIlluSizeAllLarge = (aveIlluSizeLeftLarge+aveIlluSizeRightLarge)/2;
        
        %         [out(:,sbjnum),index(:,sbjnum)] = sort([back.contrastratioMat]);
        %
        %         aveIlluSizeAscendContra(:,sbjnum) = aveIlluSizeAllSmall(index(:,sbjnum));
end

IlluSizeSmall = (aveIlluSizeAllSmall(1:5,:) + flipud(aveIlluSizeAllSmall(6:10,:)))/2;
IlluSizeLarge = (aveIlluSizeAllLarge(1:5,:) + flipud(aveIlluSizeAllLarge(6:10,:)))/2;

aveIlluSizeSmall = mean(IlluSizeSmall,2);
aveIlluSizeSmall_ste = ste(IlluSizeSmall,2);
aveIlluSizeLarge = mean(IlluSizeLarge,2); 
aveIlluSizeLarge_ste = ste(IlluSizeLarge,2);


figure(1);
aveIlluSizeSmall_ste = ste(IlluSizeSmall,2);
bar(mean(aveIlluSizeSmall,2));
hold on;
errorbar(1:size(aveIlluSizeSmall,1),aveIlluSizeSmall,aveIlluSizeSmall_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');

% text(1:length(aveIlluSizeSmall),aveIlluSizeSmall',split(num2str(aveIlluSizeSmall)),'vert','bottom','horiz','center','FontSize', 20); %num2str(aveIlluSizeAll)
title('Illusion size for small annulus','FontSize',25);
set(gca, 'XTick', 1:length(aveIlluSizeSmall) , 'XTickLabels', {'0.06' '0.12' '0.24' '0.48' '0.96'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
X = categorical({'Degree'});
xlim([0 length(aveIlluSizeSmall)+1]);
ylim([0 30]);

figure(2);
bar(aveIlluSizeLarge);
hold on;
errorbar(1:size(aveIlluSizeLarge,1),aveIlluSizeLarge,aveIlluSizeLarge_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
% text(1:length(aveIlluSizeLarge),aveIlluSizeLarge',split(num2str(aveIlluSizeLarge)),'vert','bottom','horiz','center','FontSize', 20); %num2str(aveIlluSizeAll)
title('Illusion size for large annulus','FontSize',25);

set(gca, 'XTick', 1:length(aveIlluSizeSmall) , 'XTickLabels', {'0.06' '0.12' '0.24' '0.48' '0.96'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
X = categorical({'Degree'});
xlim([0 length(aveIlluSizeSmall)+1]);
ylim([0 30]);






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

