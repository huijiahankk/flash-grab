function CFSMatMovie=GenerateCFS(dx, dy, frames)
% This program generates and saves CFS
% GenerateCFS(dx, dy, frames)
% GenerateCFS(120, 120, 100)
% Yi Jiang, Vision and Attention Lab, University of Minnesota
repetition=500;
patchcolor=[255 0 0; 255 255 0; 0 255 0; 0 0 255; 255 0 128; 0 255 255; 255 128 0; 128 0 255; 0 128 255; 128 0 128];
% patchcolor(:,1)=[1:255];patchcolor(:,2)=[1:255];patchcolor(:,3)=[1:255];
patchx=[1:dx/4]; patchy=[1:dy/4];
for j=1:frames
    pic=zeros(dy,dx,3);
    for k=1:repetition
    patchdx=randsample(patchx,10); patchdy=randsample(patchy,10);
    patchcenter1=randsample(1:dy,10); patchcenter2=randsample(1:dx,10);
    patchdy1=round(patchcenter1-patchdy/2); if patchdy1<1 patchdy1=1; end
    patchdy2=round(patchcenter1+patchdy/2); if patchdy2>dy patchdy2=dy; end
    patchdx1=round(patchcenter2-patchdx/2); if patchdx1<1 patchdx1=1; end
    patchdx2=round(patchcenter2+patchdx/2); if patchdx2>dx patchdx2=dx; end
    samplecolor=patchcolor(Sample(1:size(patchcolor,1)),:);
    for i=1:3
    pic(patchdy1:patchdy2,patchdx1:patchdx2,i)=samplecolor(i);
    end
    end
%     imwrite(pic/255,['maskimg' int2str(j) '.bmp']);
    CFSMatMovie{j}=pic;
end
save CFSMatMovie.mat CFSMatMovie
return