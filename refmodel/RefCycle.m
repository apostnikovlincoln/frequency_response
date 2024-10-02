function [TairOffHT, TairOnHT, TfoodHT, MrHT, dMrInHT, dMrOutHT, dMrSumHT, ValvesHT, ...
                PsuctionHT, TeHT, NcompHT, dWcompHT,...
          TairOffLT, TairOnLT, TfoodLT, MrLT, dMrInLT, dMrOutLT, dMrSumLT, ValvesLT, ...
                PsuctionLT, TeLT, NcompLT, dWcompLT]... 
          = RefCycle(TrefHT,PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
                dPrefMinusZoneHT,DefrostScheduleHT,...
                     TrefLT,PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
                dPrefMinusZoneLT,DefrostScheduleLT,Tindoor,PackID)

persistent PsucHT PsucLT hState Pc ODHT ODLT

% initial values
if (isempty(PsucHT) || isempty(Pc) || isempty(ODHT))
    PsucHT = 3.4;
    Pc = 12;
    ODHT = unidrnd(2,13,1)-1;
    %ODHT = [1 0 1 0 1 0 1 0 1 0 1 0 1]';
    %ODHT = [0 0 0 0 0 0 0 0 0 0 0 0 0]';
end
if (isempty(PsucLT) || isempty(hState) || isempty(Pc) || isempty(ODLT))
    PsucLT = 0.7;
    Pc = 12;
    ODLT = unidrnd(2,2,1)-1;
    hState = zeros(2,1);
    %ODLT = [0 1]';
    %ODLT = [0 0]';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HT Cases
    
    % calculate thermal dynamics of HT cabinets
    [TairOffHT, TairOnHT, TfoodHT, MrHT, dMrInHT, dMrOutHT, dMrSumHT, TeHT] = CabinetHT(ODHT,PsucHT,Tindoor,PackID);
    
    % apply temperature control for HT cabinets
    ODHT = TempCtrlHT(TrefHT,TairOffHT,DefrostScheduleHT);
    ValvesHT = ODHT;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LT Cases
    
    % calculate thermal dynamics of LT cabinets
    [TairOffLT, TairOnLT, TfoodLT, MrLT, dMrInLT, dMrOutLT, dMrSumLT, TeLT] = CabinetLT(ODLT,hState,PsucLT,Tindoor,PackID);
    
    % apply temperature control for LT cabinets
    [ODLT, hState] = TempCtrlLT(TrefLT,TairOffLT,DefrostScheduleLT);
    ValvesLT = ODLT;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pack
    
    % apply suction pressure control for HT compressors
    [NcompHT] = PressureCtrlHT(PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
        dPrefMinusZoneHT,PsucHT,PackID);
    
    % calculate pressure dynamics and power consumption of HT compressors
    [PsucHT, dWcompHT] = CompressorHT(dMrSumHT,NcompHT,Pc,PackID);
    PsuctionHT = PsucHT;
    
    % apply suction pressure control for LT compressors
    [NcompLT] = PressureCtrlLT(PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
        dPrefMinusZoneLT,PsucLT,PackID);
    
    % calculate pressure dynamics and power consumption of LT compressors
    [PsucLT, dWcompLT] = CompressorLT(dMrSumLT,NcompLT,Pc,PackID);
    PsuctionLT = PsucLT;
   
end