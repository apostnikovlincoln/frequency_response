function dydt = Frequency(t,y,Tg,Tt,Req,M,D,u)
    dydt(1) = (-1/Tg)*y(1) + (-1/(Req*Tg))*y(3);
    dydt(2) = (1/Tt)*y(1) + (-1/Tt)*y(2);
    dydt(3) = (1/M)*y(2) + (-D/M)*y(3) + (-1/M)*u;
    dydt = [dydt(1); dydt(2); dydt(3)];
end