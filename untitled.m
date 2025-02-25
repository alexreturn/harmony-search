close all;
figure,imshow(X);
E = entropyfilt(X);
Eim = mat2gray(E);
BW1 = im2bw(Eim, .8);
BWao = bwareaopen(BW1,2000);
nhood = true(9);
closeBWao = imclose(BWao,nhood);
roughMask = imfill(closeBWao,'holes');
figure,imshow(roughMask);
I2 = X;
I2(roughMask) = 0;
figure,imshow(I2);
E2 = entropyfilt(I2);
E2im = mat2gray(E2);
figure,imshow(E2im);
BW2 = im2bw(E2im);
mask2 = bwareaopen(BW2,1000);
figure,imshow(mask2);
texture1 = X;
texture1(~mask2) = 0;
texture2 = X;
texture2(mask2) = 0;
boundary = bwperim(mask2);
segmentResults = X;
segmentResults(boundary) = 255;
figure,imshow(segmentResults);