sbjnames = { 'maguangquan1','maguangquan2' };

for sbjnum = 1:length(sbjnames)
    s1 = string(sbjnames(sbjnum));
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(s3);
    load (Files.name);
    
       
    bar_only_new(sbjnum,:) = bar_only;
    off_sync_new(sbjnum,:) = off_sync;
    flash_grab_new(sbjnum,:)  = flash_grab;
    
end

 savePath =    
filename = [savePath,filename];
% save(filename2,'data','back');
save(filename2);
    
    
