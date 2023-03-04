function [center,bound] = correct_bound_south(cen0,bou0)
%  Transform the splicing longitude to normal longitude in the South Hemisphere
%  By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

% center-----------------------------------------------------------
center=cen0; cen=cen0(:,1);
[a,~]=find(cen<68.625);
center(a,1)=cen0(a,1)+291.625;
[a,~]=find(cen>=68.625);
center(a,1)=cen0(a,1)-68.625;
% each day of an eddy bound----------------------------------------
bound=bou0;
for n=1:length(bou0)
    bou=bou0{n};
    lon_tem=bou(:,1); % temporary
    lon1=zeros(length(lon_tem),1);
    [a,~]=find(lon_tem<68.625);
    if ~isempty(a)
        lon1(a)=lon1(a)+291.625;
    end
    lon2=zeros(length(lon_tem),1);
    [a,~]=find(lon_tem>=68.625);
    if ~isempty(a)
        lon2(a)=lon2(a)-68.625;
    end
    lon_tem=lon_tem+lon1+lon2;
    bound{n}(:,1)=lon_tem;
end

end

