function [output1,output2,output3] = onedimgrid(varargin)
% Interpolate one-dimensional data into gridded data.
% varargin cantains {X,Y,V,'limit',[x1,x2,y1,y2],'dx',dx,'overlap',index}:
% -- X,Y,V are all one-dimension data. 
% -- limit represents the upper and the lower bound of [x1,x2,y1,y2],
%    defalut:[min(X),max(X);min(Y),max(Y)].
% -- dx(>0) is the grid points unit spacing. 
% -- the index represents the method of handling the overlap; 
%    they are:{-1 nanmin; 0 nanmean; +1 nanmax;
%              -2 nan negative mean; +2 nan positive mean},(defalut index=0).
% [бя Attention:'dx' should be inputed, while 'limit' and 'overlap' are optional!]
% Example:
% X=[1,4,1,3,1,4]
% Y=[5,1,2,3,5,5]
% V=rand(1,6)*10
% [x,y,v]=onedimgrid(X,Y,V,'dx',1); v

% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.7.29
%% Identify each quantity
X = varargin{1}; % input x; (1 dimension)
Y = varargin{2}; % input y; (1 dimension)
V = varargin{3}; % input the corresponding value ; (1 dimension)
if  length(varargin) == 9
    LIMIT=varargin{5};
    dx=varargin{7};
    index=varargin{9};
elseif length(varargin) == 7
    if isempty(findstr(varargin{4},'i')) % can not find a 'i' in varargin{4}, so varargin{4} is 'dx'
        dx=varargin{5};
        index=varargin{7};
    else % can find a 'i' in varargin{4}, so varargin{4} is 'limit'
        LIMIT=varargin{5};
        dx=varargin{7};
        index=0;
    end
elseif length(varargin) == 5
    dx=varargin{5};
    index=0;
elseif length(varargin) < 5 
    error(['  Insufficient input!'])
end
%% Determine the upper and lower bounds of the interpolation grid
if exist('LIMIT') %#ok<*EXIST> 
    x1=LIMIT(1);x2=LIMIT(2);  % assign the Upper and lower limits of X and Y
    y1=LIMIT(3);y2=LIMIT(4);
else
    x1=nanmin(X);x2=nanmax(X); % search the Upper and lower limits of X and Y
    y1=nanmin(Y);y2=nanmax(Y);
end
xx=x1:dx:x2; % create the x and y axes of the grid points
yy=y1:dx:y2;
if length(xx) >= 1000
    error(['Please consider the unit spacing ',num2str(varargin{5}),...
        ' is too small or not since the grid points is too large and the function may break out!'])
end
%% Creating grid points with value
vv=zeros(length(xx),length(yy))+NaN;
num=zeros(length(xx),length(yy)); % for counting the number of data in each grid point
for i=1:length(X)
    % if an original value outside the given bound,than skip it
    if X(i)<nanmin(xx) || X(i)>nanmax(xx)
        continue
    else
       x0=near(xx,X(i));% rounded
    end
    if Y(i)<nanmin(yy) || Y(i)>nanmax(yy)
        continue
    else
       y0=near(yy,Y(i));% rounded
    end
%     if abs(x0) > length(xx)
%         x0=sign(x0)*length(xx);
%     end
%     if abs(y0) > length(yy)
%         y0=sign(y0)*length(yy);
%     end
    % ---------------------------------------------------------------------
    if isnan(vv(x0,y0)) % directly assign the grid point for it's already NaN, otherwise sum them
        vv(x0,y0)=V(i);num(x0,y0)=1;
    else % handling the overlap
        if index == -1
            vv(x0,y0)=nanmin(vv(x0,y0),V(i));num(x0,y0)=1;   % nan min
        elseif index == 0
            vv(x0,y0)=vv(x0,y0)+V(i);num(x0,y0)=num(x0,y0)+1;% namean
        elseif index == 1
               vv(x0,y0)=nanmax(vv(x0,y0),V(i));num(x0,y0)=1;   % nan positive max
        elseif index == -2
            if V(i) <= 0
               vv(x0,y0)=vv(x0,y0)+V(i);num(x0,y0)=num(x0,y0)+1; % nan negative mean    
            end
        elseif index == 2
            if V(i) > 0
               vv(x0,y0)=vv(x0,y0)+V(i);num(x0,y0)=num(x0,y0)+1; % nan positive mean    
            end
        end
    end
end
%% Output
   % [xx,yy]=meshgrid(xx,yy);
   output1=xx;
   output2=yy;
   num(num==0)=NaN;
   output3=(vv./num)';  % averaged for multi-data in each grid point
end
