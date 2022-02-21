function [radius] = radius_compute(center_x,center_y,bound_x,bound_y)
% Compute the radius based on center and bound data with 'mean distance'method.
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

for i=1:length(bound_x)
    distance(i)=sqrt((center_x-bound_x(i))^2+(center_y-bound_y(i))^2);
end
   radius=roundn(nanmean(distance),-3);
end

