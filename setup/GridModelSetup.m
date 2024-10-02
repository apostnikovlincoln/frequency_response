function GridModelSetup()

% constant parameters
global Tg Tt Req M D Ptot Pl

global t_period n_days

Tg = 0.2;           % Governor time constant
Tt = 50;            % Turbine time constant
Req = 0.177;        % Governor droop control equivalent gain
M = 6.7;            % System inertia
D = 1;              % System damping

Ptot = 50;          % Total power (GW)

% simulation time settings
t_period = 60*24;           % 24 hours
n_days = 1;                 % Number of days
t_stop = n_days*t_period;   % Stop time
n_step = t_stop*60;         % Number of time steps (seconds)

% incident setup
incident_time = 12*60*60; % twelve hours in
loss_time = 20*60;
recovery_time = 10*60;
normal_operation = n_step - incident_time - loss_time - recovery_time;

Pl1 = 0*ones(incident_time,1);
Pl2 = 1.25*ones(loss_time,1);
for k = 1:recovery_time
    Pl3(k) = 1.25*(recovery_time-k)/recovery_time;
end
Pl3 = Pl3';
Pl4 = 0*ones(normal_operation,1);
Pl = [Pl1; Pl2; Pl3; Pl4];

end