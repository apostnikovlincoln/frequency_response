function PlotDutyLT(t,DutyLT)

global tm

name = strcat('LT Compressors Duty');

DutyLT = DutyLT(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,DutyLT)   
legend(' LT Compressors On');
hold off
axis([0 length(t)*tm -2 6]);
ylabel('Compressors On [num]')
xlabel('t [minutes]')

end