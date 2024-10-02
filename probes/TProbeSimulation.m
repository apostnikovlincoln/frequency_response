function [Tambient, Tstore] = TProbeSimulation(period,t)

global n_HT n_LT n_packs

%% ambient temperature
% average value
Tout_avr = 10;

% variation
Tout_var = 2;

Tambient = Tout_avr + Tout_var*cos(2*pi/period*t);
Tambient = Tambient';

%% temperature inside the store

% average value
Tin_avr = 20;

% variation
Tin_var = 0*ones((n_HT+n_LT)*n_packs,1);

% noise
Tin_disturb = zeros((n_HT+n_LT)*n_packs,size(t,2));
for i = 1:(n_HT+n_LT)*n_packs
    Tin_disturb(i,:) = wgn(size(t,2),1,6)';
end

Tstore = Tin_avr + Tin_var*sin(2*pi/period*t+pi) + Tin_disturb;
Tstore = Tstore';

end