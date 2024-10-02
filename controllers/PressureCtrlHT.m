function [u] = PressureCtrlHT(PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
        dPrefMinusZoneHT,PsucHT,PackID)

%   relayHT(i,1):  i compressor state; 0: off, 1: on
%   relayHT(i,2):  i compressor timeout value;
%   relayHT(i,3):  i compressor total duty time;
%   relayHT(i,4):  i compressor duty time;
    
global t Ts tm MaxCompHT packTimerShuffle

persistent NcompHT timeOut maxDuty minOnTime relayHT e PsucHT_prev

if(isempty(PsucHT_prev))
    PsucHT_prev = PsucHT;
end

if(isempty(NcompHT) || isempty(timeOut) || isempty(relayHT))
    NcompHT = 0;
    timeOut = 3/tm;
    maxDuty = 30/tm;
    minOnTime = 0;
    relayHT = zeros(MaxCompHT,4);
    for i=1:MaxCompHT
        relayHT(i,1) = unidrnd(2)-1;
        if relayHT(i,1) == 0
            relayHT(i,2) = unidrnd(timeOut+1)-1;
        end
        if relayHT(i,1) == 1
            relayHT(i,3) = unidrnd(20)-1;
            relayHT(i,4) = unidrnd(5)-1;
        end
    end
end

% updating relay timers
for i=1:MaxCompHT
    if (relayHT(i,1) == 1)
        relayHT(i,3) = relayHT(i,3) + 1;
        relayHT(i,4) = relayHT(i,4) + 1;        
    end
    if (relayHT(i,2) ~= 0)
        relayHT(i,2) = relayHT(i,2) - 1;
    end
%     %old code
%     if (relayHT(i,3) > maxDuty)
%         relayHT(i,1) = 0;
%         relayHT(i,2) = timeOut;
%         relayHT(i,3) = 0;
%     end
end

min_ind = 0;
max_ind = 0;

% ++zone: 30 (5*ts) second check
if (PsucHT >= PrefHT + dPrefNeutralZoneHT/2 + dPrefPlusZoneHT) && (sum(relayHT(:,1)) < MaxCompHT) ...
                                            && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
    for i=1:MaxCompHT
        if (relayHT(i,1) == 0) && (relayHT(i,2) == 0)
            min = relayHT(1,3);
            min_ind = i;
            break;
        end
    end
    if min_ind ~= 0
        for i=1:MaxCompHT
            if (relayHT(i,3)<min) && (relayHT(i,1) == 0) && (relayHT(i,2) == 0)
                min=relayHT(i,3);
                min_ind = i;
            end
        end
        relayHT(min_ind,1) = 1;
    end
    
%     % old code
%     for i=1:MaxCompHT
%         if (relayHT(i,1) == 0) && (relayHT(i,2) == 0) 
%             relayHT(i,1) = 1;
%             break;   
%         end
%     end
    
% --zone: 18 (3*ts) second check
elseif (PsucHT <= PrefHT - dPrefNeutralZoneHT/2 - dPrefMinusZoneHT) && (sum(relayHT(:,1)) > 0) ...
                                                && (mod((t-1)+packTimerShuffle(PackID),3) == 0)
    for i=1:MaxCompHT
        if (relayHT(i,1) == 1) && (relayHT(i,4) > minOnTime)
            max = relayHT(1,3);
            max_ind = i;
            break;
        end
    end
    if max_ind ~= 0
        for i=1:MaxCompHT
            if (relayHT(i,3)>max) && (relayHT(i,1) == 1) && (relayHT(i,4) > minOnTime)
                max=relayHT(i,3);
                max_ind = i;
            end
        end
        relayHT(max_ind,1) = 0;  
        relayHT(max_ind,2) = timeOut;  
        relayHT(max_ind,4) = 0;          
    end
    
%     %old code
%     for i=1:MaxCompHT
%         if relayHT(i,1) == 1
%             relayHT(i,1) = 0;
%             relayHT(i,2) = timeOut;
%             relayHT(i,3) = 0;
%             break;
%         end
%     end
    
% +zone: 0.4 bar, 2 (20*ts) min check    
elseif (PsucHT >= PrefHT + dPrefNeutralZoneHT/2) && (PsucHT - PsucHT_prev > 0) ...
              && (sum(relayHT(:,1)) < MaxCompHT) && (mod((t-1)+packTimerShuffle(PackID),20) == 0)
    for i=1:MaxCompHT
        if (relayHT(i,1) == 0) && (relayHT(i,2) == 0)
            min = relayHT(1,3);
            min_ind = i;
            break;
        end
    end
    if min_ind ~= 0
        for i=1:MaxCompHT
            if (relayHT(i,3)<min) && (relayHT(i,1) == 0) && (relayHT(i,2) == 0)
                min=relayHT(i,3);
                min_ind = i;
            end
        end
        relayHT(min_ind,1) = 1;
    end
    
% -zone: 0.3 bar, 30 (5*ts) second check
elseif (PsucHT <= PrefHT - dPrefNeutralZoneHT/2) && (PsucHT - PsucHT_prev < 0) ...
                      && (sum(relayHT(:,1)) > 0) && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
    for i=1:MaxCompHT
        if (relayHT(i,1) == 1) && (relayHT(i,4) > minOnTime)
            max = relayHT(1,3);
            max_ind = i;
            break;
        end
    end
    if max_ind ~= 0
        for i=1:MaxCompHT
            if (relayHT(i,3)>max) && (relayHT(i,1) == 1) && (relayHT(i,4) > minOnTime)
                max=relayHT(i,3);
                max_ind = i;
            end
        end
        relayHT(max_ind,1) = 0;  
        relayHT(max_ind,2) = timeOut;  
        relayHT(max_ind,4) = 0;        
    end 
end

PsucHT_prev = PsucHT;
NcompHT = sum(relayHT(:,1));

% DSR simulation
if (t>=400/tm) && (t<400.5/tm) 
	NcompHT = 0;
    for i=1:MaxCompHT    
        if relayHT(i,1) == 1
            relayHT(i,1) = 0; 
        end
    end
end

% DSR simulation
if (t>=1000.5/tm) && (t<1001/tm) 
	NcompHT = 0;
    for i=1:MaxCompHT    
        if relayHT(i,1) == 1
            relayHT(i,1) = 0; 
        end
    end
end

u = NcompHT;

end