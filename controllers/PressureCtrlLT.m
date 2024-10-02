function [u] = PressureCtrlLT(PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
        dPrefMinusZoneLT,PsucLT,PackID)

%   relayLT(i,1):  i compressor state; 0: off, 1: on
%   relayLT(i,2):  i compressor timeout value;
%   relayLT(i,3):  i compressor total duty time;
%   relayLT(i,4):  i compressor duty time;
    
global t Ts tm MaxCompLT packTimerShuffle

persistent NcompLT timeOut maxDuty minOnTime relayLT e PsucLT_prev

if(isempty(PsucLT_prev))
    PsucLT_prev = PsucLT;
end

if(isempty(NcompLT) || isempty(timeOut) || isempty(relayLT))
    NcompLT = 0;
    timeOut = 3/tm;
    maxDuty = 30/tm;
    minOnTime = 0;
    relayLT = zeros(MaxCompLT,4);
    for i=1:MaxCompLT
        relayLT(i,1) = unidrnd(2)-1;
        if relayLT(i,1) == 0
            relayLT(i,2) = unidrnd(timeOut+1)-1;
        end
        if relayLT(i,1) == 1
            relayLT(i,3) = unidrnd(20)-1;
            relayLT(i,4) = unidrnd(5)-1;
        end
    end
end

% updating relay timers
for i=1:MaxCompLT
    if (relayLT(i,1) == 1)
        relayLT(i,3) = relayLT(i,3) + 1;
        relayLT(i,4) = relayLT(i,4) + 1;        
    end
    if (relayLT(i,2) ~= 0)
        relayLT(i,2) = relayLT(i,2) - 1;
    end
%     %old code
%     if (relayLT(i,3) > maxDuty)
%         relayLT(i,1) = 0;
%         relayLT(i,2) = timeOut;
%         relayLT(i,3) = 0;
%     end
end

min_ind = 0;
max_ind = 0;

% ++zone: 30 (5*ts) second check
if (PsucLT >= PrefLT + dPrefNeutralZoneLT/2 + dPrefPlusZoneLT) && (sum(relayLT(:,1)) < MaxCompLT) ...
                                            && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
    for i=1:MaxCompLT
        if (relayLT(i,1) == 0) && (relayLT(i,2) == 0)
            min = relayLT(1,3);
            min_ind = i;
            break;
        end
    end
    if min_ind ~= 0
        for i=1:MaxCompLT
            if (relayLT(i,3)<min) && (relayLT(i,1) == 0) && (relayLT(i,2) == 0)
                min=relayLT(i,3);
                min_ind = i;
            end
        end
        relayLT(min_ind,1) = 1;
    end
    
%     % old code
%     for i=1:MaxCompLT
%         if (relayLT(i,1) == 0) && (relayLT(i,2) == 0) 
%             relayLT(i,1) = 1;
%             break;   
%         end
%     end
    
% --zone: 18 (3*ts) second check
elseif (PsucLT <= PrefLT - dPrefNeutralZoneLT/2 - dPrefMinusZoneLT) && (sum(relayLT(:,1)) > 0) ...
                                                && (mod((t-1)+packTimerShuffle(PackID),3) == 0)
    for i=1:MaxCompLT
        if (relayLT(i,1) == 1) && (relayLT(i,4) > minOnTime)
            max = relayLT(1,3);
            max_ind = i;
            break;
        end
    end
    if max_ind ~= 0
        for i=1:MaxCompLT
            if (relayLT(i,3)>max) && (relayLT(i,1) == 1) && (relayLT(i,4) > minOnTime)
                max=relayLT(i,3);
                max_ind = i;
            end
        end
        relayLT(max_ind,1) = 0;  
        relayLT(max_ind,2) = timeOut;  
        relayLT(max_ind,4) = 0;          
    end
    
%     %old code
%     for i=1:MaxCompLT
%         if relayLT(i,1) == 1
%             relayLT(i,1) = 0;
%             relayLT(i,2) = timeOut;
%             relayLT(i,3) = 0;
%             break;
%         end
%     end
    
% +zone: 0.4 bar, 2 (20*ts) min check    
elseif (PsucLT >= PrefLT + dPrefNeutralZoneLT/2) && (PsucLT - PsucLT_prev > 0) ...
              && (sum(relayLT(:,1)) < MaxCompLT) && (mod((t-1)+packTimerShuffle(PackID),20) == 0)
    for i=1:MaxCompLT
        if (relayLT(i,1) == 0) && (relayLT(i,2) == 0)
            min = relayLT(1,3);
            min_ind = i;
            break;
        end
    end
    if min_ind ~= 0
        for i=1:MaxCompLT
            if (relayLT(i,3)<min) && (relayLT(i,1) == 0) && (relayLT(i,2) == 0)
                min=relayLT(i,3);
                min_ind = i;
            end
        end
        relayLT(min_ind,1) = 1;
    end
    
% -zone: 0.3 bar, 30 (5*ts) second check
elseif (PsucLT <= PrefLT - dPrefNeutralZoneLT/2) && (PsucLT - PsucLT_prev < 0) ...
                      && (sum(relayLT(:,1)) > 0) && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
    for i=1:MaxCompLT
        if (relayLT(i,1) == 1) && (relayLT(i,4) > minOnTime)
            max = relayLT(1,3);
            max_ind = i;
            break;
        end
    end
    if max_ind ~= 0
        for i=1:MaxCompLT
            if (relayLT(i,3)>max) && (relayLT(i,1) == 1) && (relayLT(i,4) > minOnTime)
                max=relayLT(i,3);
                max_ind = i;
            end
        end
        relayLT(max_ind,1) = 0;  
        relayLT(max_ind,2) = timeOut;  
        relayLT(max_ind,4) = 0;        
    end 
end

PsucLT_prev = PsucLT;
NcompLT = sum(relayLT(:,1));

% DSR simulation
if (t>=400/tm) && (t<400.5/tm) 
	NcompLT = 0;
    for i=1:MaxCompLT    
        if relayLT(i,1) == 1
            relayLT(i,1) = 0; 
        end
    end
end

% DSR simulation
if (t>=1000.5/tm) && (t<1001/tm) 
	NcompLT = 0;
    for i=1:MaxCompLT    
        if relayLT(i,1) == 1
            relayLT(i,1) = 0; 
        end
    end
end

u = NcompLT;

end