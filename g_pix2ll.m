function [LON,LAT] = g_pix2ll(xp,yp,imgWidth,imgHeight,ic,jc,...
                              hfov,lambda,phi,theta,H,LON0,LAT0,field);
% G_PIX2LL Converts pixel to ground coordinates
%
% input: 
%        xp, yp:     The image coordinate
%        imgWidth:   Number of horizontal pixel of the image
%        imgHeight:  Number of vertical pixel of the image
%        ic, jc:     The number of pixel off center for the principal point
%                    (generally both set to 0)
%        hfov:       Horizontal field of view
%        lambda:     Dip angle below horizontal (straight down = 90, horizontal = 0)
%        phi:        Tilt angle clockwise around the principal axis
%        theta:      View angle clockwise from North (e.g. East = 90)
%        H:          Camera altitude (m) above surface of interest.
%        LON0, LAT0: Camera longitude and latitude position
%
% output: LAT,LON: Ground coordinates
%
% Authors:
%
% R. Pawlowicz 2002, University of British Columbia
%   Reference: Pawlowicz, R. (2003) Quantitative visualization of 
%                 geophysical flows using low-cost oblique digital 
%                 time-lapse imaging, IEEE Journal of Oceanic Engineering
%                 28 (4), 699-710.
%
% D. Bourgault 2012 - Naming convention slightly modified to match naming
%                     convention used in other part of the g_rect package.
%
%

% Earth's radius (m)
Re   = 6378135.0;

% Transformation factors for local cartesian coordinate
meterPerDegLat = 1852*60.0;
meterPerDegLon = meterPerDegLat*cosd(LAT0);

% Image aspect ratio.
aspectRatio = imgWidth/imgHeight;

% Construct the image coordinate given the width and height of the image. 
%xp = repmat([1:imgWidth]',1,imgHeight);
%yp = repmat([1:imgHeight],imgWidth,1);

[n,m] = size(xp);

% Image origin
x_c = imgWidth/2;
y_c = imgHeight/2;

% Compute the vertical angle of view (vfov) given the horizontal angle 
% of view (hfov) and the image aspect ratio. Then calculate the focal 
% length (fx, fy).
% In principle, the horizontal and vertical focal lengths are identical.
% However these may slighty differ from cameras. The calculation done here
% provides identical focal length.

vfov = 2*atand(tand(hfov/2)/aspectRatio);
fx   = (imgWidth/2)/tand(hfov/2);
fy   = (imgHeight/2)/tand(vfov/2);


% Subtract the principal point
x_p = xp - x_c + (jc);
y_p = yp - y_c + (ic);

% Divide by the focal length
xd = x_p./fx;
yd = y_p./fy;

x = xd;
y = yd;

% The rotations are performed clockwise, first around the z-axis (rot), 
% then around the already once rotated x-axis (dip) and finally around the 
% twice rotated y-axis (tilt);

% Tilt angle
R_phi =  [ cosd(-phi), -sind(-phi), 0;
           sind(-phi),  cosd(-phi), 0;
	               0,            0, 1];

% Dip angle
R_lambda = [ 1,          0,        0;
	         0, cosd(-lambda), -sind(-lambda);
	         0, sind(-lambda),  cosd(-lambda)];

% View from North
R_theta = [ cosd(-theta), 0, -sind(-theta);
	                   0, 1,           0;
	        sind(-theta), 0,  cosd(-theta)];
          
z = ones(size(x));

% Apply tilt and dip corrections

p = R_lambda*R_phi*[(x(:))';(y(:))';(z(:))'];

% Rotate towards true direction
M = R_theta*p;

% Project forward onto ground plane (flat-earth distance)
alpha = H./M(2,:);
alpha(M(2,:) < 0) = NaN; % Blanks out vectors pointing above horizon

% Need distance away and across field-of-view for auto-scaling
xx = alpha.*p(1,:);
zz = alpha.*p(3,:);

x_w = reshape(alpha.*M(1,:),n,m);
z_w = reshape(alpha.*M(3,:),n,m);

% Spherical earth corrections
Dfl2    = (x_w.^2 + z_w.^2);
Dhoriz2 = (2*H*Re);  % Distance to spherical horizon

fac             = (4*Dfl2/Dhoriz2);
fac(fac >= 1.0) = NaN;     % Points past horizon
s2f             = 2*(1 - sqrt( 1 - fac )) ./ fac;

x_w = x_w.*s2f;
z_w = z_w.*s2f;

% Convert coordinates to lat/lon using locally cartesian assumption
if field
    LON = x_w/meterPerDegLon + LON0;
    LAT = z_w/meterPerDegLat + LAT0;
else
    LON = x_w + LON0;
    LAT = z_w + LAT0;
end
