function PlotMrRateHT(t,dMrIn,dMrOut)

global tm

name = strcat('HT Mass Flow Rate');
fig = figure('name',name);
TabGroup = uitabgroup(fig);

global n_HT

for i=1:n_HT
    if ~isempty(dMrIn)
        dMrInHT = dMrIn(:,i);
        dMrOutHT = dMrOut(:,i);
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
            plot(t,dMrInHT) 
            plot(t,dMrOutHT) 
            plot(t,dMrInHT-dMrOutHT) 
        else
            plot(a,t,dMrInHT) 
            plot(a,t,dMrOutHT) 
            plot(a,t,dMrInHT-dMrOutHT) 
        end    
        legend(' dM_{ref} at Evap Inlet', ' dM_{ref} at Evap Outlet', ...
            ' M_{ref} accumulation rate');
        hold off
        axis([0 length(t)*tm -0.02 0.04]);
        ylabel('dM_{ref} [kg/s]')
        xlabel('t [minutes]')
    end
end

end