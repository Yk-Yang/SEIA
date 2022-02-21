function [x,y] = gridnanpeak(lon,lat,qua,peak)
% Search grid points for peaks (max/min) and output their location(lon,lat).
% peak
% - 'max':searching for maximum points
% - 'min':searching for minimum points
% num
% - 8: the neighbour 8 points
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

x=[ ];y=[ ];
for i=2:length(lon)-1
    for j=2:length(lat)-1
        qua0=qua(i,j); qua_n=qua(i-1:i+1,j-1:j+1);
        switch peak
            case 'max'
                if qua0==nanmax(qua_n(:)) && sum(isnan(qua_n(:)))==0 % && qua0>0
                    x=[x,lon(i)];y=[y,lat(j)];
                end
            case 'min'
                if qua0==nanmin(qua_n(:)) && sum(isnan(qua_n(:)))==0 % && qua0<0
                    x=[x,lon(i)];y=[y,lat(j)];
                end
        end
        clear qua0 qua_n
    end
end
end

