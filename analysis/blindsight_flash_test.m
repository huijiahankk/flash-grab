
clear all;
% huangwenxiang1 only have the illusion to the normal vision field
% huangwenxiang  have the data in both directions  the flash on the edge 
sbjnames = {'wuzhigang'} ;



%----------------------------------------------------------------------
%                blind field test
%----------------------------------------------------------------------

addpath '../function';
cd '../data/illusionSize/corticalBlindness/bar/blindField/'



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
    
    blindFieldUpper = mean(data.wedgeTiltEachBlock(1,:))
    blindFieldLower = mean(data.wedgeTiltEachBlock(2,:))
    
       
end

