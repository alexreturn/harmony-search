%function Delta = g_res(LON,LAT,i,j,field);
function [Delta DeltaX DeltaY] = g_res(LON,LAT,i,j,field);

[m n] = size(LON);

if i == 1
  Delta1 = g_dist(LON(i+1,j),LAT(i+1,j),LON(i,j),LAT(i,j),field);
elseif i == m
  Delta1 = g_dist(LON(i,j),LAT(i,j),LON(i-1,j),LAT(i-1,j),field);
else
  Delta1 = g_dist(LON(i+1,j),LAT(i+1,j),LON(i-1,j),LAT(i-1,j),field);
  Delta1 = Delta1/2;  
end

if j == 1
  Delta2 = g_dist(LON(i,j+1),LAT(i,j+1),LON(i,j),LAT(i,j),field);
elseif j == n
  Delta2 = g_dist(LON(i,j),LAT(i,j),LON(i,j-1),LAT(i,j-1),field);
else
  Delta2 = g_dist(LON(i,j+1),LAT(i,j+1),LON(i,j-1),LAT(i,j-1),field);
  Delta2 = Delta2/2;  
end

Delta = sqrt(Delta1^2 + Delta2^2);
DeltaX = sqrt(Delta1^2);
DeltaY = sqrt(Delta2^2);

end