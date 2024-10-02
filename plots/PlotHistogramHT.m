function PlotHistogramHT(t,T)

global tm

name = strcat('HT Cases');

avg_air_off = T(:);


figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,avg_air_off)
legend(' Avg Air Off');
hold off
axis([0 length(t)*tm -5 15]);
ylabel('T [^\circC]')
xlabel('t [minutes]')

end