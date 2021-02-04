
clear all;
% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang  have the data in both directions  the flash on the edge
sbjnames = {'wuzhigang'} ;
addpath '../function';


%----------------------------------------------------------------------
%                blind field test
%----------------------------------------------------------------------


cd '../data/illusionSize/corticalBlindness/bar/lower_field/'


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir([s3]);
    load (Files.name);
    
    
    
    %----------------------------------------------------------------------
    %                    average illusion size
    %----------------------------------------------------------------------
    
    if barLocation == 'u'
        % tilt right
        illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 1);
        % tilt left
        illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 2);
        
    elseif barLocation == 'l'
        illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 1);
        % tilt left
        illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 2);
    end
    
    illusionTiltRightDegree = data.wedgeTiltEachBlock(illusionTiltIndexRight);
    illusionAveTiltRight = mean(illusionTiltRightDegree);
    

    illusionTiltLeftDegree = data.wedgeTiltEachBlock(illusionTiltIndexLeft(1:end-1));
    illusionAveTiltLeft = mean(illusionTiltLeftDegree);

        
    illusionAll = [ illusionTiltLeftDegree'  illusionTiltLeftDegree'];
    illusionAve = (illusionAveTiltRight + illusionAveTiltLeft)/2;
    
   
    
    y = [illusionAve illusionAveTiltLeft illusionAveTiltRight];
    illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
    illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
    illusionAll_ste = ste(illusionAll,2);
    y_error = [illusionAll_ste   illusionTiltLeftDegree_ste   illusionTiltRightDegree_ste];
    h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
    hold on;
    h_error = errorbar(1:3,y,y_error,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
    set(gca, 'XTick', 1:3, 'XTickLabels', {'average' 'tilt left'  'tilt right' },'fontsize',35,'FontWeight','bold');
    set(gcf,'color','w');
    set(gca,'box','off');
    title('Lower visiual field illusion size','FontSize',40);
end

[H1,P1,CI1] = ttest2(illusionTiltLeftDegree,  illusionTiltRightDegree);

% [H,P,CI] = ttest( flashTiltDegreeRow,[illusionTiltRightDegree;  illusionTiltLeftDegree]');
%
% flashTiltDegreeRow_ste = ste(flashTiltDegreeRow,2);
% illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
% illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
% illusionTiltDegreeRow_ste = ste([illusionTiltRightDegree;  illusionTiltLeftDegree]',2);
% y_error = [flashTiltDegreeRow_ste  illusionTiltDegreeRow_ste illusionTiltLeftDegree_ste illusionTiltRightDegree_ste];
% y = abs([aveFlashShift illusionAveTilt illusionTiltLeftDegreeAve illusionTiltRightDegreeAve]);
% h = bar(y,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% hold on;
% h_error = errorbar(1:4,y,y_error,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
% set(gca, 'XTick', 1:4, 'XTickLabels', {'Flash' 'Illusion'  'Tilt left' 'Tilt right'},'fontsize',30,'FontWeight','bold');
% set(gcf,'color','w');
% set(gca,'box','off');
% title('upper visual field bar shift','FontSize',40);
%
%
% [H1,P1,CI1] = ttest2(illusionTiltLeftDegree,flashTiltDegreeRow(2:end));

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
