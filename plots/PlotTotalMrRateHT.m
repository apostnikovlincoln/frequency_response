function PlotTotalMrRateHT(t,dMr)

global tm

name = strcat('Mass Flow Rate to HT Suction Lines');

dMr = dMr(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,dMr)   
legend(' Mass Flow Rate');
hold off
axis([0 length(t)*tm -0.2 0.5]);
ylabel('dM_{ref} [kg/s]')
xlabel('t [minutes]')

end