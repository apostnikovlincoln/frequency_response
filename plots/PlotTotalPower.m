function PlotTotalPower(t,dWcompHT,dWcompLT, limit)

global tm

name = strcat('Total Compressor Power');

%ActivePowerHT = dWcompHT(:);
%ActivePowerLT = dWcompLT(:);
TotalPower = dWcompHT(:) + dWcompLT(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,TotalPower)   
legend(' Active Power');
hold off
axis([0 length(t)*tm 0 limit]);
ylabel('Power [kW]')
xlabel('t [minutes]')

end