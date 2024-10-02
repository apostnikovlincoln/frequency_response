function PlotTemperaturesHT(t,T1,T2,T3)

global tm

name = strcat('HT Temperature');
fig = figure('name',name);
TabGroup = uitabgroup(fig);

global n_HT

for i=1:n_HT
    if ~isempty(T1)
        air_off = T1(:,i);
        air_on = T2(:,i);
        product = T3(:,i);
        if(isempty(TabGroup))
            figure;
        else
            name = strcat('HT',num2str(i));
            tab = uitab(TabGroup,'title',name);
            a = axes('parent', tab);
        end
        ax = gca;
        ax.Box = 'on';
        ax.FontName='Times New Roman';
        ax.Title.String = name;
        hold on
        if(isempty(TabGroup))
            plot(t,air_off)
            plot(t,air_on)
            plot(t,product) 
        else
            plot(a,t,air_off)
            plot(a,t,air_on)
            plot(a,t,product)
        end    
        legend(' Air-Off Temperature',' Air-On Temperature',...
            ' Product Temperature');
        hold off
        axis([0 length(t)*tm -5 15]);
        ylabel('T [^\circC]')
        xlabel('t [minutes]')
    end
end

end