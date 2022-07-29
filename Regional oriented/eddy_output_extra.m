function [  ] = eddy_output(eddy,path,year,polarity)
% Output dead eddy
% By Yikai Yang (email: yangyikai@scsio.ac.cn), 2022.2.21

k=1;
eddy_out=dir([path,'/Output/',year,'/',polarity,'_*.mat']);
for i=1:length(eddy)
    time=eddy(i).time;
    if length(time)>=1
        eval([strcat(polarity,'.time'),'=eddy(i).time;'])
        eval([strcat(polarity,'.bound'),'=eddy(i).bound;'])
        eval([strcat(polarity,'.center'),'=eddy(i).center;'])
        eval([strcat(polarity,'.radius'),'=eddy(i).radius;'])
        eval([strcat(polarity,'.amplitude'),'=eddy(i).amplitude;'])
        eval([strcat(polarity,'.eke'),'=eddy(i).eke;'])
        eval([strcat(polarity,'.vorticity'),'=eddy(i).vorticity;'])
        eval([strcat(polarity,'.McS'),'=eddy(i).McS;'])
        switch polarity
            case  'AE'
                save([path,'/Output/',year,'/',polarity,'_',num2str(length(eddy_out)+k)],'AE')
                Output_AE_no=length(eddy_out)+k
            case  'CE'
                save([path,'/Output/',year,'/',polarity,'_',num2str(length(eddy_out)+k)],'CE')
                Output_CE_no=length(eddy_out)+k
        end
        k=k+1;
    else
        continue
    end
end

