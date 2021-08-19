% Analysis the illusion  over the all subjects to find out the maximum
% illusion size pattern



clear all;
clear all;
% whichData = 1 ContrastHierarchy   whichData = 0  ContrastHierarchy/wrong_contrast/'; 
whichData = 1;
if whichData
    sbjnames = { 'chenchen','dengjia', 'huijiahan','liuchen','wangye','zhangluhan','zhangruotong','zhaoyitong','zhaozitong','zhuwenyu','xiangshuqin'};  %'huangsiyuan','huijiahan','chenhaoyu','houwenhao','zhaona','dingyongli'
    %   'chenchen','dengjia', huijiahan','liuchen','wangye','zhangluhan','zhangruotong','zhaoyitong','zhaozitong','zhuwenyu'
else ~ whichData
    sbjnames = {'huangsiyuan','huijiahan','chenhaoyu','houwenhao','zhaona','dingyongli','mojiaye','qiaoyuyao','chenzhiqiang'} ;
%    'huangsiyuan','huijiahan','chenhaoyu','houwenhao','zhaona','dingyongli','mojiaye','qiaoyuyao','chenzhiqiang'，
end
% 'huangsiyuan','huijiahan','chenhaoyu','houwenhao','zhaona','dingyongli','mojiaye','qiaoyuyao','chenzhiqiang','yuanziyi'
for mark = 1:1
    % mark = 4;
    
    % if mark == 1
    %     cd '../data/illusionSize/120/SpinSpeed_4'
    % elseif mark == 2
    %     cd '../data/illusionSize/120/SpinSpeed_2.3'
    % elseif mark == 3
    %     cd '../data/illusionSize/180/SpinSpeed_4'
    % elseif mark == 4
    %     cd '../data/illusionSize/180/SpinSpeed_2.3'
    % end
    
    
    % 1 background tilt，flash vertical  2 flash/background vertical
    % if mark == 1
    %     cd '../data/illusionSize/backTilt_FlashVer/1frame/';
    % elseif mark == 2
    %     cd  '../data/illusionSize/backTilt_FlashVer/3frame/';
    % elseif mark == 3
    %     cd  '../data/illusionSize/backFlash_Ver/1frame/';
    % elseif mark == 4
    %     cd '../data/illusionSize/backFlash_Ver/3frame/';
    % end
    
    
    if  mark == 1 && whichData == 0
        cd '../data/illusionSize/ContrastHierarchy/wrong_contrast/';   % highContrast
        addpath '../../../../function';
    elseif mark == 1 && whichData == 1
        cd '../data/illusionSize/ContrastHierarchy/'
        addpath '../../../function';
        %         cd   '../whiteAndBlack/';
        % elseif mark == 3
        %     cd   '../../3frame/0InnerRadii/';
        % elseif mark == 4
        %     cd    '../../3frame/200InnerRadii/';
    end
    
%     addpath '../function';
    
    for sbjnum = 1:length(sbjnames)
        s1 = string(sbjnames(sbjnum));
        s2 = '*.mat';
        s3 = strcat(s1,s2);
        %     if sbjnum > 1
        %         cd '../../percLocaTest/added_gabor_location'
        %     end
        Files = dir([s3]);
        load (Files.name);
        
        
        if whichData == 0
            back.contrastratioMat = back.contrastMat;
        end
        

        for contrastCondi = 1:length(back.contrastratioMat)
            
            tiltRightIndex = find( data.flashTiltDirection == 1 );
            tiltLeftIndex = find( data.flashTiltDirection == 2 );
            
            aveTiltRight(contrastCondi) = mean(data.wedgeTiltEachBlock(contrastCondi,tiltRightIndex),2);
            aveTiltLeft(contrastCondi) = mean(data.wedgeTiltEachBlock(contrastCondi,tiltLeftIndex),2);
            
            aveIlluSize(contrastCondi) = (aveTiltRight(contrastCondi) + abs(aveTiltLeft(contrastCondi)))/2;
            
        end
        
        if back.contrastratioMat(1) == 0.96
            aveIlluSizeMat(sbjnum,:) = flip(aveIlluSize);
        elseif back.contrastratioMat(1) == 0.06
            aveIlluSizeMat(sbjnum,:) = aveIlluSize;
        end
      
    end
end

figure(mark);

aveIlluSize_ste = ste(aveIlluSizeMat,1);
bar(mean(aveIlluSizeMat,1));
hold on;
errorbar(1:size(aveIlluSizeMat,2),mean(aveIlluSizeMat,1),aveIlluSize_ste,'k.');

plot(1:size(aveIlluSizeMat,2),mean(aveIlluSizeMat,1));

xlim([0 length(back.contrastratioMat)+1]);
ylim([0 15]);

title('illusion size for different contrast','fontSize',20);
ylabel('reported perceived position °','fontSize',20);
set(gca,'xticklabel',{'0.06','0.12','0.24','0.48','0.96'},'fontSize',20);

length(sbjnames)

load hahn1;
cftool;
if back.contrastratioMat(1) == 0.06
    xdata = back.contrastratioMat;
elseif   back.contrastratioMat(1) == 0.96
    xdata = flip(back.contrastratioMat);
end
ydata = mean(aveIlluSizeMat,1);
% f = fit(1:size(aveIlluSizeMat,2),mean(aveIlluSizeMat,1),'smoothingspline');%, 'rat23' 
% Plot your fit and the data.

% plot( f, temp, thermex );
% f( 600 );


% if mark == 1
%     title('illusion size(120-SpinSpeed-4)','fontSize',20);
% elseif mark == 2
%     title('illusion size(120-SpinSpeed-2.3)','fontSize',20);
% elseif mark == 3
%     title('illusion size(180-SpinSpeed-4)','fontSize',20);
% elseif mark == 4
%     title('illusion size(180-SpinSpeed-2.3)','fontSize',20);
% end

%
% if mark == 1
%     title('background Tilt- Flash Vertical present for 1 frame','fontSize',20);
% elseif mark == 2
%     title('background Tilt- Flash Vertical present for 3 frame','fontSize',20);
% elseif mark == 3
%     title('background and Flash Vertical flash present for 1 frame','fontSize',20);
% elseif mark == 4
%     title('background and Flash Vertical flash present for 3 frame','fontSize',20);
% end
%





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
