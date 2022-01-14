function ftfilt=makeGaussianMask(r, center_r1, blur_win_r1, center_r2, blur_win_r2)
ftfilt1 = normpdf(r,center_r1,blur_win_r1); %
ftfilt1 = ftfilt1./max(max(ftfilt1));
ftfilt2 = normpdf(r,center_r2,blur_win_r2);
ftfilt2 = ftfilt2./max(max(ftfilt2));
filtmask1 = ones(size(r));
filtmask1(find(r>center_r1&r<center_r1+10*blur_win_r1))= 0;
ftfilt1 = ftfilt1.*filtmask1;
filtmask2 = ones(size(r));
filtmask2(find(r>center_r2-10*blur_win_r2&r<center_r2))= 0;
ftfilt2 = ftfilt2.*filtmask2;
ftfilt3 = zeros(size(r));
ftfilt3(find(r>center_r1&r<center_r2))= 1;
ftfilt=ftfilt1+ftfilt2+ftfilt3;
ftfilt(find(ftfilt>1))=1;
% figure;imshow(ftfilt1);
% figure;imshow(ftfilt2);
% figure;imshow(ftfilt3);
% figure;imshow(ftfilt);
return