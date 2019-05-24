function g_viz_lab(imgFname,outputFname);

% Set some plotting parameters
ms = 10;  % Marker Size
fs = 10;  % Font size
lw = 2;  % Line width

load(outputFname);

lon_min = min(lon_gcp);
lon_max = max(lon_gcp);
lat_min = min(lat_gcp);
lat_max = max(lat_gcp);
lon_min = min(lon_min,LON0);
lon_max = max(lon_max,LON0);
lat_min = min(lat_min,LAT0);
lat_max = max(lat_max,LAT0);

fac = 0.1;
lon_min= lon_min - fac*abs(lon_max-lon_min);
lon_max= lon_max + fac*abs(lon_max-lon_min);
lat_min= lat_min - fac*abs(lat_max-lat_min);
lat_max= lat_max + fac*abs(lat_max-lat_min);

rgb0 = double(imread(imgFname))/255;

[mm nn pp] = size(rgb0);
if pp == 3
  int = (rgb0(:,:,1)+rgb0(:,:,2)+rgb0(:,:,3))/3; 
else
  int = rgb0;     
end
clear rgb0;
int = int';

hold on;

X = LON;
Y = LAT;

colormap(gray);
h = pcolor(X,Y,int);
shading('flat');


plot(LON0,LAT0,'kx','markersize',ms,'linewidth',lw);  % Camera location

%% Plot GCPs and ICPs.
for n=1:length(i_gcp)
  plot(lon_gcp(n),lat_gcp(n),'bo','markersize',ms,'linewidth',lw);
  plot(LON(i_gcp(n),j_gcp(n)),LAT(i_gcp(n),j_gcp(n)),'rx','MarkerSize',ms,'linewidth',lw);
end
