function [eddy] = cal_amp_eke_vor(eddy,min_points,rslt)
% Calculation of amplitude, eke and vorticity by geostrophic approximation
% See the following paper for more details:
% Xing, T., & Yang, Y., 2020. Three mesoscale eddy detection and tracking 
% methods: Assessment for the South China Sea. JAOT, 243иC258.

% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.7.29

% for calculation of amplitude, eke and vorticity
ga=9.8; % Gravitational acceleration, unit:m/s^2
eras=7.292e-5; % earth rotation angle speed, unit:rad/s
er=6371e3; % earth radius, unit:m
 
for i=1:length(eddy)
    bound=eddy(i).bound;
    if isempty(bound); continue; end
    amplitude=eddy(i).amplitude;
    
    xx0=[ ]; yy0=[ ]; zz0=[ ];
    for j=1:length(bound)
        bou=cell2mat(bound(j)); bou_len(j)=length(bou);
        xx0=[xx0;bou(:,1)]; yy0=[yy0;bou(:,2)]; 
        zz0=[zz0;zeros(length(bou(:,1)),1)+amplitude(j)];
    end
    
    % Select the largest contour as the boundary
    [num,wh]=max(bou_len); bou_len=[ ];
    if num < min_points % the largest one doesn't fit for the scale-selective scheme
       eddy(i).center=[ ]; eddy(i).bound=[ ]; % marked to be removed afterwards
       continue
    end
    
    % бя Interpolation of a 1D unordered sequence to a 2D grid array
    % The output zz below is the sla distribution inside eddy
    [xx,yy,zz]=onedimgrid(xx0,yy0,zz0,'dx',rslt); 
    ug=[ ]; vg=[ ]; vor=[ ];
    for m=1:length(yy)-1
        for n=1:length(xx)-1 % geostrophic velocity anomaly
            ug(m,n)=-(ga/(2*eras*sind(yy(m))))*((zz(m+1,n)-zz(m,n))/(rslt*2*pi*er/360));
            vg(m,n)=(ga/(2*eras*sind(yy(m))))*((zz(m,n+1)-zz(m,n))/(rslt*2*pi*er*cosd(yy(m))/360));
        end
    end
    for m=1:length(yy)-2
        for n=1:length(xx)-2 % vorticity
            vor(m,n)=(vg(m,n+1)-vg(m,n))/(rslt*2*pi*er*cosd(yy(m))/360)-...
                     (ug(m+1,n)-ug(m,n))/(rslt*2*pi*er/360);
%             div(m,n)=(ug(m,n+1)-ug(m,n))/(rslt*2*pi*er*cosd(yy(m))/360)+... % divergence
%                 (vg(m+1,n)-vg(m,n))/(rslt*2*pi*er/360);
        end
    end
    eddy(i).bound={bound{wh}};
    eddy(i).radius=eddy(i).radius(wh);
    eddy(i).amplitude=nanmean(nanmean(zz));
    eddy(i).eke=nansum(nansum((ug.^2+vg.^2)/2));
    eddy(i).vorticity=nansum(nansum(vor));
end
end

