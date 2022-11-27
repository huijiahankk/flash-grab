% Analysis the illusion  over the all subjects to find out the maximum
% illusion size pattern



clear all;
clear all;

sbjnames = {'huijiahan'} ;

for mark = 1:2
    % mark = 4;
    
    if mark == 1
        cd '../data/illusionSize/adjustFlashVertical/Dot'
    elseif mark == 2
        cd '../Wedge'
        % elseif mark == 3
        %     cd '../data/illusionSize/180/SpinSpeed_4'
        % elseif mark == 4
        %     cd '../data/illusionSize/180/SpinSpeed_2.3'
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
        
        
        
        tiltRightIndex = find( data.flashTiltDirection == 1 );
        tiltLeftIndex = find( data.flashTiltDirection == 2 );
        
        aveTiltRight = mean(data.wedgeTiltEachBlock(tiltRightIndex),2);
        aveTiltLeft = mean(data.wedgeTiltEachBlock(tiltLeftIndex),2);
        
        aveIllusionSizeAll(mark) = (aveTiltRight + abs(aveTiltLeft))/2;
        

    end
end


X = categorical({'Dot','Wedge'});
bar(aveIllusionSizeAll);
y = [aveIllusionSizeAll(1) aveIllusionSizeAll(2)];
h = bar(y,0.4,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(gca, 'XTick', 1:2, 'XTickLabels', {'Dot','Wedge'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Illusion size for different flash shape','FontSize',25);

% title('illusion size for different contrast','fontSize',20);
% ylabel('reported perceived position °','fontSize',20);
% set(gca,'xticklabel',{'0.06','0.12','0.24','0.48','0.96'},'fontSize',20);
% 
% length(sbjnames)
% 
% load hahn1;
% cftool;
% 
% ydata = mean(aveIlluSizeMat,1);
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
