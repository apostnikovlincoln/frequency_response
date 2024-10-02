function PlotMrRateLT(t,dMrIn,dMrOut)

global tm

name = strcat('LT Mass Flow Rate');
fig = figure('name',name);
TabGroup = uitabgroup(fig);

global n_LT

for i=1:n_LT
    if ~isempty(dMrIn)
        dMrInLT = dMrIn(:,i);
        dMrOutLT = dMrOut(:,i);
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
            plot(t,dMrInLT) 
            plot(t,dMrOutLT) 
            plot(t,dMrInLT-dMrOutLT) 
        else
            plot(a,t,dMrInLT) 
            plot(a,t,dMrOutLT) 
            plot(a,t,dMrInLT-dMrOutLT) 
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