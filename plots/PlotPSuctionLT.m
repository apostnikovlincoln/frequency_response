function PlotPSuctionLT(t,Psuc)

global tm

name = strcat('LT Suction Pressure');

PSuction = Psuc(:);
figure('name',name);

ax = gca;
ax.Box = 'on';
ax.FontName='Times New Roman';
ax.Title.String = name;
hold on
plot(t,PSuction)   
legend(' Suction Pressure');
hold off
axis([0 length(t)*tm 0 10]);
ylabel('P_{suc} [bar]')
xlabel('t [minutes]')

end