function distance = g_dist(lon1,lat1,lon2,lat2,field);

% This function computes the distance (m) between two points on a
% Cartesian Earth given their lat-lon coordinate.
%
% If field = false then simple cartesian transformation
%
%

dlon = lon2 - lon1;
dlat = lat2 - lat1;

if field
    
    meterPerDegLat = 1852*60.0;
    meterPerDegLon = meterPerDegLat * cosd(lat1);
    dx = dlon*meterPerDegLon;
    dy = dlat*meterPerDegLat;
    
else
    
    dx = dlon;
    dy = dlat;
    
end

distance = sqrt(dx^2 + dy^2);

end
