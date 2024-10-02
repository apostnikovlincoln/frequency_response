function dxdt = SuctionLT(t,x,dMrLT,dMrCompLT,dRhodP,PackID)

%   dMrLT:      total mass flow entering the suction line
%   dMrCompLT:   mass flow provided by LT compressors

% constant parameter
global Vsuc_LT
        
% differential equations
dPsucLTdt = (dMrLT-dMrCompLT)/(Vsuc_LT(PackID)*dRhodP);
dxdt = dPsucLTdt;

end