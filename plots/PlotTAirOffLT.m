function PlotTAirOffLT(t,T)

global tm

name = strcat('LT Air Off Temperature');
fig = figure('name',name);
TabGroup = uitabgroup(fig);

global n_LT

for i=1:n_LT
    if ~isempty(T)
        air_off = T(:,i);
        if(isempty(TabGroup))
            figure;
        else
            name = strcat('LT',num2str(i));
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
        else
            plot(a,t,air_off) 
        end    
        legend(' Air-Off Temperature');
        hold off
        axis([0 length(t)*tm -25 5]);
        ylabel('T [^\circC]')
        xlabel('t [minutes]')
    end
end

end