

% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang2  have the data in both directions  the flash on the edge
% huagnwenxiang  data can't use this program because it has flash alone
% trials in the same block
% wuzhigang
% huangwenxiang2 doesn't have the tilt lefe and right control over normal
% visual field. Only flash and tilt left

% clear all;
clearvars;

addpath '../function'

pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 2;
folders = { 'normal_field', 'upper_field','lower_field'};
path = '../data/illusionSize/corticalBlindness/bar';

thisFolderName = fullfile(path, folders{folderNum});

cd(thisFolderName)


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
        %                    average illusion shift
        %----------------------------------------------------------------------
        
        if barLocation == 'u'
            % tilt left
            illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
            % tilt right
            illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
            
        elseif barLocation == 'l'
            illusionTiltDirectionIndexLeft = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
            % tilt left
            illusionTiltDirectionIndexRight = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);
        end
        
        illusionTiltDegree = data.wedgeTiltEachBlock(:,2:2:trialNumber);
        illusionTiltLeftDegree = illusionTiltDegree(illusionTiltDirectionIndexLeft);
        illusionTiltRightDegree = illusionTiltDegree(illusionTiltDirectionIndexRight);
        
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
            
        elseif  barLocation == 'n'   %  define up is left   down is right
            illusionTiltIndexLeft = find(data.flashTiltDirection(:,:) == 2);
            % tilt left
            illusionTiltIndexRight = find(data.flashTiltDirection(:,:) == 1);
            
            
        end
        
        
        illusionTiltLeftDegree  = data.wedgeTiltEachBlock(illusionTiltIndexLeft);
        illusionTiltLeftDegree_ste = ste(illusionTiltLeftDegree,1);
        illusionAveTiltLeft = mean(illusionTiltLeftDegree);
        
        
        
        illusionTiltRightDegree = data.wedgeTiltEachBlock(illusionTiltIndexRight);
        illusionTiltRightDegree_ste = ste(illusionTiltRightDegree,1);
        illusionAveTiltRight  = mean(illusionTiltRightDegree);
        
        
        %     % for different subject have the different trial numbers
        %     % we have to put all the results in the same matrix
        %     % comparing matrix for each subject and filling gap with zeros
        %     k = data.wedgeTiltEachBlock(illusionTiltIndexRight);
        %
        %     if strcmp(sbjnames(sbjnum), {'linhuangzhang'}) == 1
        %         matrixNum = max(numel(k),numel(illusionTiltRightDegree(:,sbjnum - 1)));
        %     else
        %         matrixNum = max(numel(k),numel(illusionTiltRightDegree(:,sbjnum)));
        %     end
        %     %     matrixNum = max(numel(k),numel(illusionTiltRightDegree(:,sbjnum - 1)));
        %     illusionTiltLeftDegree(end+1:matrixNum,sbjnum) = 0;
        %     illusionTiltRightDegree(end+1:matrixNum,sbjnum) = 0;
        %     %     k(end+1:matrixNum,sbjnum) = 0;
        
        
        %     illusionAll = [ illusionTiltLeftDegree'  illusionTiltLeftDegree'];
        %     illusionAve = (illusionAveTiltRight + illusionAveTiltLeft)/2;
        
    end
    
    
    leftAllSub(:,sbjnum) = illusionAveTiltLeft;
    rightAllSub(:,sbjnum) = illusionAveTiltRight;
    leftAll_ste(:,sbjnum) = illusionTiltLeftDegree_ste;
    rightAll_ste(:,sbjnum) = illusionTiltRightDegree_ste;
    
    
    
end

% illusionAve(:,sbjnum) = abs([illusionAveTiltLeft(:,sbjnum)  illusionAveTiltRight(:,sbjnum)]);
% illusionTiltRightDegree_ste(:,sbjnum) = ste(illusionTiltRightDegree(:,sbjnum),1);
% illusionTiltLeftDegree_ste(:,sbjnum) = ste(illusionTiltLeftDegree(:,sbjnum),1);
% %     illusionAll_ste = ste(illusionAll,2);
% illusionAve_error(:,sbjnum) = abs([illusionTiltLeftDegree_ste(:,sbjnum)   illusionTiltRightDegree_ste(:,sbjnum)]);

leftAllSubAddAve = [leftAllSub mean(leftAllSub)];
rightAllSubAddAve = [rightAllSub  mean(rightAllSub)];

leftAllSub_abs = abs(leftAllSubAddAve);
rightAllSub_abs = abs(rightAllSubAddAve);



if pValue == 'n'
    
    y_barData = [];
    
    for datailluNum = 1:length(sbjnames)
        y_barData = [y_barData;leftAllSub_abs(datailluNum) rightAllSub_abs(datailluNum)];
    end
    
    %     y_barData = [leftAllSub_abs(1) rightAllSub_abs(1); leftAllSub_abs(2) rightAllSub_abs(2); leftAllSub_abs(3) rightAllSub_abs(3); leftAllSub_abs(4) rightAllSub_abs(4); leftAllSub_abs(5) rightAllSub_abs(5)]; % ; leftAllSub_abs(5) rightAllSub_abs(5)
    
    h = bar(y_barData,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
    
    
    hold on;
    % h_error = errorbar(1:2,illusionAve(:,sbjnum),illusionAve_error(:,sbjnum),'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
    
    % set(gca, 'XTick', 1:2, 'XTickLabels', {'tilt left'  'tilt right' },'fontsize',35,'FontWeight','bold');
    
    set(gca, 'XTick', 1:5, 'XTickLabels', {'patient 1' 'patient 2'  'patient 3' 'patient 4'  'mean'},'fontsize',35,'FontWeight','bold');
    set(gcf,'color','w');
    set(gca,'box','off');
    
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
