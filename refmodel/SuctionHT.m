function dxdt = SuctionHT(t,x,dMrHT,dMrCompHT,dRhodP,PackID)

%   dMrHT:      total mass flow entering the suction line
%   dMrCompHT:   mass flow provided by HT compressors

% constant parameter
global Vsuc_HT
        
% differential equations
dPsucHTdt = (dMrHT-dMrCompHT)/(Vsuc_HT(PackID)*dRhodP);
dxdt = dPsucHTdt;

end