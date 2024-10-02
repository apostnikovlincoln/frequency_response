clc
close all
clear all

% add folder paths
addpath('setup');
addpath('refmodel');
addpath('refprop');
addpath('controllers');
addpath('setpoints');
addpath('probes');
addpath('plots');
addpath('gridmodel');

global n_step t_period time tm t n_packs packTimerShuffle
global Vsuc_HT Vsuc_LT n_HT n_LT
global Pl t_trigger

t_trigger = 100000000;
fr_prev = -1*ones(6,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% system initialisation and setup

n_packs = 3;

RefModelSetup();
GridModelSetup();

%% defrost schedule generation

for PackID=1:n_packs    
    % defrost schedule generation
    DefrostScheduleHT(:,:,PackID) = DefrostSetupHT(PackID);
    DefrostScheduleLT(:,:,PackID) = DefrostSetupLT(PackID);  
    pk(PackID) = PackClass(DefrostScheduleHT(:,:,PackID),DefrostScheduleLT(:,:,PackID));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ambient and indoor temperatures

[Tambient, Tstore] = TProbeSimulation(t_period,time);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% simulation

CasesHToff = zeros(n_step,n_packs*n_HT);
CasesHTon = zeros(n_step,n_packs*n_HT);
CasesHTcpt = zeros(n_step,n_packs*n_HT);

CasesLToff = zeros(n_step,n_packs*n_LT);
CasesLTon = zeros(n_step,n_packs*n_LT);
CasesLTcpt = zeros(n_step,n_packs*n_LT);

Vsuc_HT = 0.35 + 0.1*rand(n_packs,1);
Vsuc_LT = 0.25 + 0.1*rand(n_packs,1);

packTimerShuffle = unidrnd(60,n_packs,1);

Pf = zeros(size(Pl,1),1);
Pfridge = ones(size(Pl,1),1);
fr_ffr = zeros(size(Pl,1),1);
fr_noffr = zeros(size(Pl,1),1);
for t=1:n_step
    fr_noffr(6*(t-1)+1:6*(t-1)+6) = GridModel(Pf(6*(t-1)+1:6*(t-1)+6),Pl(6*(t-1)+1:6*(t-1)+6));
    t_r = n_step - t
end

for t=1:n_step

    % read indoor temperature at time = t
    Tindoor = Tstore(t,:)';
    
    % set-points for temperature and suction pressure control
    [TrefHT, PrefHT, dPrefNeutralZoneHT, dPrefPlusZoneHT,...
        dPrefMinusZoneHT] = SetPointsHT();
    [TrefLT, PrefLT, dPrefNeutralZoneLT, dPrefPlusZoneLT,...
        dPrefMinusZoneLT] = SetPointsLT();
    
%     if t>1
%         PrefHT = PrefHT - 15*(fr_prev(6)-50);
%     end
    
    % LF trigger check
%     if (t>1) && (sum(fr_prev<49.7)) && (t_trigger == 100000000)
%         t_trigger = t;
%     end
    
    % DSR suction pressure offset
    if (t>=t_trigger+0.5/tm) && (t<t_trigger+30/tm) 
        PrefHT = PrefHT + 1.1;
        PrefLT = PrefLT + 1.1;
    elseif (t>=t_trigger+30/tm) && (t<t_trigger+35/tm) 
        PrefHT = PrefHT + 0.95;
        PrefLT = PrefLT + 0.95;
    elseif (t>=t_trigger+35/tm) && (t<t_trigger+40/tm) 
        PrefHT = PrefHT + 0.8;
        PrefLT = PrefLT + 0.8;
    elseif (t>=t_trigger+40/tm) && (t<t_trigger+45/tm) 
        PrefHT = PrefHT + 0.65;
        PrefLT = PrefLT + 0.65;
    elseif (t>=t_trigger+45/tm) && (t<t_trigger+50/tm) 
        PrefHT = PrefHT + 0.5;
        PrefLT = PrefLT + 0.5;
    elseif (t>=t_trigger+50/tm) && (t<t_trigger+55/tm) 
        PrefHT = PrefHT + 0.35;
        PrefLT = PrefLT + 0.35;
    elseif (t>=t_trigger+55/tm) && (t<t_trigger+60/tm) 
        PrefHT = PrefHT + 0.2;
        PrefLT = PrefLT + 0.2;
    end
    
%     % DSR suction pressure offset
%     if (t>=400/tm) && (t<430/tm) 
%         PrefHT = PrefHT + 0.6;
%         PrefLT = PrefLT + 0.6;
%     end
%     
%     % DSR suction pressure offset
%     if (t>=1000.5/tm) && (t<1030/tm) 
%         PrefHT = PrefHT + 1.1;
%         PrefLT = PrefLT + 1.1;
%     end

    for PackID=1:n_packs          
        % refrigeration cycle simulation
        [TAirOffHT(t,:,PackID), TAirOnHT(t,:,PackID), TProductHT(t,:,PackID), MrHT(t,:,PackID), dMrInHT(t,:,PackID),...
            dMrOutHT(t,:,PackID), dMrOutSumHT(t,PackID), ValvesHT(t,:,PackID), PSucHT(t,PackID), TEvapHT(t,PackID),...
            DutyHT(t,PackID), PowerHT(t,PackID),TAirOffLT(t,:,PackID), TAirOnLT(t,:,PackID), TProductLT(t,:,PackID),...
            MrLT(t,:,PackID), dMrInLT(t,:,PackID), dMrOutLT(t,:,PackID), dMrOutSumLT(t,PackID), ValvesLT(t,:,PackID),...
            PSucLT(t,PackID), TEvapLT(t,PackID), DutyLT(t,PackID), PowerLT(t,PackID)]...
            = pk(PackID).RefCycle(TrefHT,PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
            dPrefMinusZoneHT,DefrostScheduleHT(:,:,PackID),TrefLT,PrefLT,dPrefNeutralZoneLT,...
            dPrefPlusZoneLT,dPrefMinusZoneLT,DefrostScheduleLT(:,:,PackID),Tindoor,PackID);      
        
        remaining_packs = n_packs - PackID;
    end
    
    Pavg = 8.85*n_packs;
    Pfridge(6*(t-1)+1:6*(t-1)+6) = Pfridge(6*(t-1)+1:6*(t-1)+6).*(50*100*(-Pavg+(sum(PowerHT(t,:),2)+sum(PowerLT(t,:),2)))/1000000);
    fr_ffr(6*(t-1)+1:6*(t-1)+6) = GridModel(Pfridge(6*(t-1)+1:6*(t-1)+6),Pl(6*(t-1)+1:6*(t-1)+6));
    fr_prev = fr_ffr(6*(t-1)+1:6*(t-1)+6);
        
    time_remains = n_step - t
end

avgTAirOffHT = sum(sum(TAirOffHT,2)/n_HT,3)/n_packs;
avgTAirOffLT = sum(sum(TAirOffLT,2)/n_LT,3)/n_packs;

avgTAirOnHT = sum(sum(TAirOnHT,2)/n_HT,3)/n_packs;
avgTAirOnLT = sum(sum(TAirOnLT,2)/n_LT,3)/n_packs;

avgTProductHT = sum(sum(TProductHT,2)/n_HT,3)/n_packs;
avgTProductLT = sum(sum(TProductLT,2)/n_LT,3)/n_packs;

for PackID=1:n_packs  
    CasesHToff(:,1+(PackID-1)*n_HT:PackID*n_HT) = TAirOffHT(:,:,PackID);
    CasesHTon(:,1+(PackID-1)*n_HT:PackID*n_HT) = TAirOnHT(:,:,PackID);
    CasesHTcpt(:,1+(PackID-1)*n_HT:PackID*n_HT) = TProductHT(:,:,PackID);

    CasesLToff(:,1+(PackID-1)*n_LT:PackID*n_LT) = TAirOffLT(:,:,PackID);
    CasesLTon(:,1+(PackID-1)*n_LT:PackID*n_LT) = TAirOnLT(:,:,PackID);
    CasesLTcpt(:,1+(PackID-1)*n_LT:PackID*n_LT) = TProductLT(:,:,PackID);
end
    
totalPowerHT = sum(PowerHT,2);
totalPowerLT = sum(PowerLT,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plots

totalPower = totalPowerHT+totalPowerLT;
PlotPowerHT(time,totalPowerHT,max(totalPowerHT)+5);
PlotPowerLT(time,totalPowerLT,max(totalPowerLT)+5);
PlotTotalPower(time,totalPowerHT,totalPowerLT,max(totalPower)+5);
PlotAggregatedHT(time,avgTAirOffHT,avgTAirOnHT,avgTProductHT,totalPowerHT,max(totalPowerHT)+5);
PlotAggregatedLT(time,avgTAirOffLT,avgTAirOnLT,avgTProductLT,totalPowerLT,max(totalPowerLT)+5);

% DSR1

% HT histogram
timepoints = 60;
data_ht = zeros(timepoints, n_packs*n_HT);
for k = 1:timepoints
    data_ht(k,:) = CasesHToff(3850+10*k,:);
end

% generate data for histograms: 1 histogram per column
edges_ht = -5:0.5:10; % bin edges
counts_ht = histc(data_ht, edges_ht, 2); % specify dim 2 to act column-wise

% plot results
hf_ht = figure;
ha_ht = axes;
hb_ht = bar3(edges_ht, counts_ht.'); % note the transpose to get the colors right
data = counts_ht.';
for k = 1:size(data,2)
    for i = 1:size(data,1)*6
        for j = 1:4
            cdata(i,j) = i;
        end
    end
    set(hb_ht(k),'cdata',cdata);
end
clear cdata
xlabel('time')
ylabel('temperature');
zlabel('cases');

%LT histogram
timepoints = 60;
data_lt = zeros(timepoints, n_packs*n_LT);
for k = 1:timepoints
    data_lt(k,:) = CasesLToff(3850+10*k,:);
end

% generate data for histograms: 1 histogram per column
edges_lt = -30:0.5:-10; % bin edges
counts_lt = histc(data_lt, edges_lt, 2); % specify dim 2 to act column-wise

% plot results
hf_lt = figure;
ha_lt = axes;
hb_lt = bar3(edges_lt, counts_lt.'); % note the transpose to get the colors right
data = counts_lt.';
for k = 1:size(data,2)
    for i = 1:size(data,1)*6
        for j = 1:4
            cdata(i,j) = i;
        end
    end
    set(hb_lt(k),'cdata',cdata);
end
clear cdata
xlabel('time')
ylabel('temperature');
zlabel('cases');

% DSR2

% HT histogram
timepoints = 60;
data_ht = zeros(timepoints, n_packs*n_HT);
for k = 1:timepoints
    data_ht(k,:) = CasesHToff(9850+10*k,:);
end

% generate data for histograms: 1 histogram per column
edges_ht = -5:0.5:10; % bin edges
counts_ht = histc(data_ht, edges_ht, 2); % specify dim 2 to act column-wise

% plot results
hf_ht = figure;
ha_ht = axes;
hb_ht = bar3(edges_ht, counts_ht.'); % note the transpose to get the colors right
data = counts_ht.';
for k = 1:size(data,2)
    for i = 1:size(data,1)*6
        for j = 1:4
            cdata(i,j) = i;
        end
    end
    set(hb_ht(k),'cdata',cdata);
end
clear cdata
xlabel('time')
ylabel('temperature');
zlabel('cases');

%LT histogram
timepoints = 60;
data_lt = zeros(timepoints, n_packs*n_LT);
for k = 1:timepoints
    data_lt(k,:) = CasesLToff(9850+10*k,:);
end

% generate data for histograms: 1 histogram per column
edges_lt = -30:0.5:-15; % bin edges
counts_lt = histc(data_lt, edges_lt, 2); % specify dim 2 to act column-wise

% plot results
hf_lt = figure;
ha_lt = axes;
hb_lt = bar3(edges_lt, counts_lt.'); % note the transpose to get the colors right
data = counts_lt.';
for k = 1:size(data,2)
    for i = 1:size(data,1)*6
        for j = 1:4
            cdata(i,j) = i;
        end
    end
    set(hb_lt(k),'cdata',cdata);
end
clear cdata
xlabel('time')
ylabel('temperature');
zlabel('cases');


% individual pack data
for PackID=1:1  
    % plot all HT temperatures
    PlotTemperaturesHT(time,TAirOffHT(:,:,PackID),TAirOnHT(:,:,PackID),TProductHT(:,:,PackID));
    % plot all LT temperatures
    PlotTemperaturesLT(time,TAirOffLT(:,:,PackID),TAirOnLT(:,:,PackID),TProductLT(:,:,PackID));

    % plot HT suction pressure
    PlotPSuctionHT(time,PSucHT(:,PackID));
    % plot LT suction pressure
    PlotPSuctionLT(time,PSucLT(:,PackID));
    
    % plot HT compressor active power
    PlotPowerHT(time,PowerHT(:,PackID),max(PowerHT(:,PackID))+5);
    % plot LT compressor active power
    PlotPowerLT(time,PowerLT(:,PackID),max(PowerLT(:,PackID))+5);
    % plot total active power
    PlotTotalPower(time,PowerHT(:,PackID),PowerLT(:,PackID),max(PowerHT(:,PackID)+PowerLT(:,PackID))+5);

%     % plot HT sites evaporation temperature
%     PlotTEvapHT(time,TEvapHT(:,PackID));
%     % plot LT sites evaporation temperature
%     PlotTEvapLT(time,TEvapLT(:,PackID));
%     
%     % plot HT compressor duty
%     PlotDutyHT(time,DutyHT(:,PackID));
%     % plot LT compressor duty
%     PlotDutyLT(time,DutyLT(:,PackID));
% 
%     % plot ambient temperature
%     PlotAmbientTemp(time,mean(Tstore,2));
%     
%     % plot HT sites mass of refrigerant
%     PlotMrValvesHT(time,MrHT,ValvesHT);
%     % plot LT sites mass of refrigerant
%     PlotMrValvesLT(time,MrLT,ValvesLT);
% 
%     % plot mass flow rates to HT cases from condenser
%         ...and from HT cases to HT suction lines
%     PlotMrRateHT(time,dMrInHT,dMrOutHT);
%     % plot mass flow rates to LT cases from condenser
%         ...and from LT cases to LT suction lines
%     PlotMrRateLT(time,dMrInLT,dMrOutLT);
% 
%     % plot total mass flow rate to HT suction lines
%     PlotTotalMrRateHT(time,dMrOutSumHT);
%     % plot total mass flow rate to LT suction lines
%     PlotTotalMrRateLT(time,dMrOutSumLT);
end
    
figure;
plot(fr_noffr);
hold on
plot(fr_ffr);

% for t=1:n_step
%     fr_ffr(6*(t-1)+1:6*(t-1)+6) = GridModel(Pfridge(6*(t-1)+1:6*(t-1)+6),Pl(6*(t-1)+1:6*(t-1)+6));       
%     time_remains = n_step - t
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
