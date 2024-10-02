function PlotDutyHT(t,DutyHT)

global tm

name = strcat('HT Compressors Duty');

DutyHT = DutyHT(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,DutyHT)   
legend(' HT Compressors On');
hold off
axis([0 length(t)*tm -2 6]);
ylabel('Compressors On [num]')
xlabel('t [minutes]')

end