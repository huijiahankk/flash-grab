

% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang2  have the data in both directions  the flash on the edge
% huagnwenxiang  data can't use this program because it has flash alone
% trials in the same block
% wuzhigang
% huangwenxiang2 doesn't have the tilt lefe and right control over normal
% visual field. Only flash and tilt left
% For the degree record for example: right visual field damaged, the blind visual field is
% blindFieldUpper =  -15   blindFieldLower =   15


% clear all;
clearvars;

addpath '../function'

pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 3;
folders = { 'normal_field', 'upper_field','lower_field'};
path = '../data/corticalBlindness/bar';

thisFolderName = fullfile(path, folders{folderNum});

cd(thisFolderName)


blindFieldUpper = 90 + [-34.5625  -25  -16   -31];  % in sequence 'huangwenxiang2','wuzhigang','linhuangzhang','sunnan' 
blindFieldLower = 90 - [15.9375   12.5  88   45];
blindFieldUpperAddAve = [mean(blindFieldUpper)  blindFieldUpper] ; % in sequence mean CB1  CB2 CB3  CB4
blindFieldLowerAddAve = [mean(blindFieldLower)  blindFieldLower] ; 

%----------------------------------------------------------------------
%                blind field illusion size test
%----------------------------------------------------------------------
sbjnames = { 'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'} ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials


for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    %     if sbjnum > 1
    %         cd '../../percLocaTest/added_gabor_location'
    %     end
    Files = dir(s3);
    load (Files.name);
    
    if strcmp(string(sbjnames(sbjnum)),'huangwenxiang2') == 1
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
        
        if barLocation == 'u'    % right hemifield upper visual field
            % tilt left
            illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
            % tilt right
            illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
            
        elseif barLocation == 'l'   % right hemifield lower visual field
            illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
            % tilt left
            illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
        end
        
        illusionTiltDegree = data.wedgeTiltEachBlock(:,2:2:trialNumber);
        illusionTiltLeftDegree = illusionTiltDegree(illusionTiltDirectionIndexLeft);
        illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
        illusionTiltLeftDegree_std = std(illusionTiltLeftDegree);
         
        illusionTiltRightDegree = illusionTiltDegree(illusionTiltDirectionIndexRight);
        illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
        illusionTiltRightDegree_std = std(illusionTiltRightDegree);
         
        illusionAveTiltLeft = mean(illusionTiltLeftDegree);
        illusionAveTiltRight  = mean(illusionTiltRightDegree);
        
        
    else
        
        %----------------------------------------------------------------------
        %                    average illusion size
        %----------------------------------------------------------------------
        
        if barLocation == 'u'
            % tilt right
            illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 2);
            % tilt left
            illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 1);
            
        elseif barLocation == 'l'
            illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 2);
            % tilt left
            illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 1);
            
        elseif  barLocation == 'n'   %  n means normal visual field     define up is left   down is right
            illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 2);
            % tilt left
            illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 1);
            
            
        end
        
        
        illusionTiltLeftDegree  = data.wedgeTiltEachBlock(illusionTiltIndexLeft);
        illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
        illusionAveTiltLeft = mean(illusionTiltLeftDegree);
        illusionTiltLeftDegree_std = std(illusionTiltLeftDegree);
        
        
        illusionTiltRightDegree = data.wedgeTiltEachBlock(illusionTiltIndexRight);
        illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
        illusionAveTiltRight  = mean(illusionTiltRightDegree);
        illusionTiltRightDegree_std = std(illusionTiltRightDegree);
        
        
    end
    
    
    leftAllSub(:,sbjnum) = illusionAveTiltLeft;
    rightAllSub(:,sbjnum) = illusionAveTiltRight;
    leftAll_ste(:,sbjnum) = illusionTiltLeftDegree_ste;
    rightAll_ste(:,sbjnum) = illusionTiltRightDegree_ste;
    leftAll_std(:,sbjnum) = illusionTiltLeftDegree_std;
    rightAll_std(:,sbjnum) = illusionTiltRightDegree_std;   
    
    
end

% illusionAve(:,sbjnum) = abs([illusionAveTiltLeft(:,sbjnum)  illusionAveTiltRight(:,sbjnum)]);
% illusionTiltRightDegree_ste(:,sbjnum) = ste(illusionTiltRightDegree(:,sbjnum),1);
% illusionTiltLeftDegree_ste(:,sbjnum) = ste(illusionTiltLeftDegree(:,sbjnum),1);
% %     illusionAll_ste = ste(illusionAll,2);
% illusionAve_error(:,sbjnum) = abs([illusionTiltLeftDegree_ste(:,sbjnum)   illusionTiltRightDegree_ste(:,sbjnum)]);

leftAllSubAddAve = [mean(leftAllSub) leftAllSub];
rightAllSubAddAve = [mean(rightAllSub) rightAllSub];
leftAllSubAddAve_ste = [ste(leftAllSub,2), leftAll_ste];
rightAllSubAddAve_ste = [ste(rightAllSub,2),rightAll_ste];
leftAllSubAddAve_std = [std(leftAllSub),leftAll_std];
rightAllSubAddAve_std = [std(rightAllSub),rightAll_std];


if barLocation == 'n'
    leftAllSub_abs = leftAllSubAddAve + 90;
    rightAllSub_abs = rightAllSubAddAve + 90;
elseif barLocation == 'u'
    leftAllSub_fromHori = 90 + leftAllSubAddAve;    
    rightAllSub_fromHori = 90 + rightAllSubAddAve;
    leftAllSub_from_BlindBorder = leftAllSub_fromHori - blindFieldUpperAddAve;
    rightAllSub_from_BlindBorder = rightAllSub_fromHori - blindFieldUpperAddAve;
elseif barLocation == 'l'
    leftAllSub_fromHori = 90 - leftAllSubAddAve;    
    rightAllSub_fromHori = 90 - rightAllSubAddAve;
    leftAllSub_from_BlindBorder = leftAllSub_fromHori - blindFieldLowerAddAve;
    rightAllSub_from_BlindBorder = rightAllSub_fromHori - blindFieldLowerAddAve;    
end




if pValue == 'n'
    
y_barData = [];
    
    for datailluNum = 1:length(sbjnames)+1
        y_barData = [y_barData;leftAllSub_from_BlindBorder(datailluNum) rightAllSub_from_BlindBorder(datailluNum)];
    end
    
    %     y_barData = [leftAllSub_abs(1) rightAllSub_abs(1); leftAllSub_abs(2) rightAllSub_abs(2); leftAllSub_abs(3) rightAllSub_abs(3); leftAllSub_abs(4) rightAllSub_abs(4); leftAllSub_abs(5) rightAllSub_abs(5)]; % ; leftAllSub_abs(5) rightAllSub_abs(5)
    
%     h = bar(1:4,y_barData,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
    hold on;
    y_barData_ste = [leftAllSubAddAve_ste' rightAllSubAddAve_ste'];
    y_barData_std = [leftAllSubAddAve_std' rightAllSubAddAve_std'];
%     errorbar(reshape(1:8,2,4)',y_barData,,'k.');
  
% subplot(1,2,1);

figure(1);
    for ib = 1:5
        %XData property is the tick labels/group centers; XOffset is the offset
        %of each distinct group
%         xData = h(ib).XData + h(ib).XOffset;  
%         errorbar(xData,y_barData(ib,:),y_barData_ste(ib,:),'k.')
        hold on;
        h1=bar(2*ib - 0.5,y_barData(ib,1),'Barwidth',0.4,'FaceColor',[0 0.4470 0.7410],'LineWidth',1.5);  % ,'EdgeColor',[0 .9 .9]
        h2=bar(2*ib -1, y_barData(ib,2),'Barwidth',0.4,'FaceColor',[0.8500 0.3250 0.0980],'LineWidth',1.5); % ,'EdgeColor',[0 .9 .9]
        errorbar(2*ib - 0.5,y_barData(ib,1),y_barData_ste(ib,1),'k.');
        errorbar(2*ib - 1,y_barData(ib,2),y_barData_ste(ib,2),'k.');
    end
 
    if barLocation == 'l'
        set(gca, 'YDir', 'reverse');
    end
% figure(2);    
%     for ib = 1:4
%         %XData property is the tick labels/group centers; XOffset is the offset
%         %of each distinct group
%         %         xData = h(ib).XData + h(ib).XOffset;
%         %         errorbar(xData,y_barData(ib,:),y_barData_ste(ib,:),'k.')
%         hold on;
%         bar(2*ib - 0.5,y_barData(ib,1),'Barwidth',0.4,'FaceColor',[0 0.4470 0.7410],'LineWidth',1.5);
%         bar(2*ib -1, y_barData(ib,2),'Barwidth',0.4,'FaceColor',[0.8500 0.3250 0.0980],'LineWidth',1.5);
%         errorbar(2*ib - 0.5,y_barData(ib,1),y_barData_std(ib,1),'k.');
%         errorbar(2*ib - 1,y_barData(ib,2),y_barData_std(ib,2),'k.');
%     end
    
    
    
    
    %     % from yazhu
    %     hold on;
    %     P=DepROIPostIndex-1;  %normalize base=DepROIPreIndex=1
    %     M=NdepROIPostIndex-1;  %%normalize base=NdepROIPreIndex=1
    %     bar(2*k-0.5,nanmean(M),'BarWidth',0.4,'FaceColor','b');
    %     bar(2*k-1,nanmean(P),'BarWidth',0.4,'FaceColor','r');
    %     errorbar(2*k-0.5,nanmean(M),nanstd(M),'b','LineWidth',LineWidth);
    %     errorbar(2*k-1,nanmean(P),nanstd(P),'r','LineWidth',LineWidth);
    %     set(gca,'xlim',[0 2*size(cond_num,2)],'xTick',2-0.75:2:2*size(cond_num,2)-0.75,'XTickLabels',...
    %         {conds{cond_num}});
    %     title(['normalized response'],'FontSize',dotSize);
    %     ylabel('Normalized response (Post/Pre)','FontSize',dotSize);
    %     set(gca,'linewidth',LineWidth,'FontSize',dotSize,'FontName','Arial');box off;
    %     hold on;
    %     errorbar([1 2],nanmean([DepROIPreIndex DepROIPostIndex]),nanstd([DepROIPreIndex DepROIPostIndex])/sqrt(size(data,1)),'r','LineWidth',LineWidth);
    %     errorbar([1 2],nanmean([NdepROIPreIndex NdepROIPostIndex]),nanstd([NdepROIPreIndex NdepROIPostIndex])/sqrt(size(data,1)),'b','LineWidth',LineWidth);
    %     set(gca,'xlim',[0.5 2.5],'Xtick',[1 2],'xTickLabels',{'Pre' 'Post'});%legend('Dep','Ndep');
    %     set(gca,'linewidth',LineWidth,'FontSize',dotSize,'FontName','Arial');box off;axis square ;
    
    hold on;
    % h_error = errorbar(1:2,illusionAve(:,sbjnum),illusionAve_error(:,sbjnum),'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
    
    % set(gca, 'XTick', 1:2, 'XTickLabels', {'tilt left'  'tilt right' },'fontsize',35,'FontWeight','bold');
    
%     set(gca, 'XTick', 1:4, 'XTickLabels', {'mean' 'CB2' 'CB3'  'CB4'},'fontsize',35,'FontWeight','bold');
    set(gcf,'color','w');
    set(gca,'box','off');
    set(gcf,'color','w');
    ylabel('Shift degree from blind visual field border','FontSize',14);
    set(gca,'xlim',[0 10],'xTick',[1.5 3.5 5.5 7.5 9.5],'XtickLabels',{'Mean','CB1','CB2','CB3','CB4'},'FontName','Arial','FontSize',14);
    legend(h1,{'reverse counter-clockwise'},'EdgeColor','w');
    title('Motion reversal towards and outwards the scotoma-upper visual field ','FontSize',30);
%     legend(h2,{'reverse clockwise'},'EdgeColor','w');

    %     titleName = {'Normal visual field illusion size','upper visual field illusion size','lower visual field illusion size'};
    %     title(titleName{folderNum},'FontSize',40);
end

if pValue == 'y'
    [H1,P1,CI1] = ttest2(illusionTiltLeftDegree,  illusionTiltRightDegree);
    
    % bootstrap treats the original sample as a proxy for the real population and then draws random samples from it
    bootstats = bootstrp(10000,@(x)[mean(x) ste(x)],[abs(illusionTiltLeftDegree),abs(illusionTiltRightDegree)]);
    
    % cumulative distribution  from small to big
    [f,x] = ecdf(bootstats(:,1) - bootstats(:,2));
    
    % f(1) = 0  so assign the min in x to f(1)
    pBootstrap = f(abs(x)==min(abs(x)))
    P1
end

[H2,Pave2,CI2] = ttest(leftAllSub,rightAllSub);
Pave2
% fprintf('illusion tilt left compare tilt right: \n');
% disp(['p = ' num2str(p)]);



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
% 
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
