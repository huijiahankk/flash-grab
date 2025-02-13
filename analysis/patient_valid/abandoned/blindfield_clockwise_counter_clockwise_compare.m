

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

addpath '../../function'

% pValue = input('>>>Calculate p Value? (y/n):  ','s');

folderNum = 1;
folders = { 'upper_field','lower_field','normal_field'};
path = '../../data/corticalBlindness/bar';

thisFolderName = fullfile(path, folders{folderNum});

cd(thisFolderName)


blindFieldUpper = 90 + [-34.5625  -25  -16   -31];  % in sequence 'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'
blindFieldLower = 90 - [15.9375   12.5  88   45];
blindFieldUpperAddAve = [mean(blindFieldUpper)  blindFieldUpper] ; % in sequence mean CB1  CB2 CB3  CB4
blindFieldLowerAddAve = [mean(blindFieldLower)  blindFieldLower] ;

%----------------------------------------------------------------------
%                blind field illusion size test
%----------------------------------------------------------------------
sbjnames = {'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'} ; %   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'    'linhuangzhang' has 6 trials
%   'huangwenxiang2','wuzhigang','linhuangzhang','sunnan'

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
        
        % reverse counter_clockwise
        counter_clockwiseDirectionIndex = find(data.flashTiltDirection(:,2:2:trialNumber) == 1);  % 1:2:trialNumber is flash test
        counter_clockwiseDegreeIndex = data.wedgeTiltEachBlock(:,2:2:trialNumber);
        counter_clockwiseDegree = counter_clockwiseDegreeIndex(counter_clockwiseDirectionIndex);
        counter_clockwiseDegree_ste = ste(counter_clockwiseDegree,1);
        counter_clockwiseDegreeAve = mean(counter_clockwiseDegree);
        
        % reverse clockwise
        clockwiseDirectionIndex = find(data.flashTiltDirection(:,2:2:trialNumber) == 2);
        clockwiseDegreeIndex = data.wedgeTiltEachBlock(:,2:2:trialNumber);
        clockwiseDegree = clockwiseDegreeIndex(clockwiseDirectionIndex);
        clockwiseDegree_ste = ste(clockwiseDegree,1);
        clockwiseDegreeAve  = mean(clockwiseDegree);
        
        
    else
        
        %----------------------------------------------------------------------
        %                    average illusion size
        %----------------------------------------------------------------------
        
        counter_clockwiseDirectionIndex = find(data.flashTiltDirection(:,:) == 1);
        counter_clockwiseDegree  = data.wedgeTiltEachBlock(counter_clockwiseDirectionIndex);
        counter_clockwiseDegree_ste = ste(counter_clockwiseDegree,1);
        counter_clockwiseDegreeAve = mean(counter_clockwiseDegree);
        
        % reverse clockwise
        clockwiseDirectionIndex = find(data.flashTiltDirection(:,:) == 2);
        clockwiseDegree = data.wedgeTiltEachBlock(clockwiseDirectionIndex);
        clockwiseDegree_ste = ste(clockwiseDegree,1);
        clockwiseDegreeAve  = mean(clockwiseDegree);
        
    end
    
    
    counter_clockwiseDegreeAveAllSub(:,sbjnum) = counter_clockwiseDegreeAve;
    clockwiseDegreeAveAllSub(:,sbjnum) = clockwiseDegreeAve;
    counter_clockwiseDegreeAll_ste(:,sbjnum) = counter_clockwiseDegree_ste;
    clockwiseDegreeAll_ste(:,sbjnum) = clockwiseDegree_ste;
    
    
end


% counter_clockwiseDegreeAllSubAddAve = [mean(counter_clockwiseDegreeAveAllSub) counter_clockwiseDegreeAveAllSub];
% clockwiseDegreeAllSubAddAve = [mean(clockwiseDegreeAveAllSub) clockwiseDegreeAveAllSub];
% counter_clockwiseDegreeAllSubAddAve_ste = [ste(counter_clockwiseDegreeAveAllSub,2), counter_clockwiseDegreeAll_ste];
% clockwiseDegreeAllSubAddAve_ste = [ste(clockwiseDegreeAveAllSub,2),clockwiseDegreeAll_ste];



if barLocation == 'n'
    counter_clockwiseDegreeAllSubAddAve_fromHori = counter_clockwiseDegreeAllSubAddAve + 90;
    counter_clockwiseDegreeAllSubAddAve_from_BlindBorder = clockwiseDegreeAllSubAddAve + 90;
elseif barLocation == 'u'
    %     counter_clockwiseDegreeAllSubAddAve_fromHori = 90 + counter_clockwiseDegreeAllSubAddAve;
    %     clockwiseDegreeAllSubAddAve_fromHori = 90 + clockwiseDegreeAllSubAddAve;
    %     counter_clockwiseDegreeAllSubAddAve_from_BlindBorder = counter_clockwiseDegreeAllSubAddAve_fromHori - blindFieldUpperAddAve;
    % clockwiseDegreeAllSubAddAve_from_BlindBorder = clockwiseDegreeAllSubAddAve_fromHori;
    
    
    counter_clockwiseDegreeAllSub_fromHori = 90 + counter_clockwiseDegreeAveAllSub;
    clockwiseDegreeAllSub_fromHori = 90 + clockwiseDegreeAveAllSub;
    
elseif barLocation == 'l'
    %     counter_clockwiseDegreeAllSubAddAve_fromHori = 90 - counter_clockwiseDegreeAllSubAddAve;
    %     clockwiseDegreeAllSubAddAve_fromHori = 90 - clockwiseDegreeAllSubAddAve;
    %     counter_clockwiseDegreeAllSubAddAve_from_BlindBorder = counter_clockwiseDegreeAllSubAddAve_fromHori - blindFieldLowerAddAve;
    %     clockwiseDegreeAllSubAddAve_from_BlindBorder = clockwiseDegreeAllSubAddAve_fromHori - blindFieldLowerAddAve;
    
    counter_clockwiseDegreeAllSub_fromHori = 90 - counter_clockwiseDegreeAveAllSub;
    clockwiseDegreeAllSub_fromHori = 90 - clockwiseDegreeAveAllSub;
end


pValue = 'n';

if pValue == 'n'
    
    y_barData = [];
    
    %     for datailluNum = 1:length(sbjnames)+1
    %         y_barData = [y_barData;counter_clockwiseDegreeAllSubAddAve_from_BlindBorder(datailluNum) clockwiseDegreeAllSubAddAve_from_BlindBorder(datailluNum)];
    %     end
    hold on;
%     y_barData_ste = [counter_clockwiseDegreeAllSubAddAve_ste' clockwiseDegreeAllSubAddAve_ste'];
    
    for datailluNum = 1:length(sbjnames)
        y_barData = [y_barData;blindFieldUpper(datailluNum) counter_clockwiseDegreeAllSub_fromHori(datailluNum) clockwiseDegreeAllSub_fromHori(datailluNum)];
    end
     y_barData_ste = [counter_clockwiseDegreeAll_ste' clockwiseDegreeAll_ste'];

    

    figure(1);
%     for ib = 1:5   %  1:%
%         %XData property is the tick labels/group centers; XOffset is the offset
%         %of each distinct group
%         %         xData = h(ib).XData + h(ib).XOffset;
%         %         errorbar(xData,y_barData(ib,:),y_barData_ste(ib,:),'k.')
%         hold on;
%         h1=bar(2*ib - 1,y_barData(ib,1),'Barwidth',0.4,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5);  % ,'EdgeColor',[0 .9 .9]
%         h2=bar(2*ib - 0.5, y_barData(ib,2),'Barwidth',0.4,'FaceColor',[1 1 1],'EdgeColor',[0.8500 0.3250 0.0980],'LineWidth',1.5); % ,'EdgeColor',[0 .9 .9]
%         errorbar(2*ib - 1,y_barData(ib,1),y_barData_ste(ib,1),'k.');
%         errorbar(2*ib - 0.5,y_barData(ib,2),y_barData_ste(ib,2),'k.');
%         %         legend(h1,{'reverse counter-clockwise'},'EdgeColor','w');
%         %         legend(h2,{'reverse clockwise'},'EdgeColor','w');
%     end
    
    
    figure(1);
    for ib = 1:4   %  1:%
        %XData property is the tick labels/group centers; XOffset is the offset
        %of each distinct group
        %         xData = h(ib).XData + h(ib).XOffset;
        %         errorbar(xData,y_barData(ib,:),y_barData_ste(ib,:),'k.')
        hold on;
        
        h1=bar(2*ib - 0.5,y_barData(ib,1),'Barwidth',0.4,'FaceColor',[1 1 1],'EdgeColor',[0.74 0.7470 0.7410],'LineWidth',1.5);  % ,'EdgeColor',[0 .9 .9]   0 0.4470 0.7410
        h2=bar(2*ib, y_barData(ib,2),'Barwidth',0.4,'FaceColor',[1 1 1],'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5); % ,'EdgeColor',[0 .9 .9]    0.8500 0.3250 0.0980
        h3=bar(2*ib + 0.5, y_barData(ib,3),'Barwidth',0.4,'FaceColor',[1 1 1],'EdgeColor',[0.8500 0.3250 0.0980],'LineWidth',1.5);
        errorbar(2*ib,y_barData(ib,2),y_barData_ste(ib,1),'k.');
        errorbar(2*ib + 0.5,y_barData(ib,3),y_barData_ste(ib,2),'k.');

    end
    
    
    if barLocation == 'l'
        % set the origin on the left top
        set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
    end
    
    hold on;

    set(gcf,'color','w');
    set(gca,'box','off');
    
%     ylabel('Shift degree from blind visual field border','FontName','Arial','FontSize',25);
    
%     set(gca,'xlim',[0 10],'xTick',[1.5 3.5 5.5 7.5 9.5],'XtickLabels',{'Mean','CB1','CB2','CB3','CB4'},'FontName','Arial','FontSize',25);
%     set(gca,'xlim',[0 10],'xTick',[1.5 3.5 5.5 7.5 9.5],'XtickLabels',{'CB1','CB2','CB3','CB4'},'FontName','Arial','FontSize',25);
%     set(gca,'ylim',[-15 20],'FontName','Arial','FontSize',25);
%   legend({'reverse counter-clockwise','reverse clockwise'},'EdgeColor','w');

    set(gca,'xlim',[0 10],'xTick',[2 4 6 8],'XtickLabels',{'CB1','CB2','CB3','CB4'},'FontName','Arial','FontSize',25);
    ylabel('Shift degree from horizontal meridian','FontName','Arial','FontSize',25);
    legend({'blind field border' 'reverse counter-clockwise','reverse clockwise'},'EdgeColor','w');
    if folderNum == 1
        title('Motion reversal towards and outwards the scotoma---upper visual field ','FontName','Arial','FontSize',35);
    elseif folderNum == 2
        title('Motion reversal towards and outwards the scotoma---lower visual field ','Position', [5, 0, 0],'FontName','Arial','FontSize',35);
        
    end
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

% [H2,Pave2,CI2] = ttest(leftAllSub,rightAllSub);



