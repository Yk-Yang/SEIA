clear; close all; clc

%% Preset path and parameters
% the path with profiles named 'SLA', 'Output' and 'SEIA'
main_path='F:\SCSEddy\ÎÐÐýÕï¶Ï\Closed_Streamline\SEIA\SEIA_global'  

% For global SEIA, SLA data will be seperated into the North and South 
% hemisphere with corresponding profiles in the 'SLA' profile.
hemi=['North';'South']; 
yr=num2str((2015:2015)');

rslt=0.25; % resolution of input SLA data, unit:degree

% longitude better varies from 0 to 360 degree but not -180 to 180 degree
area_n=[0.125 359.875 0.125 65.125];   % [lonmin lonmax latmin latmax]
area_s=[0.125 359.875 -65.125 -0.125]; % [lonmin lonmax latmin latmax]

mask_depth=50; % unit:m
mask_n=topo_mask(main_path,area_n,rslt,mask_depth);
mask_s=topo_mask(main_path,area_s,rslt,mask_depth);

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
SEIA(main_path,hemi,yr,rslt,mask_n,mask_s,...
     min_points,max_points_lat,Dt,Rt)
 
 
 
 

