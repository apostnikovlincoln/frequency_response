function [TrefLT, PrefLT, dPrefNeutralZoneLT, dPrefPlusZoneLT,...
    dPrefMinusZoneLT] = SetPointsLT()

% constant parameters
global n_LT

% default values
TrefLT = -23*ones(n_LT,1);

PrefLT = 0.7;
dPrefNeutralZoneLT = 0.5;
dPrefPlusZoneLT = 0.5;
dPrefMinusZoneLT = 0.3;

end