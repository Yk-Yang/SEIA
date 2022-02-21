function [ output ] = intersection_ratio(input1,input2,rslt)
% Calculate the intersection area of the new and old bounds, and then output 
% the ratio of the area to the old bound. Check how much the two bounds overlap.
% Basically, the grid points will be regarded as area.
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

old_bound=input1;
% x_min=min(old_bound(:,1));x_max=max(old_bound(:,1));
% y_min=min(old_bound(:,2));y_max=max(old_bound(:,2));
% x1=x_min:rslt:x_max;y1=y_min:rslt:y_max;
% [x1,y1]=meshgrid(x1,y1);
% in1=inpolygon(x1,y1,old_bound(:,1),old_bound(:,2));
% xx1=x1(in1);yy1=y1(in1); % all the points inside old bound

new_bound=input2;
% x_min=min(new_bound(:,1));x_max=max(new_bound(:,1));
% y_min=min(new_bound(:,2));y_max=max(new_bound(:,2));
% x2=x_min:rslt:x_max;y2=y_min:rslt:y_max;
% [x2,y2]=meshgrid(x2,y2);
% in2=inpolygon(x2,y2,old_bound(:,1),old_bound(:,2));
% xx2=x2(in2);yy2=y2(in2); % all the points inside new bound

x_min=min([old_bound(:,1);new_bound(:,1)]);x_max=max([old_bound(:,1);new_bound(:,1)]);
y_min=min([old_bound(:,2);new_bound(:,2)]);y_max=max([old_bound(:,2);new_bound(:,2)]);
x=x_min:rslt:x_max;y=y_min:rslt:y_max;
[x,y]=meshgrid(x,y);
in_old=inpolygon(x,y,old_bound(:,1),old_bound(:,2));
in_new=inpolygon(x,y,new_bound(:,1),new_bound(:,2));
x_old=x(in_old);y_old=y(in_old);
x_new=x(in_new);% y_new=y(in_new);
% new bound grid points inside the old bound
inter=inpolygon(x_old,y_old,new_bound(:,1),new_bound(:,2)); 

output=length(x_old(inter))/max(length(x_old),length(x_new));
end

