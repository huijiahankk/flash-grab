% generate stim time course for fMRI data analysis  mainL.txt 

cd '../data/3T/main_exp/';
% cd '../data/3T/control/';

sbjname = 'wangjiazhen'; % 'dingyingshi' 'zhangzixiao' 'xuepeng' 'wangyidan' 'wangjiazhen'
runNum = '4';
FileName = strcat(sbjname,'_',runNum,'*.mat');
Files = dir(FileName);
load (Files.name);
% stimtypeNew = stimtype(find(stimtype~=0));
% % stimtypeNew == 1  illusion left ;   stimtypeNew == 2 illusion right
% mainLflashTimePointActu = round(flashTimePoint(stimtypeNew == 2));
% mainLflashTimePoint = mainLflashTimePointActu'

mainLflashTimePoint_left = [];
mainLflashTimePoint_right = [];
for i = 1:numel(flashTimePoint)
    % background 180 for 1s    so left and right condition should happen at
    % the time when odd and even 
    if mod(round(flashTimePoint(i)),2)>0  % stimtype == 1  illusion left    odd number=left
        mainLflashTimePoint_left = [mainLflashTimePoint_left round(flashTimePoint(i))];
    else                                  % stimtype == 2 illusion right    even number=right
        mainLflashTimePoint_right = [mainLflashTimePoint_right round(flashTimePoint(i))];
    end
end
mainLflashTimePoint_left
mainLflashTimePoint_right

cd '../data/3T/localizer/';
sbjname = 'wangyidan';
runNum = '2';
FileName = strcat(sbjname,'_',runNum,'*.mat');
Files = dir(FileName);
load (Files.name);


localizerflashtimepoint_left = (find(localizerMat(1:20) == 1) - 1) * 16 %flash left

localizerflashtimepoint_right = (find(localizerMat(1:20) == 2) - 1) * 16 %flash left


localizerflashtimepoint_left'
localizerflashtimepoint_right'
