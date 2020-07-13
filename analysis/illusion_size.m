% Analysis the illusion  over the all subjects to find out the maximum
% illusion size pattern



clear all;
clear all;
% addpath '../function';

sbjnames = {'huijiahan','jiangyong','hehuixia'}; 

mark = 3;

if mark == 1
    cd '../data/illusionSize/120/SpinSpeed_4'
elseif mark == 2
    cd '../data/illusionSize/120/SpinSpeed_2.3'
elseif mark == 3
    cd '../data/illusionSize/180/SpinSpeed_4'
elseif mark == 4
    cd '../data/illusionSize/180/SpinSpeed_2.3'
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



tiltRightIndex(:,sbjnum) = find( data.flashTiltDirection == 1 );
tiltLeftIndex(:,sbjnum) = find( data.flashTiltDirection == 2 );

aveTiltRight(sbjnum) = mean(data.wedgeTiltEachBlock(tiltRightIndex(:,sbjnum)),2);
aveTiltLeft(sbjnum) = mean(data.wedgeTiltEachBlock(tiltLeftIndex(:,sbjnum)),2);

aveIlluSize(sbjnum) = (aveTiltRight(sbjnum) + abs(aveTiltLeft(sbjnum)))/2;

% plot(1:size(tiltRightIndex,1),data.wedgeTiltEachBlock(tiltRightIndex),'r');
% hold on;
% plot(1:size(tiltLeftIndex,1),abs(data.wedgeTiltEachBlock(tiltLeftIndex)),'b');
% legend({'tilt right','tilt left'},'FontSize',14);
% xlim([1 6]);
% ylim([0 10]);

end


figure(mark);
bar(aveIlluSize,'r');

xlim([0 4]);
ylim([0 15]);
if mark == 1
    title('illusion size(120-SpinSpeed-4)','fontSize',20);
elseif mark == 2
    title('illusion size(120-SpinSpeed-2.3)','fontSize',20);
elseif mark == 3
    title('illusion size(180-SpinSpeed-4)','fontSize',20);
elseif mark == 4
    title('illusion size(180-SpinSpeed-2.3)','fontSize',20);
end

xlabel('tilt direction');
ylabel('degree');
hold on;


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
