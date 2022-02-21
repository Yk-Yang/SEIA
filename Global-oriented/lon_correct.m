function [output] = lon_correct(eddy,lon_splice,lon_ori)
% correcct the longitude because of the Southern hemisphere splice issue
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

for i=1:length(eddy)
    bound=eddy(i).bound; center=eddy(i).center;
    
    center(:,1)=lon_ori(arrayfun(@(x) near(lon_splice,x),center(:,1)));
    
    for j=1:length(bound)
        bou=bound{j};
        bou(:,1)=lon_ori(arrayfun(@(x) near(lon_splice,x),bou(:,1)));
        bound{j}=bou;
    end
    eddy(i).bound=bound; eddy(i).center=center;
end
   output=eddy;
end

