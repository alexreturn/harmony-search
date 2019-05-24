function g_rect(imgname,lvlthres,BwInver,BwOpen)
%G_RECT - Main function for georectifying oblique images.
%
% Syntax:  Simply type g_rect at the command line and follow the
%          instructions.
%
% Inputs:
%    The function G_RECT reads an input parameter file that contains all 
%     information required to perfrorm a georectification of a given image. 
%     The format of this parameter file is detailed on-line on the G_RECT 
%     Wiki page.
%
% Outputs:
%    The function G_RECT creates an output file that contains the following 
%    variables: 
%
%        imgFname:      The reference image for the georectification.
%
%        firstImgFname: The first image of a sequence of images to which the
%                       georectification could be applied to. This is really
%                       just a comment. 
%
%        lastImgFname: The last image of a sequence of images to which the
%                      georectification could be applied to. This is really
%                      just a comment.
%
%        LON:          The main matrix that contain the longitude of each 
%                      pixel of the referecne image (imgFname). Note that
%                      if the package is used to rectify lab images this 
%                      matrix rather contains the distance in meters from
%                      a predefined x-origin. 
%                       
%        LAT:          Same as LON but for the latitude.
% 
%        LON0:         A scalar for the longitude of the camera or, in the 
%                      case of a lab setup its cartesian coordinate in meters.  
%                       
%        LAT0:         Same as LON0 but for the latitude.
%            
%        lon_gcp:      A vector containing the longitude of each ground 
%                      control points (GCP). For the lab case this is the 
%                      cartesian coordinate in meters. 
%                       
%        lat_gcp:      Same as lon_gcp for latitude.
%
%        i_gcp:        The horizontal index of the image ground control
%                      points.
%         
%        j_gcp:        The vertical index of the image ground control
%                      points.
%         
%        hfov:         The camera horizontal field of view [degree].
%
%        phi:          Camera tilt angle [degree].
%
%        H:            The camera altitude relative to the water [m].
%
%        theta:        View angle clockwise from North [degree].
%
%
%        errGeoFit:    The rms error of the georectified image after
%                      geometrical transformation [m].
%
%        errPolyFit:   The rms error of the georectified image after
%                      geometrical transformation and the polynomial 
%                      correction [m].
%
%        precision:    Calculation can be done in single or double
%                      precisions as defined by the user in the parameter
%                      file. With today's computers this is now obsolete 
%                      and calculations can always be done in double 
%                      precision.
%
%
% Other m-files required: Works best with the m_map package for
%                         visualization.
% Subfunctions: all functions contained within the G_RECT folder.
% MAT-files required: none
% 
% Author: Daniel Bourgault
%         Institut des sciences de la mer de Rimouski
% email: daniel_bourgault@uqar.ca 
% Website: http://demeter.uqar.ca/g_rect/
% February 2013
%

%
% The minimization is repeated nMinimize times where each time a random 
% combination of the initial guesses is chosen within the given
% uncertainties provided by the user. This is becasue the algorithm often 
% converges toward a local minimum. The repetition is used to increase chances
% that the minimum found is a true minimum within the uncertainties provided.  
nMinimize = 50;


%% Read the parameter file
% Count the number of header lines before the ground control points (GCPs)
% The GCPs start right after the variable gcpData is set to true.

display('  ');  
display('  Welcome to g_rect: a package for georectifying oblique images on a flat ocean');  
display('  Authors: Daniel Bourgault and Rich Pawlowicz');  
display('  ');  
prompt = {'  Enter the filename for the input parameters: ','s'};
dlg_title = 'Input';
num_lines = 1;
% inputFname1 = inputdlg(prompt,dlg_title,num_lines);
% display(inputFname1{1});
% inputFname2 = input('  Enter the filename for the input parameters: ','s');  
% display(inputFname2);
inputFname='pantaimatahariTimexBaru.dat';
fid = fopen(inputFname);
 
nHeaderLine = 0;
gcpData = false;

% Read and execute each line of the parameter file until gcpData = true
% after which the GCP data appear and are read below with the importdata
% function.
while gcpData == false
   eval(fgetl(fid));
   nHeaderLine = nHeaderLine + 1;
end
fclose(fid);
%imgFname= imgname;
%firstImgFname =imgname;
%lastImgFname= imgname;

%% Import the GCP data (4 column) at the end of the parameter file
gcp = importdata(inputFname,' ',nHeaderLine);
i_gcp   = gcp.data(:,1);
j_gcp   = gcp.data(:,2);
lon_gcp = gcp.data(:,3);
lat_gcp = gcp.data(:,4);
ngcp    = length(i_gcp);

% Get the image size
imgInfo   = imfinfo(imgFname);
imgWidth  = imgInfo.Width;
imgHeight = imgInfo.Height;

if precision == 'single'
  imgWidth  = single(imgWidth);
  imgHeight = single(imgHeight);
end


%% Display information 
fprintf('\n')
fprintf('  INPUT PARAMETERS\n')
fprintf('    Image filename: (imgFname):........... %s\n',imgFname)
fprintf('    First image: (firstImgFname):......... %s\n',firstImgFname)
fprintf('    Last image: (lastImgFname):........... %s\n',lastImgFname)
fprintf('    Output filename: (outputFname):....... %s\n',outputFname);
fprintf('    Image width (imgWidth):............... %i\n',imgWidth)
fprintf('    Image width (imgHeight):.............. %i\n',imgHeight)
fprintf('    Camera longitude (LON0):.............. %f\n',LON0)
fprintf('    Camera latitude (LAT0):............... %f\n',LAT0)
fprintf('    Principal point offset (ic):.......... %f\n',ic)
fprintf('    Principal point offset (jc):.......... %f\n',jc)
fprintf('    Field of view (hfov):................. %f\n',hfov)
fprintf('    Dip angle (lambda):................... %f\n',lambda)
fprintf('    Tilt angle (phi):..................... %f\n',phi)
fprintf('    Camera altitude (H):.................. %f\n',H)
fprintf('    View angle from North (theta):........ %f\n',theta)
fprintf('    Uncertainty in hfov (dhfov):.......... %f\n',dhfov)
fprintf('    Uncertainty in dip angle (dlambda):... %f\n',dlambda)
fprintf('    Uncertainty in tilt angle (dphi):..... %f\n',dphi)
fprintf('    Uncertainty in altitude (dH):......... %f\n',dH)
fprintf('    Uncertainty in view angle (dtheta):... %f\n',dtheta)
fprintf('    Polynomial order (polyOrder):......... %i\n',polyOrder)
fprintf('    Number of GCPs (ngcp):................ %i\n',ngcp)
fprintf('    Precision (precision):................ %s\n',precision)
fprintf('    Field or lab (field=true; lab=false):. %i\n',field)
fprintf('\n')

% Display the image with GCPs;
% image(imread(imgFname));
imagesc(imread(imgFname));
colormap(gray);
for i = 1:ngcp
  text(i_gcp(i),j_gcp(i),num2str(i),'color','r','horizontalalignment','center');
end
title('Ground Control Points','color','r');

%print -dpng image1.png

%fprintf('\n')
% ok = input('Is it ok to proceed with the rectification (y/n): ','s');
% if ok ~= 'y'
%   return
%   %break
% end

%%

nUnknown = 0;
if dhfov   > 0.0; nUnknown = nUnknown+1; end
if dlambda > 0.0; nUnknown = nUnknown+1; end
if dphi    > 0.0; nUnknown = nUnknown+1; end
if dH      > 0.0; nUnknown = nUnknown+1; end
if dtheta  > 0.0; nUnknown = nUnknown+1; end

if nUnknown > ngcp
  fprintf('\n')
  fprintf('WARNING: \n');  
  fprintf('         The number of GCPs is < number of unknown parameters.\n');  
  fprintf('         Program stopped.\n');
  %break
  return
end

% Check for consistencies between number of GCPs and order of the polynomial 
% correction
ngcp = length(i_gcp);
if ngcp < 3*polyOrder
  fprintf('\n')
  fprintf('WARNING: \n');  
  fprintf('         The number of GCPs is inconsistent with the order of the polynomial correction.\n');  
  fprintf('         ngcp should be >= 3*polyOrder.\n');  
  fprintf('         Polynomial correction will not be applied.\n');  
  polyCorrection = false;
else
  polyCorrection = true;
end
if polyOrder == 0
  polyCorrection = false;
end

%% This is the main section for the minimization algorithm

if nUnknown > 0
    
  % Options for the fminsearch function. May be needed for some particular
  % problems but in general the default values should work fine.  
  %options=optimset('MaxFunEvals',100000,'MaxIter',100000);
  %options=optimset('MaxFunEvals',100000,'MaxIter',100000,'TolX',1.d-12,'TolFun',1.d-12);
  options = [];
  
    
  % Only feed the minimization algorithm with the GCPs. xp and yp are the
  % image coordinate of these GCPs.
  xp = i_gcp;
  yp = j_gcp;

  % This is the call to the minimization
  bestErrGeoFit = Inf;
  
  % Save inital guesses in new variables. 
  hfovGuess   = hfov;
  lambdaGuess = lambda;
  phiGuess    = phi;
  HGuess      = H;
  thetaGuess  = theta;
  
  for iMinimize = 1:nMinimize
      
      % First guesses for the minimization
      if iMinimize == 1
          hfov0   = hfov; 
          lambda0 = lambda; 
          phi0    = phi; 
          H0      = H;
          theta0  = theta;
      else
          % Select randomly new initial guesses within the specified
          % uncertainties.
          hfov0   = (hfovGuess - dhfov)     + 2*dhfov*rand(1); 
          lambda0 = (lambdaGuess - dlambda) + 2*dlambda*rand(1); 
          phi0    = (phiGuess - dphi)       + 2*dphi*rand(1); 
          H0      = (HGuess - dH)           + 2*dH*rand(1);
          theta0  = (thetaGuess - dtheta)   + 2*dtheta*rand(1);
      end
  
      % Cretae vector cv0 for the initial guesses. 
      i = 0;
      if dhfov > 0.0
          i = i+1;
          cv0(i) = hfov0;
          theOrder(i) = 1;
      end
      if dlambda > 0.0
          i = i + 1;
          cv0(i) = lambda0;
          theOrder(i) = 2;
      end
      if dphi > 0.0
          i = i + 1;
          cv0(i) = phi0;
          theOrder(i) = 3;
      end
      if dH > 0.0
          i = i + 1;
          cv0(i) = H0;
          theOrder(i) = 4;
      end
      if dtheta > 0.0
          i = i + 1;
          cv0(i) = theta0;
          theOrder(i) = 5;
      end

      [cv, errGeoFit] = fminsearch('g_error_geofit',cv0,options, ...
                                  imgWidth,imgHeight,xp,yp,ic,jc,...
                                  hfov,lambda,phi,H,theta,...
                                  hfov0,lambda0,phi0,H0,theta0,...
                                  hfovGuess,lambdaGuess,phiGuess,HGuess,thetaGuess,...
                                  dhfov,dlambda,dphi,dH,dtheta,...
                                  LON0,LAT0,...
                                  i_gcp,j_gcp,lon_gcp,lat_gcp,...
                                  theOrder,field);

                              
      if errGeoFit < bestErrGeoFit
          bestErrGeoFit = errGeoFit;
          cvBest = cv;
      end
      
      fprintf('\n')
      fprintf('  Iteration # (iMinimize):                       %i\n',iMinimize);
      fprintf('  Max. number of iteration (nMinimize):          %i\n',nMinimize);
      fprintf('  RSM error (m)  for this iteration (errGeoFit): %f\n',errGeoFit);
      fprintf('  Best RSM error (m) so far (bestErrGeoFit):     %f\n',bestErrGeoFit);
      
  end
  
 
  
  fprintf('\n')
  fprintf('PARAMETERS AFTER GEOMETRICAL RECTIFICATION \n')
  fprintf('  Field of view (hfov):            %f\n',hfov)
  fprintf('  Dip angle (lambda):              %f\n',lambda)
  fprintf('  Tilt angle (phi):                %f\n',phi)
  fprintf('  Camera altitude (H):             %f\n',H)
  fprintf('  View angle from North (theta):   %f\n',theta)
  fprintf('\n')

  if length(theOrder) > 1
    fprintf('The rms error after geometrical correction (m): %f\n',bestErrGeoFit);
  end
  
end

%%  

% Now construct the matrices LON and LAT for the entire image using the 
% camera parameters found by minimization just above.

% Camera coordinate of all pixels
xp = repmat([1:imgWidth]',1,imgHeight);
yp = repmat([1:imgHeight],imgWidth,1);

% Transform camera coordinate to ground coordinate.
[LON LAT] = g_pix2ll(xp,yp,imgWidth,imgHeight,ic,jc,...
                     hfov,lambda,phi,theta,H,LON0,LAT0,field);


%% Apply polynomial correction if requested.
if polyCorrection == true
  [LON LAT errPolyFit] = g_poly(LON,LAT,LON0,LAT0,i_gcp,j_gcp,lon_gcp,lat_gcp,polyOrder,field);
  fprintf('The rms error after polynomial stretching (m):  %f\n',errPolyFit)
else
  errPolyFit = NaN;
end
%%

fprintf('\n')
fprintf('Saving rectification file in: %s\n',outputFname);

errGeoFit = 0.0;


save(outputFname,'imgFname','firstImgFname','lastImgFname','lvlthres','BwInver','BwOpen',...
                 'LON','LAT',...
                 'LON0','LAT0',...
                 'lon_gcp','lat_gcp',...
                 'i_gcp','j_gcp',...
                 'hfov','lambda','phi','H','theta',...
                 'errGeoFit','errPolyFit',...
                 'precision');

clear LON LAT
set(findobj(gcf, 'type','axes'), 'Visible','off')

fprintf('\n')
fprintf('Making figure\n');
figure;

if field
   [a,b,~]= g_viz_field(imgFname,outputFname);
else
    g_viz_lab(imgFname,outputFname);
end
F = getframe(gcf);
[X, Map] = frame2im(F);

%close gcf;
%hfig = imgcf;

%figure;imshow(X,Map),title('X');
imshow(b,Map);

imwrite(b,'CitraRectivikasi.jpg','jpg','Comment','My JPEG file')
    figure,imshow(b,Map),title('Rectification Image');
save('rect.mat');
%figure,imshow(X),title('Coba');

%figure,imshow(),title();   
%figure,imshow(image2.png);
%print -dpng image212.png