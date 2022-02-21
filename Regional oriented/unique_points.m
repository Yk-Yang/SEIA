function [output_lon,output_lat] = unique_points(llon,llat)
% Find unique points with original boundary points because
% the overlap issuce occurs when the interpoalted contour points
% are traced back to the original boundary points.
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

x=llon(1:end-1);y=llat(1:end-1); % for searching unique points
output_lon=[ ];output_lat=[ ];
for i=1:length(x)
    lon=llon(i);lat=llat(i);
    same=intersect(find(x==lon),find(y==lat)); % find all the same points
    if isempty(same) % the overlap points are removed in the x and y already
        continue
    else
        output_lon=[output_lon;x(same(1))]; % only take one out of them
        output_lat=[output_lat;y(same(1))];
        x(same)=[ ]; y(same)=[ ]; % and remove the rest of the same points
    end
end
% make sure not to break the closed
output_lon(end+1)=llon(end);
output_lat(end+1)=llat(end);
end

