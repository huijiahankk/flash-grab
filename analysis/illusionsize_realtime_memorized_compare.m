% use mouse click data to analysis the illusion size of the wedge
% flash-grab illusion
% noted: mouse is not at the vertical location under the fixation it could
% be at any location of the screen



clear all;

sbjnames = {'huijiahan','wangyaxuan'}; 
addpath '../function';

% s = what('flash-grab');
% uigetdir(s.path)   % opens a modal dialog box that displays the folders in the current working directory


% D=dir illusionSize_memorized_illusion_adjust;
% A=dir('myfolder\*.csv');
numberOfCondi = 4;
for folderNum = 1:numberOfCondi
%     folders = {'illusionSize_memorized_illusion_adjust/small','illusionSize_memorized_illusion_adjust/magnification'};
    folders = {'illusionSize_realtime_adjust/small', 'illusionSize_realtime_adjust/magnification', 'illusionSize_memorized_illusion_adjust/small','illusionSize_memorized_illusion_adjust/magnification'};
       
    
    if folderNum == 1
        path = '../data/7T/';
    else
        path = '../../';
    end
    
    thisFolderName = fullfile(path, folders{folderNum});
    
    cd(thisFolderName)
    
    
    
    for sbjnum = 1:length(sbjnames)
        s1 = string(sbjnames(sbjnum));
        s2 = '*.mat';
        s3 = strcat(s1,s2);
        %     if sbjnum > 1
        %         cd '../../percLocaTest/added_gabor_location'
        %     end
        Files = dir([s3]);
        load (Files.name);
        
%         illusionSizeL = [];
%         illusionSizeR = [];
      
        tiltRightIndex = find( data.flashTiltDirection(:,:) == 1 );
        tiltLeftIndex = find( data.flashTiltDirection(:,:) == 2 );
        
        
        illusionSizeR = data.wedgeMoveDegreeMat(tiltRightIndex);
        illusionSizeL = data.wedgeMoveDegreeMat(tiltLeftIndex);
        
                
        aveIlluSizeLeft(folderNum,sbjnum) = abs(mean(illusionSizeL,2));
        aveIlluSizeRight(folderNum,sbjnum) = abs(mean(illusionSizeR,2));
        
                
        
    end
    
end

aveIlluSizeAll = [mean(aveIlluSizeLeft,2); mean(aveIlluSizeRight,2)];


bar(aveIlluSizeAll); %  
text(1:length(aveIlluSizeAll),aveIlluSizeAll,num2str(aveIlluSizeAll),'vert','bottom','horiz','center','FontSize', 20); 
set(gca, 'XTick', 1:numberOfCondi*2 , 'XTickLabels', {'Tilt Left' 'Tilt Right' 'Tilt Left' 'Tilt Right' 'Tilt Left' 'Tilt Right' 'Tilt Left' 'Tilt Right'},'fontsize',20,'FontWeight','bold');
set(gcf,'color','w');
set(gca,'box','off');
% title('Illusion size','FontSize',25);
X = categorical({'Degree'});
xlim([0 numberOfCondi*2+1]);
ylim([0 20]);






% % normalized data
% normAveIllusionSize = normalize(aveIllusionSize,'norm');
% aveNorm = mean(normAveIllusionSize,2);
% aveNorm_ste = ste(normAveIllusionSize,2);
%
% aveIllusionSize_ste = ste(aveIllusionSize,2);



% bar(aveNorm,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% hold on;
% errorbar(aveNorm,aveNorm_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');
%
% bar(aveSub,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% hold on;
% errorbar(aveSub,aveIllusionSize_ste,'color',[0 .9 .9],'LineWidth',1.5,'LineStyle','none');

% legend('Dot','Wedge');

% bar([mean(aveIllusionSize,2)],'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% h = bar([aveIllusionSizeL aveIllusionSizeR aveIllusionSize],30,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
% ylim([0 50]);

