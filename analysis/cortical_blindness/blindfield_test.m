
clear all;
% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang2  have the data in both directions  the flash on the edge in
% the same data file


%----------------------------------------------------------------------
%                blind field test
%----------------------------------------------------------------------

addpath '../function';
cd '../data/corticalBlindness/bar/blindField/'

sbjnames = {'wuzhigang','linhuangzhang','sunnan'} ; %  'wuzhigang','linhuangzhang','sunnan'


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
    %                blind field test
    %----------------------------------------------------------------------
    
    blindFieldUpper(:,sbjnum) = mean(data.wedgeTiltEachBlock(1,:));
    blindFieldLower(:,sbjnum) = mean(data.wedgeTiltEachBlock(2,:));
    
       
end

 y_barData = [leftAllSub_abs(1) rightAllSub_abs(1); leftAllSub_abs(2) rightAllSub_abs(2); leftAllSub_abs(3) rightAllSub_abs(3); leftAllSub_abs(4) rightAllSub_abs(4)]; % ; leftAllSub_abs(5) rightAllSub_abs(5)
    
    h = bar(y_barData,'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
