
clear all;
% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang  have the data in both directions  the flash on the edge 

% this program is not fit for wuzhigang 


sbjnames = {'huangwenxiang2'} ;

addpath '../function';


cd '../data/illusionSize/corticalBlindness/bar/upper_field/'




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
    
    if barLocation == 'u'
        % tilt right
        illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
        % tilt left
        illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
        
    elseif barLocation == 'l' 
        illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
        % tilt left
        illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
    
    end
    
    
    % illusion degree
    illusionTiltDegree = data.wedgeTiltEachBlock(:,2:2:trialNumber);
%     illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
%     illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
    
    % average illusion
    illusionTiltRightDegree = illusionTiltDegree(illusionTiltDirectionIndexRight);
    illusionTiltLeftDegree = illusionTiltDegree(illusionTiltDirectionIndexLeft);
    
    illusionTiltRightDegreeAve = mean(illusionTiltRightDegree);
    illusionTiltLeftDegreeAve = mean(illusionTiltLeftDegree);
    
    illusionAveTilt = mean([illusionTiltRightDegree;  illusionTiltLeftDegree]);  
end

[H,P,CI] = ttest( flashTiltDegreeRow,[illusionTiltRightDegree;  illusionTiltLeftDegree]');
;
flashTiltDegreeRow_ste = ste(flashTiltDegreeRow,2);
illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
illusionTiltDegreeRow_ste = ste([illusionTiltRightDegree;  illusionTiltLeftDegree]',2);
y_error = [flashTiltDegreeRow_ste  illusionTiltDegreeRow_ste illusionTiltLeftDegree_ste illusionTiltRightDegree_ste];
y = abs([aveFlashShift illusionAveTilt illusionTiltLeftDegreeAve illusionTiltRightDegreeAve]);
h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
hold on;
h_error = errorbar(1:4,y,y_error,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
set(gca, 'XTick', 1:4, 'XTickLabels', {'Flash' 'Illusion'  'Tilt left' 'Tilt right'},'fontsize',30,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Upper visual field bar shift','FontSize',40);


[H1,P1,CI1] = ttest2(illusionTiltLeftDegree,flashTiltDegreeRow(2:end));

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
