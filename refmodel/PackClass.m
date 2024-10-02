classdef PackClass < handle
    
   properties
        PsucHT, PsucLT, hState, Pc, ODHT, ODLT, initCondHT, initCondLT,...
            PsucHT_ic, PsucLT_ic, NcompHT, timeOutHT, minOnTimeHT,...
            relayHT, eHT, PsucHT_prev, NcompLT, timeOutLT, minOnTimeLT,...
            relayLT, eLT, PsucLT_prev, OD_HT, defrostDurationHT, defrostStateHT,...
            dsrDurationHT, OD_LT, heaterStateLT, defrostDurationLT, dsrDurationLT,...
            DefrostScheduleHT, DefrostScheduleLT
   end
   
   methods
        %% Constructor
        function obj = PackClass(dsHT,dsLT)
            global n_HT n_LT tm MaxCompHT MaxCompLT defrostDurationHT defrostDurationLT
            
            obj.DefrostScheduleHT = dsHT;
            obj.DefrostScheduleLT = dsLT;
            
            % initial values
            obj.PsucHT = 3.4;
            obj.Pc = 12;
            obj.ODHT = unidrnd(2,13,1)-1;
            obj.PsucLT = 0.7;
            obj.Pc = 12;
            obj.ODLT = unidrnd(2,2,1)-1;
            obj.hState = zeros(2,1);

            % inintial conditions for HT air-off, air-on and product
            obj.initCondHT = zeros(4*n_HT,1);
            obj.initCondHT(1:4:end-3) = 1*rand(n_HT,1);                                         
            obj.initCondHT(2:4:end-2) = 3*rand(n_HT,1);                                        
            obj.initCondHT(3:4:end-1) = 0.6*obj.initCondHT(1:4:end-3) + 0.4*obj.initCondHT(2:4:end-2);
            obj.initCondHT(4:4:end) = 1.2*rand(n_HT,1);   
            
            % inintial conditions for LT air-off, air-on and product
            obj.initCondLT = zeros(4*n_LT,1);
            obj.initCondLT(1:4:end-3) = -24 + 4*rand(n_LT,1);                                     
            obj.initCondLT(2:4:end-2) = -19 + 4*rand(n_LT,1);                                     
            obj.initCondLT(3:4:end-1) = 0.6*obj.initCondLT(1:4:end-3) + 0.4*obj.initCondLT(2:4:end-2);
            obj.initCondLT(4:4:end) = 1.2*rand(n_LT,1); 
            
            % HT suction pressure initial conditions
            obj.PsucHT_ic = 3.4 - (0.25 - 0.5*rand());
            obj.PsucHT = obj.PsucHT_ic;
            
            % LT suction pressure initial conditions
            obj.PsucLT_ic = 0.7 - (0.1 - 0.2*rand());
            obj.PsucLT = obj.PsucLT_ic;
            
            % HT pack control parameters
            obj.PsucHT_prev = obj.PsucHT;    
            obj.NcompHT = 0;
            obj.timeOutHT = 3/tm;
            obj.minOnTimeHT = 0;
            obj.relayHT = zeros(MaxCompHT,4);
            for i=1:MaxCompHT
                obj.relayHT(i,1) = unidrnd(2)-1;
                if obj.relayHT(i,1) == 0
                    obj.relayHT(i,2) = unidrnd(obj.timeOutHT+1)-1;
                end
                if obj.relayHT(i,1) == 1
                    obj.relayHT(i,3) = unidrnd(20)-1;
                    obj.relayHT(i,4) = unidrnd(5)-1;
                end
            end
            
            % LT pack control parameters
            obj.PsucLT_prev = obj.PsucLT;    
            obj.NcompLT = 0;
            obj.timeOutLT = 3/tm;
            obj.minOnTimeLT = 0;
            obj.relayLT = zeros(MaxCompLT,4);
            for i=1:MaxCompLT
                obj.relayLT(i,1) = unidrnd(2)-1;
                if obj.relayLT(i,1) == 0
                    obj.relayLT(i,2) = unidrnd(obj.timeOutLT+1)-1;
                end
                if obj.relayLT(i,1) == 1
                    obj.relayLT(i,3) = unidrnd(20)-1;
                    obj.relayLT(i,4) = unidrnd(5)-1;
                end
            end
            
            % HT temperature control parameters
            obj.OD_HT = obj.ODHT;

            % initial value for HT defrost duration
            obj.defrostDurationHT = defrostDurationHT*ones(size(obj.DefrostScheduleHT));
            obj.defrostStateHT = zeros(n_HT,1);
            
            % initial value for HT DSR duration            
            obj.dsrDurationHT = 30/tm*ones(n_HT,4);    
            
            % LT temperature control parameters
            obj.OD_LT = unidrnd(2,2,1)-1;
            obj.heaterStateLT = zeros(n_LT,1);

            % initial value for LT defrost duration
            obj.defrostDurationLT = defrostDurationLT*ones(size(obj.DefrostScheduleLT));

            % initial value for DSR duration
            obj.dsrDurationLT = 30/tm*ones(n_LT,1);
        end
        
        %% Refrigeration Cycle
        function [TairOffHT, TairOnHT, TfoodHT, MrHT, dMrInHT, dMrOutHT, dMrSumHT, ValvesHT, ...
                        PsuctionHT, TeHT, NcompHT, dWcompHT,...
                  TairOffLT, TairOnLT, TfoodLT, MrLT, dMrInLT, dMrOutLT, dMrSumLT, ValvesLT, ...
                        PsuctionLT, TeLT, NcompLT, dWcompLT]... 
                  = RefCycle(obj,TrefHT,PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
                        dPrefMinusZoneHT,DefrostScheduleHT,...
                             TrefLT,PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
                        dPrefMinusZoneLT,DefrostScheduleLT,Tindoor,PackID)
            % HT Cases

            % calculate thermal dynamics of HT cabinets
            [TairOffHT, TairOnHT, TfoodHT, MrHT, dMrInHT, dMrOutHT, dMrSumHT, TeHT] = obj.CabinetHT(obj.ODHT,obj.PsucHT,Tindoor,PackID);
            
            % apply temperature control for HT cabinets
            obj.ODHT = obj.TempCtrlHT(TrefHT,TairOffHT,DefrostScheduleHT);
            ValvesHT = obj.ODHT;

            % LT Cases

            % calculate thermal dynamics of LT cabinets
            [TairOffLT, TairOnLT, TfoodLT, MrLT, dMrInLT, dMrOutLT, dMrSumLT, TeLT] = obj.CabinetLT(obj.ODLT,obj.hState,obj.PsucLT,Tindoor,PackID);

            % apply temperature control for LT cabinets
            [obj.ODLT, obj.hState] = obj.TempCtrlLT(TrefLT,TairOffLT,DefrostScheduleLT);
            ValvesLT = obj.ODLT;

            % Pack

            % apply suction pressure control for HT compressors
            [NcompHT] = obj.PressureCtrlHT(PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
                dPrefMinusZoneHT,obj.PsucHT,PackID);

            % calculate pressure dynamics and power consumption of HT compressors
            [obj.PsucHT, dWcompHT] = obj.CompressorHT(dMrSumHT,NcompHT,obj.Pc,PackID);
            PsuctionHT = obj.PsucHT;

            % apply suction pressure control for LT compressors
            [NcompLT] = obj.PressureCtrlLT(PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
                dPrefMinusZoneLT,obj.PsucLT,PackID);

            % calculate pressure dynamics and power consumption of LT compressors
            [obj.PsucLT, dWcompLT] = obj.CompressorLT(dMrSumLT,NcompLT,obj.Pc,PackID);
            PsuctionLT = obj.PsucLT;

        end
   end
   
   methods (Access = private)
        %% HT cabinet
        function [TairOffHT, TairOnHT, TfoodHT, MrHT, dMrInHT, dMrOutHT, dMrHT, Te] = CabinetHT(obj,OD,PsucHT,Tindoor,PackID)
            % constant parameters
            global Ts rho_h2o Prec Pc Tsh_HT Tsubcool
            
            % mass flow from odefun EvaporatorHT
            global dMrmaxHT dMroutHT

            % preliminary calculations for HT evaporation odefun
            Te = refpropm('T','P',PsucHT*100,'Q',1,'r407f.mix') - 273.15;
            Tcond = refpropm('T','P',Pc*100,'Q',0,'r407f.mix') - 273.15;
            rho_comp = refpropm('D','T',Tcond-Tsubcool+273.15,'P',Pc*100,'r407f.mix');
            hi = refpropm('H','T',Tcond-Tsubcool+273.15,'P',Pc*100,'r407f.mix');
            ho = refpropm('H','T',Te+Tsh_HT+273.15,'P',PsucHT*100,'r407f.mix');
            dh = ho - hi;

            kv = [0.025 0.025 0.046 0.025 0.025 0.025 0.025 0.025 0.064 0.046 0.046 0.046 0.046]';

            % volumetric and mass flow through the valves
            SG_ref = rho_h2o/rho_comp;
            dVrinHT = OD.*kv*sqrt((Prec-PsucHT)/SG_ref)/3600;
            dMrinHT = rho_comp*dVrinHT;

            % dynamics of the refrigerant in the evaporation coil
            tspan = 0:Ts/60:Ts;
            [t,states] = ode45(@(t,states) EvaporatorHT(t,states,Tindoor,PackID,dMrinHT,Te,dh),tspan,obj.initCondHT);
            % updating initial conditions
            obj.initCondHT = states(length(tspan),:)';

            % extract temperatures and mass of refrigerant
            TairOffHT = obj.initCondHT(1:4:end-3)';
            TairOnHT = obj.initCondHT(2:4:end-2)';
            TfoodHT = obj.initCondHT(3:4:end-1)';
            MrHT = obj.initCondHT(4:4:end)';

            % mass flow in the evaporators
            dMrInHT = dMrmaxHT;

            % mass flow out of the evaporators
            dMrOutHT = dMroutHT;

            % total mass flow out of the evaporators 
            dMrHT = sum(dMroutHT);
        end
        
        %% LT cabinet
        function [TairOffLT, TairOnLT, TfoodLT, MrLT, dMrInLT, dMrOutLT, dMrLT, Te] = CabinetLT(obj,OD,hState,PsucLT,Tindoor,PackID)
            % constant parameters
            global Ts rho_h2o Prec Pc Tsh_LT Tsubcool

            % mass flow from odefun EvaporatorLT
            global dMrmaxLT dMroutLT

            % preliminary calculations for LT evaporation odefun
            Te = refpropm('T','P',PsucLT*100,'Q',1,'r407f.mix') - 273.15;
            Tcond = refpropm('T','P',Pc*100,'Q',0,'r407f.mix') - 273.15;
            rho_comp = refpropm('D','T',Tcond-Tsubcool+273.15,'P',Pc*100,'r407f.mix');
            hi = refpropm('H','T',Tcond-Tsubcool+273.15,'P',Pc*100,'r407f.mix');
            ho = refpropm('H','T',Te+Tsh_LT+273.15,'P',PsucLT*100,'r407f.mix');
            dh = ho - hi;

            % flow factor of TEX valves
            kv = 0.01/3600; % m^3/hr to m^3/sec

            % volumetric and mass flow through the valves
            SG_ref = rho_h2o/rho_comp;
            dVrinLT = OD.*kv*sqrt((Prec-PsucLT)/SG_ref);
            dMrinLT = rho_comp*dVrinLT;

            % dynamics of the refrigerant in the evaporation coil
            tspan = 0:Ts/60:Ts;
            [t,states] = ode45(@(t,states) EvaporatorLT(t,states,Tindoor,PackID,dMrinLT,Te,hState,dh),tspan,obj.initCondLT);
            % updating initial conditions
            obj.initCondLT = states(length(tspan),:)';

            % extract temperatures and mass of refrigerant
            TairOffLT = obj.initCondLT(1:4:end-3)';
            TairOnLT = obj.initCondLT(2:4:end-2)';
            TfoodLT = obj.initCondLT(3:4:end-1)';
            MrLT = obj.initCondLT(4:4:end)';

            % mass flow in the evaporators
            dMrInLT = dMrmaxLT;

            % mass flow out of the evaporators
            dMrOutLT = dMroutLT;

            % total mass flow out of the evaporators 
            dMrLT = sum(dMroutLT);
        end  
        
        %% HT Compressor
        function [PsucHT, dWcompHT] = CompressorHT(obj,dMrHT,NcompHT,Pc,PackID)

            % constant parameters
            global Ts Vd_HT me_HT Tsh_HT

            % volumetric efficiency
            nvol = 0.95;

            % mass flow through the compressor
            Te = refpropm('T','P',obj.PsucHT_ic*100,'Q',1,'r407f.mix') - 273.15;
            rho = refpropm('D','T',Te+Tsh_HT+273.15,'P',obj.PsucHT_ic*100,'r407f.mix');
            dVcomp = NcompHT*nvol*Vd_HT;
            dMrCompHT = rho*dVcomp;

            % preliminary calculations for HT suction pressure odefun
            dRhodP = refpropm('R','T',Te+Tsh_HT+273.15,'P',obj.PsucHT_ic*100,'r407f.mix')*100;

            % % check
            % dP = 0.01;
            % dRhodP = (refpropm('D','T',Te+Tsh_HT+273.15,'P',(PsucHT_ic+dP)*100,'r407f.mix') ...
            %     -refpropm('D','T',Te+Tsh_HT+273.15,'P',(PsucHT_ic-dP)*100,'r407f.mix'))/(2*dP);

            % suction pressure
            tspan = 0:Ts/60:Ts;
            [t,states] = ode45(@(t,states) SuctionHT(t,states,dMrHT,dMrCompHT,dRhodP,PackID),tspan,obj.PsucHT_ic);
            PsucHT = states(length(tspan));
            obj.PsucHT_ic = PsucHT;

            % inlet enthalpy
            Te = refpropm('T','P',obj.PsucHT_ic*100,'Q',1,'r407f.mix') - 273.15;
            hicompHT = refpropm('H','T',Te+Tsh_HT+273.15,'P',obj.PsucHT_ic*100,'r407f.mix');

            % outlet enthalpy
            S = refpropm('S','T',Te+Tsh_HT+273.15,'P',obj.PsucHT_ic*100,'r407f.mix');
            Tis = refpropm('T','P',Pc*100,'S',S,'r407f.mix') - 273.15;
            his = refpropm('H','T',Tis+273.15,'P',Pc*100,'r407f.mix');
            nis = 0.7;
            hocompHT = hicompHT+max(0,(his-hicompHT))/nis;

            % mechanical power consumption [kW]
            dWcompMechHT = dMrCompHT*(hocompHT-hicompHT)/1000;

            % electrical power consumption [kW]
            dWcompHT = dWcompMechHT/me_HT;
        end

        %% LT Compressor
        function [PsucLT, dWcompLT] = CompressorLT(obj,dMrLT,NcompLT,Pc,PackID)

            % constant parameters
            global Ts Vd_LT me_LT Tsh_LT

            % volumetric efficiency
            nvol = 0.95;

            % mass flow through the compressor
            Te = refpropm('T','P',obj.PsucLT_ic*100,'Q',1,'r407f.mix') - 273.15;
            rho = refpropm('D','T',Te+Tsh_LT+273.15,'P',obj.PsucLT_ic*100,'r407f.mix');
            dVcomp = NcompLT*nvol*Vd_LT;
            dMrCompLT = rho*dVcomp;

            % preliminary calculations for LT suction pressure odefun
            dRhodP = refpropm('R','T',Te+Tsh_LT+273.15,'P',obj.PsucLT_ic*100,'r407f.mix')*100;

            % suction pressure
            tspan = 0:Ts/60:Ts;
            [t,states] = ode45(@(t,states) SuctionLT(t,states,dMrLT,dMrCompLT,dRhodP,PackID),tspan,obj.PsucLT_ic);
            PsucLT = states(length(tspan));
            if(PsucLT > 0.1)
                obj.PsucLT_ic = PsucLT;
            else
                PsucLT = 0.1;
                obj.PsucLT_ic = 0.1;
            end

            % inlet enthalpy
            Te = refpropm('T','P',obj.PsucLT_ic*100,'Q',1,'r407f.mix') - 273.15;
            hicompLT = refpropm('H','T',Te+Tsh_LT+273.15,'P',obj.PsucLT_ic*100,'r407f.mix');

            % outlet enthalpy
            S = refpropm('S','T',Te+Tsh_LT+273.15,'P',obj.PsucLT_ic*100,'r407f.mix');
            Tis = refpropm('T','P',Pc*100,'S',S,'r407f.mix') - 273.15;
            his = refpropm('H','T',Tis+273.15,'P',Pc*100,'r407f.mix');
            nis = 0.7;
            hocompLT = hicompLT+max(0,(his-hicompLT))/nis;

            % mechanical power consumption [kW]
            dWcompMechLT = dMrCompLT*(hocompLT-hicompLT)/1000;

            % electrical power consumption [kW]
            dWcompLT = dWcompMechLT/me_LT;
        end

        %% HT Compressor Controller
        function [u] = PressureCtrlHT(obj,PrefHT,dPrefNeutralZoneHT,dPrefPlusZoneHT,...
                dPrefMinusZoneHT,PsucHT,PackID)

            %   relayHT(i,1):  i compressor state; 0: off, 1: on
            %   relayHT(i,2):  i compressor timeout value;
            %   relayHT(i,3):  i compressor total duty time;
            %   relayHT(i,4):  i compressor duty time;

            global t tm MaxCompHT packTimerShuffle t_trigger

            % updating relay timers
            for i=1:MaxCompHT
                if (obj.relayHT(i,1) == 1)
                    obj.relayHT(i,3) = obj.relayHT(i,3) + 1;
                    obj.relayHT(i,4) = obj.relayHT(i,4) + 1;        
                end
                if (obj.relayHT(i,2) ~= 0)
                    obj.relayHT(i,2) = obj.relayHT(i,2) - 1;
                end
            end

            min_ind = 0;
            max_ind = 0;

            % ++zone: 30 (5*ts) second check
            if (PsucHT >= PrefHT + dPrefNeutralZoneHT/2 + dPrefPlusZoneHT) && (sum(obj.relayHT(:,1)) < MaxCompHT) ...
                                                        && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
                for i=1:MaxCompHT
                    if (obj.relayHT(i,1) == 0) && (obj.relayHT(i,2) == 0)
                        min = obj.relayHT(1,3);
                        min_ind = i;
                        break;
                    end
                end
                if min_ind ~= 0
                    for i=1:MaxCompHT
                        if (obj.relayHT(i,3)<min) && (obj.relayHT(i,1) == 0) && (obj.relayHT(i,2) == 0)
                            min=obj.relayHT(i,3);
                            min_ind = i;
                        end
                    end
                    obj.relayHT(min_ind,1) = 1;
                end

            % --zone: 18 (3*ts) second check
            elseif (PsucHT <= PrefHT - dPrefNeutralZoneHT/2 - dPrefMinusZoneHT) && (sum(obj.relayHT(:,1)) > 0) ...
                                                            && (mod((t-1)+packTimerShuffle(PackID),3) == 0)
                for i=1:MaxCompHT
                    if (obj.relayHT(i,1) == 1) && (obj.relayHT(i,4) > obj.minOnTimeHT)
                        max = obj.relayHT(1,3);
                        max_ind = i;
                        break;
                    end
                end
                if max_ind ~= 0
                    for i=1:MaxCompHT
                        if (obj.relayHT(i,3)>max) && (obj.relayHT(i,1) == 1) && (obj.relayHT(i,4) > obj.minOnTimeHT)
                            max=obj.relayHT(i,3);
                            max_ind = i;
                        end
                    end
                    obj.relayHT(max_ind,1) = 0;  
                    obj.relayHT(max_ind,2) = obj.timeOutHT;  
                    obj.relayHT(max_ind,4) = 0;          
                end

            % +zone: 0.4 bar, 2 (20*ts) min check    
            elseif (PsucHT >= PrefHT + dPrefNeutralZoneHT/2) && (PsucHT - obj.PsucHT_prev > 0) ...
                          && (sum(obj.relayHT(:,1)) < MaxCompHT) && (mod((t-1)+packTimerShuffle(PackID),20) == 0)
                for i=1:MaxCompHT
                    if (obj.relayHT(i,1) == 0) && (obj.relayHT(i,2) == 0)
                        min = obj.relayHT(1,3);
                        min_ind = i;
                        break;
                    end
                end
                if min_ind ~= 0
                    for i=1:MaxCompHT
                        if (obj.relayHT(i,3)<min) && (obj.relayHT(i,1) == 0) && (obj.relayHT(i,2) == 0)
                            min=obj.relayHT(i,3);
                            min_ind = i;
                        end
                    end
                    obj.relayHT(min_ind,1) = 1;
                end

            % -zone: 0.3 bar, 30 (5*ts) second check
            elseif (PsucHT <= PrefHT - dPrefNeutralZoneHT/2) && (PsucHT - obj.PsucHT_prev < 0) ...
                                  && (sum(obj.relayHT(:,1)) > 0) && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
                for i=1:MaxCompHT
                    if (obj.relayHT(i,1) == 1) && (obj.relayHT(i,4) > obj.minOnTimeHT)
                        max = obj.relayHT(1,3);
                        max_ind = i;
                        break;
                    end
                end
                if max_ind ~= 0
                    for i=1:MaxCompHT
                        if (obj.relayHT(i,3)>max) && (obj.relayHT(i,1) == 1) && (obj.relayHT(i,4) > obj.minOnTimeHT)
                            max=obj.relayHT(i,3);
                            max_ind = i;
                        end
                    end
                    obj.relayHT(max_ind,1) = 0;  
                    obj.relayHT(max_ind,2) = obj.timeOutHT;  
                    obj.relayHT(max_ind,4) = 0;        
                end 
            end

            obj.PsucHT_prev = PsucHT;
            obj.NcompHT = sum(obj.relayHT(:,1));
            
            % DSR simulation
            if (t>=t_trigger) && (t<t_trigger+0.5/tm) 
                obj.NcompHT = 0;
                for i=1:MaxCompHT    
                    if obj.relayHT(i,1) == 1
                        obj.relayHT(i,1) = 0; 
                    end
                end
            end            

%             % DSR simulation
%             if (t>=400/tm) && (t<400.5/tm) 
%                 obj.NcompHT = 0;
%                 for i=1:MaxCompHT    
%                     if obj.relayHT(i,1) == 1
%                         obj.relayHT(i,1) = 0; 
%                     end
%                 end
%             end
% 
%             % DSR simulation
%             if (t>=1000.5/tm) && (t<1001/tm) 
%                 obj.NcompHT = 0;
%                 for i=1:MaxCompHT    
%                     if obj.relayHT(i,1) == 1
%                         obj.relayHT(i,1) = 0; 
%                     end
%                 end
%             end

            u = obj.NcompHT;
        end

        %% LT Compressor Controller
        function [u] = PressureCtrlLT(obj,PrefLT,dPrefNeutralZoneLT,dPrefPlusZoneLT,...
        dPrefMinusZoneLT,PsucLT,PackID)

            %   relayLT(i,1):  i compressor state; 0: off, 1: on
            %   relayLT(i,2):  i compressor timeout value;
            %   relayLT(i,3):  i compressor total duty time;
            %   relayLT(i,4):  i compressor duty time;

            global t tm MaxCompLT packTimerShuffle t_trigger

            % updating relay timers
            for i=1:MaxCompLT
                if (obj.relayLT(i,1) == 1)
                    obj.relayLT(i,3) = obj.relayLT(i,3) + 1;
                    obj.relayLT(i,4) = obj.relayLT(i,4) + 1;        
                end
                if (obj.relayLT(i,2) ~= 0)
                    obj.relayLT(i,2) = obj.relayLT(i,2) - 1;
                end
            end

            min_ind = 0;
            max_ind = 0;

            % ++zone: 30 (5*ts) second check
            if (PsucLT >= PrefLT + dPrefNeutralZoneLT/2 + dPrefPlusZoneLT) && (sum(obj.relayLT(:,1)) < MaxCompLT) ...
                                                        && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
                for i=1:MaxCompLT
                    if (obj.relayLT(i,1) == 0) && (obj.relayLT(i,2) == 0)
                        min = obj.relayLT(1,3);
                        min_ind = i;
                        break;
                    end
                end
                if min_ind ~= 0
                    for i=1:MaxCompLT
                        if (obj.relayLT(i,3)<min) && (obj.relayLT(i,1) == 0) && (obj.relayLT(i,2) == 0)
                            min=obj.relayLT(i,3);
                            min_ind = i;
                        end
                    end
                    obj.relayLT(min_ind,1) = 1;
                end

            % --zone: 18 (3*ts) second check
            elseif (PsucLT <= PrefLT - dPrefNeutralZoneLT/2 - dPrefMinusZoneLT) && (sum(obj.relayLT(:,1)) > 0) ...
                                                            && (mod((t-1)+packTimerShuffle(PackID),3) == 0)
                for i=1:MaxCompLT
                    if (obj.relayLT(i,1) == 1) && (obj.relayLT(i,4) > obj.minOnTimeLT)
                        max = obj.relayLT(1,3);
                        max_ind = i;
                        break;
                    end
                end
                if max_ind ~= 0
                    for i=1:MaxCompLT
                        if (obj.relayLT(i,3)>max) && (obj.relayLT(i,1) == 1) && (obj.relayLT(i,4) > obj.minOnTimeLT)
                            max=obj.relayLT(i,3);
                            max_ind = i;
                        end
                    end
                    obj.relayLT(max_ind,1) = 0;  
                    obj.relayLT(max_ind,2) = obj.timeOutLT;  
                    obj.relayLT(max_ind,4) = 0;          
                end

            % +zone: 0.4 bar, 2 (20*ts) min check    
            elseif (PsucLT >= PrefLT + dPrefNeutralZoneLT/2) && (PsucLT - obj.PsucLT_prev > 0) ...
                          && (sum(obj.relayLT(:,1)) < MaxCompLT) && (mod((t-1)+packTimerShuffle(PackID),20) == 0)
                for i=1:MaxCompLT
                    if (obj.relayLT(i,1) == 0) && (obj.relayLT(i,2) == 0)
                        min = obj.relayLT(1,3);
                        min_ind = i;
                        break;
                    end
                end
                if min_ind ~= 0
                    for i=1:MaxCompLT
                        if (obj.relayLT(i,3)<min) && (obj.relayLT(i,1) == 0) && (obj.relayLT(i,2) == 0)
                            min=obj.relayLT(i,3);
                            min_ind = i;
                        end
                    end
                    obj.relayLT(min_ind,1) = 1;
                end

            % -zone: 0.3 bar, 30 (5*ts) second check
            elseif (PsucLT <= PrefLT - dPrefNeutralZoneLT/2) && (PsucLT - obj.PsucLT_prev < 0) ...
                                  && (sum(obj.relayLT(:,1)) > 0) && (mod((t-1)+packTimerShuffle(PackID),5) == 0)
                for i=1:MaxCompLT
                    if (obj.relayLT(i,1) == 1) && (obj.relayLT(i,4) > obj.minOnTimeLT)
                        max = obj.relayLT(1,3);
                        max_ind = i;
                        break;
                    end
                end
                if max_ind ~= 0
                    for i=1:MaxCompLT
                        if (obj.relayLT(i,3)>max) && (obj.relayLT(i,1) == 1) && (obj.relayLT(i,4) > obj.minOnTimeLT)
                            max=obj.relayLT(i,3);
                            max_ind = i;
                        end
                    end
                    obj.relayLT(max_ind,1) = 0;  
                    obj.relayLT(max_ind,2) = obj.timeOutLT;  
                    obj.relayLT(max_ind,4) = 0;        
                end 
            end

            obj.PsucLT_prev = PsucLT;
            obj.NcompLT = sum(obj.relayLT(:,1));

            % DSR simulation
            if (t>=t_trigger) && (t<t_trigger+0.5/tm) 
                obj.NcompLT = 0;
                for i=1:MaxCompLT    
                    if obj.relayLT(i,1) == 1
                        obj.relayLT(i,1) = 0; 
                    end
                end
            end                     
            
%             % DSR simulation
%             if (t>=400/tm) && (t<400.5/tm) 
%                 obj.NcompLT = 0;
%                 for i=1:MaxCompLT    
%                     if obj.relayLT(i,1) == 1
%                         obj.relayLT(i,1) = 0; 
%                     end
%                 end
%             end
% 
%             % DSR simulation
%             if (t>=1000.5/tm) && (t<1001/tm) 
%                 obj.NcompLT = 0;
%                 for i=1:MaxCompLT    
%                     if obj.relayLT(i,1) == 1
%                         obj.relayLT(i,1) = 0; 
%                     end
%                 end
%             end

            u = obj.NcompLT;
        end
        
        %% HT Temperature Controller
        function u = TempCtrlHT(obj,TrefHT,TairHT,DefrostScheduleHT)

            % constant parameter
            global n_HT t tm t_trigger

            % differential
            dTrefHT = 2*ones(n_HT,1);

            % modulation range
            modTrefHT = 1*ones(n_HT,1);

            for i = 1:n_HT

                if t>=10000/tm
                    % hysteresis control
                    if (TairHT(i) >= TrefHT(i)+dTrefHT(i))
                        obj.OD_HT(i) = 1;        
                    elseif (TairHT(i) <= TrefHT(i))
                        obj.OD_HT(i) = 0.0;
                    end
                else    
                    % modulation control
                    if (TairHT(i) >= TrefHT(i))
                        obj.OD_HT(i) = min(1,(TairHT(i)-(TrefHT(i)-modTrefHT(i)))/2*modTrefHT(i)); 
                    elseif (TairHT(i) < TrefHT(i))
                        obj.OD_HT(i) = max(0,(TairHT(i)-(TrefHT(i)-modTrefHT(i)))/2*modTrefHT(i));
                    end
                end

                % defrost
                for j = 1:size(DefrostScheduleHT,2)
                    if (t>=DefrostScheduleHT(i,j)) && (t<DefrostScheduleHT(i,j)+obj.defrostDurationHT(i,j))
                        obj.OD_HT(i) = 0.0;
                        % termination by temperature check
                        if (TairHT(i) >= 8) 
                            obj.OD_HT(i) = 1;
                            obj.defrostDurationHT(i,j) = 0;
                        end
                    end
                end

                % DSR simulation
                if (t>=t_trigger) && (t<t_trigger+obj.dsrDurationHT(i,1))
                    obj.OD_HT(i) = 0.0;
                    % termination by temperature check        
                    if (TairHT(i) >= 8)
                        obj.OD_HT(i) = 1;
                        obj.dsrDurationHT(i,1) = 0;
                    end   
                end
                
%                 % DSR simulation
%                 if (t>=400/tm) && (t<400/tm+obj.dsrDurationHT(i,1)) && (~ismember(i,[1 5 7 9]))
%                     obj.OD_HT(i) = 0.0;
%                     % termination by temperature check        
%                     if (TairHT(i) >= 8)
%                         obj.OD_HT(i) = 1;
%                         obj.dsrDurationHT(i,1) = 0;
%                     end   
%                 end
% 
%                 % DSR simulation
%                 if (t>=1000/tm) && (t<1000/tm+obj.dsrDurationHT(i,2)) && (~ismember(i,[1 5 7 9]))
%                     obj.OD_HT(i) = 0.0;
%                     % termination by temperature check        
%                     if (TairHT(i) >= 8)
%                         obj.OD_HT(i) = 1;
%                         obj.dsrDurationHT(i,2) = 0;
%                     end
%                 end

            end

            u = obj.OD_HT;
        end   
        
        %% LT Temperature Controller
        function [u,h] = TempCtrlLT(obj,TrefLT,TairLT,DefrostScheduleLT)

            % constant parameter
            global n_LT t tm t_trigger

            % modulation
            modTrefLT = 1*ones(n_LT,1);

            for i = 1:n_LT    

                % modulation control
                if (TairLT(i) >= TrefLT(i))
                    obj.OD_LT(i) = min(1,(TairLT(i)-(TrefLT(i)-modTrefLT(i)))/2*modTrefLT(i)); 
                elseif (TairLT(i) < TrefLT(i))
                    obj.OD_LT(i) = max(0,(TairLT(i)-(TrefLT(i)-modTrefLT(i)))/2*modTrefLT(i));
                end

                % LT heaters are switched off outside defrost
                obj.heaterStateLT(i) = 0;

                % defrost
                for j = 1:size(DefrostScheduleLT,2)
                    if (t>=DefrostScheduleLT(i,j)) && (t<DefrostScheduleLT(i,j)+obj.defrostDurationLT(i,j)) 
                        obj.OD_LT(i) = 0.0;
                        obj.heaterStateLT(i) = 1;
                    end
                end

                % DSR simulation
                if (t>=t_trigger) && (t<t_trigger+30/tm)
                    obj.OD_LT(i) = 0.0;
                end

%                 % DSR simulation
%                 if (t>=400/tm) && (t<430/tm)
%                     obj.OD_LT(i) = 0.0;
%                 end
% 
%                 % DSR simulation
%                 if (t>=1000/tm) && (t<1030/tm)
%                     obj.OD_LT(i) = 0.0;
%                 end

            end

            u = obj.OD_LT;
            h = obj.heaterStateLT;
        end        
   end
end