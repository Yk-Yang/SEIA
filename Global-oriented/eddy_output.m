function [  ] = eddy_output(eddy,path,hemi,year,polarity)
% Output dead eddy
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

k=1;
eddy_out=dir([path,'/Output/',hemi,'/',year,'/',polarity,'_*.mat']);
for i=1:length(eddy)
    time=eddy(i).time;
    if length(time)>=1
        eval([strcat(polarity,'.time'),'=eddy(i).time;'])
        if strfind(hemi,'S')==1
            cen=eddy(i).center; bou=eddy(i).bound;
            [center,bound]=correct_bound_south(cen,bou);
            eval([strcat(polarity,'.bound'),'=bound;'])
            eval([strcat(polarity,'.center'),'=center;'])
        else
            eval([strcat(polarity,'.bound'),'=eddy(i).bound;'])
            eval([strcat(polarity,'.center'),'=eddy(i).center;'])
        end
        eval([strcat(polarity,'.radius'),'=eddy(i).radius;'])
        eval([strcat(polarity,'.McS'),'=eddy(i).McS;'])
        
        switch polarity
            case  'AE'
                save([path,'/Output/',hemi,'/',year,'/',polarity,'_',num2str(length(eddy_out)+k)],'AE')
                Output_AE_no=length(eddy_out)+k
            case  'CE'
                save([path,'/Output/',hemi,'/',year,'/',polarity,'_',num2str(length(eddy_out)+k)],'CE')
                Output_CE_no=length(eddy_out)+k
        end
        k=k+1;
    else
        continue
    end
end

