clear; close all; clc

cd G:\SCSEddy\ÎÐÐýÕï¶Ï\Closed_Streamline\SEIA\SEIA_regional
%% 
% The automatic scale?selective eddy identification algorithm (SEIA).
%--------------------------------------------------------------------------  
%  Author: Yikai Yang (yangyikai@scsio.ac.cn) 
%  [Ver 1  Jan 2022]
%  Please cite correctly:
%  Yang, Y., Zeng, L. & Wang, Q. Assessment of global eddies from satellite
%  data by a scale-selective eddy identification algorithm (SEIA). Clim Dyn
%  62, 881¨C894 (2024).
%--------------------------------------------------------------------------
% Main_program.m
%  |
%  |--> topo_mask.m
%  |
%  |--> SEIA.m
%  |     |
%  |     |--> gridnanpeak.m
%  |     |--> radius_compute.m
%  |     |--> intersection_ratio.m
%  |     |--> mean_bound.m
%  |     |--> eddy_output.m
%--------------------------------------------------------------------------
%  Note: Please ensure that the SLA data you prepare is consistent with the sample.
%  Note: You need the global topo data named ETOPO1.mat which will be used by
%  topo_mask.m containning 'lon (m)', 'lat (n)' and 'topo (mxn)'.
%% Preset path and parameters
% the path with profiles named 'SLA', 'Output' and 'SEIA'
main_path='G:\SEIA_regional'  

% For regional SEIA, SLA data will be categorized by year and 
% ¡ï should include infos of 'lon', 'lat', 'sla' and 'Time(datenum)'.
yr=num2str((1993)');

rslt=0.25; % resolution of input SLA data, unit:degree

% longitude better varies from 0 to 360 degree but not -180 to 180 degree
area=[99.875 123.375 0.125 29.875];   % [lonmin lonmax latmin latmax]
area=[108 121 4 24];
mask_depth=50; % unit:m
mask=topo_mask(main_path,area,rslt,mask_depth);

c=1;     % error-compensating correction
L=150;  % half of the mesoscale, unit: km
r=6371;         % earth radius (km)
d=2*pi*r*cosd(1:70)/360;      % distance per degree by latitude (km)
min_points=10;                   % lower grid points of eddy boundary
max_points_lat=floor(2*pi*L./(rslt*d))+c; % upper grid points by latitude

% among the tracking procedure
Dt=1.25;  % the largest searching distance of the nearest eddies
Rt=0.25;  % the overlapping ratio

%% Run the SEIA
SEIA(main_path,yr,rslt,mask,...
     min_points,max_points_lat,Dt,Rt)
 
 
 
 

