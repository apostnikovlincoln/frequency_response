function PlotAggregatedHT(t,T1,T2,T3,P,limit)

global tm

name1 = strcat('Average HT Temperature');
name2 = strcat('HT Compressor Power');

avg_air_off = T1(:);
avg_air_on = T2(:);
avg_product = T3(:);
pack_power = P(:);

figure('name','Avg HT Temperature vs HT Pack Duty');

ax1 = subplot(2,1,1);%gca;
ax1.Box = 'on';
ax1.FontName='Times New Roman';
ax1.Title.String = name1;
hold on
plot(ax1,t,avg_air_off)
plot(ax1,t,avg_air_on)
plot(ax1,t,avg_product)
legend(ax1,' Avg Air Off',' Avg Air On',...
    ' Avg Product');
hold off
axis([0 length(t)*tm -5 15]);
ylabel(ax1,'T [^\circC]')
xlabel(ax1,'t [minutes]')

ax2 = subplot(2,1,2);%gca;
ax2.Box = 'on';
ax2.FontName='Times New Roman';
ax2.Title.String = name2;
hold on
plot(ax2,t,pack_power)   
legend(ax2,' Active Power');
hold off
axis(ax2,[0 length(t)*tm 0 limit]);
ylabel(ax2,'Power [kW]')
xlabel(ax2,'t [minutes]')

end