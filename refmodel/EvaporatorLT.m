function dxdt = EvaporatorLT(t,x,Tindoor,PackID,dMrinLT,Te,hState,dh)

% constant parameters
global n_LT n_HT

global UAproduct_LT UAload_LT UAmref_LT dQheater

global Mair_LT Cpair_LT Mproduct_LT Cpproduct_LT

% returning the output mass flow
global dMrmaxLT dMroutLT

% states
TairOffLT = x(1:4:end-3);
TairOnLT = x(2:4:end-2);
TproductLT = x(3:4:end-1);
MrLT = x(4:4:end);

MrLT = max(0,MrLT);

% cooling capacity
% 1/UAe = 1/(h1*A1)+dx_wall/(k*A)+1/(h2*A2)
% 1/Ue = 1/h1 + dx_wall/k + 1/h2  %-- per unit area, given A=A1=A2

% MrMaxLT = 1.0;          % [kg]
% k_coil = 385;           % [W/(m*K)]
% dx_wall = 0.005;        % [0.5cm]
% h_ref = 3000;           % [W/(m^2*K)]
% h_air = 1000;            % [W/(m^2*K)]
% A = 0.5;                  %[m^2]
% 
% UAe = A/(1/h_ref + dx_wall/k_coil + 1/h_air)*MrLT/MrMaxLT; % ~800

UAe = UAmref_LT.*MrLT;
dQeOff = UAe.*(TairOffLT-Te);
dQeOn = 0.5*UAe.*(TairOnLT-Te);

% output mass flow
dMroutLT = max(0,dQeOff/dh);

% handling the full charge condition
for i=1:n_LT
    if MrLT(i) >= 1.2
        dMrinLT(i) = min(dMrinLT(i),dMroutLT(i));
    end
end

dMrmaxLT = dMrinLT;

% heat transfer from productstuffs
dQproductOff = UAproduct_LT.*(TproductLT - TairOffLT);
dQproductOn = UAproduct_LT.*(TproductLT - TairOnLT);

UAload_LT = [7 7]';
% heat load from indoor temperature and LT heaters
dQloadOff = UAload_LT.*(Tindoor(n_HT+1+(PackID-1)*(n_HT+n_LT):n_HT+n_LT+(PackID-1)*(n_HT+n_LT))...
                                - TairOffLT) + hState.*dQheater;
dQloadOn = UAload_LT.*(Tindoor(n_HT+1+(PackID-1)*(n_HT+n_LT):n_HT+n_LT+(PackID-1)*(n_HT+n_LT))...
                                - TairOnLT) + hState.*dQheater;

% state differential equations
dTairOffLTdt = (dQloadOff + dQproductOff - dQeOff)./(Mair_LT*Cpair_LT);
dTairOnLTdt = (dQloadOn + dQproductOn - dQeOn)./(Mair_LT*Cpair_LT);
dTproductLTdt = -(0.6*dQproductOff + 0.4*dQproductOn)./(Mproduct_LT*Cpproduct_LT);
dMrLTdt = dMrinLT - dMroutLT;

% state updates
dxdt = zeros(4*n_LT,1);
dxdt(1:4:end-3) = real(dTairOffLTdt);
dxdt(2:4:end-2) = real(dTairOnLTdt);
dxdt(3:4:end-1) = real(dTproductLTdt);
dxdt(4:4:end) = real(dMrLTdt);

end