function PlotAmbientTemp(t,T)

global tm

name = strcat('Ambient Temperature');

ambient = T(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,ambient)
legend(' Ambient Temperature');
hold off
axis([0 length(t)*tm 5 30]);
ylabel('T [^\circC]')
xlabel('t [minutes]')

end