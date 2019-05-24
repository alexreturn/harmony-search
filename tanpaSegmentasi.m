function [rgb,coast_line,vpsnr,vstds,vmse,lvlthres,BwInver,BwOpen,segmimg,histimg] = Mth_HS1()
%Diego Oliva, Erik Cuevas, Gonzalo Pajares, Daniel Zaldivar y Marco Perez-Cisneros
%Multilevel Thresholding Segmentation Based on Harmony Search Optimization
%Universidad Complutense de Madrid / Universidad de Guadalajara

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The algorithm was published in:
%Diego Oliva, Erik Cuevas, Gonzalo Pajares, Daniel Zaldivar, and Marco Perez-Cisneros, 
%?Multilevel Thresholding Segmentation Based on Harmony Search Optimization,? 
%Journal of Applied Mathematics, vol. 2013, 
%Article ID 575414, 24 pages, 2013. doi:10.1155/2013/575414
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Intructions:
% I -> Original Image, could be RGB or Gray Scale
% level -> Number of threshold to find
% This version works with KAPUR as fitness function.


% Se carga la imagen RGB o escala de grises
load('rect.mat');
I = b; 
%I=imread('newImageCorrect.jpg');   
%I=imadjust(I,[],[],1.3);
I=rgb2gray(I);
A=I;

% lvlthres=2;
% BwInver=32;
% BwOpen=400;


%I=Output;

%I2 = imcrop(I,[90 143 325 92]);


%figure, imshow(I2);
%I=I2;
level = lvlthres;
% Se obtienen los histogramas si la imagen es RGB uno por cada canal si es
% en escala de grises solamente un historgrama.
if size(I,3) == 1 %grayscale image
    [n_countR, x_valueR] = imhist(I(:,:,1));
elseif size(I,3) == 3 %RGB image
    %histograma para cada canal RGB
    [n_countR, x_valueR] = imhist(I(:,:,1));
    [n_countG, x_valueG] = imhist(I(:,:,2));
    [n_countB, x_valueB] = imhist(I(:,:,3));
end
disp(n_countR);

disp(x_valueR);
Nt = size(I,1) * size(I,2); %Cantidad total de pixeles en la imagen RENG X COL
%Lmax niveles de color a segmentar 0 - 256
Lmax = 256;   %256 different maximum levels are considered in an image (i.e., 0 to 255)

% Distribucion de probabilidades de cada nivel de intensidad del histograma 0 - 256 
for i = 1:Lmax
    if size(I,3) == 1 
        %grayscale image
        probR(i) = n_countR(i) / Nt;
    elseif size(I,3) == 3 
        %RGB image    
        probR(i) = n_countR(i) / Nt;
        probG(i) = n_countG(i) / Nt;
        probB(i) = n_countB(i) / Nt;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parametros del problema de segmentacion
N_PAR = level; %number of thresholds (number of levels-1) (dimensiones)
ndim = N_PAR;  

%Parametros Harmony Search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MaxAttempt = 25000;  % Max number of Attempt
% Initial parameter setting
HS_size = 50;        %Length of solution vector
HMacceptRate = 0.95; %HM Accepting Rate
PArate = 0.5;        %Pitch Adjusting rate

if size(I,3) == 1 
    %Imagen escala de grises
    range = ones(ndim,2);
    range(:,2) = range(:,2) * Lmax;
    
    %initializa harmony memory
    HM = zeros(HS_size,ndim);
    
    % Pitch range for pitch adjusting
    pa_range = ones(ndim);
    pa_range = pa_range * 100;
elseif size(I,3) == 3
    %Imagen RGB
    range = ones(ndim,2);
    range(:,2) = range(:,2) * Lmax;
    %IR
    xR = zeros(HS_size,ndim);
    %IG
    xG = zeros(HS_size,ndim);
    %IB
    xB = zeros(HS_size,ndim);
end


C_Func = 0;
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generating Initial Solution Vector
for i = 1:HS_size,
    for j = 1:ndim,
        x(j) = range(j,1) + (range(j,2) - range(j,1)) * rand;
    end
    x = fix(sort(x));
    HM(i, :) = x;
end %% for i

    %evalua x en la funcion objetivo
     %[HMbest, fitBestR] = fitnessIMG(I, HS_size, Lmax, level, HM, probR);
%     C_Func = length(HMbest);
    
    HMbest = Kapur(HS_size,level,HM,probR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting the Harmony Search
for count = 1:MaxAttempt,
    for j = 1:ndim,
        if (rand >= HMacceptRate)
            % New Search via Randomization   <--- prob 1-HCMR
            x(j) = range(j,1) + (range(j,2) - range(j,1)) * rand;
        else
            % Harmony Memory Accepting Rate
            x(j) = HM(fix(HS_size * rand) + 1,j); %<--- prob HMCR
            if (rand <= PArate)
                % Pitch Adjusting in a given range
                pa = (range(j,2) - range(j,1)) / pa_range(j);
                x(j) = x(j) + pa * (rand - 0.5);
            end
        end
        if x(j) >= range(j,2), x(j) = range(j,2); end
        if x(j) <= range(j,1), x(j) = range(j,2); end
    end %% for j
    % Evaluate the new solution
    %evalua x en la funcion objetivo
    x = fix(sort(x));
    %evalua x en la funcion objetivo
    %[fbest, fitBestR] = fitnessIMG(I, 1, Lmax, level, x, probR);
    fbest = Kapur(1,level,x,probR);
    C_Func = C_Func + 1;
    
    
    % Find the best in the HS solution vector   
    [HStemp, ii] = sort(HMbest, 'descend'); %Maximiza
    HMbest = HMbest(ii);
    HM = HM(ii,:);
    
    % Updating the current solution if better
    if fbest > HMbest(HS_size), %maximiza
        HM(HS_size, :) = x;
        HMbest(HS_size) = fbest;
    end
    solution = x;   % Record the solution
    %Obtiene los mejores valores de cada attempt y los alamacena
    [mm,ii] = max(HMbest); %maximiza
    Fit_bests(count) = mm; %Mejores Fitness
    HS_elem(count,:) = HM(ii,1:ndim-1); %Mejores Elementos de HM
    HS_bestit = HM(ii,1:ndim-1); %Guarda el mejor HS
    HS_bestF = mm; %Guarda el mejor fitness
    
   % Output the results  to screen
   str=strcat('Best estimates: =',num2str(HS_bestit));
   str=strcat(str,'  fmin='); str=strcat(str,num2str(HS_bestF));
   str=strcat(str,'  Iteration='); str=strcat(str,num2str(count));
   disp(str);   
   
   %Save the best values that will be chek in the stop criterion
   if count == 1  || HS_bestF > HS_ant
        HS_ant = HS_bestF;
        cc = 0;
   elseif HS_bestF == HS_ant
        cc = cc + 1;
   end
   
   if cc > (MaxAttempt * 0.10)
       break;
   end
   
end %% for count (harmony search)
toc
%plot fitness
plot(Fit_bests)

%Prepare results to be show
 gBestR = sort(HS_bestit);
%    Iout = imageGRAY(I);
    Iout = mat2gray(I);
    imshow(Iout);
    figure,imshow(Iout),title('Segmentasi');
    %Show results
    intensity = gBestR(1:ndim-1)     
    STDR =  std(Fit_bests)      %Standar deviation of fitness       
    MEANR = mean(Fit_bests)     %Mean of fitness
    MSE = immse(I, imageGRAY(I,gBestR )) 
    PSNRV = PSNR(I, Iout)       %PSNR between original image I and the segmented image Iout
    
    vpsnr=PSNR(I, Iout);
    vstds=std(Fit_bests);
    vmse=immse(I, imageGRAY(I,gBestR ));
  
    
    Fit_bests(count)            %Best fitness
    %Show results on images
   
bw=A;
 
%s = 25;
%for c = 1:s
%    bw=Iout;
%    bw(Iout<c)=0;
%%    bwInverse = ~bw;
%    figure,imshow(bwInverse),title(c);
%end

bw(Iout<BwInver)=0;
bwInverse = ~bw;
bwpure=bwareaopen(bwInverse,BwOpen);
%figure,imshow(bwpure),title('bwareaopen');
bwpure=imfill(bwpure,'holes');
%figure,imshow(Iout);
imgDisk = imdilate(bwpure,strel('disk',8)); 
%figure,imshow(imgDisk),title('imgDisk');
%lo=canny(double(bwpure));
lo=edge(double(imgDisk),'canny');
testro=lo;
[I2, rect]=imcrop(testro,[167 280 573 54]);
I_rot = I;

imwrite(bwInverse,'binerisasi.jpg','jpg','Comment','My JPEG file')
imwrite(bwareaopen(bwInverse,BwOpen),'bwareaopen.jpg','jpg','Comment','My JPEG file')
imwrite(imfill(bwpure,'holes'),'bwpure.jpg','jpg','Comment','My JPEG file')
imwrite(imgDisk,'imgDisk.jpg','jpg','Comment','My JPEG file')
imwrite(lo,'Canny.jpg','jpg','Comment','My JPEG file')
imwrite(imcrop(testro,[169 294 569 78]),'Crop.jpg','jpg','Comment','My JPEG file')

[labeledImage, numberOfRegions] = bwlabel(I2, 8);


%%%%% OTSU SAJA %%%%
%levelOTSU = graythresh(I)
%BWOTSU = imbinarize(I,levelOTSU);
%imshow(BWOTSU);

%%%%%%%% KAPUR %%%%%

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


%%%%%%%%%%%

% 
% 
% I2=imrotate(I2,30);
% %I2 = imcrop(lo,[90 143 325 92]);
% 
%    %figure,     imshow(I2);
% nRows = size(Iout,1);
% nCols = size(Iout,2);
% rowshift=143;
% colshift=90;
% lineFin=false(nRows,nCols);
% I2=double(I2);
% z=(1:size(I2,1))+double(rowshift);
% s= (1:size(I2,2))+double(colshift);
% lineFin(z, s, :) = I2;
% 
%     %Iout=im2bw(Iout,gBestR);
%   % figure,   imshow(lineFin);
%    
% Iss=X; 167 
nRows = size(I_rot,1);
nCols = size(I_rot,2);
rowshift=280;
colshift=167;
lineFin=false(nRows,nCols);
I2=double(I2);
z=(1:size(I2,1))+double(rowshift);
s= (1:size(I2,2))+double(colshift);
lineFin(z, s, :) = I2;

lf=lineFin;
data_ref=load('frame_referensi.mat');
line_sebelumnya=data_ref.lf;

rgb2 = imoverlay(I, line_sebelumnya, [1 1 0.5]);
rgb3 = imoverlay(rgb2, lf, [1 0 0.5]);
figure,imshow(rgb3),title('Perbandingan Garis Sebelumnya');
rgb = imoverlay(I, lf, [1 0 0.5]);
%imshow(rgb3);
segmimg=Iout;
histimg=imhist(Iout);

imwrite(Iout,'CitraSegmentasi.jpg','jpg','Comment','My JPEG file')
imwrite(rgb,'CitraDeteksi.jpg','jpg','Comment','My JPEG file')
imwrite(I,'CitraRectivikasi.jpg','jpg','Comment','My JPEG file')
imwrite(rgb3,'CitraGabung.jpg','jpg','Comment','My JPEG file')

%figure, imhist(I),title('Histogram x');
%figure, imhist(Iout),title('Histogram Segmentasi');

%imshow(Iout), colormap(gray), colorbar
%histogram(Iout(:),256,'FaceColor',[.64 .64 .64],'EdgeColor',[.64 .64 .64])
%set(gca,'XLim',[0 255])
%set(gca,'YLim',[0 15000])
%grid on

imwrite(imhist(I),'Histogramx.jpg','jpg','Comment','My JPEG file')
imwrite(imhist(Iout),'HistogramSegmentasi.jpg','jpg','Comment','My JPEG file')
coast_line=lf;

disp(lvlthres)
     disp(BwInver)
      disp(BwOpen)
%     
  %  lo=canny(double(Iout));
   %  figure,   imshow(rgb);
  
    %Plot the threshold values over the histogram
%     figure 
%     plot(probR)
%     hold on
%     vmax = max(probR);
%     for i = 1:ndim-1
%         %line([intensity(i), intensity(i)],[0 vmax],[1 1],'Color','r','Marker','.','LineStyle','-')
%         %plot(lineas(i,:))
%         hold on
%     end
%      hold off


