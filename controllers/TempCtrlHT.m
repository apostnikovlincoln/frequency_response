function u = TempCtrlHT(TrefHT,TairHT,DefrostScheduleHT)

%   TempCtrlHT applies a hysteresis control command to the expansion valves
%   
%   TrefHT: reference temperature
%   TairHT: measured temperature
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constant parameter
global n_HT defrostDurationHT t tm

% differential
dTrefHT = 2*ones(n_HT,1);

% modulation range
modTrefHT = 1*ones(n_HT,1);

% persistent variables
persistent OD defrostDuration defrostState dsrDuration

% initial value for OD
if isempty(OD)
   OD = unidrnd(2,13,1)-1;
   %OD = [1 0 1 0 1 0 1 0 1 0 1 0 1]';
   %OD = [0 0 0 0 0 0 0 0 0 0 0 0 0]';
end

% initial value for defrost duration
if isempty(defrostDuration)
    defrostDuration = defrostDurationHT*ones(size(DefrostScheduleHT));
end

if isempty(defrostState)
    defrostState = zeros(n_HT,1);
end

% initial value for DSR duration
if isempty(dsrDuration)
    dsrDuration = 30/tm*ones(n_HT,4);
end

for i = 1:n_HT

    if t>=10000/tm
        % hysteresis control
        if (TairHT(i) >= TrefHT(i)+dTrefHT(i))
            OD(i) = 1;        
        elseif (TairHT(i) <= TrefHT(i))
            OD(i) = 0.0;
        end
    else    
        % modulation control
        if (TairHT(i) >= TrefHT(i))
            OD(i) = min(1,(TairHT(i)-(TrefHT(i)-modTrefHT(i)))/2*modTrefHT(i)); 
        elseif (TairHT(i) < TrefHT(i))
            OD(i) = max(0,(TairHT(i)-(TrefHT(i)-modTrefHT(i)))/2*modTrefHT(i));
        end
    end

    % defrost
    for j = 1:size(DefrostScheduleHT,2)
        if (t>=DefrostScheduleHT(i,j)) && (t<DefrostScheduleHT(i,j)+defrostDuration(i,j))
            OD(i) = 0.0;
            % termination by temperature check
            if (TairHT(i) >= 8) 
                OD(i) = 1;
                defrostDuration(i,j) = 0;
            end
        end
    end
    
    % DSR simulation
    if (t>=400/tm) && (t<400/tm+dsrDuration(i,1)) && (~ismember(i,[1 5 7 9]))
        OD(i) = 0.0;
        % termination by temperature check        
        if (TairHT(i) >= 8)
            OD(i) = 1;
            dsrDuration(i,1) = 0;
        end   
    end
    
    % DSR simulation
    if (t>=1000/tm) && (t<1000/tm+dsrDuration(i,2)) && (~ismember(i,[1 5 7 9]))
        OD(i) = 0.0;
        % termination by temperature check        
        if (TairHT(i) >= 8)
            OD(i) = 1;
            dsrDuration(i,2) = 0;
        end
    end
   
end

u = OD;

end