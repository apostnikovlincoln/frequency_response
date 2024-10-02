function [DefrostScheduleHT] = DefrostSetupHT(packid)

% constant parameters
global n_HT n_days DefrostNum_HT tm

n = n_days;

DefrostScheduleHT = zeros(n_HT,DefrostNum_HT*n);
for i=1:n_HT
    for j=1:DefrostNum_HT*n
        DefrostScheduleHT(i,j) = mod(((j-1)*24*60/DefrostNum_HT + i*30 + 5*(packid-1))/tm,24*60*n/tm);
    end
end

DefrostScheduleHT = sort(DefrostScheduleHT,2);

end