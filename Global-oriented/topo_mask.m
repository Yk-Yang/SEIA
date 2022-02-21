function mask = topo_mask(path,area,rslt,mask_depth) 
% Output a topo mask based the given control depth and resolution.
% Shallower than control depth will be masked as nan, while as 1.
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

% Cutoff corresponding data from ETOPO1------------------------------------
lonmin=area(1);lonmax=area(2);latmin=area(3);latmax=area(4);
load([path,'/ETOPO1.mat']); % lon lat topo
% Find the two closest points and remove one under interpolation principle
xmin=near(lon,lonmin,2); xmin(arrayfun(@(x) lon(x)>lonmin,xmin))=[ ];
xmax=near(lon,lonmax,2); xmax(arrayfun(@(x) lon(x)<lonmax,xmax))=[ ];
ymin=near(lat,latmin,2); ymin(arrayfun(@(y) lat(y)>latmin,ymin))=[ ];
ymax=near(lat,latmax,2); ymax(arrayfun(@(y) lat(y)<latmax,ymax))=[ ];
lon=lon(xmin:xmax);
lat=lat(ymin:ymax);
data=topo(xmin:xmax,ymin:ymax);
% Interp-------------------------------------------------------------------
[lon,lat] = meshgrid(lon,lat);
[longrid,latgrid] = meshgrid(lonmin:rslt:lonmax,latmin:rslt:latmax); 
interp_topo=-interp2(lon,lat,data',longrid,latgrid);
% Masking------------------------------------------------------------------
index1=find(interp_topo<mask_depth);interp_topo(index1)=nan;
index2=find(interp_topo>=mask_depth);interp_topo(index2)=1;
mask=interp_topo;


