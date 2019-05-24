
% Se carga la imagen RGB o escala de grises
load('rect.mat');
I = b; 
%I=imread('newImageCorrect.jpg');   
%I=imadjust(I,[],[],1.3);
I=rgb2gray(I);
A=I;

[n,m]=size(I);
    h=imhist(I);
    %normalize the histogram ==>  hn(k)=h(k)/(n*m) ==> k  in [1 256]
    hn=h/(n*m);
    %Cumulative distribution function
	c(1) = hn(1);
    for l=2:256
        c(l)=c(l-1)+hn(l);
    end
    hl = zeros(1,256);
    hh = zeros(1,256);
    for t=1:256
        %low range entropy
        cl=double(c(t));
        if cl>0
            for i=1:t
                if hn(i)>0
                    hl(t) = hl(t)- (hn(i)/cl)*log(hn(i)/cl);                      
                end
            end
        end
        
        %high range entropy
        ch=double(1.0-cl);  %constraint cl+ch=1
        if ch>0
            for i=t+1:256
                if hn(i)>0
                    hh(t) = hh(t)- (hn(i)/ch)*log(hn(i)/ch);
                end
            end
        end
    end
    
    % choose best threshold
	h_max =hl(1)+hh(1)
	threshold = 0;
    entropie(1)=h_max;
    for t=2:256
        entropie(t)=hl(t)+hh(t);
        if entropie(t)>h_max
            h_max=entropie(t);
            threshold=t-1;
        end
    end
    % Display    
    I1 = zeros(size(I));
    I1(I<threshold) = 0;
    I1(I>threshold) = 255;
   % imshow(I1) ;  
    
    
    Iout = I1;

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
