clear; close all; clc

cd F:\SCSEddy\ÎÐÐýÕï¶Ï\Closed_Streamline\SEIA\SEIA_regional
%% Preset path and parameters
% the path with profiles named 'SLA', 'Output' and 'SEIA'
main_path='F:\SCSEddy\ÎÐÐýÕï¶Ï\Closed_Streamline\SEIA\SEIA_regional'  

% For regional SEIA, SLA data will be categorized by year and 
% ¡ï should include infos of 'lon', 'lat', 'sla' and 'Time(datenum)'.
yr=num2str((1993)');

rslt=0.25; % resolution of input SLA data, unit:degree

% longitude better varies from 0 to 360 degree but not -180 to 180 degree
area=[99.875 123.375 0.125 29.875];   % [lonmin lonmax latmin latmax]

mask_depth=50; % unit:m
mask=topo_mask(main_path,area,rslt,mask_depth);

c=1;     % error-compensating correction
L=125;  % half of the mesoscale, unit: km
r=6371;         % earth radius (km)
d=2*pi*r*cosd(1:70)/360;      % distance per degree by latitude (km)
min_points=10;                   % lower grid points of eddy boundary
max_points_lat=floor(2*pi*L./(rslt*d))+c; % upper grid points by latitude

% among the tracking procedure
Dt=1.25;  % the largest searching distance of the nearest eddies
Rt=0.25;  % the overlapping ratio

%% Run the SEIA
% Additional output eddy amplitude, EKE and vorticity and
% additional calls to functions cal_amp_eke_vor and onedimgrid
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.7.29
SEIA_extra(main_path,yr,rslt,mask,...
           min_points,max_points_lat,Dt,Rt)
 
 
 
 
