function [mbound] = mean_bound(bound1,bound2,lon,lat)
% Calculate the boundary of re-tracked eddy by neighbor eddies.
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

bound1=cell2mat(bound1);bound2=cell2mat(bound2);
if length(bound1(:,1))<length(bound2(:,2))
   exchange=bound1;
   bound1=bound2;bound2=exchange;
end
for i=1:length(bound1(:,1))
    [wh,~]=near(bound2,bound1(i,:),1); % help find the nearest points
    mx=mean([bound1(i,1),bound2(wh,1)]);
    my=mean([bound1(i,2),bound2(wh,2)]);
    mlon(i)=lon(near(lon,mx));
    mlat(i)=lat(near(lat,my));
end
[u_lon,u_lat]=unique_points(mlon,mlat);
mbound=[u_lon,u_lat];
end

