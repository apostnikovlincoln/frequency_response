function fr = GridModel(Pf, Pl)

% constant parameters
global Tg Tt Req M D Ptot

% initial conditions
persistent y0
    
ts = 10;

if(isempty(y0))
    y0 = [0; 0; 0];
end

u = (Pl+Pf)/Ptot;

dpv = [];
dpm = [];
df = [];
fr = [];

for i = 1:size(Pl,1)
    tspan = (i-1):1/ts:i;
    [t,y] = ode45(@(t,y) Frequency(t,y,Tg,Tt,Req,M,D,u(i)),tspan,y0);
    y0 = y(end,:);
    dpv = [dpv; y(1:end-1,1)];
    dpm = [dpm; y(1:end-1,2)];
    df = [df; y(1:end-1,3)];
end

y0 = [dpv(end),dpm(end),df(end)];

fr = 50+50*df(1:ts:end)';

% figure;
% plot(u);
% 
% figure;
% plot(dpv(1:ts:end));
% 
% figure;
% plot(dpm(1:ts:end));
% 
% figure;
% plot(df(1:ts:end));