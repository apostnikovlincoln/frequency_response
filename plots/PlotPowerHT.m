function PlotPowerHT(t,dWcomp,limit)

global tm

name = strcat('HT Compressor Power');

ActivePower = dWcomp(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,ActivePower)   
legend(' Active Power');
hold off
axis([0 length(t)*tm 0 limit]);
ylabel('Power [kW]')
xlabel('t [minutes]')

end