 function [index,distance]=near(x,x0,n)
 % NEAR  finds the indices of x that are closest to the point x0.  
 % function [index,distance]=near(x,x0,[n]);  
 %     x is an array, x0 is a point, n is the number of closest points to get  
 %     (in order of increasing distance).  Distance is the abs(x-x0)  
 % rsignell@usgs.gov    
 if nargin==2       
     n=1;  
 end
 
 % Modified by Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21
 [a,b]=size(x0);
 if a==1 && b==1
     [distance,index]=sort(abs(x-x0));
 else
     [distance,index]=sort(sqrt((x(:,1)-x0(1)).^2+(x(:,2)-x0(2)).^2));
 end
 

 distance=distance(1:n);  
 index=index(1:n);    
 end