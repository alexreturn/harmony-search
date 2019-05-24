% Se carga la imagen RGB o escala de grises
load('rect.mat');
I = b; 
%I=imread('newImageCorrect.jpg');   
%I=imadjust(I,[],[],1.3);
I=rgb2gray(I);
A=I;

%%%%% OTSU SAJA %%%%
%levelOTSU = graythresh(I)
%BWOTSU = imbinarize(I,levelOTSU);
%imshow(BWOTSU);
[counts,x] = imhist(I,16);
stem(x,counts)
T = otsuthresh(counts);
BW = imbinarize(I,T);


%%%%%%%%%%%%%%%%

  Iout = BW;

lo=edge(double(Iout),'canny');
testro=lo;
[I2, rect]=imcrop(testro,[326 362 604 168]);
I_rot = I;
[labeledImage, numberOfRegions] = bwlabel(I2, 8);

%%%%%%%%%%%

nRows = size(I_rot,1);
nCols = size(I_rot,2);
rowshift=362;
colshift=326;
lineFin=false(nRows,nCols);
I2=double(I2);
z=(1:size(I2,1))+double(rowshift);
s= (1:size(I2,2))+double(colshift);
lineFin(z, s, :) = I2;


rgb = imoverlay(I, lineFin, [1 0 0.5]);
imshow(rgb);

%% 