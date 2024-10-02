function PlotTEvapHT(t,T)

global tm

name = strcat('HT Evaporation Temperature');

Tevap = T(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,Tevap)   
legend(' Evaporation Temperature');
hold off
axis([0 length(t)*tm -25 15]);
ylabel('T_{e} [^\circC]')
xlabel('t [minutes]')

end