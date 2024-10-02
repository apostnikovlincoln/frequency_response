function RefModelSetup()

% constant parameters
global rho_h2o Pc Prec MaxCompHT MaxCompLT 

global Tsh_HT Tsubcool me_HT Vd_HT Vsuc_HT DefrostNum_HT defrostDurationHT
global Tsh_LT me_LT Vd_LT Vsuc_LT DefrostNum_LT defrostDurationLT

global n_HT AKV_HT UAmref_HT 
global n_LT TEX_LT UAmref_LT dQheater

global UAload_HT UAproduct_HT Mair_HT Mproduct_HT Cpair_HT Cpproduct_HT
global UAload_LT UAproduct_LT Mair_LT Mproduct_LT Cpair_LT Cpproduct_LT

global Ts t_period n_days n_step time tm


% simulation time settings
Ts = 6;                     % Simulation sampling time
tm = Ts/60;                 % Simulation step size in minutes
t_period = 60*24;           % 24 hours
n_days = 1;                 % Number of days
t_stop = n_days*t_period;   % Stop time
n_step = t_stop/tm;         % Number of time steps
time = 0:tm:t_stop-tm;      % Time array

% constant values
rho_h2o = 1000;
Pc = 12;
Prec = 11;
Tsubcool = 2;
dQheater = 1250;

Tsh_HT = 10;
me_HT = 0.75;
MaxCompHT = 4;
% fixed displacement volume, ZB45KCE: 17.1 m^3/h /3600
Vd_HT = 0.00475; 
% volume of the suction line from the barn layout
% total length: 93m, avg. diameter: 20mm, avg. volume: pi*d^2*l/4
%Vsuc_HT = 1.2; % 0.0073 (or 0.0044 for the largest part)
Vsuc_HT = 0.35; % 0.0073 (or 0.0044 for the largest part)
DefrostNum_HT = 4;
defrostDurationHT = 30/tm;

Tsh_LT = 10;
me_LT = 0.75;
MaxCompLT = 2;
% fixed displacement volume, ZF15KE: 7.9 m^3/h /3600, ZF09KE(small): 3.9 m^3/h
Vd_LT = 0.00475;
% volume of the suction line from the barn layout
% total length: 22m, avg. diameter: 20mm, avg. volume: pi*d^2*l/4
%Vsuc_LT = 1.2; % 0.0037 (or 0.0025 for the largest part)
Vsuc_LT = 0.15; % 0.0037 (or 0.0025 for the largest part)
DefrostNum_LT = 2;
defrostDurationLT = 30/tm;

% load HT cabinet parameters
load('CabinetsHT')
n_HT = CabinetsHT.num;
AKV_HT = CabinetsHT.AKV;
UAmref_HT = CabinetsHT.UAmref;
UAload_HT = CabinetsHT.UAload;
UAproduct_HT = CabinetsHT.UAproduct;
Mair_HT = CabinetsHT.Mair;
Mproduct_HT = CabinetsHT.Mproduct;
Cpair_HT = CabinetsHT.Cpair;
Cpproduct_HT = CabinetsHT.Cpproduct;

% load LT cabinet parameters
load('CabinetsLT')
n_LT = CabinetsLT.num;
TEX_LT = CabinetsLT.TEX;
UAmref_LT = CabinetsLT.UAmref;
UAload_LT = CabinetsLT.UAload;
UAproduct_LT = CabinetsLT.UAproduct;
Mair_LT = CabinetsLT.Mair;
Mproduct_LT = CabinetsLT.Mproduct;
Cpair_LT = CabinetsLT.Cpair;
Cpproduct_LT = CabinetsLT.Cpproduct;

end