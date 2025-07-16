function [ ] = SEIA(main_path,hemi,yr,rslt,mask_n,mask_s,min_points,max_points_lat,Dt,Rt)
% Main detection procedure of SEIA
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

for h=1:2
    str_sla=dir([main_path,'/SLA/',hemi(h,:),'/SLA_*.mat']);
    if h==1; mask=mask_n; else; mask=mask_s; end
for year=1:length(str_sla)
    load([main_path,'/SLA/',hemi(h,:),'/',str_sla(year).name]) % lon lat sla Time 
    SLA=sla;LON=lon;LAT=lat;TIME=time; clear lon lat sla Time % the VERY original infos
    if h==2 % splice of the Southern data
        wh=near(LON,291.5);  % ¡ï Artificially defined boundary: from Cape Horn to the Antarctic continent
        SLA=[SLA(wh+1:end,:,:);SLA(1:wh,:,:)];   
        mask=[mask(:,wh+1:end),mask(:,1:wh)];
        lon_ori=[LON(wh+1:end);LON(1:wh)];
    end
for day=1:length(TIME(:,1))
%% search peak points and extract qualified sla contours
year_day=[year,day]
sla0=squeeze(SLA(:,:,day)); sla0=sla0.*mask';
% peak points
[x_max,y_max]=gridnanpeak(LON,LAT,sla0,'max');
[x_min,y_min]=gridnanpeak(LON,LAT,sla0,'min');
% produce closed contours
ctr=contourc(double(LON),double(LAT),sla0',...
    [nanmin(nanmin(sla0)):0.01:-0.025,0.025:0.01:nanmax(nanmax(sla0))]);% the AVISO SLA error of approximately 0.03 m?
% extract closed contours
k=1;ori=1;points=0;
while ori<=length(ctr)
    points=ctr(2,ori+points);
    llon=ctr(1,ori+1:ori+points);llat=ctr(2,ori+1:ori+points);
    llon=LON(arrayfun(@(x) near(LON,x),llon)); % trace back to the original grids
    llat=LAT(arrayfun(@(x) near(LAT,x),llat));
    [llon,llat]=unique_points(llon,llat);      % remove repatitive points
    max_points=max_points_lat(near(1:70,nanmean(llat))); % determine max points by latitude    
    if length(llon)>=min_points && length(llon)<=max_points && ...
            (llon(1)==llon(end) && llat(1)==llat(end)) % ¡ï Closed contour
        sla_c(k).lon=llon; sla_c(k).lat=llat; k=k+1;
    end
    ori=ori+points+1;
    points=0;
end
%% AE: detect the original snapshot
% preset raw ae struct array
ae_cir(length(x_max))=struct('time',[ ],'bound',[ ],'center',[ ],...
                              'radius',[ ],'McS',[ ],'alive',[ ]); % multi-core structure (McS)
                          
% search a biggest contour for each peak                          
occupy_num=[ ];
for i=1:length(sla_c)
    llon=sla_c(i).lon;llat=sla_c(i).lat;
    in=inpolygon(x_max,y_max,llon,llat);
    in2=inpolygon(x_min,y_min,llon,llat); % check minimuns fall in AE contours or not
    [~,lo]=find(in==1);
    if sum(in2)==0 && length(lo)==1 % ¡ï Mononuclear
        occupy_num=[occupy_num,i];  % qualified closed contours
        bound0=cell2mat(ae_cir(lo).bound); 
        if length(llon)>length(bound0)    % 
            ae_cir(lo).time=TIME(day,:);  % datenum(TIME(day,:),'yyyymmdd');
            ae_cir(lo).bound={[llon,llat]};
            ae_cir(lo).center=[x_max(lo),y_max(lo)];     % take peak as center
            % ae_cir(lo).center=[mean(llon),mean(llat)]; % tacke centroid as center
            ae_cir(lo).radius=radius_compute(x_max(lo),y_max(lo),llon,llat); % compute radius
        end
     elseif sum(in2)==0 && length(lo)>=2 % ¡ï Polyonuclear: >=2
        polynuclear=num2cell(zeros(length(lo),1)+1);
        [ae_cir(lo).McS]=polynuclear{:}; % 1: suspected; 0: not suspected   
    end
end

% remove unmatched peaks and contours
sla_c(occupy_num)=[ ];
ae_cir(arrayfun(@(ae_cir) isempty(ae_cir.bound) && isempty(ae_cir.center),ae_cir))=[ ];

% asign mononuclear info
mononuclear_lo=arrayfun(@(ae_cir) isempty(ae_cir.McS),ae_cir);
mononuclear=num2cell(zeros(length(mononuclear_lo),1));
[ae_cir(mononuclear_lo).McS]=mononuclear{:};

% asign alive info
alive=num2cell(zeros(length(ae_cir),1)+1);
[ae_cir(:).alive]=alive{:};  % 1 = alive, 0 = dead

%% AE: tracking
if day==1 && year==1
    ae=ae_cir;
else
    ae_num=length(ae); clear old_center % the number of existed ae
    for m=1:ae_num % all the centers from the former time step
        old_center(m,:)=ae(m).center(end,:);
    end
    clear new_center new_bound index dis ratio wh track track_no new
    for n=1:length(ae_cir)
        new_center=ae_cir(n).center;new_bound=cell2mat(ae_cir(n).bound);
        [index,dis]=near(old_center,new_center,1); % find the 2 colsest centers
        for k=1:length(index)
            if isnan(dis(k)) || dis(k)>Dt % beyond the max searching distance
                ratio(k)=NaN;
            else
                old_bound=ae(index(k)).bound{end};
                ratio(k)=intersection_ratio(old_bound,new_bound,rslt);% intersection ratio
            end
        end
        [~,wh]=max(ratio);
        if ~isnan(ratio(wh)) && max(ratio)>=Rt % ¡ï successfully tracked
            track=index(wh);track_no(n)=track;
            if ae(track).alive==-1 % missing in the last time step, change the Replaced infos
                mbou=mean_bound(ae(track).bound(end),ae_cir(n).bound,LON,LAT); % construct the misssing bound
                ae(track).bound(end)={mbou};
                ae(track).center(end,:)=mean(mbou); % centroid
                ae(track).radius(end)=radius_compute(mean(mbou(:,1)),mean(mbou(:,2)),mbou(:,1),mbou(:,2));
            end
            ae(track).time=[ae(track).time;ae_cir(n).time];
            ae(track).bound=[ae(track).bound;ae_cir(n).bound];
            ae(track).center=[ae(track).center;ae_cir(n).center];
            ae(track).radius=[ae(track).radius;ae_cir(n).radius];
            ae(track).McS=[ae(track).McS;ae_cir(n).McS];
            ae(track).alive=1;
            old_center(track,:)=[NaN,NaN]; % remove the tracked eddy to avoid cross tracking
        else % ¡ï a new-born eddy
            new=length(ae)+1;
            ae(new).time=ae_cir(n).time;
            ae(new).bound=ae_cir(n).bound;
            ae(new).center=ae_cir(n).center;
            ae(new).radius=ae_cir(n).radius;
            ae(new).McS=ae_cir(n).McS;
            ae(new).alive=1;
        end
    end
    missing_no=setdiff([1:ae_num],track_no); % old eddies that are not tracked 
    for i=missing_no % ¡ï failed to be tracked
        alive=ae(i).alive;
        if alive==1 % alive in the last time step
            ae(i).time=[ae(i).time;(ae(i).time(end))+1]; 
            ae(i).bound=[ae(i).bound;ae(i).bound(end)];  % match with last eddy info
            ae(i).center=[ae(i).center;ae(i).center(end,:)];
            ae(i).radius=[ae(i).radius;ae(i).radius(end)];
            ae(i).McS=[ae(i).McS;ae(i).McS(end)];
            ae(i).alive=-1; % allow it to be missing for one time step
        elseif  alive==-1   % also missing in the last time step
            ae(i).time(end)=[ ]; % remove the Replaced infos
            ae(i).bound(end)=[ ];
            ae(i).center(end,:)=[ ];
            ae(i).radius(end)=[ ];
            ae(i).McS(end)=[ ];
            ae(i).alive=0;  % punish to be dead
        end
    end
    % ¡ï ouput dead ae
    if year==length(str_sla) && day==length(TIME)
        ae_dead=ae;
    else
        ae_dead=ae(arrayfun(@(x) x.alive==0,ae));
    end  
    ae=ae(arrayfun(@(x) x.alive~=0,ae)); % continue to be tracked
    
    if ~isempty(ae_dead)
        % ¡ï the Southern hemisphere splice issue
        if h==2
           ae_dead=lon_correct(ae_dead,LON,lon_ori);
        end
        
        eddy_output(ae_dead,main_path,hemi(h,:),yr(year,:),'AE');
        clear ae_dead
    end
end
%% CE: detect the original snapshot 
% preset raw ce struct array
ce_cir(length(x_min))=struct('time',[ ],'bound',[ ],'center',[ ],...
                              'radius',[ ],'McS',[ ],'alive',[ ]);
% search a biggest contour for each peak     
for i=1:length(sla_c)
    llon=sla_c(i).lon;llat=sla_c(i).lat;
    in=inpolygon(x_min,y_min,llon,llat);
    in2=inpolygon(x_max,y_max,llon,llat); 
    [~,lo]=find(in==1);
    if sum(in2)==0 && length(lo)==1 
        bound0=cell2mat(ce_cir(lo).bound); 
        if length(llon)>length(bound0)
            ce_cir(lo).time=TIME(day,:);% datenum(TIME(day,:),'yyyymmdd');
            ce_cir(lo).bound={[llon,llat]};
            ce_cir(lo).center=[x_min(lo),y_min(lo)]; 
            % ce_cir(lo).center=[mean(llon),mean(llat)];
            ce_cir(lo).radius=radius_compute(x_min(lo),y_min(lo),llon,llat);
        end
    elseif sum(in2)==0 && length(lo)>=2 
        polynuclear=num2cell(zeros(length(lo),1)+1);
        [ce_cir(lo).McS]=polynuclear{:}; % 1: suspected; 0: not suspected      
    end
end

% remove unmatched peaks and contours
ce_cir(arrayfun(@(x) isempty(x.bound)&&isempty(x.center),ce_cir))=[ ]; 

% asign mononuclear info
mononuclear_lo=arrayfun(@(ce_cir) isempty(ce_cir.McS),ce_cir);
mononuclear=num2cell(zeros(length(mononuclear_lo),1));
[ce_cir(mononuclear_lo).McS]=mononuclear{:};

% asign alive info
alive=num2cell(zeros(length(ce_cir),1)+1);
[ce_cir(:).alive]=alive{:};  % 1 = alive, 0 = dead

%% CE: tracking
if day==1 && year==1
    ce=ce_cir;
else
    ce_num=length(ce); clear old_center % the number of existed ce
    for m=1:ce_num % all the centers from the former time step
        old_center(m,:)=ce(m).center(end,:);  % ce(:).center(end,:)
    end
    clear new_center new_bound index dis ratio wh track track_no new
    for n=1:length(ce_cir)
        new_center=ce_cir(n).center;new_bound=cell2mat(ce_cir(n).bound);
        [index,dis]=near(old_center,new_center,1); % find the 2 colsest centers
        for k=1:length(index)
            if isnan(dis(k)) || dis(k)>Dt % beyond the max searching distance
                ratio(k)=NaN;
            else
                old_bound=ce(index(k)).bound{end};
                ratio(k)=intersection_ratio(old_bound,new_bound,rslt);% intersection ratio
            end
        end
        [~,wh]=max(ratio);
        if ~isnan(ratio(wh)) && max(ratio)>=Rt % ¡ï successfully tracked
            track=index(wh);track_no(n)=track;
            if ce(track).alive==-1 % missing in the last time step, change the Replaced infos
                mbou=mean_bound(ce(track).bound(end),ce_cir(n).bound,LON,LAT); % construct the misssing bound
                ce(track).bound(end)={mbou};
                ce(track).center(end,:)=mean(mbou); % centroid
                ce(track).radius(end)=radius_compute(mean(mbou(:,1)),mean(mbou(:,2)),mbou(:,1),mbou(:,2));
            end
            ce(track).time=[ce(track).time;ce_cir(n).time];
            ce(track).bound=[ce(track).bound;ce_cir(n).bound];
            ce(track).center=[ce(track).center;ce_cir(n).center];
            ce(track).radius=[ce(track).radius;ce_cir(n).radius];
            ce(track).McS=[ce(track).McS;ce_cir(n).McS];
            ce(track).alive=1;
            old_center(track,:)=[NaN,NaN]; % remove the tracked eddy to avoid cross tracking
        else % ¡ï a new-born eddy
            new=length(ce)+1;
            ce(new).time=ce_cir(n).time;
            ce(new).bound=ce_cir(n).bound;
            ce(new).center=ce_cir(n).center;
            ce(new).radius=ce_cir(n).radius;
            ce(new).McS=ce_cir(n).McS;
            ce(new).alive=1;
        end
    end
    missing_no=setdiff([1:ce_num],track_no); % old eddies that are not tracked 
    for i=missing_no % ¡ï failed to be tracked
        alive=ce(i).alive;
        if alive==1  % alive in the last time step
            ce(i).time=[ce(i).time;(ce(i).time(end))+1]; 
            ce(i).bound=[ce(i).bound;ce(i).bound(end)]; % match with last eddy info
            ce(i).center=[ce(i).center;ce(i).center(end,:)];
            ce(i).radius=[ce(i).radius;ce(i).radius(end)];
            ce(i).McS=[ce(i).McS;ce(i).McS(end)];
            ce(i).alive=-1; % allow it to be missing for one time step
        elseif  alive==-1   % also missing in the last time step
            ce(i).time(end)=[ ]; % remove the Replaced infos
            ce(i).bound(end)=[ ];
            ce(i).center(end,:)=[ ];
            ce(i).radius(end)=[ ];
            ce(i).McS(end)=[ ];
            ce(i).alive=0;  % punish to be dead
        end
    end
    
    % ¡ï ouput dead ce
    if year==length(str_sla) && day==length(TIME)
        ce_dead=ce;
    else
        ce_dead=ce(arrayfun(@(x) x.alive==0,ce));
    end
    ce=ce(arrayfun(@(x) x.alive~=0,ce)); % continue to be tracked
    if ~isempty(ce_dead)
        % ¡ï the Southern hemisphere splice issue
        if h==2
           ce_dead=lon_correct(ce_dead,LON,lon_ori);
        end
        
        eddy_output(ce_dead,main_path,hemi(h,:),yr(year,:),'CE');
        clear ce_dead
    end
end
close all
clear ctr x_max y_max x_min y_min sla_c ae_cir ce_cir
end
end
end

end

