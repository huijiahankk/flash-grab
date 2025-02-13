

clear all;
% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang  have the data in both directions  the flash on the edge
% the stimulus present:
% first red flash without background
% second red flash with moving background back and forth
% repeat first and second for 8 times

% this analysis script only work for huangwenxiang2
% this program is not fit for others




sbjnames = {'huangwenxiang2'} ;

addpath '../function';

folderNum = 3;
folders = { 'normal_field', 'upper_field','lower_field'};
path = '../data/corticalBlindness/bar';

thisFolderName = fullfile(path, folders{folderNum});

cd(thisFolderName)

% cd '../data/illusionSize/corticalBlindness/bar/upper_field/'


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir([s3]);
    load (Files.name);
    
    
    % if barLocation == 'l'
    %     % back.flashTiltDirection = 2 is tilt left
    %     back.flashTiltDirectionMat = repmat([2],trialNumber,1);
    % elseif barLocation == 'u'
    %     % back.flashTiltDirection = 2 is tilt left
    %     back.flashTiltDirectionMat = repmat([1],trialNumber,1);
    % elseif barLocation == 'lowerleft'
    %     % back.flashTiltDirection = 1 is tilt right
    %     back.flashTiltDirectionMat = repmat([1],trialNumber,1);
    % end
    
    
    %----------------------------------------------------------------------
    %                    average flash shift
    %----------------------------------------------------------------------
    
    %flash tilt degree
    flashTiltDegree = data.wedgeTiltEachBlock(:,1:2:trialNumber);
    
    flashTiltDegreeRow = [flashTiltDegree(1,:) flashTiltDegree(2,:)];
    aveFlashShift = mean(flashTiltDegreeRow);
    
    
    %----------------------------------------------------------------------
    %                    average illusion shift
    %----------------------------------------------------------------------
    
    if folders{folderNum} == 'upper_field'       
        % tilt left
        illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
        % tilt right
        illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
        
    elseif folders{folderNum} == 'lower_field'
        illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
        % tilt left
        illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
        
    end
    
    
    % illusion degree
    illusionTiltDegree = data.wedgeTiltEachBlock(:,2:2:trialNumber);
    %     illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
    %     illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
    
    % average illusion
    illusionTiltLeftDegree = illusionTiltDegree(illusionTiltDirectionIndexLeft);
    illusionTiltRightDegree = illusionTiltDegree(illusionTiltDirectionIndexRight);
    
    illusionTiltLeftDegreeAve = mean(illusionTiltLeftDegree);
    illusionTiltRightDegreeAve = mean(illusionTiltRightDegree);
    
    
%     illusionAveTilt = mean([illusionTiltRightDegree;  illusionTiltLeftDegree]);
end

[H,P,CI] = ttest( flashTiltDegreeRow,[illusionTiltRightDegree;  illusionTiltLeftDegree]');

flashTiltDegreeRow_ste = ste(flashTiltDegreeRow,2);
illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
illusionTiltDegreeRow_ste = ste([illusionTiltRightDegree;  illusionTiltLeftDegree]',2);
y_error = [flashTiltDegreeRow_ste  illusionTiltLeftDegree_ste illusionTiltRightDegree_ste];

y = abs([aveFlashShift illusionTiltLeftDegreeAve illusionTiltRightDegreeAve]);

h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
hold on;
h_error = errorbar(1:3,y,y_error,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
set(gca, 'XTick', 1:3, 'XTickLabels', {'Flash' 'Tilt left' 'Tilt right'},'fontsize',30,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title(folders{folderNum},'FontSize',40);


% [H1,P1,CI1] = ttest2(illusionTiltLeftDegree,flashTiltDegreeRow(2:end));

[H1,P1,CI1] = ttest2(illusionTiltLeftDegree,illusionTiltRightDegree);
% bootstrap
% bootstrap treats the original sample as a proxy for the real population and then draws random samples from it
bootstats = bootstrp(10000,@(x)[mean(x) ste(x)],[abs(illusionTiltLeftDegree),abs(illusionTiltRightDegree)]);

% cumulative distribution  from small to big
[f,x] = ecdf(bootstats(:,1) - bootstats(:,2));

% f(1) = 0  so assign the min in x to f(1)
pBootstrap = f(abs(x)==min(abs(x)))
P1



% axis equal;
% set(gca,'Visible','off');
% % set(gca,'XColor','none','YColor','none')
% set(gca,'XTick',[], 'YTick', []);
% set(gcf,'color','w');
% % set the origin on the left top
% set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
% % if mark == 4;
% % saveas(figure(1),[pwd '/lucy.bmp']);
% % end
