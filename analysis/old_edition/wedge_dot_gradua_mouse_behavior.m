
clear all;


sbjnames = { 'huijiahan'};
addpath '../../../../function';

% s = what('flash-grab');
% uigetdir(s.path)

for condition = 1:2
    if condition == 1
        cd '../data/illusionSize/mousePress/Dot'
    elseif condition == 2
        cd '../Wedge'
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
        
        
        %----------------------------------------------------------------------
        %                    average illusion size
        %----------------------------------------------------------------------
        
        tiltRightIndex = find( data.flashTiltDirection == 1 );
        tiltLeftIndex = find( data.flashTiltDirection == 2 );
        
        xCoordinateL = data.mousePressCoordinate_x(tiltLeftIndex);
        yCoordinateL = data.mousePressCoordinate_y(tiltLeftIndex);
        
        xCoordinateR = data.mousePressCoordinate_x(tiltRightIndex);
        yCoordinateR = data.mousePressCoordinate_y(tiltRightIndex);
        
        
        for m = 1: length(xCoordinateR)
            
            illusionSizeL(m) = rad2deg(atan(abs((xCenter - xCoordinateL(m))/(yCoordinateL(m) - yCenter))));
            illusionSizeR(m) = rad2deg(atan(abs((xCoordinateR(m) - xCenter)/(yCoordinateR(m) - yCenter))));
            
        end
        
        aveIllusionSizeL = mean(illusionSizeL,2);
        aveIllusionSizeR = mean(illusionSizeR,2);
        
        aveIllusionSize = (aveIllusionSizeL + aveIllusionSizeR)/2;
        
%         scatter(xCenter,yCenter,'r');
%         hold on;
%         scatter(data.mousePressCoordinate_x,data.mousePressCoordinate_y);
    end
    aveIllusionSizeAll(condition) = aveIllusionSize;
end

X = categorical({'Dot','Wedge'});

% legend('Dot','Wedge');
% bar([aveIllusionSizeAll(1) aveIllusionSizeAll(2)],0.4,'r');
y = [aveIllusionSizeAll(1) aveIllusionSizeAll(2)];
h = bar(y,0.4,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(gca, 'XTick', 1:2, 'XTickLabels', {'Dot','Wedge'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
title('Illusion size for different flash shape','FontSize',25);


