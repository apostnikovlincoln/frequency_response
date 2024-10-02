function [u,h] = TempCtrlLT(TrefLT,TairLT,DefrostScheduleLT)

%   TempCtrlLT applies a hysteresis control command to the expansion valves
%   
%   TrefLT: reference temperature
%   TairLT: measured temperature
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constant parameter
global n_LT defrostDurationLT t tm

% modulation
modTrefLT = 1*ones(n_LT,1);

% persistent variables
persistent OD heaterState defrostDuration dsrDuration

% initial value for OD
if isempty(OD) || isempty(heaterState)
   OD = unidrnd(2,2,1)-1;
   heaterState = zeros(n_LT,1);
   %OD = [0 1]';
   %OD = [0 0]';
end

% initial value for defrost duration
if isempty(defrostDuration)
    defrostDuration = defrostDurationLT*ones(size(DefrostScheduleLT));
end

% initial value for DSR duration
if isempty(dsrDuration)
    dsrDuration = 30/tm*ones(n_LT,1);
end
    
for i = 1:n_LT    
    
    % modulation control
    if (TairLT(i) >= TrefLT(i))
        OD(i) = min(1,(TairLT(i)-(TrefLT(i)-modTrefLT(i)))/2*modTrefLT(i)); 
    elseif (TairLT(i) < TrefLT(i))
        OD(i) = max(0,(TairLT(i)-(TrefLT(i)-modTrefLT(i)))/2*modTrefLT(i));
    end
    
    % LT heaters are switched off outside defrost
    heaterState(i) = 0;
    
    % defrost
    for j = 1:size(DefrostScheduleLT,2)
        if (t>=DefrostScheduleLT(i,j)) && (t<DefrostScheduleLT(i,j)+defrostDuration(i,j)) 
            OD(i) = 0.0;
            heaterState(i) = 1;
        end
    end

    % DSR simulation
    if (t>=400/tm) && (t<430/tm)
        OD(i) = 0.0;
    end
    
    % DSR simulation
    if (t>=1000/tm) && (t<1030/tm)
        OD(i) = 0.0;
    end
    
end

u = OD;
h = heaterState;

end