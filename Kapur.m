%Diego Oliva, Erik Cuevas, Gonzalo Pajares, Daniel Zaldivar y Marco Perez-Cisneros
%Multilevel Thresholding Segmentation Based on Harmony Search Optimization
%Universidad Complutense de Madrid / Universidad de Guadalajara

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The algorithm was published in:
%Diego Oliva, Erik Cuevas, Gonzalo Pajares, Daniel Zaldivar, and Marco Perez-Cisneros, 
%“Multilevel Thresholding Segmentation Based on Harmony Search Optimization,” 
%Journal of Applied Mathematics, vol. 2013, 
%Article ID 575414, 24 pages, 2013. doi:10.1155/2013/575414
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fitR = Kapur(m,level,xR,PI)

%Metodo de Entropia de Kapur
fitR = zeros(1,m);
for j = 1: m
    PI0 = PI(1:xR(j,1)); % probabilidad de la primer clase
    ind = PI0 == 0;
    ind = ind .* eps;
    PI0 = PI0 + ind;
    clear ind
    w0 =  sum(PI0); %w0 de la primer clase
    H0 = -sum((PI0/w0).*(log2(PI0/w0)));
    fitR(j) = fitR(j) + H0;
    
    for jl = 2: level
        PI0 = PI(xR(j,jl-1)+1:xR(j,jl)); % probabilidad de la primer clase
        ind = PI0 == 0;
        ind = ind .* eps;
        PI0 = PI0 + ind;
        clear ind
        w0 =  sum(PI0); %w0 de la primer clase
        H0 = -sum((PI0/w0).*(log2(PI0/w0)));
        fitR(j) = fitR(j) + H0;
    end  
end








