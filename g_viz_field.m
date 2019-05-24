function [h_figure,h_pcolor,h_datetext] = g_viz_field(imgFname,rectFile,varargin)
%G_VIZ_FIELD Generates a map with a georectified image
%       G_VIZ_FIELD Generates a map with the georectified image in imgFname
%                   Converts in grayscale if needed.
%       Inputs:
%           imgFname,   filename of the image to georectify
%           rectFile,   .mat file created by g_rect
%       Parameters (name, value)
%           showTime,   Default 0, if 1, displays the timestamp of the
%                       image in the figure's title
%           showLand,   Default 0, if 'f' or 'h', displays the land contour
%                       with m_gshhs_f or m_gshhs_f
%           landcolor,  Default [241 235 144]/255, Color of the land on the
%                       map
%
%       Outputs:
%           h_figure, h_pcolor and h_datetext are the handles to the
%               corresponding objects in the figure, for use in g_viz_anim
%

show_time = 0;
show_land = 0;
land_color = [241 235 144]/255;
if length(varargin) > 1
    for i=1:2:length(varargin)
        switch lower(varargin{i})
            case 'showtime'
                show_time = varargin{i+1};
            case 'showland'
                show_land = varargin{i+1};
            case 'landcolor'
                land_color = varargin{i+1};
        end
    end
end


% Set some plotting parameters
ms = 10;  % Marker Size
fs = 10;  % Font size
lw = 2;  % Line width

load(rectFile);

%p = size(LON,3);

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

pp = size(rgb0,3);
if pp == 3
  int = g_rgb2gray(rgb0); 
else
  int = rgb0;     
end
clear rgb0;
int = int';

int = int - nanmean(nanmean(int));



m_proj('mercator','longitudes',[lon_min lon_max],'latitudes',[lat_min lat_max]);
hold on;

[X,Y] = m_ll2xy(LON,LAT);
cmap = contrast(int,256);
colormap(cmap);
h = pcolor(X,Y,int);
shading('interp');
  set(findobj(gcf, 'type','axes'), 'Visible','off')
F = getframe(gcf);
[Xj, Map] = frame2im(F);
figure,imshow(Xj);

% % Uncomment one of these lines if you want the coastline to be pltoted.
 if show_land
     if strcmpi(show_land,'f')
         m_gshhs_f('patch',land_color)
     else
         m_gshhs_h('patch',land_color)
     end
 end
% 
 if show_time
     info = imfinfo(imgFname);
     if isField(info,'DateTime')
         date = info.DateTime;
     elseif isField(info,'Comment')
         date = info.Comment;
     else
         date = '';
     end
     ht = title(date);
 end
m_plot(LON0,LAT0,'kx','markersize',ms,'linewidth',lw);  % Camera location

%% Plot GCPs and ICPs.
for n=1:length(i_gcp)
  m_plot(lon_gcp(n),lat_gcp(n),'bo','markersize',ms,'linewidth',lw);
  m_plot(LON(i_gcp(n),j_gcp(n)),LAT(i_gcp(n),j_gcp(n)),'rx','MarkerSize',ms,'linewidth',lw);
end

%title([datestr(mtime,31),' UTC']);
%title([time,' UTC']);

clear LON LAT X Y

%%%% m_grid('box','fancy','fontsize',fs);

if nargout > 1
      set(findobj(gcf, 'type','axes'), 'Visible','off')
    h_figure = gcf;
  %  h_fig_modif=Xj;
    h_pcolor = Xj;
    if nargout == 3
        h_datetext = 0;
    end
end
