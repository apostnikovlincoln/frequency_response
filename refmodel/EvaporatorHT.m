function dxdt = EvaporatorHT(t,x,Tindoor,PackID,dMrinHT,Te,dh)

% constant parameters
global n_HT n_LT

global UAproduct_HT UAload_HT UAmref_HT 

global Mair_HT Cpair_HT Mproduct_HT Cpproduct_HT

% returning the output mass flow
global dMrmaxHT dMroutHT

% states
TairOffHT = x(1:4:end-3);
TairOnHT = x(2:4:end-2);
TproductHT = x(3:4:end-1);
MrHT = x(4:4:end);

MrHT = max(0,MrHT);

% cooling capacity
% 1/UAe = 1/(h1*A1)+dx_wall/(k*A)+1/(h2*A2)
% 1/Ue = 1/h1 + dx_wall/k + 1/h2  %-- per unit area, given A=A1=A2

% MrMaxHT = 1.0;          % [kg]
% k_coil = 385;           % [W/(m*K)]
% dx_wall = 0.005;        % [0.5cm]
% h_ref = 3000;           % [W/(m^2*K)]
% h_air = 1000;            % [W/(m^2*K)]
% A = 0.5;                  %[m^2]
% 
% UAe = A/(1/h_ref + dx_wall/k_coil + 1/h_air)*MrHT/MrMaxHT; % ~800

UAe = UAmref_HT.*MrHT;
dQeOff = 0.8*UAe.*(TairOffHT-Te);
dQeOn = 0.4*UAe.*(TairOnHT-Te);

% output mass flow
dMroutHT = max(0,dQeOff/dh);

% max coil charge
coil_cap = [2.5 2.5 4.6 2.5 2.5 2.5 2.5 2.5 6.4 4.6 4.6 4.6 4.6]';

for i=1:n_HT
    if MrHT(i) >= coil_cap(i)
        dMrinHT(i) = min(dMrinHT(i),dMroutHT(i));
    end
end

dMrmaxHT = dMrinHT;

% heat transfer from productstuffs
dQproductOff = UAproduct_HT.*(TproductHT - TairOffHT);
dQproductOn = UAproduct_HT.*(TproductHT - TairOnHT);

UAload_HT = [42 42 62 42 42 126 126 126 196 126 126 126 126]';
% heat load from indoor temperature
dQloadOff = 0.8*UAload_HT.*(Tindoor(1+(PackID-1)*(n_HT+n_LT):n_HT+(PackID-1)*(n_HT+n_LT)) - TairOffHT);
dQloadOn = 0.8*UAload_HT.*(Tindoor(1+(PackID-1)*(n_HT+n_LT):n_HT+(PackID-1)*(n_HT+n_LT)) - TairOnHT);

% state differential equations
dTairOffHTdt = (dQloadOff + dQproductOff - dQeOff)./(Mair_HT*Cpair_HT);
dTairOnHTdt = (dQloadOn + dQproductOn - dQeOn)./(Mair_HT*Cpair_HT);
dTproductHTdt = -(0.6*dQproductOff + 0.4*dQproductOn)./(1.2*Mproduct_HT*Cpproduct_HT);
dMrHTdt = dMrinHT - dMroutHT;

% state updates
dxdt = zeros(4*n_HT,1);
dxdt(1:4:end-3) = real(dTairOffHTdt);
dxdt(2:4:end-2) = real(dTairOnHTdt);
dxdt(3:4:end-1) = real(dTproductHTdt);
dxdt(4:4:end) = real(dMrHTdt);

end