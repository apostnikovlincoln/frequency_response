function PlotTotalMrRateLT(t,dMr)

global tm

name = strcat('Mass Flow Rate to LT Suction Lines');

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
axis([0 length(t)*tm -0.15 0.3]);
ylabel('dM_{ref} [kg/s]')
xlabel('t [minutes]')

end