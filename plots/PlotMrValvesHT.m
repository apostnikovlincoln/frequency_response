function PlotMrValvesHT(t,Mr,Valves)

global tm

name = strcat('HT Mass of Refrigerant & Valves');
fig = figure('name',name);
TabGroup = uitabgroup(fig);

global n_HT

for i=1:n_HT
    if ~isempty(Mr)
        Mref = Mr(:,i);
        OD = Valves(:,i);
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
            yyaxis left   
            ax.FontName='Times New Roman';
            plot(t,Mref,'g','Color',[0.3,0.7,0])
            axis([0 length(t)*tm -2 3]);
            ylabel('M_{ref} [kg]')

            yyaxis right
            ax.FontName='Times New Roman';
            plot(t,OD*100,'g','Color',[0.8,0.8,0.8])
            axis([0 length(t)*tm -100 200]);
            ylabel('Valve %')
        else
            yyaxis left  
            ax.FontName='Times New Roman';   
            plot(a,t,Mref,'g','Color',[0.3,0.7,0])
            axis([0 length(t)*tm -2 3]);
            ylabel('M_{ref} [kg]')

            yyaxis right
            ax.FontName='Times New Roman';   
            plot(a,t,OD*100,'g','Color',[0.8,0.8,0.8])
            axis([0 length(t)*tm -100 200]);
            ylabel('Valve %')
        end 

        legend(' M_{ref}',' Valve %');

        hold off

        xlabel('t [minutes]')
    end
end

end