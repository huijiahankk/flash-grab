% Analysis the illusion  over the all subjects to find out the maximum
% illusion size pattern



clear all;
clear all;
% addpath '../function';

sbjnames = {'huijiahan'};  %,'huangsiyuan','houwenhao'

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
    
    
    if  mark == 1
        cd '../data/illusionSize/ContrastHierarchy/';   % highContrast
    elseif mark == 2
        cd   '../whiteAndBlack/';
        % elseif mark == 3
        %     cd   '../../3frame/0InnerRadii/';
        % elseif mark == 4
        %     cd    '../../3frame/200InnerRadii/';
    end
    
    
    
    
    for sbjnum = 1:length(sbjnames)
        s1 = string(sbjnames(sbjnum));
        s2 = '*.mat';
        s3 = strcat(s1,s2);
        %     if sbjnum > 1
        %         cd '../../percLocaTest/added_gabor_location'
        %     end
        Files = dir([s3]);
        load (Files.name);
        
        for contrastCondi = 1:length(back.contrastratioMat)
            
            tiltRightIndex = find( data.flashTiltDirection == 1 );
            tiltLeftIndex = find( data.flashTiltDirection == 2 );
            
            aveTiltRight(sbjnum,contrastCondi) = mean(data.wedgeTiltEachBlock(contrastCondi,tiltRightIndex),2);
            aveTiltLeft(sbjnum,contrastCondi) = mean(data.wedgeTiltEachBlock(contrastCondi,tiltLeftIndex),2);
            
            aveIlluSize(sbjnum,contrastCondi) = (aveTiltRight(sbjnum,contrastCondi) + abs(aveTiltLeft(sbjnum,contrastCondi)))/2;
            
            % plot(1:size(tiltRightIndex,1),data.wedgeTiltEachBlock(tiltRightIndex),'r');
            % hold on;
            % plot(1:size(tiltLeftIndex,1),abs(data.wedgeTiltEachBlock(tiltLeftIndex)),'b');
            % legend({'tilt right','tilt left'},'FontSize',14);
            % xlim([1 6]);
            % ylim([0 10]);
        end
    end
end

figure(mark);
% bar(aveIlluSize,'r');
bar(mean(aveIlluSize,1));

xlim([0 length(back.contrastratioMat)+1]);
ylim([0 15]);

title('illusion size for different contrast','fontSize',20);
ylabel('reported perceived position °','fontSize',20);
set(gca,'xticklabel',{'0.06','0.12','0.24','0.48','0.96'},'fontSize',20);



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
