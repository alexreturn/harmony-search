
clc;
load('rect.mat');
I = b;      % read image
I = imadjust(I,[],[],1.3);
T = graythresh(I)               % find the threshold for input image
S = im2bw(I,T);                 % Segment the image using thresholding
% [Path,File] = uiputfile('*.jpg');% Save the thresholded image with .jpg extention
% imwrite(S,[File,Path]);         % Save the thresholded image to the specified path
%subplot(1,2,1),imshow(I),title('Original Image');
%subplot(1,2,2),imshow(S),title('Thresholded Image');
BWao = bwareaopen(S,50);
nhood = true(4);
closeBWao = imclose(BWao,nhood);
%figure,imshow(closeBWao);
%lo=edge(double(closeBWao),'Canny',[],1);
 lo=canny(double(closeBWao),2);
%figure,imshow(lo);
Iss=X;
rgb = imoverlay(Iss, lo, [1 0 0.5]);
%figure,imshow(rgb),title('Hasil');
