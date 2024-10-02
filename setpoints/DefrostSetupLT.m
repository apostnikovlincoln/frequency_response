function [DefrostScheduleLT] = DefrostSetupLT(packid)

% constant parameters
global n_LT n_days DefrostNum_LT tm

n = n_days;

DefrostScheduleLT = zeros(n_LT,DefrostNum_LT*n);
for i=1:n_LT
    for j=1:DefrostNum_LT*n
        DefrostScheduleLT(i,j) = mod(((j-1)*24*60/DefrostNum_LT + i*30 + 5*(packid-1))/tm,24*60*n/tm);
    end
end

DefrostScheduleLT = sort(DefrostScheduleLT,2);

end